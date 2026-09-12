# Contract: The shared-step seam

**Feature**: `039-back-office-order-workspace` | **Date**: 2026-09-11

What a host must provide for `CaptureStep` and `DeliveryStep` to serve it, and
what those widgets may assume in return. Satisfies FR-041 – FR-046.

The contract's purpose is narrow: a shared step asks its host **two questions**
(which document, which write gate) and receives **one instruction** (what the
forward action is). It asks nothing about steps, payment, registers or cash
sessions.

---

## 1. The four providers

Declared in `lib/features/sales/presentation/sale_editor.dart`. All are plain
(non-family) providers, overridden together in one nested `ProviderScope`.

| Provider | Type | Default (register) | Overridden by the workspace |
|---|---|---|---|
| `saleEditorProvider` | `SaleEditor` | `posSaleControllerProvider.notifier` | `orderEditorControllerProvider(orderId).notifier` |
| `saleWritesScopeProvider` | `String` | `posWritesScope` | `salesOrderWritesScope` |
| `saleConfirmFailureProvider` *(new)* | `void Function(AppError)` | records on `confirmErrorProvider`, then `jumpTo(PosStep.venta)` | records on the workspace banner, then returns to `venta` |

**Overriding one without the others is the mistake this contract exists to
prevent.** Override only `saleEditorProvider` and the two screens silently share
a write gate; override only the first two and a back-office delivery commits the
cashier's sale. They are declared adjacently and documented as a set for that
reason, and `sale_editor_isolation_test.dart` asserts it.

### Rule: `dependencies:` is mandatory

Any provider that reads the seam MUST declare it:

```dart
@Riverpod(dependencies: [saleEditor])
```

Without it the provider resolves against the **root** container, ignores the
nested scope, and writes to the register's sale. `product_lookup_controller.dart`
already carries this annotation; it is load-bearing, not decorative.

---

## 2. `CaptureStep`

```dart
CaptureStep({
  required Sale? sale,
  required VoidCallback? onContinue,   // null disables the forward action
  required String continueLabel,
  bool showFulfillmentSelector = true,
})
```

| Host | `onContinue` | `continueLabel` | `showFulfillmentSelector` |
|---|---|---|---|
| Register | advance to Cobro | "Continuar al cobro" | `true` |
| Workspace | advance to Entrega | "Continuar a entrega" | `false` (FR-021) |

**The widget must not**: read `posStepControllerProvider`, read
`confirmErrorProvider`, or name `posWritesScope`. It resolves its scope through
`saleWritesScopeProvider` and reports a confirm failure through
`saleConfirmFailureProvider`.

**The widget may assume**: `saleEditorProvider` edits the right document, and
`resolveUnconfirmedEdits` has been given the right scope.

**Unchanged for the register**: the enabling rule stays
`enabled && lineCount > 0 && !writesPending`, and the label and destination are
what POS passes in. FR-046 requires this to be observably identical.

---

## 3. `DeliveryStep`

```dart
DeliveryStep({
  required Sale sale,
  required FulfillmentMode mode,
  required VoidCallback onClose,
})
```

The signature does **not** change — it already takes its document and its mode
as parameters. Two internals do:

- `delivery_step.dart:259` — `pendingWritesProvider(posWritesScope)` becomes
  `pendingWritesProvider(ref.watch(saleWritesScopeProvider))`;
- `delivery_controller.dart:82` — the same, for write tracking.

The workspace always passes `mode: FulfillmentMode.delivery`, which is what makes
the remainder rule strict (`isMixed: false`) and suppresses the counter-pickup
sweep (FR-031). No new branch is added for this; it is the existing
pure-delivery behaviour.

---

## 4. `confirmBeforePayableAction`

Current signature (`pos_confirm.dart`) reaches for two POS singletons:

```dart
read(posSaleControllerProvider.notifier).confirm();
read(posStepControllerProvider.notifier).jumpTo(PosStep.venta);   // on failure
```

Becomes:

```dart
read(saleEditorProvider).confirm();
read(saleConfirmFailureProvider)(error);                          // on failure
```

Everything else is preserved: it is still a no-op once `status != draft`, still
rethrows so the caller aborts, and is still called from exactly
`delivery_controller.addDestination` and `sweepRemainderToCounter`.

`confirmErrorProvider` remains, POS-only, now written *by POS's implementation
of the callback* rather than by the shared helper.

---

## 5. What the workspace supplies

```dart
ProviderScope(
  overrides: [
    saleEditorProvider.overrideWith((ref) =>
        ref.watch(orderEditorControllerProvider(orderId).notifier)),
    saleWritesScopeProvider.overrideWithValue(salesOrderWritesScope),
    saleConfirmFailureProvider.overrideWithValue(_onConfirmFailed),
  ],
  child: …,
)
```

---

## 6. Invariants a test must hold (SC-007)

1. A line edited in one host is written to that host's document only.
2. An outstanding write in one host does not gate any action in the other.
3. Creating a destination in the workspace commits the **order**, and leaves a
   register sale open at the same time untouched.
4. The register's capture step keeps its label, its enabling rule and its
   fulfilment-mode selector.
5. Every existing point-of-sale test passes unmodified.

Invariant 3 is the one with no current coverage — `sale_editor_isolation_test.dart`
covers the capture surface only — and is the single most important test this
feature adds.
