import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';

/// A generic single-select search-as-you-type picker for form fields backed
/// by paginated server-side search (data-model.md `CatalogEntityPicker<T>`,
/// plan.md — no new pub deps, uses Flutter's built-in [Autocomplete]).
///
/// Calls [optionsBuilder] with a debounce (`inputDebounceProvider`, spec 036
/// FR-028/FR-029, default 300 ms) on each text change.
/// When [enabled] is false, renders a read-only [TextFormField] showing
/// [initialDisplayText] with no dropdown.
///
/// When either [optionImageUrl] or [optionSubtitle] is provided
/// (specs/008-merge-products contracts/ui-contracts.md §1), suggestion rows
/// render as a `ListTile` with a leading thumbnail and a secondary line,
/// instead of the default text-only option. Existing callers that pass
/// neither (the supplier and SAT-catalog pickers) are unaffected.
class CatalogEntityPicker<T extends Object> extends ConsumerStatefulWidget {
  const CatalogEntityPicker({
    super.key,
    required this.label,
    required this.displayStringForOption,
    required this.optionsBuilder,
    required this.onSelected,
    this.initialDisplayText,
    this.errorText,
    this.enabled = true,
    this.optionImageUrl,
    this.optionSubtitle,
    this.autofocus = false,
  });

  final String label;
  final String Function(T) displayStringForOption;
  final Future<Iterable<T>> Function(String query) optionsBuilder;
  final ValueChanged<T> onSelected;
  final String? initialDisplayText;
  final String? errorText;
  final bool enabled;

  /// Requests focus as soon as the field is mounted — for a picker that
  /// replaces other content in place (e.g. the POS customer band's search
  /// face, spec 023 FR-023) and should take the keyboard immediately rather
  /// than waiting for a tap.
  final bool autofocus;

  /// Leading thumbnail URL for a suggestion row, or `null` for that item's
  /// placeholder. `null` (the default) keeps the default text-only option
  /// rendering unless [optionSubtitle] is set.
  final String? Function(T)? optionImageUrl;

  /// Secondary line under [displayStringForOption] in a suggestion row.
  /// `null` (the default) keeps the default text-only option rendering
  /// unless [optionImageUrl] is set.
  final String? Function(T)? optionSubtitle;

  @override
  ConsumerState<CatalogEntityPicker<T>> createState() =>
      _CatalogEntityPickerState<T>();
}

class _CatalogEntityPickerState<T extends Object>
    extends ConsumerState<CatalogEntityPicker<T>> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      // Keyed on the resolved text: a plain `TextFormField.initialValue`
      // (like `Autocomplete.initialValue` below) only ever seeds on first
      // mount, so a value that arrives *after* this widget is already on
      // screen — a cold-loaded record's display name resolving, or a
      // shared list URL's facet id resolving to a label
      // (017-ui-consistency-filters data-model.md §4) — would otherwise be
      // silently dropped. Forcing a remount when the value actually changes
      // re-seeds it; this generalizes the `ValueKey(formState.isEdit)`
      // workaround already used ad hoc in a couple of detail screens.
      return TextFormField(
        key: ValueKey('ro-${widget.initialDisplayText}'),
        initialValue: widget.initialDisplayText ?? '',
        decoration: InputDecoration(labelText: widget.label),
        enabled: false,
      );
    }

    return Autocomplete<T>(
      key: ValueKey('rw-${widget.initialDisplayText}'),
      initialValue: TextEditingValue(text: widget.initialDisplayText ?? ''),
      displayStringForOption: widget.displayStringForOption,
      optionsBuilder: (textEditingValue) {
        // Return a future via a completer so the debounce can cancel it.
        final completer = Completer<Iterable<T>>();
        _debounce?.cancel();
        _debounce = Timer(ref.read(inputDebounceProvider), () async {
          if (!completer.isCompleted) {
            try {
              final results = await widget.optionsBuilder(
                textEditingValue.text,
              );
              if (!completer.isCompleted) completer.complete(results);
            } catch (_) {
              if (!completer.isCompleted) completer.complete(const []);
            }
          }
        });
        return completer.future;
      },
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: widget.autofocus,
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: widget.errorText,
          ),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder:
          (widget.optionImageUrl == null && widget.optionSubtitle == null)
          ? null
          : (context, onSelected, options) => _RichOptionsView<T>(
              options: options,
              onSelected: onSelected,
              displayStringForOption: widget.displayStringForOption,
              optionImageUrl: widget.optionImageUrl,
              optionSubtitle: widget.optionSubtitle,
            ),
    );
  }
}

/// The suggestion list rendered when [CatalogEntityPicker.optionImageUrl] or
/// [CatalogEntityPicker.optionSubtitle] is set — mirrors the size/elevation
/// of Flutter's own default `Autocomplete` options view
/// (`_AutocompleteOptions` in `autocomplete.dart`), swapping each row for a
/// `ListTile` with a leading thumbnail and a secondary line.
class _RichOptionsView<T extends Object> extends StatelessWidget {
  const _RichOptionsView({
    required this.options,
    required this.onSelected,
    required this.displayStringForOption,
    required this.optionImageUrl,
    required this.optionSubtitle,
  });

  final Iterable<T> options;
  final AutocompleteOnSelected<T> onSelected;
  final String Function(T) displayStringForOption;
  final String? Function(T)? optionImageUrl;
  final String? Function(T)? optionSubtitle;

  @override
  Widget build(BuildContext context) {
    final list = options.toList(growable: false);
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              final option = list[index];
              return ListTile(
                leading: ProductPhoto(
                  photoUrl: optionImageUrl?.call(option),
                  size: 40,
                ),
                title: Text(displayStringForOption(option)),
                subtitle: switch (optionSubtitle?.call(option)) {
                  final subtitle? when subtitle.isNotEmpty => Text(subtitle),
                  _ => null,
                },
                onTap: () => onSelected(option),
              );
            },
          ),
        ),
      ),
    );
  }
}
