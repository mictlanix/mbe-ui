# Contract: The Wire Datetime Rule

**Feature**: [spec.md](../spec.md) | **Data model**: [data-model.md](../data-model.md) | **Research**: [research.md](../research.md)

The one interface this feature defines: how a `DateTime` crosses the boundary between mbe-ui and mbe-api. It is enforced by a single serializer and a single shared `Serializers` value, and guarded by a source scan.

## Upstream contract this consumes

Settled by mictlanix/mbe-api#228 and stated on every date-time field in the published schema:

> Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.

## Reading: wire string to `DateTime`

| Wire value | Result fields | `isUtc` | Rule |
|---|---|---|---|
| `2026-09-26T13:05:28` | 2026-09-26 13:05:28 | `false` | no offset: unchanged (FR-001) |
| `2026-09-26T13:05:28.000` | 2026-09-26 13:05:28 | `false` | fractional seconds: same |
| `2026-09-26T13:05:28Z` | that instant in the host zone | `false` | offset: `toLocal()` (FR-002) |
| `2026-09-26T13:05:28-06:00` | that instant in the host zone | `false` | offset: `toLocal()` (FR-002) |

On a host in the business zone, the last row reads 13:05:28. The `Z` row reads 07:05:28 there, which is correct: it is a different instant.

A value that is not a parseable ISO-8601 string raises `FormatException`, as the replaced serializer did. The API never sends one, and a malformed payload should fail loudly rather than become a plausible wrong time.

## Writing: `DateTime` to wire string

Format: `yyyy-MM-ddTHH:mm:ss.SSS`. Built from the value's own fields as text. No suffix. The `isUtc` flag is ignored.

| Value | Wire string |
|---|---|
| `DateTime(2026, 9, 27)` | `2026-09-27T00:00:00.000` |
| `DateTime.utc(2026, 9, 27)` | `2026-09-27T00:00:00.000` |
| `DateTime(2026, 9, 27, 23, 59, 59, 999)` | `2026-09-27T23:59:59.999` |
| `DateTime(2026, 9, 27, 8, 5, 3, 7, 999)` | `2026-09-27T08:05:03.007` (microseconds dropped) |
| `DateTime.utc(2026, 3, 8, 2, 30)` | `2026-03-08T02:30:00.000` on **every** host |

The last row is the DST guard. A local rebuild of those fields becomes `03:30` on a host observing US daylight saving, research R3. It must be `02:30` everywhere.

Writing never throws. The replaced serializer threw `ArgumentError` on any local value.

## Round trip

For every offset-less wire string `s` the API sends, `write(read(s))` equals `s` up to fractional-second padding. That is the property the unit tests pin, and it is what makes the rule its own inverse for everything the API actually produces.

## The shared `Serializers`

- Exactly one value, `appSerializers`, defined in `lib/core/network/`, built as the generated `standardSerializers` plus this serializer.
- Every construction of a generated `*Api`, and every direct `deserialize`/`serialize` call, uses `appSerializers`.
- The date-only `Date` type keeps its own generated `DateSerializer`, untouched.

## The guard

A source scan under `lib/` and `test/` fails the build on any reference to `standardSerializers` outside:

- `lib/generated/`, the generated client, never hand-edited (constitution §III);
- the one file in `lib/core/network/` that defines `appSerializers`.

Adding an exemption means adding a path that reads timestamps the way the app no longer does. The guard's failure message says so.
