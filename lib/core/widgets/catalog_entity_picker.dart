import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mbe_ui/core/widgets/product_photo.dart';

/// A generic single-select search-as-you-type picker for form fields backed
/// by paginated server-side search (data-model.md `CatalogEntityPicker<T>`,
/// plan.md — no new pub deps, uses Flutter's built-in [Autocomplete]).
///
/// Calls [optionsBuilder] with a 300 ms debounce on each text change.
/// When [enabled] is false, renders a read-only [TextFormField] showing
/// [initialDisplayText] with no dropdown.
///
/// When either [optionImageUrl] or [optionSubtitle] is provided
/// (specs/008-merge-products contracts/ui-contracts.md §1), suggestion rows
/// render as a `ListTile` with a leading thumbnail and a secondary line,
/// instead of the default text-only option. Existing callers that pass
/// neither (the supplier and SAT-catalog pickers) are unaffected.
class CatalogEntityPicker<T extends Object> extends StatefulWidget {
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
  });

  final String label;
  final String Function(T) displayStringForOption;
  final Future<Iterable<T>> Function(String query) optionsBuilder;
  final ValueChanged<T> onSelected;
  final String? initialDisplayText;
  final String? errorText;
  final bool enabled;

  /// Leading thumbnail URL for a suggestion row, or `null` for that item's
  /// placeholder. `null` (the default) keeps the default text-only option
  /// rendering unless [optionSubtitle] is set.
  final String? Function(T)? optionImageUrl;

  /// Secondary line under [displayStringForOption] in a suggestion row.
  /// `null` (the default) keeps the default text-only option rendering
  /// unless [optionImageUrl] is set.
  final String? Function(T)? optionSubtitle;

  @override
  State<CatalogEntityPicker<T>> createState() =>
      _CatalogEntityPickerState<T>();
}

class _CatalogEntityPickerState<T extends Object>
    extends State<CatalogEntityPicker<T>> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return TextFormField(
        initialValue: widget.initialDisplayText ?? '',
        decoration: InputDecoration(labelText: widget.label),
        enabled: false,
      );
    }

    return Autocomplete<T>(
      initialValue: TextEditingValue(text: widget.initialDisplayText ?? ''),
      displayStringForOption: widget.displayStringForOption,
      optionsBuilder: (textEditingValue) {
        // Return a future via a completer so the debounce can cancel it.
        final completer = Completer<Iterable<T>>();
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () async {
          if (!completer.isCompleted) {
            try {
              final results =
                  await widget.optionsBuilder(textEditingValue.text);
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
