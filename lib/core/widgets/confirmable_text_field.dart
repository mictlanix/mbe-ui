import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';

/// How long the reset cross-fade/tint runs (spec 030 FR-013, spec 031
/// FR-015). Named here rather than drawn from `core/design/` because that
/// package has no motion scale yet (spec 030 research R4).
const kFieldResetAnimation = Duration(milliseconds: 250);

/// The confirm-or-discard rule spec 030 built for the quantity stepper,
/// extracted so any typed field that mirrors a server value can have it
/// without a second copy (spec 031 FR-020): typed text is confirmed only by
/// an explicit submit, and text abandoned without confirmation — by losing
/// focus, by failing to parse, or by the server refusing it — is discarded
/// and the discard is acknowledged, never silent.
///
/// A plain `ChangeNotifier`, not a Riverpod provider (constitution §II) —
/// per-widget input state with a disposal contract, the same category as the
/// `TextEditingController` it wraps. One instance per field, created and
/// disposed by the host `State` that renders it.
///
/// [parse] turns typed text into a wire value, or `null` if it cannot —
/// [commit] never sees a value [parse] rejected. [commit] performs the write
/// and reports whether it stuck — `false` (never a thrown error) triggers
/// the same discard-and-reset a bad typed value does (spec 030 research R3).
/// Two commits are never in flight together: a value that arrives while one
/// is outstanding is applied once it settles, never dropped, never raced.
///
/// [id] and [unconfirmedEdits] are optional: supplied, the controller
/// registers itself in [UnconfirmedEdits] for the length of time it holds
/// unconfirmed text (spec 031 FR-024, FR-030), so a critical action reading
/// that registry can ask about — and commit through — this exact field.
/// Omitted (as every existing caller of [QuantityStepperController] does
/// today), the controller behaves exactly as before this feature: no
/// registration, no dialog ever asks about it.
class ConfirmableFieldController extends ChangeNotifier {
  ConfirmableFieldController({
    required String value,
    required String? Function(String text) parse,
    required this.commit,
    Object? id,
    UnconfirmedEdits? unconfirmedEdits,
  }) : _accepted = value,
       _parse = parse,
       _id = id ?? Object(),
       _unconfirmedEdits = unconfirmedEdits;

  final String? Function(String text) _parse;

  /// `null` means [text] cannot be read as a value at all. A public
  /// *method*, not the constructor-supplied field directly, so
  /// [QuantityStepperController] can override it to add bounds-checking on
  /// top of the plain decimal parse it's constructed with — every internal
  /// caller (`submit`, the "keep" dialog path) calls this method, so an
  /// override is honored everywhere parsing happens, including from a
  /// different library (spec 031 research/implementation: a subclass cannot
  /// override a private member across a library boundary, which is why this
  /// is public rather than a stored callback field).
  @protected
  String? parse(String text) => _parse(text);

  final Future<bool> Function(String value) commit;

  final Object _id;
  final UnconfirmedEdits? _unconfirmedEdits;

  /// The last value known to be on the server.
  String _accepted;
  String get accepted => _accepted;

  /// A value confirmed (submitted, or a subclass's own confirmed action)
  /// that has not reached the server yet — or has, and is waiting for its
  /// response. `null` at this level unless a subclass sets it (only
  /// [QuantityStepperController] does, via [pendingValue]).
  String? _pending;

  /// Unconfirmed text currently in the field. Never sent; discarded by
  /// confirmation, by abandonment, by an external [sync], and by teardown.
  String? _typed;

  bool _inFlight = false;
  bool _disposed = false;

  /// Bumped on every discard — the widget animates when this changes; the
  /// value itself carries no meaning beyond "different from last time".
  int _resetTick = 0;
  int get resetTick => _resetTick;

  /// What the control shows right now.
  String get displayed => _typed ?? _pending ?? _accepted;

  /// Whether the cashier has typed something not yet confirmed.
  bool get hasUnconfirmedText => _typed != null;

  /// A subclass's read/write access to [_pending] — e.g.
  /// [QuantityStepperController.step] sets it directly rather than through
  /// [submit].
  @protected
  String? get pendingValue => _pending;

  @protected
  set pendingValue(String? value) => _pending = value;

  @protected
  void notifyChanged() {
    if (!_disposed) notifyListeners();
  }

  @protected
  void bumpResetTick() => _resetTick++;

  /// Drops any unconfirmed typed text **without** animating a discard —
  /// unlike [abandon], which is a discard the cashier should notice, this is
  /// for a subclass whose own action (a −/+ step, a host-driven [set]) is
  /// about to move the value some other way, and a draft the cashier never
  /// confirmed is simply not a base for that action to work from (spec 030
  /// FR-015). A no-op when nothing was typed.
  @protected
  void clearTypedText() {
    if (_typed == null) return;
    _typed = null;
    _clearUnconfirmed();
  }

  /// Whether two wire values are the same value — plain string equality at
  /// this level. [QuantityStepperController] overrides this with decimal
  /// comparison, since `'0.10'` and `'0.1'` are the same quantity but
  /// different strings.
  @protected
  bool valuesEqual(String a, String b) => a == b;

  void _registerUnconfirmed() {
    final typed = _typed;
    if (typed == null) return;
    // [confirm] is bound to this exact [typed] snapshot, not to whatever
    // `_typed` holds when the cashier eventually answers (research: opening
    // the dialog that asks about it blurs the field, and blur is itself a
    // discard by the ordinary rule (FR-014) — so by the time "keep" runs,
    // `_typed` may already be null). The snapshot is what makes "keep" still
    // commit the value the cashier actually saw and chose to keep, rather
    // than silently doing nothing because the live field moved on first.
    _unconfirmedEdits?.put(
      UnconfirmedEdit(
        id: _id,
        text: typed,
        confirm: () => _confirmSnapshot(typed),
        discard: abandon,
        resume: () => _resumeSnapshot(typed),
      ),
    );
  }

  /// The "keep editing" answer (FR-028): re-establishes [snapshot] as the
  /// live draft if the dialog's own blur already discarded it — a no-op
  /// when the draft was never actually lost.
  void _resumeSnapshot(String snapshot) {
    if (_typed == snapshot) return;
    edit(snapshot);
  }

  void _clearUnconfirmed() => _unconfirmedEdits?.remove(_id);

  /// Records a keystroke. Nothing is sent — [submit] or a subclass's own
  /// confirmed action is what commits.
  void edit(String text) {
    _typed = text;
    _registerUnconfirmed();
    notifyChanged();
  }

  /// An explicit submit (Enter). A value [parse] accepts is confirmed and
  /// queued for commit; anything else is discarded with a reset.
  void submit(String text) {
    final parsed = parse(text);
    if (parsed == null) {
      _typed = null;
      _clearUnconfirmed();
      bumpResetTick();
      notifyChanged();
      return;
    }
    _typed = null;
    _clearUnconfirmed();
    _pending = parsed;
    notifyChanged();
    scheduleCommit();
  }

  /// Focus lost (or the surface torn down) with unconfirmed text still in
  /// the field: discarded, with a reset. A no-op if nothing was typed.
  void abandon() {
    if (_typed == null) return;
    _typed = null;
    _clearUnconfirmed();
    bumpResetTick();
    notifyChanged();
  }

  /// Pushes the server's own value in. Unconfirmed typed text that
  /// disagrees with the new value is discarded and animated away, since it
  /// now describes a value that no longer exists.
  void sync({required String value}) {
    if (_pending != null) {
      _accepted = value;
      notifyChanged();
      return;
    }
    if (_typed != null) {
      if (!valuesEqual(value, _accepted)) {
        _accepted = value;
        _typed = null;
        _clearUnconfirmed();
        bumpResetTick();
      } else {
        _accepted = value;
      }
      notifyChanged();
      return;
    }
    if (!valuesEqual(value, _accepted)) {
      _accepted = value;
      notifyChanged();
    }
  }

  /// The "keep" answer from the unconfirmed-changes dialog (spec 031
  /// FR-026): commits [snapshot] — the text as it was when this field
  /// registered with [UnconfirmedEdits] — exactly as pressing Enter on it
  /// would, but reports whether it stuck rather than firing and forgetting,
  /// since the dialog's caller needs to know before deciding whether to
  /// proceed. Deliberately does not go through [_pending]/[scheduleCommit]:
  /// by the time this runs the cashier has already made an explicit choice,
  /// so there is no reason to still coalesce it behind a debounce window.
  ///
  /// Operates on [snapshot], not on whatever `_typed` holds *now* — opening
  /// the dialog that leads here blurs this field, which discards `_typed`
  /// by the ordinary rule (FR-014) before the cashier ever answers. Only
  /// clears `_typed`/notifies here if it still matches [snapshot] — i.e. if
  /// nothing else has already handled it.
  Future<bool> _confirmSnapshot(String snapshot) async {
    // Whether [snapshot] is still the live draft — if something else (the
    // dialog's own blur, another edit) has already discarded it, that
    // discard already played its own acknowledgement, and this call must
    // not play a second, redundant one.
    final stillLive = _typed == snapshot;
    if (stillLive) {
      _typed = null;
      _clearUnconfirmed();
      notifyChanged();
    }
    final parsed = parse(snapshot);
    if (parsed == null) {
      if (stillLive) {
        bumpResetTick();
        notifyChanged();
      }
      return false;
    }
    bool ok;
    try {
      ok = await commit(parsed);
    } catch (_) {
      ok = false;
    }
    if (_disposed) return ok;
    if (ok) {
      // Updates the line's true value regardless of [stillLive] — the write
      // landed, and the field must reflect it whether or not it was still
      // showing the draft when this resolved.
      _accepted = parsed;
    } else if (stillLive) {
      bumpResetTick();
    }
    notifyChanged();
    return ok;
  }

  /// Decides when a confirmed [_pending] value actually reaches [commit].
  /// This level flushes immediately — an explicit submit with no debounce
  /// (spec 031 FR-013). [QuantityStepperController] overrides this to
  /// interpose its ~400 ms coalescing window (spec 030 FR-003).
  @protected
  void scheduleCommit() => unawaited(flush());

  /// Fires a pending commit now. Public so a host or a test can force the
  /// write without waiting out a subclass's own scheduling, and overridable
  /// so [QuantityStepperController] can release its guard hold once the
  /// value this call was tracking has fully settled — including through the
  /// tail recursion below, which re-enters this same (possibly overridden)
  /// method, never the private base implementation directly.
  Future<void> flush() async {
    if (_disposed || _inFlight) return;
    final requested = _pending;
    if (requested == null) return;
    if (valuesEqual(requested, _accepted)) {
      _pending = null;
      notifyChanged();
      return;
    }

    _inFlight = true;
    bool ok;
    try {
      ok = await commit(requested);
    } catch (_) {
      ok = false;
    }
    _inFlight = false;
    if (_disposed) return;

    if (ok) {
      _accepted = requested;
      if (_pending == requested) _pending = null;
    } else {
      _pending = null;
      bumpResetTick();
    }
    notifyChanged();

    // A step (or a fresh commit) landed mid-flight — still waiting to be
    // sent. `flush()`, not a private helper, so an override still runs.
    if (_pending != null) unawaited(flush());
  }

  /// What [dispose] sends a still-pending value through — a hook so
  /// [QuantityStepperController] can attach its guard-hold release to the
  /// resulting future, since the fire-and-forget below bypasses [flush]
  /// entirely (there is nothing left to coalesce; the controller is going
  /// away).
  @protected
  Future<bool> flushOnTeardown(String pending) => commit(pending);

  @override
  void dispose() {
    _disposed = true;
    _clearUnconfirmed();
    // Fire-and-forget, deliberately bypassing `flush`'s own bookkeeping —
    // this controller is going away, so there is nothing left to update.
    // Not sending it would silently lose a change the cashier already made;
    // a throw from the host's write must not escape `dispose()`.
    final pending = _pending;
    if (pending != null) {
      unawaited(flushOnTeardown(pending).catchError((_) => false));
    }
    super.dispose();
  }
}

/// The confirm-or-discard field itself: a `TextField` wrapped so a discard
/// cross-fades the old text out and the restored text in while a brief tint
/// of the same wrapper peaks and settles — both driven by one `peak` value
/// so the swap always lands while the text is invisible (spec 030
/// FR-013, spec 031 FR-015).
///
/// [format] turns [ConfirmableFieldController.displayed]'s wire value into
/// what the field shows — a host with a formatted display (currency, a
/// rate, a quantity) supplies it; the default is the identity function, for
/// a field that is already display-ready.
class ConfirmableTextField extends StatefulWidget {
  const ConfirmableTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.fieldKey,
    this.decoration,
    this.style,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.format,
  });

  final ConfirmableFieldController controller;
  final bool enabled;

  /// Goes on the `TextField` itself, distinct from this widget's own [key] —
  /// a test locating the field by key expects to find a `TextField`, not
  /// this wrapper.
  final Key? fieldKey;

  final InputDecoration? decoration;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final String Function(String wire)? format;

  @override
  State<ConfirmableTextField> createState() => _ConfirmableTextFieldState();
}

class _ConfirmableTextFieldState extends State<ConfirmableTextField>
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
    _resetAnimation = AnimationController(vsync: this, duration: kFieldResetAnimation);
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant ConfirmableTextField oldWidget) {
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

  String _formatted(String wire) => widget.format?.call(wire) ?? wire;

  void _handleFocusChange() {
    if (!_focus.hasFocus) widget.controller.abandon();
  }

  void _handleControllerChange() {
    if (!mounted) return;
    final tick = widget.controller.resetTick;
    if (tick != _lastResetTick) {
      _lastResetTick = tick;
      unawaited(_playReset());
    } else if (!widget.controller.hasUnconfirmedText) {
      // Not keyed on focus: pressing Enter confirms and clears the typed
      // draft immediately, but does not itself move focus off the field —
      // gating on focus here left a confirmed value showing the cashier's
      // raw keystrokes, unformatted, until they later tabbed away. Gating on
      // "nothing left to confirm" instead reformats the instant a value
      // settles, whether that is by Enter, by a step, or by losing focus,
      // and still leaves an *actively typed* draft alone — the field's own
      // text stays the source of truth for that, exactly as before.
      _syncText();
    } else {
      // A live draft exists, but not necessarily because this box's own
      // keystroke just produced it — "keep editing" (FR-028) can
      // re-establish one programmatically, after the dialog that raised the
      // question blurred (and so discarded) it. An ordinary keystroke has
      // already updated `_text` itself by the time this listener runs, so
      // this is a no-op then; it only does something for a draft restored
      // from outside the box.
      final live = widget.controller.displayed;
      if (_text.text != live) _text.text = live;
    }
    setState(() {}); // let a host reacting to the same controller re-render
  }

  void _syncText() {
    final formatted = _formatted(widget.controller.displayed);
    if (_text.text != formatted) _text.text = formatted;
  }

  /// What a reset animation's swap actually applies — formatting only
  /// belongs on an accepted/pending value, never on live typed text. A
  /// reset started for one discard can still be mid-flight when "keep
  /// editing" (FR-028) re-establishes a *new* live draft on the same field
  /// (`resume()` racing this animation's own ~250 ms window) — in that case
  /// the draft is what's live now, and [_handleControllerChange] already
  /// put its raw text in the box; formatting it here would treat typed
  /// keystrokes as a stored wire value (e.g. turning a typed "15" into a
  /// stored-rate reading of "1500").
  void _syncIfSettled() {
    if (!widget.controller.hasUnconfirmedText) _syncText();
  }

  Future<void> _playReset() async {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _syncIfSettled();
      setState(() => _reducedMotionTint = true);
      await Future<void>.delayed(kFieldResetAnimation);
      if (mounted) setState(() => _reducedMotionTint = false);
      return;
    }
    var swapped = false;
    void maybeSwap() {
      if (!swapped && _resetAnimation.value >= 0.5) {
        swapped = true;
        _syncIfSettled();
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
    final field = TextField(
      key: widget.fieldKey,
      controller: _text,
      focusNode: _focus,
      enabled: widget.enabled,
      textAlign: widget.textAlign,
      style: widget.style,
      keyboardType: widget.keyboardType,
      decoration: widget.decoration,
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
          decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(8)),
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: field,
    );
  }
}
