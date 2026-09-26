# Research: Show Timestamps as the Local Times They Are

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Issue**: mictlanix/mbe-ui#176

Every decision below was checked against running code: a probe on this machine (CST, no DST) and the same probe under `TZ=America/New_York` (a DST-observing zone), or a read-only query against a backend running mictlanix/mbe-api#228. Where a decision rests on a probe, its output is quoted.

---

## R1. Where the conversion rule lives, and how it reaches every call

**Decision**: A new `WallClockDateTimeSerializer` in `lib/core/network/`, plus one top-level `appSerializers` built by adding it on top of the generated `standardSerializers`. Every repository constructs its generated `*Api` with `appSerializers` instead of `api.standardSerializers`.

```dart
final appSerializers =
    (api.standardSerializers.toBuilder()..add(const WallClockDateTimeSerializer())).build();
```

**Rationale**:

- The generated `MbeApiClient` and every generated `*Api` already take a `Serializers` argument. The seam exists, so no generated file is touched and a regeneration cannot undo the fix (FR-007, constitution §III).
- A later `add` for the same type and wire name replaces the earlier registration. That is the documented built_value mechanism, and it is how `Iso8601DateTimeSerializer` itself displaces built_value's default epoch serializer inside the generated `serializers.dart:761`.
- `lib/core/network/` already holds the shared HTTP concerns (`dio_client.dart`, `auth_interceptor.dart`). A serializer that every feature's `data/` layer consumes is shared kernel, not feature code (constitution §I).
- One definition, one import. That is FR-006.

**Alternatives considered**:

- *Override the openapi-generator template* for `serializers.dart`. Durable, but moves the fix into the codegen toolchain, where it is invisible from the Dart code and has to be re-verified on every generator upgrade. Rejected: the runtime seam is simpler and already there.
- *Hand-edit `serializers.dart:761`*. Forbidden by constitution §III, and silently reverted by the next regeneration. Rejected.
- *Rewrite timestamp strings in a dio interceptor*. Would have to know which JSON fields are timestamps, duplicating the schema. Rejected.
- *Correct each value in the `fromResponse` mappers* (`toLocal()` per field). 45 date-time fields across 29 models, each a chance to forget one, and it cannot fix the outgoing direction. Rejected: FR-006 asks for one place.
- *Expose `appSerializers` as a Riverpod provider*. Constitution §II requires providers for things tests override. Nothing overrides this: every test wants the real conversion, which is the point of the guard in R7. It is configuration with the same shape as the generated `standardSerializers` it replaces, which is also a top-level value. Recorded under the Constitution Check.

---

## R2. The reading rule

**Decision**: Parse with `DateTime.parse`. If the result is UTC-flagged, return `toLocal()`. Otherwise return it unchanged.

```dart
final parsed = DateTime.parse(serialized as String);
return parsed.isUtc ? parsed.toLocal() : parsed;
```

**Rationale**: `isUtc` is exactly the "did the string carry an offset" signal. An offset-less string parses as local with its fields intact; any explicit offset, `Z` or numeric, parses UTC-flagged:

```
parse 2026-09-26T13:05:28       -> isUtc=false  fields 13:05:28   (both zones)
parse 2026-09-26T13:05:28Z      -> isUtc=true   toLocal 07:05 (CST) / 09:05 (New York)
parse 2026-09-26T13:05:28-06:00 -> isUtc=true   toLocal 13:05 (CST) / 15:05 (New York)
```

The first line is FR-001: what the API sends today comes back unchanged. The other two are FR-002: an offset, if the API ever sends one, is honored instead of shifted a second time. That keeps this forward-compatible with the aware-UTC option mictlanix/mbe-api#228 rejected, at no cost.

**Alternatives considered**: *Strip any offset and read the digits as wall clock*. Simpler to state, but it would misread a genuine offset by exactly its size, trading today's bug for a latent one. Rejected.

---

## R3. The writing rule

**Decision**: Format the value's own fields as text, `yyyy-MM-ddTHH:mm:ss.SSS`, with no suffix and regardless of `isUtc`. Pad each field directly. Never rebuild a local `DateTime` from the fields first.

**Rationale**:

- Ignoring `isUtc` makes `DateTime(2026, 9, 27)` and `DateTime.utc(2026, 9, 27)` produce the same string, `2026-09-27T00:00:00.000`. The server reads that as local midnight. Verified live: this exact offset-less, millisecond form selected the correct day (R12, the `REF` row).
- **Rebuilding a local `DateTime` is the obvious one-liner, and it is wrong on a DST-observing host.** Probed with a wall-clock time that does not exist on the night US clocks spring forward:

  ```
  fields 02:30 rebuilt as local, host CST       -> 2026-03-08T02:30:00.000
  fields 02:30 rebuilt as local, host New York  -> 2026-03-08T03:30:00.000
  ```

  The rebuilt value slides an hour, on some hosts, on some nights. Test machines are exactly where that surfaces (FR-010). Formatting the fields as text has no such gap because it never asks the host's calendar anything.
- Milliseconds stay. `wireDateEnd`'s inclusive `23:59:59.999` needs them, and the server already accepts them (the current wire sends `.000`). Microseconds are dropped: the API stores seconds, and the web build cannot represent microseconds anyway.
- The old serializer threw `ArgumentError` on any local `DateTime`. The new one accepts both flags, so that whole class of failure, the one PR #180 fixed for the promise-date picker, cannot recur.

**Alternatives considered**: *`toIso8601String()` on a local rebuild*. Rejected for the DST reason above. *Keep throwing on local values*. Rejected: it is the reason the outgoing compensation had to exist.

---

## R4. Removing PR #180's compensation, and what `wireDate`/`wireDateEnd` become

**Decision**: In the same change as the serializer swap, drop `.toUtc()` from both helpers:

```dart
DateTime wireDate(DateTime local)    => DateTime(local.year, local.month, local.day);
DateTime wireDateEnd(DateTime local) => DateTime(local.year, local.month, local.day, 23, 59, 59, 999);
```

Keep both helpers and their names. Rewrite their doc comments.

**Rationale**: This is the trap the spec's User Story 2 exists for, and it is sharper than "the two fixes cancel". Under the new writing rule, which ignores `isUtc`, the stopgap's form `DateTime(y, m, d).toUtc()` carries the fields `06:00` and serializes as `…T06:00:00.000` with no offset. The server reads that as **06:00 local**. The register's "today" would silently lose its first six hours. Nothing throws and every existing test of the helpers keeps passing unless its expectation is updated in the same change.

Both helpers still earn their keep after the change: callers pass `DateTime.now()` or a picked date, so truncation to the day is still needed, and `date_to` is still compared inclusively against full timestamps, so the end-of-day form is still needed (spec 023 research U2). Keeping the names keeps every call site and its tests untouched except for expectations.

Note, for completeness, that the pre-#180 form `DateTime.utc(y, m, d)` would have been *correct* under the new rule, because its fields are already `00:00`. Only the stopgap's form breaks. That is why the removal cannot be left for later.

**Alternatives considered**: *Delete the helpers and inline the constructors*. Churns 6 call sites and their tests for no behavioral gain. Rejected. *Rename them to `startOfDay`/`endOfDay`*. Better names, same churn. Deferred: not what this fix is for.

---

## R5. The `listOpen` guard test

**Decision**: Repurpose `sales_order_list_open_test.dart`'s "a local DateTime is refused outright" into "a local DateTime reaches the wire as its own wall clock", keeping its assertion that the request is actually sent.

**Rationale**: The test guarded a real incident: the open-sales selector passed a local `DateTime`, the serializer threw while building the query string, and dio abandoned a request no widget test could see, because every widget test mocks the repository. Under R3 a local value serializes, so the premise "local is refused" is gone. The incident the test exists for, a request silently never sent, is still worth pinning, and the inverted assertion pins it more directly.

---

## R6. Test fixtures that carry offsets

**Decision**: Rewrite the 27 offset-bearing timestamp fixtures across 9 test files to the offset-less form the API actually sends, and expect local `DateTime`s built with `DateTime(...)`.

**Inventory** (every file goes through the real generated client, so all are affected):

| Fixtures | File |
|---:|---|
| 5 | `test/unit/features/sales/sales_quote_repository_impl_test.dart` |
| 5 | `test/unit/features/sales/sale_mapping_test.dart` |
| 4 | `test/unit/features/catalog/taxpayer_certificate_test.dart` |
| 3 | `test/unit/features/sales/sales_order_update_header_test.dart` |
| 2 | `test/unit/features/sales/sales_order_list_orders_test.dart` |
| 2 | `test/unit/features/sales/delivery_order_repository_impl_test.dart` |
| 2 | `test/unit/features/catalog/vehicle_operator_repository_impl_test.dart` |
| 2 | `test/unit/features/catalog/taxpayer_certificate_repository_impl_test.dart` |
| 2 | `test/unit/features/auth/user_repository_impl_test.dart` |

**Rationale**:

- `DateTime ==` compares the `isUtc` flag, not only the instant:

  ```
  utc == utc.toLocal(): false    isAtSameMomentAs: true
  ```

  So an expectation like `DateTime.parse('2026-08-05T00:00:00.000Z')` fails against a correctly converted local value, even though both name the same moment.
- A `Z` fixture is also *host-dependent* under the new rule: `…T13:05:28Z` reads 07:05 on this machine and 09:05 in New York. Keeping it would make FR-010 fail by construction.
- The fixtures were never realistic. The API has not sent an offset since before #228.

Widget tests are unaffected. They construct domain entities with `DateTime(...)` directly and mock repositories, so no value passes through the serializer.

**Alternatives considered**: *Compare with `isAtSameMomentAs`*. Keeps the unrealistic fixtures and hides the flag mismatch the feature is about. Rejected.

---

## R7. The guard against bypassing the shared rule

**Decision**: A `dart:io` source scan, modeled on `test/unit/core/formatting_guard_test.dart`: no file under `lib/` or `test/` may reference `standardSerializers`, except `lib/generated/` and the one file that defines `appSerializers`.

**Rationale**: FR-009 asks for a build failure when a new data-access path skips the rule. The likeliest way that happens is a new repository copied from an older one, or the upload-bypass pattern the constitution itself describes (R11). A text scan catches both, needs no tooling, and matches how this repo already guards the formatting surface (spec 028) and layering. `test/` is in scope because a test deserializing a fixture with the raw serializers is testing the conversion the app no longer uses.

**Alternatives considered**: *A custom lint rule*. Heavier than the problem. Rejected, as spec 028 rejected it for the same reason.

---

## R8. Cash session staleness

**Decision**: No code change to `lib/features/sales/domain/cash_session_status.dart`. Add a test that a session opened the previous evening reads stale.

**Rationale**: The rule compares the start's calendar day against today's. It was only wrong because `start` arrived shifted six hours, so an evening start landed on the next day. With a correct `start` the existing rule matches mbe-api's `session_state` as written. FR-008 is met by fixing the input, and the new test proves it.

---

## R9. Web parity

**Decision**: No web-specific handling.

**Rationale**: The app runs on web in development (Chrome, `localhost:8081`). On dart2js, `DateTime.parse` of an offset-less string is local and a `Z` string is UTC, the same as the VM, and local time is the browser's zone. The only difference, no microseconds, is already covered by R3 dropping them.

---

## R10. Upstream dependency and codegen

**Decision**: No mbe-api change is needed, and codegen is already current.

**Rationale**: mictlanix/mbe-api#228 shipped the contract this feature consumes (PR mictlanix/mbe-api#229, deployed). The client was regenerated against it in `db64d5b`, which changed doc comments only: every changed line is a `///`, verified mechanically. The constitution's workflow gate, "re-run codegen when mbe-api changes", is satisfied before this feature starts.

FR-007 asks for more than a current client, though: that the fix *survives* a future regeneration. That is proven rather than argued by re-running `tool/generate_api_client.sh` at the end and confirming both an empty `lib/generated/` diff and a still-green rule and guard test (quickstart step 8). The design makes the guarantee structural, since the override never lives under `lib/generated/`, but structural is not the same as tested.

---

## R11. Constitution and DESIGN.md wording

**Decision**: A PATCH amendment, constitution 1.13.0 → 1.13.1, preceded by the matching DESIGN.md edit as governance requires. Both currently tell authors to deserialize the upload-bypass response with `standardSerializers.deserialize` (constitution line 280, DESIGN.md line 201). They will name `appSerializers` instead.

**Rationale**: After R7, following the constitution's own instruction would fail the build. The two call sites it describes, `product_repository_impl.dart:352` and `taxpayer_certificate_repository_impl.dart:73`, are among the 45 references this feature switches. The change is wording only, no principle changes, which is the definition of PATCH.

---

## R12. Live verification

**Decision**: Three checks against a backend running #228: the day-filter comparison below, a display check comparing on-screen times to wire values, and the cash-session staleness case. Written up in [quickstart.md](./quickstart.md).

**Evidence already in hand** (read-only, 2026-09-26, the same calendar day queried three ways):

```
OLD  wall clock + fake Z   from=2026-09-21T00:00:00.000Z  to=2026-09-21T23:59:59.999Z
    total=14   first=2026-09-20T19:03:05   last=2026-09-20T21:25:08
NEW  instant of midnight   from=2026-09-21T06:00:00.000Z  to=2026-09-22T05:59:59.999Z
    total=3    first=2026-09-21T22:54:33   last=2026-09-21T22:55:39
REF  naive local           from=2026-09-21T00:00:00.000   to=2026-09-21T23:59:59.999
    total=3    first=2026-09-21T22:54:33   last=2026-09-21T22:55:39
```

`NEW` is what `main` sends today. `REF` is exactly what this feature will send. They agree, so the swap is behavior-preserving on the way out, and the `REF` form is proven accepted by the server.

---

## R13. Proving timezone independence without CI

**Decision**: Run the full suite under `TZ=UTC` and `TZ=America/New_York` as well as the host zone, documented in the quickstart.

**Rationale**: This repo has no CI workflow, so there is no build server to fail. FR-010 still matters on any developer machine outside the business zone. `America/New_York` is the stronger check because it observes DST, which is where R3's trap lives.
