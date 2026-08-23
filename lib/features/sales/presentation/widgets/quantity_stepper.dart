import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Coalesces a burst of stepper taps into one write (spec 030 FR-003) — the
/// delivery step's own window, tuned by hand against a live register (spec
/// 026), now shared by every host of [QuantityStepper].
const kQuantityCommitDebounce = Duration(milliseconds: 400);

/// How long the reset cross-fade/tint runs (spec 030 FR-013). Named here
/// rather than drawn from `core/design/` because that package has no motion
/// scale yet (research R4) — see the feature's plan Complexity Tracking.
const kQuantityResetAnimation = Duration(milliseconds: 250);

/// Owns one sale line's (or one destination line's) quantity: the value the
/// cashier last stepped or confirmed, the debounce that flushes it, and the
/// discard-and-reset that fires when a typed value is abandoned or refused.
///
/// A plain `ChangeNotifier`, not a Riverpod provider (constitution §II) —
/// this is per-widget input state with a `Timer` and a disposal contract,
/// the same category as the `TextEditingController` it replaces. One
/// instance per line, created and disposed by the host `State` that renders
/// it (spec 030 research R2).
///
/// [onCommit] performs the write and reports whether it stuck — `false`
/// (never a thrown error) triggers the same discard-and-reset a bad typed
/// value does (research R3). Two commits for the same controller are never
/// in flight together: a value that arrives while one is outstanding is
/// applied once it settles, never dropped, never raced (FR-006).
class QuantityStepperController extends ChangeNotifier {
  QuantityStepperController({
    required String value,
    required this.onCommit,
    this.min = '0',
    this.max,
    this.stepBy = '1',
  }) : _accepted = value;

  final Future<bool> Function(String value) onCommit;

  /// Inclusive floor — `'1'` on the capture surface (a line is removed with
  /// its own delete action, never stepped to zero), `'0'` on the delivery
  /// surface.
  String min;

  /// Inclusive ceiling, or `null` for none (the capture surface: stock is a
  /// non-blocking warning, not a bound).
  String? max;

  final String stepBy;

  /// The last value known to be on the server.
  String _accepted;

  /// A value the cashier committed (stepped, or confirmed) that has not
  /// reached the server yet — or has, and is waiting for its response.
  String? _pending;

  /// Unconfirmed text currently in the field. Never sent; discarded by
  /// confirmation, by abandonment, and by teardown.
  String? _typed;

  Timer? _debounce;
  bool _inFlight = false;
  bool _disposed = false;

  /// Bumped on every discard — the widget animates when this changes; the
  /// value itself carries no meaning beyond "different from last time".
  int _resetTick = 0;
  int get resetTick => _resetTick;

  /// What the control shows right now.
  String get displayed => _typed ?? _pending ?? _accepted;

  String get accepted => _accepted;

  /// Whether the cashier has typed something not yet confirmed — read by the
  /// widget in the same file to decide whether an external update may
  /// overwrite the field's live text (spec 030 research, widget wiring).
  bool get hasUnconfirmedText => _typed != null;

  /// What a step actually acts on — [_pending] if a burst is already under
  /// way, [_accepted] otherwise, matching [step]'s own base. Deliberately
  /// **not** [displayed]: unconfirmed [_typed] text is not a value a step
  /// applies to (FR-015), and it is not even guaranteed to be a parseable
  /// decimal at every keystroke — an emptied field, a lone `-` or `.` while
  /// the cashier is still typing would otherwise throw here on every
  /// rebuild.
  String get _stepBase => _pending ?? _accepted;

  bool get canDecrement =>
      compareAmounts(subtractAmounts(_stepBase, stepBy), min) >= 0;

  bool get canIncrement =>
      max == null || compareAmounts(addAmounts(_stepBase, stepBy), max!) <= 0;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Pushes the server's own value in. While a commit is pending it is newer
  /// than the server's copy and stays displayed (research R7); unconfirmed
  /// typed text that disagrees with the new value is discarded and animated
  /// away, since it now describes a line that no longer exists.
  void sync({required String value, String? min, String? max}) {
    if (min != null) this.min = min;
    if (max != null) this.max = max;
    if (_pending != null) {
      _accepted = value;
      _notify();
      return;
    }
    if (_typed != null) {
      if (compareAmounts(value, _accepted) != 0) {
        _accepted = value;
        _typed = null;
        _resetTick++;
      } else {
        _accepted = value;
      }
      _notify();
      return;
    }
    if (compareAmounts(value, _accepted) != 0) {
      _accepted = value;
      _notify();
    }
  }

  /// A −/+ press. Steps from whatever is already committed — [_pending] if a
  /// burst is already under way, [_accepted] otherwise — never from
  /// unconfirmed [_typed] text (FR-015): a draft the cashier never confirmed
  /// is not a base to step from.
  void step(int delta) {
    final candidate = delta > 0
        ? addAmounts(_stepBase, stepBy)
        : subtractAmounts(_stepBase, stepBy);
    if (compareAmounts(candidate, min) < 0) return;
    if (max != null && compareAmounts(candidate, max!) > 0) return;
    _typed = null;
    _pending = candidate;
    _notify();
    _scheduleFlush();
  }

  /// Records a keystroke. Nothing is sent — [submit] or a step is what
  /// commits.
  void edit(String text) {
    _typed = text;
    _notify();
  }

  /// Enter. A valid, in-range value is confirmed and queued for the
  /// debounce, exactly as a step is (FR-010); anything else is discarded
  /// with a reset (FR-012).
  void submit(String text) {
    final parsed = tryParseAmount(text);
    if (parsed == null ||
        compareAmounts(parsed, min) < 0 ||
        (max != null && compareAmounts(parsed, max!) > 0)) {
      _typed = null;
      _resetTick++;
      _notify();
      return;
    }
    _typed = null;
    _pending = parsed;
    _notify();
    _scheduleFlush();
  }

  /// Focus lost (or the surface torn down) with unconfirmed text still in
  /// the field: discarded, with a reset (FR-011). A no-op if nothing was
  /// typed.
  void abandon() {
    if (_typed == null) return;
    _typed = null;
    _resetTick++;
    _notify();
  }

  /// A host-driven confirm — "claim everything pending", "adjust to
  /// available" — that does not go through the field at all. Same commit
  /// path as [step]/[submit], immediate on screen (research R2's reason this
  /// state cannot live only in the widget).
  void set(String value) {
    var clamped = value;
    if (compareAmounts(clamped, min) < 0) clamped = min;
    if (max != null && compareAmounts(clamped, max!) > 0) clamped = max!;
    _typed = null;
    _pending = clamped;
    _notify();
    _scheduleFlush();
  }

  void _scheduleFlush() {
    _debounce?.cancel();
    _debounce = Timer(kQuantityCommitDebounce, () {
      unawaited(_flush());
    });
  }

  /// Fires a pending commit now, out of turn — the public entry point
  /// [dispose] uses under the hood, and available to a host or a test that
  /// needs the write without waiting out the window.
  Future<void> flush() async {
    _debounce?.cancel();
    _debounce = null;
    await _flush();
  }

  Future<void> _flush() async {
    if (_disposed || _inFlight) return;
    final requested = _pending;
    if (requested == null) return;
    if (compareAmounts(requested, _accepted) == 0) {
      _pending = null;
      _notify();
      return;
    }

    _inFlight = true;
    bool accepted;
    try {
      accepted = await onCommit(requested);
    } catch (_) {
      accepted = false;
    }
    _inFlight = false;
    if (_disposed) return;

    if (accepted) {
      _accepted = requested;
      if (_pending == requested) _pending = null;
    } else {
      _pending = null;
      _resetTick++;
    }
    _notify();

    // A tap (or a fresh commit) landed mid-flight — still waiting to be sent.
    if (_pending != null) unawaited(_flush());
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    // Fire-and-forget, deliberately bypassing `_flush`'s own bookkeeping —
    // this controller is going away, so there is nothing left to update.
    // Not sending it would silently lose a change the cashier already made
    // (FR-005); a throw from the host's write must not escape `dispose()`.
    final pending = _pending;
    if (pending != null) {
      unawaited(Future(() => onCommit(pending)).catchError((_) => false));
    }
    super.dispose();
  }
}

/// The −/field/+ control itself (spec 030 FR-001): one implementation shared
/// by the wide sale-line row, the compact sale-line card and the delivery
/// destination card, so the debounce, the live-during-a-write behaviour and
/// the discard-and-reset exist once rather than in three places.
///
/// [decoration] is the whole difference between the two skins it draws
/// (spec 030 research R5): `null` renders the delivery pill (filled,
/// outlined, 44 px, matching `DestinationCard`'s stepper exactly); supplied,
/// it renders a plain field inside the host's own control band, matching
/// `SaleLineRow`/`SaleLineCard`'s quantity control exactly — both skins are
/// meant to come out pixel-identical to what they replace, so a capture
/// golden that diffs is a bug, not a re-baseline.
class QuantityStepper extends ConsumerStatefulWidget {
  const QuantityStepper({
    super.key,
    required this.controller,
    this.enabled = true,
    this.fieldKey,
    this.decoration,
    this.textStyle,
    this.dense = false,
    this.decrementTooltip,
    this.incrementTooltip,
  });

  final QuantityStepperController controller;
  final bool enabled;

  /// Goes on the `TextField` itself —
  /// `test/widget/features/sales/destination_assignment_test.dart` finds it
  /// there and reads its `TextEditingController`.
  final Key? fieldKey;

  final InputDecoration? decoration;
  final TextStyle? textStyle;

  /// `true` gives the field skin `SaleLineRow`'s 32 px shrink-wrapped
  /// buttons; `false` (the default, and the pill skin's only option) keeps
  /// Material's own touch target. `tapTargetSize: shrinkWrap` (below) is
  /// what actually makes the 32 px `constraints` hold — without it Material
  /// adds its 48 px minimum tap target around the button regardless of
  /// `padding`/`constraints`. Dropping below the 48 px target is deliberate
  /// and confined to `dense: true`'s one caller: the single-row capture
  /// layout, laid out only at `saleLineSingleRowMinWidth` and above, where
  /// the input is a pointer (spec 023 contracts/capture-surface.md §6) — the
  /// phone tier renders `SaleLineCard` (`dense: false`), which keeps
  /// Material's full touch target.
  final bool dense;

  final String? decrementTooltip;
  final String? incrementTooltip;

  @override
  ConsumerState<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends ConsumerState<QuantityStepper>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _text;
  late final FocusNode _focus;
  late final AnimationController _resetAnimation;

  int _lastResetTick = 0;
  bool _reducedMotionTint = false;

  @override
  void initState() {
    super.initState();
    _lastResetTick = widget.controller.resetTick;
    _text = TextEditingController(text: _formatted(widget.controller.displayed));
    _focus = FocusNode()..addListener(_handleFocusChange);
    _resetAnimation = AnimationController(
      vsync: this,
      duration: kQuantityResetAnimation,
    );
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant QuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
      _lastResetTick = widget.controller.resetTick;
      _text.text = _formatted(widget.controller.displayed);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _focus.removeListener(_handleFocusChange);
    _focus.dispose();
    _text.dispose();
    _resetAnimation.dispose();
    super.dispose();
  }

  String _formatted(String wire) =>
      ref.read(formattersProvider).field.quantity(wire);

  void _handleFocusChange() {
    if (!_focus.hasFocus) widget.controller.abandon();
  }

  void _handleControllerChange() {
    if (!mounted) return;
    final tick = widget.controller.resetTick;
    if (tick != _lastResetTick) {
      _lastResetTick = tick;
      unawaited(_playReset());
    } else if (!_focus.hasFocus) {
      // Only pushed while the cashier isn't actively editing — mid-edit, the
      // field's own text is the source of truth for what's on screen until
      // it is confirmed or abandoned.
      _syncText();
    }
    setState(() {}); // refresh the −/+ enabled state
  }

  void _syncText() {
    final formatted = _formatted(widget.controller.displayed);
    if (_text.text != formatted) _text.text = formatted;
  }

  Future<void> _playReset() async {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _syncText();
      setState(() => _reducedMotionTint = true);
      await Future<void>.delayed(kQuantityResetAnimation);
      if (mounted) setState(() => _reducedMotionTint = false);
      return;
    }
    var swapped = false;
    void maybeSwap() {
      if (!swapped && _resetAnimation.value >= 0.5) {
        swapped = true;
        _syncText();
      }
    }

    _resetAnimation.addListener(maybeSwap);
    try {
      await _resetAnimation.forward(from: 0);
    } finally {
      _resetAnimation.removeListener(maybeSwap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return widget.decoration == null ? _pillSkin(theme) : _fieldSkin(theme);
  }

  // ── Pill skin (delivery destination card) ───────────────────────────────

  Widget _pillSkin(ThemeData theme) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      border: Border.all(color: theme.colorScheme.outlineVariant),
      borderRadius: theme.shapes.xlRadius,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pillButton(Icons.remove, widget.controller.canDecrement, -1),
        SizedBox(
          width: 56,
          child: _animatedField(
            theme: theme,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        _pillButton(Icons.add, widget.controller.canIncrement, 1),
      ],
    ),
  );

  Widget _pillButton(IconData icon, bool boundOk, int delta) => IconButton(
    icon: Icon(icon, size: 18),
    tooltip: delta < 0 ? widget.decrementTooltip : widget.incrementTooltip,
    visualDensity: VisualDensity.compact,
    onPressed: widget.enabled && boundOk
        ? () => widget.controller.step(delta)
        : null,
  );

  // ── Field skin (capture sale lines) ─────────────────────────────────────

  Widget _fieldSkin(ThemeData theme) => Row(
    mainAxisSize: widget.dense ? MainAxisSize.min : MainAxisSize.max,
    children: [
      _fieldButton(Icons.remove, widget.controller.canDecrement, -1),
      Expanded(child: _animatedField(theme: theme, decoration: widget.decoration!)),
      _fieldButton(Icons.add, widget.controller.canIncrement, 1),
    ],
  );

  Widget _fieldButton(IconData icon, bool boundOk, int delta) {
    final onPressed = widget.enabled && boundOk
        ? () => widget.controller.step(delta)
        : null;
    final tooltip = delta < 0 ? widget.decrementTooltip : widget.incrementTooltip;
    if (!widget.dense) {
      return IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed);
    }
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      onPressed: onPressed,
    );
  }

  // ── Shared animated field ────────────────────────────────────────────────

  /// The `TextField` both skins render, wrapped so a discard (spec 030
  /// FR-013) cross-fades the old text out and the restored value in while a
  /// brief tint of this same wrapper peaks and settles — both driven by one
  /// `peak` value so the swap always lands while the text is invisible.
  Widget _animatedField({required ThemeData theme, required InputDecoration decoration}) {
    final field = TextField(
      key: widget.fieldKey,
      controller: _text,
      focusNode: _focus,
      enabled: widget.enabled,
      textAlign: TextAlign.center,
      style: widget.textStyle,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: decoration,
      onChanged: widget.controller.edit,
      onSubmitted: widget.controller.submit,
    );

    return AnimatedBuilder(
      animation: _resetAnimation,
      builder: (context, child) {
        final t = _resetAnimation.value;
        final peak = _reducedMotionTint ? 1.0 : (t < 0.5 ? t / 0.5 : (1 - t) / 0.5);
        final tint = Color.lerp(Colors.transparent, theme.colorScheme.errorContainer, peak);
        final opacity = _reducedMotionTint ? 1.0 : 1 - peak;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: field,
    );
  }
}
