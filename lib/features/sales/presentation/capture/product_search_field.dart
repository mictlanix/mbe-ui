import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_lookup_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The one field that accepts both a scanned barcode and a code/name/brand/
/// SKU search (FR-020, FR-021). Owns its own `TextEditingController`/
/// `FocusNode` — independent of `Sale` rebuilds, so an in-flight mutation
/// elsewhere never drops keystrokes or steals focus (FR-010).
///
/// Store scanners are keyboard-wedge devices: they type the code and send
/// Enter (research.md §7) — the field searches on submit, not per keystroke.
/// A search matching exactly one product calls [onProductSelected] directly;
/// several matches render a results list below the field.
class ProductSearchField extends ConsumerStatefulWidget {
  const ProductSearchField({
    super.key,
    required this.onProductSelected,
    this.warehouse,
    this.enabled = true,
  });

  final ValueChanged<ProductLookupResult> onProductSelected;
  final int? warehouse;
  final bool enabled;

  @override
  ConsumerState<ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends ConsumerState<ProductSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<ProductLookupResult> _results = const [];
  bool _searching = false;
  bool _searchedEmpty = false;
  Timer? _debounce;
  // Tags every lookup so a slower, superseded one can never overwrite what a
  // faster, later one already found — the race a debounced *and* an
  // immediate (scanner) path both feeding the same state can hit, which a
  // submit-only field never could (spec 023 FR-035).
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final pattern = value.trim();
    if (pattern.isEmpty) {
      setState(() {
        _results = const [];
        _searching = false;
        _searchedEmpty = false;
      });
      return;
    }
    // FR-033: offered as the cashier types, debounced — never auto-added.
    // Only `onSubmitted` (the scanner's Enter) may add a line directly.
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _search(pattern, autoAddSingleMatch: false),
    );
  }

  Future<void> _onSubmitted(String value) async {
    _debounce?.cancel();
    final pattern = value.trim();
    if (pattern.isEmpty) return;
    // FR-034: a keyboard-wedge scanner types the code and sends Enter — the
    // one path that still adds a single exact match directly, unchanged
    // from before this field could search on every keystroke.
    await _search(pattern, autoAddSingleMatch: true);
  }

  Future<void> _search(String pattern, {required bool autoAddSingleMatch}) async {
    final requestId = ++_requestId;
    setState(() {
      _searching = true;
      _searchedEmpty = false;
    });
    final results = await ref.read(
      productLookupControllerProvider(pattern, warehouse: widget.warehouse).future,
    );
    if (!mounted || requestId != _requestId) return;
    if (autoAddSingleMatch && results.length == 1) {
      _select(results.first);
      return;
    }
    setState(() {
      _searching = false;
      _results = results;
      _searchedEmpty = results.isEmpty;
    });
  }

  void _select(ProductLookupResult result) {
    widget.onProductSelected(result);
    _controller.clear();
    setState(() {
      _results = const [];
      _searching = false;
      _searchedEmpty = false;
    });
    _focusNode.requestFocus();
  }

  void _clearResults() {
    setState(() {
      _results = const [];
      _searchedEmpty = false;
    });
  }

  /// The theme's own input borders, re-shaped as pills — the mock draws this
  /// field as a stadium (`border-radius:30` on a 60 px box, i.e. fully
  /// rounded), which is `Shapes.full`'s intent. That token is a `ShapeBorder`
  /// and `InputDecoration` takes an `InputBorder`, so the radius is applied by
  /// `copyWith` on whatever the theme already resolved: every colour and width
  /// still comes from `inputDecorationTheme`, and only the corners change.
  InputBorder? _pill(InputBorder? source) => source is OutlineInputBorder
      ? source.copyWith(borderRadius: BorderRadius.circular(_pillRadius))
      : source;

  /// Larger than any box this field is drawn at, so the corners always
  /// resolve to a full stadium rather than to a fixed radius that would read
  /// as "very rounded" at one height and as a pill at another.
  static const _pillRadius = 999.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape &&
                _results.isNotEmpty) {
              _clearResults();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: l10n.posProductSearchLabel,
              prefixIcon: const Icon(Icons.qr_code_scanner),
              // Four more on every side than the theme's own field insets —
              // this one is the surface a cashier scans into all day, and the
              // mock gives it a 60 px box against the 52 px the line fields
              // get. 20 horizontal is the mock's own value.
              contentPadding: EdgeInsets.symmetric(
                horizontal: theme.spacing.md + theme.spacing.xxs,
                vertical: theme.spacing.sm + theme.spacing.xxs,
              ),
              border: _pill(inputTheme.border),
              enabledBorder: _pill(inputTheme.enabledBorder),
              focusedBorder: _pill(inputTheme.focusedBorder),
              disabledBorder: _pill(inputTheme.disabledBorder),
              errorBorder: _pill(inputTheme.errorBorder),
              focusedErrorBorder: _pill(inputTheme.focusedErrorBorder),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: _onSubmitted,
          ),
        ),
        if (_searchedEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.posProductSearchNoResults),
          ),
        if (_results.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return ListTile(
                    // The looked-up product's own photo (mbe-api#157) — the
                    // same leading thumbnail `CatalogEntityPicker` gives a
                    // product candidate, and no extra call to get it.
                    leading: ProductPhoto(photoUrl: result.photo, size: 40),
                    title: Text('${result.code} — ${result.name}'),
                    subtitle: Text(result.brand ?? ''),
                    trailing: Text(result.price),
                    onTap: () => _select(result),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
