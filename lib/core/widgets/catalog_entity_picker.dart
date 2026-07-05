import 'dart:async';

import 'package:flutter/material.dart';

/// A generic single-select search-as-you-type picker for form fields backed
/// by paginated server-side search (data-model.md `CatalogEntityPicker<T>`,
/// plan.md — no new pub deps, uses Flutter's built-in [Autocomplete]).
///
/// Calls [optionsBuilder] with a 300 ms debounce on each text change.
/// When [enabled] is false, renders a read-only [TextFormField] showing
/// [initialDisplayText] with no dropdown.
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
  });

  final String label;
  final String Function(T) displayStringForOption;
  final Future<Iterable<T>> Function(String query) optionsBuilder;
  final ValueChanged<T> onSelected;
  final String? initialDisplayText;
  final String? errorText;
  final bool enabled;

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
    );
  }
}
