import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/confirmable_text_field.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

/// Coalesces a burst of stepper taps into one write (spec 030 FR-003) — the
/// delivery step's own window, tuned by hand against a live register (spec
/// 026), now shared by every host of [QuantityStepper].
const kQuantityCommitDebounce = Duration(milliseconds: 400);

/// Owns one sale line's (or one destination line's) quantity: the value the
/// cashier last stepped or confirmed, the debounce that flushes it, and the
/// discard-and-reset that fires when a typed value is abandoned or refused.
///
/// Extends [ConfirmableFieldController] (spec 031 research R7) — the
/// confirm-or-discard rule and its reset animation now live once in
/// `core/widgets/confirmable_text_field.dart`, shared with the sale line's
/// discount field; this class adds exactly what a stepper needs on top:
/// decimal bounds, stepping, and the debounce.
///
/// [onCommit] performs the write and reports whether it stuck — `false`
/// (never a thrown error) triggers the same discard-and-reset a bad typed
/// value does (research R3). Two commits for the same controller are never
/// in flight together: a value that arrives while one is outstanding is
/// applied once it settles, never dropped, never raced (FR-006).
///
/// [pendingWrites], if supplied, is held for the whole of the ~400 ms
/// coalescing window — not just the request that follows it — so a critical
/// action gated on it sees this stepper as outstanding from the moment a tap
/// is confirmed, not only once a request exists (spec 031 FR-004, research
/// R2). Every existing caller omits it and keeps behaving exactly as before
/// this feature.
class QuantityStepperController extends ConfirmableFieldController {
  QuantityStepperController({
    required super.value,
    required Future<bool> Function(String value) onCommit,
    this.min = '0',
    this.max,
    this.stepBy = '1',
    this.debounce = kQuantityCommitDebounce,
    PendingWrites? pendingWrites,
    super.id,
    super.unconfirmedEdits,
  }) : _pendingWrites = pendingWrites,
       // The base requires a `parse` callback; this one is never actually
       // reached — `parse` below overrides the method every internal caller
       // goes through, so a plain unbounded parse here is dead but harmless.
       super(parse: tryParseAmount, commit: onCommit);

  /// Inclusive floor — `'1'` on the capture surface (a line is removed with
  /// its own delete action, never stepped to zero), `'0'` on the delivery
  /// surface.
  String min;

  /// Inclusive ceiling, or `null` for none (the capture surface: stock is a
  /// non-blocking warning, not a bound).
  String? max;

  final String stepBy;

  /// The coalescing window [scheduleCommit] waits out before flushing
  /// (spec 036 FR-028/FR-029, `quantityCommitDebounceProvider`). Defaults to
  /// [kQuantityCommitDebounce] so a caller that doesn't pass it keeps
  /// today's exact delay.
  final Duration debounce;

  final PendingWrites? _pendingWrites;

  /// The hold on [_pendingWrites] for the coalescing window currently in
  /// progress, or `null` when nothing is pending. `??=`'d in
  /// [scheduleCommit] so a burst of taps holds it exactly once, and released
  /// once [flush] (or [flushOnTeardown]) settles with nothing left pending.
  Object? _guardToken;

  @override
  bool valuesEqual(String a, String b) => compareAmounts(a, b) == 0;

  /// Overrides the base's plain decimal parse with a bounds-checked one, so
  /// every caller that goes through [parse] — [submit] (Enter) and the
  /// unconfirmed-changes dialog's "keep" answer alike — refuses a value
  /// outside `[min, max]` exactly as [step] does, rather than only the
  /// unbounded parse the constructor was given.
  @override
  String? parse(String text) {
    final parsed = tryParseAmount(text);
    if (parsed == null) return null;
    if (compareAmounts(parsed, min) < 0) return null;
    if (max != null && compareAmounts(parsed, max!) > 0) return null;
    return parsed;
  }

  /// What a step actually acts on — [pendingValue] if a burst is already
  /// under way, [accepted] otherwise. Deliberately **not** [displayed]:
  /// unconfirmed typed text is not a value a step applies to (FR-015), and
  /// it is not even guaranteed to be a parseable decimal at every keystroke
  /// — an emptied field, a lone `-` or `.` while the cashier is still typing
  /// would otherwise throw here on every rebuild.
  String get _stepBase => pendingValue ?? accepted;

  bool get canDecrement =>
      compareAmounts(subtractAmounts(_stepBase, stepBy), min) >= 0;

  bool get canIncrement =>
      max == null || compareAmounts(addAmounts(_stepBase, stepBy), max!) <= 0;

  /// Pushes the server's own value in, and lets the host move the bounds
  /// with it (the delivery surface's ceiling changes as other destinations
  /// claim units).
  @override
  void sync({required String value, String? min, String? max}) {
    if (min != null) this.min = min;
    if (max != null) this.max = max;
    super.sync(value: value);
  }

  /// A −/+ press. Steps from whatever is already committed — [pendingValue]
  /// if a burst is already under way, [accepted] otherwise — never from
  /// unconfirmed typed text (FR-015): a draft the cashier never confirmed is
  /// not a base to step from.
  void step(int delta) {
    final candidate = delta > 0
        ? addAmounts(_stepBase, stepBy)
        : subtractAmounts(_stepBase, stepBy);
    if (compareAmounts(candidate, min) < 0) return;
    if (max != null && compareAmounts(candidate, max!) > 0) return;
    clearTypedText();
    pendingValue = candidate;
    notifyChanged();
    scheduleCommit();
  }

  /// A host-driven confirm — "claim everything pending", "adjust to
  /// available" — that does not go through the field at all. Same commit
  /// path as [step]/[submit], immediate on screen (research R2's reason this
  /// state cannot live only in the widget).
  void set(String value) {
    var clamped = value;
    if (compareAmounts(clamped, min) < 0) clamped = min;
    if (max != null && compareAmounts(clamped, max!) > 0) clamped = max!;
    clearTypedText();
    pendingValue = clamped;
    notifyChanged();
    scheduleCommit();
  }

  Timer? _debounce;

  @override
  void scheduleCommit() {
    _guardToken ??= _pendingWrites?.begin();
    _debounce?.cancel();
    _debounce = Timer(debounce, () {
      unawaited(flush());
    });
  }

  @override
  Future<void> flush() async {
    _debounce?.cancel();
    _debounce = null;
    await super.flush();
    _releaseGuardIfSettled();
  }

  @override
  Future<bool> flushOnTeardown(String pending) {
    final future = super.flushOnTeardown(pending);
    final token = _guardToken;
    if (token != null) {
      _guardToken = null;
      unawaited(future.whenComplete(() => _pendingWrites?.end(token)));
    }
    return future;
  }

  void _releaseGuardIfSettled() {
    if (pendingValue != null) return;
    final token = _guardToken;
    if (token == null) return;
    _guardToken = null;
    _pendingWrites?.end(token);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
class QuantityStepper extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    String format(String wire) => ref.read(formattersProvider).field.quantity(wire);
    return decoration == null ? _pillSkin(theme, format) : _fieldSkin(theme, format);
  }

  // ── Pill skin (delivery destination card) ───────────────────────────────

  Widget _pillSkin(ThemeData theme, String Function(String) format) => Container(
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
        _pillButton(Icons.remove, controller.canDecrement, -1),
        SizedBox(
          width: 56,
          child: ConfirmableTextField(
            controller: controller,
            fieldKey: fieldKey,
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            format: format,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        _pillButton(Icons.add, controller.canIncrement, 1),
      ],
    ),
  );

  Widget _pillButton(IconData icon, bool boundOk, int delta) => IconButton(
    icon: Icon(icon, size: 18),
    tooltip: delta < 0 ? decrementTooltip : incrementTooltip,
    visualDensity: VisualDensity.compact,
    onPressed: enabled && boundOk ? () => controller.step(delta) : null,
  );

  // ── Field skin (capture sale lines) ─────────────────────────────────────

  Widget _fieldSkin(ThemeData theme, String Function(String) format) => Row(
    mainAxisSize: dense ? MainAxisSize.min : MainAxisSize.max,
    children: [
      _fieldButton(Icons.remove, controller.canDecrement, -1),
      Expanded(
        child: ConfirmableTextField(
          controller: controller,
          fieldKey: fieldKey,
          enabled: enabled,
          textAlign: TextAlign.center,
          style: textStyle,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          format: format,
          decoration: decoration!,
        ),
      ),
      _fieldButton(Icons.add, controller.canIncrement, 1),
    ],
  );

  Widget _fieldButton(IconData icon, bool boundOk, int delta) {
    final onPressed = enabled && boundOk ? () => controller.step(delta) : null;
    final tooltip = delta < 0 ? decrementTooltip : incrementTooltip;
    if (!dense) {
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
}
