/// Which of the three sale-line arrangements applies, and the one place the
/// width thresholds between them live (spec 023 data-model §5, research
/// R10). `SaleLineRow` is the only caller that actually branches on this —
/// `card` exists for completeness/defensive floor; the real card/row choice
/// is made by `capture_step.dart`'s own compact-tier check on the *window*,
/// which already substitutes `SaleLineCard` below 600 px before `SaleLineRow`
/// is ever mounted (contracts/capture-surface.md §4.1).
enum SaleLineLayout { singleRow, twoRow, card }

/// The budget for the single-row layout (contracts/capture-surface.md §4.2):
/// fixed columns (warehouse 168, quantity 132, price 88, discount 80, tax 80,
/// total 100, delete 48) plus 6 gaps of `spacing.xs` (48) plus a 226 px
/// minimum for the product cell, which carries the 40 px thumbnail inside it.
/// These are a *budget*, not a measurement (research R10): the FR-037a widget
/// test (`sale_line_row_test.dart`) pumps a real line at 1024 px and fails on
/// overflow, which is what keeps the budget honest — it caught the quantity
/// column's first, tighter 104 px, where `IconButton`'s own sizing didn't
/// shrink as far as `constraints`/`padding` overrides alone implied.
///
/// The columns widened toward the mock's own grid (`minmax(300px,1fr) 176px
/// 128px 96px 100px 88px 84px 124px 44px`) without moving this threshold,
/// paid for by folding the separate unit column into the quantity field's
/// label — the unit is one short symbol (`Pza`), and a column of its own cost
/// more than it earned. It had already grown 36 → 56 once because a
/// six-letter unit (`Cubeta`) wrapped and took the whole row taller with it.
const saleLineSingleRowMinWidth = 970.0;

/// The height every control in a line shares — warehouse picker, quantity
/// stepper, price, discount and tax (FR-038a: one height, so the band reads as
/// one row of controls rather than five differently-sized boxes). Sized for the
/// body role every one of them now renders in — 14 px rather than the 12 px
/// they used to differ in — under a floating label, with the dense content
/// padding `SaleLineRow` applies.
const saleLineFieldHeight = 52.0;

/// The height of the box a **text field** puts inside its decoration: one line
/// of the body role (14 px at the theme's 1.43 line height).
const _saleLineTextContentHeight = 20.0;

/// The height of the box a **dropdown** puts inside its decoration. Flutter's
/// own `_kDenseButtonHeight` floor — `max(lineHeight, max(iconSize, 24))` in
/// `DropdownButton._denseButtonHeight` — so a dense dropdown is 4 px taller
/// inside than a dense text field however its icon and text are sized.
const _saleLineDropdownContentHeight = 24.0;

/// The vertical content padding that brings a **text field** to
/// [saleLineFieldHeight].
const saleLineTextFieldPadding =
    (saleLineFieldHeight - _saleLineTextContentHeight) / 2;

/// The vertical content padding that brings a **dropdown** to
/// [saleLineFieldHeight] — 2 px less than a text field's, because its inner box
/// is 4 px taller.
///
/// Paying the difference in *padding* rather than forcing the outer height is
/// what makes the two kinds of control agree on both counts at once: the boxes
/// come out the same height, and since each one centres a 20-px line of text
/// inside the same 52-px decoration, the text lands on the same baseline too —
/// the same baseline the line total sits on, being a 20-px line centred in the
/// same band.
const saleLineDropdownPadding =
    (saleLineFieldHeight - _saleLineDropdownContentHeight) / 2;

/// The height of the single row's control band, fixed so every line in the
/// list is the same height whether its product name takes one line or two.
/// Sized for the taller of the two things in it: the field band
/// ([saleLineFieldHeight]) and the product cell's reserved two name lines plus
/// its code line.
const saleLineRowHeight = 60.0;

/// Below this, even the two-row fallback has nowhere left to shrink — the
/// caller substitutes `SaleLineCard` at this width today, so `SaleLineRow`
/// itself should not normally be asked to lay out below it.
const saleLineTwoRowMinWidth = 600.0;

SaleLineLayout saleLineLayoutFor(double availableWidth) {
  if (availableWidth >= saleLineSingleRowMinWidth) return SaleLineLayout.singleRow;
  if (availableWidth >= saleLineTwoRowMinWidth) return SaleLineLayout.twoRow;
  return SaleLineLayout.card;
}

/// The width above which a line's controls are at their full, comfortable
/// sizes — a desktop workspace. Between here and
/// [saleLineSingleRowMinWidth] every column narrows proportionally toward its
/// floor, so the row degrades smoothly into a tablet rather than jumping.
const saleLineComfortableWidth = 1500.0;

/// What each fixed column of the single row gets at a given available width.
///
/// Two width sets, interpolated: the **floor** is what fits a 1024-px tablet
/// (FR-037a) once the product cell keeps its 222 px minimum, and the
/// **comfortable** set is the one drawn on the annotated screenshot of
/// 2026-08-11 — a ~35 % product cell with visibly roomier controls beside it.
/// The product column is not here: it is `Expanded`, and takes whatever these
/// leave, which is what keeps a very wide workspace from stranding empty space
/// at the right edge.
class SaleLineColumns {
  const SaleLineColumns._({
    required this.warehouse,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.tax,
    required this.total,
  });

  final double warehouse;
  final double quantity;
  final double price;
  final double discount;
  final double tax;
  final double total;

  /// The tablet floor: 652 px of columns, plus a 48 px delete button and six
  /// `spacing.xs` gaps, leaves the product cell 222 px at
  /// [saleLineSingleRowMinWidth].
  static const floor = SaleLineColumns._(
    warehouse: 168,
    quantity: 132,
    price: 88,
    discount: 76,
    tax: 88,
    total: 100,
  );

  /// The desktop set: 824 px of columns, which at a 1440-px workspace leaves
  /// the product cell a little over a third of the row.
  static const comfortable = SaleLineColumns._(
    warehouse: 240,
    quantity: 140,
    price: 100,
    discount: 112,
    tax: 120,
    total: 112,
  );

  static SaleLineColumns of(double availableWidth) {
    final t =
        ((availableWidth - saleLineSingleRowMinWidth) /
                (saleLineComfortableWidth - saleLineSingleRowMinWidth))
            .clamp(0.0, 1.0);
    double at(double a, double b) => a + (b - a) * t;
    return SaleLineColumns._(
      warehouse: at(floor.warehouse, comfortable.warehouse),
      quantity: at(floor.quantity, comfortable.quantity),
      price: at(floor.price, comfortable.price),
      discount: at(floor.discount, comfortable.discount),
      tax: at(floor.tax, comfortable.tax),
      total: at(floor.total, comfortable.total),
    );
  }
}
