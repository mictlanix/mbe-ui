/// Which of the three sale-line arrangements applies, and the one place the
/// width thresholds between them live (spec 023 data-model §5, research
/// R10). `SaleLineRow` is the only caller that actually branches on this —
/// `card` exists for completeness/defensive floor; the real card/row choice
/// is made by `capture_step.dart`'s own compact-tier check on the *window*,
/// which already substitutes `SaleLineCard` below 600 px before `SaleLineRow`
/// is ever mounted (contracts/capture-surface.md §4.1).
enum SaleLineLayout { singleRow, twoRow, card }

/// The budget for the single-row layout (contracts/capture-surface.md §4.2):
/// fixed columns (thumbnail 36, warehouse 140, quantity 128, unit 56, price
/// 84, discount 68, tax 68, total 96, delete ~48) plus 7 gaps of
/// `spacing.xs` (56) plus a 200 px minimum for the product cell. The
/// quantity column widened from an initially tighter 104 px to 128 px after
/// a widget test caught a real overflow there — `IconButton`'s own sizing
/// didn't shrink as far as `constraints`/`padding` overrides alone
/// implied, confirming these are a *budget*, not a measurement (research
/// R10): the FR-037a widget test (`sale_line_row_test.dart`) pumps a real
/// line at 1024 px and fails on overflow, which is what caught this.
///
/// The unit column later grew 36 → 56 for the same reason, caught the same
/// way but by *looking* rather than by an assertion: a rendered screenshot
/// showed a six-letter unit (`Cubeta`) wrapping to two lines and taking the
/// whole row taller with it. This threshold grew by the same 20 px, keeping
/// the product cell's 200 px floor intact — and staying well under the
/// 1024 px a landscape tablet gives it (FR-037a).
const saleLineSingleRowMinWidth = 970.0;

/// Below this, even the two-row fallback has nowhere left to shrink — the
/// caller substitutes `SaleLineCard` at this width today, so `SaleLineRow`
/// itself should not normally be asked to lay out below it.
const saleLineTwoRowMinWidth = 600.0;

SaleLineLayout saleLineLayoutFor(double availableWidth) {
  if (availableWidth >= saleLineSingleRowMinWidth) return SaleLineLayout.singleRow;
  if (availableWidth >= saleLineTwoRowMinWidth) return SaleLineLayout.twoRow;
  return SaleLineLayout.card;
}
