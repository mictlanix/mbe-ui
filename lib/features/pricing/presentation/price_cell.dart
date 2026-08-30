import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_cell_key.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_grid_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Which direction a committed edit moves next (contracts/pricing-grid-
/// screen.md §2). The grid screen resolves this into an actual
/// [PriceCellKey] against its own row/column order and calls
/// [PricingGridController.openCell] — a [PriceCell] only knows its own
/// coordinate, not the shape of the whole grid.
enum PriceCellMove { down, up, left, right }

/// One editable price in the pricing grid (spec 033 US1) — reading state
/// shows the stored price (or the shared "not set" treatment, FR-005) and,
/// when [isActive], an editable field.
///
/// **Deliberately does not reuse `ConfirmableFieldController`/
/// `ConfirmableTextField`** (specs 030/031), despite both editing a
/// server-backed value: that controller's `submit`/`flush` discard-and-reset
/// an unparseable or refused value back to the last accepted one (a "peak"
/// animation, not a persistent state) — exactly wrong for FR-009, which
/// requires a rejected value to **stay on screen, flagged, with its reason**
/// until the user corrects it. This widget holds a plain
/// `TextEditingController`/`FocusNode` instead and represents "rejected" as
/// [PricingGridState.rejected] — real per-cell state the controller keeps,
/// not a field-local animation.
class PriceCell extends ConsumerStatefulWidget {
  const PriceCell({
    super.key,
    required this.filter,
    required this.productId,
    required this.priceListId,
    required this.price,
    required this.rejected,
    this.hasChanged = false,
    this.changedFrom,
    required this.inFlight,
    required this.isActive,
    required this.canUpdate,
    required this.onMove,
  });

  final PricingGridFilter filter;
  final int productId;
  final int priceListId;

  /// The stored price row, or `null` when the product has no price on this
  /// list yet (FR-005).
  final ProductPrice? price;
  final RejectedEdit? rejected;

  /// Whether this cell differs from the value it held when the view loaded —
  /// the "saved" badge (FR-022).
  ///
  /// Separate from [changedFrom] because a cell that had **no** price before
  /// is still a change, and the badge is how the user finds the cells the
  /// summary bar is counting. Conflating the two hid the badge on exactly
  /// the cells a "Missing «list»" worklist exists to fill.
  final bool hasChanged;

  /// The value this cell held when the view loaded, when there was one —
  /// the "was X" half of the tooltip. `null` on a cell that was unpriced.
  final String? changedFrom;

  final bool inFlight;
  final bool isActive;
  final bool canUpdate;

  /// Called after a commit is issued (regardless of its outcome) by a key
  /// that moves — Enter, Tab/Shift+Tab, or an arrow key at the edge of the
  /// text. The screen resolves the next cell and opens it, or does nothing
  /// at a grid edge (contracts/pricing-grid-screen.md §2).
  final ValueChanged<PriceCellMove> onMove;

  @override
  ConsumerState<PriceCell> createState() => _PriceCellState();
}

class _PriceCellState extends ConsumerState<PriceCell> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  PriceCellKey get _key =>
      PriceCellKey(productId: widget.productId, priceListId: widget.priceListId);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    if (widget.isActive) _activate();
  }

  @override
  void didUpdateWidget(PriceCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A cell is opened far more often by *becoming* active than by being
    // built active: keyboard traversal moves the selection between cells
    // that are already mounted in reading mode. Everything below used to run
    // in `initState` alone, so an arrowed-to cell showed a field it had never
    // seeded, never selected and — the reported symptom — never focused,
    // leaving a caret-less box that swallowed the next keystroke.
    if (widget.isActive && !oldWidget.isActive) _activate();
  }

  /// Seeds this cell's field from the value it is opening on, then takes the
  /// caret and selects the text so typing replaces rather than appends.
  ///
  /// Seeding here rather than at mount also fixes a staler bug: a cell whose
  /// price changed while it sat in reading mode (a column action, an undo)
  /// would otherwise open showing whatever it held when the row was first
  /// built.
  void _activate() {
    final rejected = widget.rejected;
    _controller.text = rejected != null
        ? rejected.typed
        : (widget.price?.price ?? '');
    // Post-frame: on the false→true edge this runs during a build, and the
    // field being focused is only in the tree once that build lands.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isActive) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    // Detached *before* disposing the node: disposing a still-focused
    // `FocusNode` can itself fire a final "lost focus" notification, and
    // this cell may be unmounting precisely *because* a key handler below
    // already committed and moved away — a second commit from that
    // notification would be redundant (and, if the server reformats the
    // value between the two, would even record a spurious second
    // `PriceChange`). Removing the listener first makes that impossible
    // rather than relying on the order of Flutter's own teardown.
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    ref
        .read(pricingGridControllerProvider(widget.filter).notifier)
        .commitCell(
          productId: widget.productId,
          priceListId: widget.priceListId,
          typed: _controller.text,
        );
  }

  void _commitAndMove(PriceCellMove move) {
    _commit();
    widget.onMove(move);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      ref.read(pricingGridControllerProvider(widget.filter).notifier).closeCell();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      final shiftHeld = HardwareKeyboard.instance.isShiftPressed;
      _commitAndMove(shiftHeld ? PriceCellMove.left : PriceCellMove.right);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _commitAndMove(PriceCellMove.down);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _commitAndMove(PriceCellMove.up);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight &&
        _controller.selection.baseOffset == _controller.text.length) {
      _commitAndMove(PriceCellMove.right);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft &&
        _controller.selection.baseOffset == 0) {
      _commitAndMove(PriceCellMove.left);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isActive) return _buildEditing(context);
    return _buildReading(context);
  }

  Widget _buildReading(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fmt = ref.watch(formattersProvider);
    final rejected = widget.rejected;
    final colors = Theme.of(context).colorScheme;

    final String display;
    Color? color;
    String? tooltip;
    if (rejected != null) {
      display = rejected.typed;
      color = colors.error;
      tooltip = switch (rejected.reason) {
        'invalidAmount' => l10n.pricingInvalidAmountError,
        'saveFailed' => l10n.pricingSaveFailedError,
        final serverMessage => serverMessage,
      };
    } else if (widget.price == null) {
      display = l10n.pricingPriceNotSet;
      color = colors.outline;
      tooltip = widget.canUpdate ? l10n.editPriceTooltip : null;
    } else {
      display = fmt.display.currency(widget.price!.price);
      tooltip = widget.canUpdate ? l10n.editPriceTooltip : null;
    }

    final text = Text(
      display,
      textAlign: TextAlign.right,
      style: TextStyle(color: color),
    );

    // FR-022's three states, in the order they can be true: in flight beats
    // "changed" (the write may yet be refused), and a rejection beats both —
    // its own colour and text are already applied above.
    final badgeKey = Key(
      'price_cell_badge_${widget.productId}_${widget.priceListId}',
    );
    final Widget? badge;
    if (rejected != null) {
      badge = Icon(Icons.error_outline, key: badgeKey, size: 14, color: colors.error);
    } else if (widget.inFlight) {
      badge = SizedBox(
        key: badgeKey,
        width: 12,
        height: 12,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
      tooltip = l10n.pricingGridCellSaving;
    } else if (widget.hasChanged) {
      badge = Icon(
        Icons.check_circle_outline,
        key: badgeKey,
        size: 14,
        color: colors.primary,
      );
      tooltip = widget.changedFrom != null
          ? l10n.pricingGridCellSaved(fmt.display.currency(widget.changedFrom))
          : l10n.pricingGridCellSavedNew;
    } else {
      badge = null;
    }

    // A plain `Row`, with the price left as an untruncatable `Text`: §VI
    // forbids ellipsizing a monetary amount to make room for an adornment, so
    // the price columns carry the badge's width in `kPriceColumnWidth`
    // instead of the badge stealing it from the figure.
    final content = badge == null
        ? text
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [badge, const SizedBox(width: 4), text],
          );

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        key: Key('price_cell_${widget.productId}_${widget.priceListId}'),
        onTap: widget.canUpdate
            ? () => ref
                  .read(pricingGridControllerProvider(widget.filter).notifier)
                  .openCell(_key)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: content,
        ),
      ),
    );
  }

  Widget _buildEditing(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKey,
      child: TextField(
        key: Key('price_cell_field_${widget.productId}_${widget.priceListId}'),
        controller: _controller,
        focusNode: _focusNode,
        // Focus is requested by `_activate()`, which fires on *becoming*
        // active too — `autofocus` only ever covered the mount case.
        textAlign: TextAlign.right,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSubmitted: (_) => _commitAndMove(PriceCellMove.down),
        // Suppresses `EditableText`'s default "done" behavior, which
        // unfocuses the field — that unfocus would fire `_onFocusChange`
        // and commit a second time on top of the explicit one `onSubmitted`
        // already issued above.
        onEditingComplete: () {},
      ),
    );
  }
}
