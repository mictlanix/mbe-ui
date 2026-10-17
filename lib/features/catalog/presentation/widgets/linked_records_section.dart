import 'package:flutter/material.dart';

import 'package:mbe_ui/core/design/design_theme_extensions.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// One customer-form section listing the records of one kind (addresses,
/// contacts or taxpayer recipients) linked to the customer
/// (046-catalog-improvements FR-001..FR-004, contracts C1).
///
/// The section performs no I/O: it shows [items], and reports links and
/// unlinks through [onLinked] / [onUnlinked]. The caller keeps the list in
/// its form state, so nothing reaches the server until the form is saved
/// (FR-005). Linked records are shared, so there is no edit action
/// (FR-009) and unlinking never deletes the record (FR-004).
class LinkedRecordsSection<T extends Object> extends StatefulWidget {
  const LinkedRecordsSection({
    super.key,
    required this.sectionId,
    required this.title,
    required this.items,
    required this.idOf,
    required this.labelOf,
    required this.editable,
    required this.emptyText,
    this.subtitleOf,
    this.statusOf,
    this.searchExisting,
    this.searchLabel,
    this.onLinked,
    this.onUnlinked,
    this.onCreateNew,
  });

  /// A stable, untranslated name for this section (`addresses`, …), used to
  /// build its controls' keys.
  final String sectionId;
  final String title;
  final List<T> items;

  /// Identifies a record, for de-duplication and row keys.
  final Object Function(T) idOf;
  final String Function(T) labelOf;
  final String? Function(T)? subtitleOf;

  /// The record's status, when its kind has one. Non-active records show
  /// the shared status chip.
  final EntityStatus Function(T)? statusOf;

  /// `false` renders the list only — no unlink, link or create controls.
  final bool editable;
  final String emptyText;

  /// Search for records to link. `null` hides the picker (for example, when
  /// the user may not read records of this kind).
  final Future<Iterable<T>> Function(String query)? searchExisting;
  final String? searchLabel;
  final ValueChanged<T>? onLinked;
  final ValueChanged<T>? onUnlinked;

  /// Creates a record and resolves to it, or to `null` when cancelled. `null`
  /// hides the "New" button (for example, without the create privilege).
  final Future<T?> Function()? onCreateNew;

  @override
  State<LinkedRecordsSection<T>> createState() =>
      _LinkedRecordsSectionState<T>();
}

class _LinkedRecordsSectionState<T extends Object>
    extends State<LinkedRecordsSection<T>> {
  /// Bumped after every link so the picker remounts with an empty field.
  int _pickerGeneration = 0;

  bool _isLinked(T candidate) {
    final id = widget.idOf(candidate);
    return widget.items.any((item) => widget.idOf(item) == id);
  }

  void _link(T record) {
    if (!_isLinked(record)) widget.onLinked?.call(record);
    setState(() => _pickerGeneration++);
  }

  Future<void> _createNew() async {
    final created = await widget.onCreateNew!();
    if (!mounted || created == null) return;
    _link(created);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final search = widget.editable ? widget.searchExisting : null;
    final createNew = widget.editable ? widget.onCreateNew : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.items.isEmpty
                    ? widget.title
                    : '${widget.title} (${widget.items.length})',
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (createNew != null)
              TextButton.icon(
                key: Key('linked_new_${widget.sectionId}'),
                onPressed: _createNew,
                icon: const Icon(Icons.add),
                label: Text(l10n.linkedRecordNewAction),
              ),
          ],
        ),
        if (widget.items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: Text(
              widget.emptyText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final item in widget.items) _row(context, item),
        if (search != null)
          Padding(
            padding: EdgeInsets.only(top: spacing.xs),
            child: CatalogEntityPicker<T>(
              key: ValueKey(
                'linked_picker_${widget.sectionId}_$_pickerGeneration',
              ),
              label: widget.searchLabel ?? widget.title,
              displayStringForOption: widget.labelOf,
              optionSubtitle: widget.subtitleOf,
              optionsBuilder: (query) async {
                final results = await search(query);
                return results.where((r) => !_isLinked(r));
              },
              onSelected: _link,
            ),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, T item) {
    final l10n = AppLocalizations.of(context)!;
    final id = widget.idOf(item);
    final subtitle = widget.subtitleOf?.call(item);
    final status = widget.statusOf?.call(item);

    return ListTile(
      key: ValueKey('linked_row_${widget.sectionId}_$id'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(widget.labelOf(item)),
      subtitle: subtitle == null || subtitle.isEmpty ? null : Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != null && status != EntityStatus.active)
            EntityStatusCell(status: status),
          if (widget.editable && widget.onUnlinked != null)
            IconButton(
              key: ValueKey('unlink_${widget.sectionId}_$id'),
              tooltip: l10n.linkedRecordUnlinkTooltip,
              icon: const Icon(Icons.link_off),
              onPressed: () => widget.onUnlinked!(item),
            ),
        ],
      ),
    );
  }
}
