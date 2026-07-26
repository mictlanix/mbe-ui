import 'package:flutter/material.dart';

/// A search field that applies only on explicit submission — Enter key or
/// the trailing search button — never on every keystroke (constitution
/// §VI; FR-010). Deliberately exposes no `onChanged` parameter, so a
/// caller has no way to wire per-keystroke filtering by mistake
/// (research.md §3).
class CatalogSearchBar extends StatefulWidget {
  const CatalogSearchBar({
    super.key,
    required this.label,
    required this.onSubmitted,
    this.searchTooltip,
    this.initialValue = '',
  });

  final String label;
  final ValueChanged<String> onSubmitted;
  final String? searchTooltip;
  final String initialValue;

  @override
  State<CatalogSearchBar> createState() => _CatalogSearchBarState();
}

class _CatalogSearchBarState extends State<CatalogSearchBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void didUpdateWidget(covariant CatalogSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keeps the box in sync when `initialValue` changes out from under an
    // already-mounted state (017-ui-consistency-filters FR-018) — e.g. a
    // list screen's own widget is rebuilt with a new value decoded from the
    // URL (browser Back, a shared link, "clear filters") while this stable-
    // keyed child survives the rebuild. Guarded so it never clobbers text
    // the user is mid-typing for an unrelated reason.
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => widget.onSubmitted(_controller.text);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          tooltip: widget.searchTooltip,
          onPressed: _submit,
        ),
      ),
      onSubmitted: (_) => _submit(),
      textInputAction: TextInputAction.search,
    );
  }
}
