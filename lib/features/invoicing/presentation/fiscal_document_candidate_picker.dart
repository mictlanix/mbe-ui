import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _pageSize = 20;

/// A searchable, paged list of other fiscal documents to pick one from (spec
/// 072 C22), shared by the add-relation dialog (spec 066 C12) and the cancel
/// dialog's replacement document (reason 01).
///
/// It lists documents of one [issuerRfc] in one [status], newest first. The
/// list API has no recipient filter, so the search starts as [initialSearch]
/// (the recipient's RFC), and a non-null [recipientRfc] also drops the rows of
/// another recipient that a name match let in. Rows are keyed
/// `<keyPrefix>_row_<id>`; the search box, the "load more" button and the empty
/// state are `<keyPrefix>_search`, `_load_more` and `_empty`.
class FiscalDocumentCandidatePicker extends ConsumerStatefulWidget {
  const FiscalDocumentCandidatePicker({
    super.key,
    required this.keyPrefix,
    required this.issuerRfc,
    required this.status,
    required this.emptyMessage,
    required this.onPicked,
    this.excludeId,
    this.initialSearch = '',
    this.recipientRfc,
    this.enabled = true,
    this.notice,
  });

  final String keyPrefix;
  final String issuerRfc;
  final FiscalDocumentStatus status;
  final String emptyMessage;

  /// The document being worked on, which can never be its own candidate.
  final int? excludeId;
  final String initialSearch;
  final String? recipientRfc;
  final ValueChanged<FiscalDocumentSummary> onPicked;

  /// `false` while the caller is busy: rows stop answering taps.
  final bool enabled;

  /// Shown between the search box and the list, e.g. a refusal for the last
  /// pick.
  final Widget? notice;

  @override
  ConsumerState<FiscalDocumentCandidatePicker> createState() =>
      _FiscalDocumentCandidatePickerState();
}

class _FiscalDocumentCandidatePickerState
    extends ConsumerState<FiscalDocumentCandidatePicker> {
  late final _search = TextEditingController(text: widget.initialSearch);
  Timer? _debounce;
  int _request = 0;

  /// What the server returned so far, before the row filters.
  List<FiscalDocumentSummary>? _fetched;
  int _total = 0;
  bool _loadingMore = false;
  AppError? _loadError;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(FiscalDocumentCandidatePicker old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status || old.issuerRfc != widget.issuerRfc) {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    final request = ++_request;
    setState(() {
      _loadError = null;
      if (more) {
        _loadingMore = true;
      } else {
        _fetched = null;
      }
    });
    final search = _search.text.trim();
    try {
      final page = await ref
          .read(fiscalDocumentRepositoryProvider)
          .list(
            search: search.isEmpty ? null : search,
            issuer: widget.issuerRfc,
            status: widget.status,
            skip: more ? _fetched?.length ?? 0 : 0,
            limit: _pageSize,
          );
      if (!mounted || request != _request) return;
      setState(() {
        _fetched = [if (more) ...?_fetched, ...page.items];
        _total = page.total;
        _loadingMore = false;
      });
    } on AppError catch (e) {
      if (!mounted || request != _request) return;
      setState(() {
        _loadError = e;
        _loadingMore = false;
      });
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(ref.read(inputDebounceProvider), _load);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final prefix = widget.keyPrefix;
    final fetched = _fetched;
    final documents = fetched
        ?.where(
          (d) =>
              d.id != widget.excludeId &&
              (widget.recipientRfc == null ||
                  d.recipientRfc == widget.recipientRfc),
        )
        .toList();

    final Widget list;
    if (_loadError != null) {
      list = ListFailedView(
        error: _loadError!,
        retryLabel: l10n.retryButton,
        onRetry: _load,
      );
    } else if (documents == null) {
      list = const Center(child: CircularProgressIndicator());
    } else if (documents.isEmpty && fetched!.length >= _total) {
      list = KeyedSubtree(
        key: Key('${prefix}_empty'),
        child: ListEmptyView(message: widget.emptyMessage),
      );
    } else {
      Widget row(List<Widget> cells, {TextStyle? style}) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.sm,
        ),
        child: DefaultTextStyle.merge(
          style: style,
          child: Row(
            spacing: spacing.md,
            children: [
              Expanded(child: cells[0]),
              Expanded(child: cells[1]),
              Expanded(flex: 2, child: cells[2]),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: cells[3],
                ),
              ),
            ],
          ),
        ),
      );
      list = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row([
            Text(l10n.fiscalDocumentColFolio),
            Text(l10n.fiscalDocumentColIssued),
            Text(l10n.fiscalDocumentFactUuid),
            Text(l10n.fiscalDocumentColTotal),
          ], style: theme.textTheme.labelMedium),
          const Divider(height: 1),
          for (final d in documents)
            InkWell(
              key: Key('${prefix}_row_${d.id}'),
              onTap: widget.enabled ? () => widget.onPicked(d) : null,
              child: row([
                Text(d.folioLabel ?? '#${d.id}'),
                Text(fmt.display.date(d.issued)),
                Text(
                  d.stampUuid ?? '—',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(fmt.display.currency(d.total?.toString())),
              ]),
            ),
          if (fetched!.length < _total)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: Key('${prefix}_load_more'),
                onPressed: _loadingMore ? null : () => _load(more: true),
                child: Text(l10n.fiscalDocumentAddOrderLoadMore),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        TextField(
          key: Key('${prefix}_search'),
          controller: _search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l10n.fiscalDocumentRelationSearch,
          ),
          onChanged: _searchChanged,
          onSubmitted: (_) {
            _debounce?.cancel();
            unawaited(_load());
          },
        ),
        ?widget.notice,
        list,
      ],
    );
  }
}
