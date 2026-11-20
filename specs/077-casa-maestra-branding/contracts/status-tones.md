# Contract: Status tones (FR-014, FR-015)

## Widget

```dart
StatusChip<T>({required T value, required String label, required StatusTone tone, IconData? icon})
```

- The chip always renders an icon (`avatar`) and the label. `icon` overrides the tone's default.
- `T` and `value` are kept so tests can tell chip types apart, as today.

| Tone | Background / foreground | Default icon |
| --- | --- | --- |
| `success` | `successContainer` / `onSuccessContainer` | `Icons.check_circle_outline` |
| `warning` | `warningContainer` / `onWarningContainer` | `Icons.schedule` |
| `error` | `errorContainer` / `onErrorContainer` | `Icons.cancel_outlined` |
| `info` | `primaryContainer` / `onPrimaryContainer` | `Icons.timelapse` |
| `neutral` | `surfaceContainerHighest` / `onSurfaceVariant` | `Icons.circle_outlined` |
| `promo` | `accentContainer` / `onAccentContainer` | `Icons.local_offer_outlined` |

Rules:

- Only `promo` uses accent colors.
- `error` uses the theme's `error` family. In Casa Maestra, `errorContainer` `#FFDAD6` and `accentContainer` `#FFDAD4` look alike by design, so the icon and word are what tell them apart. That is why both are required.
- No caller passes raw colors.

## Meaning → tone

- **neutral**: not started, or inert (draft, archived, unknown).
- **info**: in progress, moving along.
- **warning**: waiting on someone, partial, or needs attention.
- **success**: finished as intended.
- **error**: cancelled, failed or reversed.

## Mapping, for product review

| Chip | Status → tone (icon override) |
| --- | --- |
| `EntityStatusCell` | active → plain text, no chip (unchanged) · inactive → neutral (`block`) · archived → neutral (`inventory_2_outlined`) |
| `FiscalDocumentStatusChip` | draft → neutral (`edit_note`) · sealed → info · stamping → warning · issued → success · cancellationPending → warning · cancelled → error |
| `InventoryDocumentStatusChip`, `InventoryCountStatusChip` | draft → neutral (`edit_note`) · completed → success · cancelled → error |
| `InventoryTransferStatusChip` | draft → neutral (`edit_note`) · inTransit → info (`local_shipping_outlined`) · received → success · cancelled → error |
| `DeliveryOrderStatusChip` | draft → neutral (`edit_note`) · pendingApproval → warning · approved, readyForPickup, inPreparation → info · inTransit → info (`local_shipping_outlined`) · pickedUp, delivered → success · partiallyDelivered → warning · failed → error · cancelled → error |
| `ItineraryStatusChip` | open → neutral · departed → info (`local_shipping_outlined`) · closed → success · cancelled → error |
| `StopOutcomeChip` | pending → neutral · delivered → success · partiallyDelivered → warning · failed → error |
| `CashSessionStatusChip` | open → info · stale → error · closed → success |
| `PosSaleStatusChip` | draft → neutral (`edit_note`) · completed (unpaid) → warning · paid → success · cancelled → error |
| `SalesQuoteStatusChip` | draft → neutral (`edit_note`) · completed → success · cancelled → error |
| `RefundStatusChip` | draft → neutral (`edit_note`) · completed → success · cancelled → error |
| `PaymentVerifiedChip` | verified → success (`verified_outlined`) · not verified → warning |
| `PaymentReversedChip` | reversed → error (`undo`) |
| Simulated badge (fiscal detail) | → warning (`science_outlined`) |
| `CancellationOutcome` (fiscal detail) | requested, pending → warning · accepted, expired, failed → error · rejected, notCancellable, unknown → neutral |

These changes differ from today's colors on purpose. Drafts become neutral everywhere. Delivery and itinerary cancellations become error, matching every other chip. A failed delivery order becomes error. A completed but unpaid POS sale and an unverified payment become warning.

## Fit

At the Expanded+ chip size the label uses `label-medium`. `fiscal_document_status_chip_test.dart:47` currently checks the label fits within 120px. The icon adds width, so that bound is re-measured with the icon, not loosened blindly.
