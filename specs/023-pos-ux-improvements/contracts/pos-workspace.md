# Contract: the POS sale workspace

**Routes**: `/sales/pos/new`, `/sales/pos/:saleId` — top-level siblings, not
shell branches ·
**Screen**: `lib/features/sales/presentation/pos_workspace_screen.dart` (new;
absorbs today's `PosScreen` body) ·
**Gate**: `(SystemObject.pos, AccessRight.read)` via the existing
`startsWith('/sales/pos')` rule, **plus** the cash-session gate below.

Revises `specs/020-point-of-sale/contracts/pos-screen.md` §1 (Layout) and its
decision that the screen renders inside the shell. Everything that contract says
about the step machine (§2), what each step owns (§3), state ownership (§4),
resume (§5), failures (§6) and input (§7) stands unchanged.

---

## 1. Routing

```dart
GoRoute(path: '/sales/pos/new',
  builder: (c, s) => const PosWorkspaceScreen()),
GoRoute(path: '/sales/pos/:saleId',
  builder: (c, s) => PosWorkspaceScreen(
    saleId: int.parse(s.pathParameters['saleId']!))),
```

Placed with the other top-level record routes, after
`/sales/cash-sessions/:cashSessionId`. No `?view=true` parameter: read-only is
decided by the sale's own status (`Sale.isEditable`), not by the URL — a
confirmed sale is read-only whichever way it was opened.

### 1.1 Mount behaviour

| Route | On first mount | URL afterwards |
|---|---|---|
| `/sales/pos/new` | nothing is fetched or created; the workspace renders the `sale == null` capture state | rewritten to `/sales/pos/<id>` via `GoRouter.replace` the moment the first action opens the sale |
| `/sales/pos/:saleId` | `PosSaleController.load(saleId)`, dispatched once and guarded by a stored id so a rebuild never re-issues it | unchanged |

The rewrite is what makes a browser reload resume the same sale instead of
starting a second one, and what makes Back land on the list. Creating the sale
eagerly on `/new` is explicitly rejected: spec 020 measured 39 accumulated empty
drafts on a live register before lazy creation, and its `PosSaleController`
docstring records that finding.

### 1.2 Unreachable sales

| Case | Rendering |
|---|---|
| `getById` → 404 | `posSaleUnreachableUnknown` |
| loaded sale is `cancelled` | `posSaleUnreachableCancelled` |
| loaded sale's `pointSale` ≠ the cashier's register | `posSaleUnreachableOtherRegister` |
| any other failure | `ErrorBanner` with retry, as today |

All three render one `key: pos_sale_unreachable` panel with the reason and a
`posSaleBackToListAction` button. **No sale is opened in their place.** A sale
that is merely *finished* is not in this table — it opens read-only (§4).

## 2. Chrome

```dart
Scaffold(
  appBar: AppBar(
    leading: BackButton(key: Key('pos_workspace_back'), onPressed: → /sales/pos),
    title: Row([
      Text(stepTitle),                    // Venta | Cobro | Entrega
      _SaleIdentityChip(sale),            // reference, and folio once assigned
      OpenSalesSelector(...),             // moved from PosHeaderBand
      Spacer(),
      _StepIndicator(step),               // moved from PosHeaderBand
    ]),
    actions: const [],                    // MUST stay empty
  ),
  body: …,                                // PosGateScreen banner + step host
)
```

- `actions` stays empty (constitution §VI v1.10.0). The identity chip, the
  selector and the step indicator are title-area content, which is also where the
  mock draws them (frame `2a`).
- `PosHeaderBand` is **deleted**; its two children move into the title and its
  `PosGateScreen` child moves to the top of the body, where the stale-session
  banner still belongs.
- On compact, the title collapses the way `_StepIndicator` already does
  (`posStepProgress`, "Paso N de M"), and the selector keeps its chip form.
- No `AppShell`: no rail, no drawer, no shell app bar. Back is the only way up.

## 3. Space rules

These are the requirements the screen exists to satisfy; each is testable.

| Rule | Implementation |
|---|---|
| No maximum content width | the body never reads `spacing.contentMaxWidth`; nothing is wrapped in a `Center` or a `ConstrainedBox` |
| No centring | every step's root is a full-width `Column`, `crossAxisAlignment: stretch` |
| No dead vertical band | the lines list is the only `Expanded` in the capture step; the footer is the last child, one band (§3.1) |
| One inset vocabulary | every padding is `Theme.of(context).spacing.*`; the doubled `EdgeInsets.all(12)` around `CustomerBar` is removed — the card keeps `cardPadding`, the step does not add its own |
| Compact unchanged | below 600 px the capture surface keeps its single `ListView` with the footer pinned (spec 020 FR-053) |

### 3.1 The footer becomes one band

Today `CaptureStep` renders `SaleTotalsBar` **and** a separate padded
`FilledButton` band beneath it. The button moves into the totals bar
(`contracts/capture-surface.md` §4), so the footer is one band instead of two.

## 4. Read-only sales

A sale past `draft` renders read-only, which already ships: `Sale.isEditable` is
false, `CaptureStep` passes `enabled: false` throughout, shows
`posSaleReadOnlyBanner`, and `SaleLineRow`/`SaleLineCard` render every control
inert (spec 020 FR-041). This feature adds no new read-only screen; it only makes
that state reachable from a row click (`contracts/pos-sales-list.md` §3).

## 5. Cash-session gate

Unchanged in behaviour, moved in location: the check that lives in `PosScreen`
today (`currentSession.state == none → PosGateScreen`) moves into
`PosWorkspaceScreen`, so it fires on every entry path — list action, deep link,
reload. No sale is opened while it fails. The list screen itself is **not** gated
(reading history needs no open shift); its "Nueva venta" action is what carries the
session condition there.

## 6. Leaving

| Trigger | Behaviour |
|---|---|
| Back, sale has lines | pop to `/sales/pos`; the sale stays open and appears in the list |
| Back, sale is an empty draft | `_discardIfEmpty`'s existing cancel-the-empty-draft rule runs first, then pop |
| Back, sale is `null` (nothing was ever opened) | pop; nothing was written |
| Back mid-mutation | the in-flight write completes or fails on its own; no cancellation is attempted, and the list re-reads on return so it never shows a half-edited row |
| Sale completed via the finish dialog | the dialog's "Nueva venta" keeps working; it now resets the workspace's sale and step rather than navigating |

`_discardIfEmpty` and `_selectSale`/`_startNewSale` move from `_PosBodyState` to
the workspace screen unchanged — the selector still needs them.
