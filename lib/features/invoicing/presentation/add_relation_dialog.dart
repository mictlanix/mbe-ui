import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_actions.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_labels.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_refusal.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _pageSize = 20;

/// Adds a related document to draft [document] (spec 066 C12): a relation
/// type (04 substitution of a cancelled invoice, 07 application of an
/// advance) and a document of the same issuer and recipient to relate. The
/// type is locked to the one the invoice already has, since an invoice has
/// one relation type.
///
/// The picker lists cancelled documents for 04 and issued ones for 07, with
/// the search prefilled with the recipient's RFC. `relation_not_allowed`,
/// `already_related` and `relation_types_mixed` stay inline so another
/// document can be picked; any other refusal closes the dialog and is
/// answered to the caller. `null` when the user backed out.
Future<FiscalDocumentActionResult?> showAddInvoiceRelationDialog(
  BuildContext context, {
  required FiscalDocument document,
}) => showResponsiveDialog<FiscalDocumentActionResult>(
  context,
  builder: (_) => _AddRelationDialog(document: document),
);

const _inlineCodes = {
  api.ErrorCode.fiscalDocumentPeriodRelationNotAllowed,
  api.ErrorCode.fiscalDocumentPeriodAlreadyRelated,
  api.ErrorCode.fiscalDocumentPeriodRelationTypesMixed,
};

class _AddRelationDialog extends ConsumerStatefulWidget {
  const _AddRelationDialog({required this.document});

  final FiscalDocument document;

  @override
  ConsumerState<_AddRelationDialog> createState() => _AddRelationDialogState();
}

class _AddRelationDialogState extends ConsumerState<_AddRelationDialog> {
  late InvoiceRelationType _type =
      widget.document.relationType ?? InvoiceRelationType.substitution;
  late final _search = TextEditingController(
    text: widget.document.summary.recipientRfc ?? '',
  );
  Timer? _debounce;
  int _request = 0;
  List<FiscalDocumentSummary>? _documents;
  int _total = 0;
  bool _loadingMore = false;
  AppError? _loadError;

  bool _busy = false;
  AppError? _refusal;

  FiscalDocument get _doc => widget.document;

  /// Locked to the type the invoice already has, if it has one.
  bool get _typeLocked => _doc.relationType != null;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
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
        _documents = null;
      }
    });
    final search = _search.text.trim();
    try {
      final page = await ref
          .read(fiscalDocumentRepositoryProvider)
          .list(
            search: search.isEmpty ? null : search,
            issuer: _doc.summary.issuerRfc,
            status: _type == InvoiceRelationType.substitution
                ? FiscalDocumentStatus.cancelled
                : FiscalDocumentStatus.issued,
            skip: more ? _documents?.length ?? 0 : 0,
            limit: _pageSize,
          );
      if (!mounted || request != _request) return;
      setState(() {
        _documents = [if (more) ...?_documents, ...page.items];
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

  Future<void> _add(FiscalDocumentSummary target) async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final error = await ref
        .read(fiscalDocumentActionsProvider.notifier)
        .addRelation(_doc.id, target.id, _type);
    if (!mounted) return;
    if (error != null && _inlineCodes.contains(error.problem?.code)) {
      setState(() {
        _busy = false;
        _refusal = error;
      });
      return;
    }
    navigator.pop((error: error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final documents = _documents;

    final Widget list;
    if (_loadError != null) {
      list = ListFailedView(
        error: _loadError!,
        retryLabel: l10n.retryButton,
        onRetry: _load,
      );
    } else if (documents == null) {
      list = const Center(child: CircularProgressIndicator());
    } else if (documents.isEmpty) {
      list = KeyedSubtree(
        key: const Key('add_relation_empty'),
        child: ListEmptyView(message: l10n.fiscalDocumentRelationEmpty),
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
              key: Key('add_relation_row_${d.id}'),
              onTap: _busy ? null : () => _add(d),
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
          if (documents.length < _total)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('add_relation_load_more'),
                onPressed: _loadingMore ? null : () => _load(more: true),
                child: Text(l10n.fiscalDocumentAddOrderLoadMore),
              ),
            ),
        ],
      );
    }

    return ResponsiveDialog(
      key: const Key('add_relation_dialog'),
      title: l10n.fiscalDocumentAddRelationTitle,
      dismissible: !_busy,
      maxWidth: 720,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.fieldGapVertical,
        children: [
          DropdownButtonFormField<InvoiceRelationType>(
            key: const Key('add_relation_type'),
            initialValue: _type,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.fiscalDocumentRelationType,
            ),
            items: [
              for (final t in [
                InvoiceRelationType.substitution,
                InvoiceRelationType.advanceApplication,
              ])
                DropdownMenuItem(
                  value: t,
                  child: Text(invoiceRelationTypeLabel(l10n, t)),
                ),
            ],
            onChanged: _typeLocked || _busy
                ? null
                : (t) {
                    if (t == null || t == _type) return;
                    setState(() => _type = t);
                    unawaited(_load());
                  },
          ),
          TextField(
            key: const Key('add_relation_search'),
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
          if (_refusal != null) FiscalDocumentRefusal(error: _refusal!),
          list,
        ],
      ),
      // Picking a row is the action, so the only button closes the dialog.
      primaryAction: ResponsiveDialogAction(
        key: const Key('add_relation_close'),
        label: l10n.cancelButton,
        busy: _busy,
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
      ),
    );
  }
}
