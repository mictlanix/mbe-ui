import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_page_viewer.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_controller.dart';
import 'package:mbe_ui/core/documents/presentation/document_zoom.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The widest the dialog gets on a desktop or tablet; wider windows leave the
/// caller visible, dimmed, around it.
const double _maxDialogWidth = 960;

/// The shared document preview (spec 044 FR-010–FR-013): a modal dialog over
/// the caller, filling the screen on a phone. Opened through
/// `DocumentActions.preview`, never directly.
///
/// A title bar, the zoomable pages, and an action bar with the zoom controls,
/// the page in view, and Descargar / Imprimir. It shows loading and error
/// states in the same frame, so a failure never leaves a blank dialog.
class DocumentPreviewDialog extends ConsumerStatefulWidget {
  const DocumentPreviewDialog({super.key, required this.document});

  final DocumentRef document;

  @override
  ConsumerState<DocumentPreviewDialog> createState() =>
      _DocumentPreviewDialogState();
}

class _DocumentPreviewDialogState extends ConsumerState<DocumentPreviewDialog> {
  final DocumentViewController _view = DocumentViewController();

  /// Print or download in progress (disables both, so a double press does
  /// not open two print dialogs).
  bool _busy = false;

  /// A print or download failure, shown above the action bar while the
  /// document stays on screen.
  AppError? _actionError;

  @override
  void dispose() {
    _view.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function(DocumentOutput output) action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _actionError = null;
    });
    try {
      await action(ref.read(documentOutputProvider));
    } catch (e) {
      if (mounted) {
        setState(
          () => _actionError = e is AppError ? e : const AppError.server(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final compact = LayoutBreakpoints.isCompact(context);
    final preview = ref.watch(
      documentPreviewControllerProvider(widget.document),
    );
    final data = preview.valueOrNull;

    final body = Column(
      key: const Key('document_preview_surface'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TitleBar(title: widget.document.title, compact: compact),
        const Divider(height: 1),
        Expanded(child: _pageArea(preview)),
        if (_actionError != null)
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, 0),
            child: ErrorBanner(
              error: _actionError!,
              onDismiss: () => setState(() => _actionError = null),
            ),
          ),
        const Divider(height: 1),
        _ActionBar(
          view: _view,
          pageCount: data?.pages.length,
          busy: _busy,
          onPrint: data == null
              ? null
              : () => _run((output) => output.print(data.document)),
          onDownload: data == null
              ? null
              : () => _run((output) => output.save(data.document)),
        ),
      ],
    );

    if (compact) return Dialog.fullscreen(child: body);

    final screen = MediaQuery.sizeOf(context);
    return Dialog(
      child: SizedBox(
        width: math.min(_maxDialogWidth, screen.width - 80),
        // Dialog's own vertical inset is 24 on each side.
        height: math.min(screen.height - 48, screen.height * 0.9),
        child: body,
      ),
    );
  }

  Widget _pageArea(AsyncValue<DocumentPreviewData> preview) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return preview.when(
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: spacing.md),
            Text(l10n.documentLoadingMessage),
          ],
        ),
      ),
      error: (error, _) => SingleChildScrollView(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.documentLoadFailedError),
            SizedBox(height: spacing.xxs),
            ErrorBanner(
              error: error is AppError ? error : const AppError.server(),
            ),
            SizedBox(height: spacing.sm),
            TextButton(
              key: const Key('document_preview_retry'),
              onPressed: () => ref.invalidate(
                documentPreviewControllerProvider(widget.document),
              ),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
      data: (data) => DocumentPageViewer(
        key: const Key('document_preview_pages'),
        pages: data.pages,
        controller: _view,
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.title, required this.compact});

  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final close = IconButton(
      key: const Key('document_preview_close'),
      icon: const Icon(Icons.close),
      tooltip: l10n.documentCloseTooltip,
      onPressed: () => Navigator.of(context).pop(),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.sm,
        vertical: theme.spacing.xs,
      ),
      child: Row(
        children: [
          if (compact) close,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.xs),
              child: Text(
                title,
                key: const Key('document_preview_title'),
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (!compact) close,
        ],
      ),
    );
  }
}

/// Zoom controls, the page in view, and the two actions.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.view,
    required this.pageCount,
    required this.busy,
    required this.onPrint,
    required this.onDownload,
  });

  final DocumentViewController view;

  /// `null` until the document has loaded.
  final int? pageCount;
  final bool busy;
  final VoidCallback? onPrint;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final loaded = pageCount != null;

    // One style for every piece of text in the band, so they share a baseline.
    final textStyle = theme.textTheme.labelLarge;

    final zoom = ListenableBuilder(
      listenable: view,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const Key('document_zoom_out'),
            icon: const Icon(Icons.remove),
            tooltip: l10n.documentZoomOutTooltip,
            onPressed: loaded && view.canZoomOut ? view.zoomOut : null,
          ),
          // A minimum width, not a fixed one, and never wrapped: a wider
          // font (or text scale) must not turn the readout into two lines.
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: spacing.xxl),
            child: Text(
              loaded ? zoomLabel(view.scale) : '–',
              key: const Key('document_zoom_level'),
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: textStyle,
            ),
          ),
          IconButton(
            key: const Key('document_zoom_in'),
            icon: const Icon(Icons.add),
            tooltip: l10n.documentZoomInTooltip,
            onPressed: loaded && view.canZoomIn ? view.zoomIn : null,
          ),
          IconButton(
            key: const Key('document_zoom_fit'),
            icon: const Icon(Icons.fit_screen_outlined),
            tooltip: l10n.documentZoomFitTooltip,
            onPressed: loaded ? view.fit : null,
          ),
        ],
      ),
    );

    final indicator = ListenableBuilder(
      listenable: view,
      builder: (context, _) => Text(
        l10n.documentPageIndicator(
          loaded ? '${view.pageIndex + 1}' : '–',
          loaded ? '$pageCount' : '–',
        ),
        key: const Key('document_page_indicator'),
        style: textStyle,
      ),
    );

    final download = OutlinedButton.icon(
      key: const Key('document_download'),
      onPressed: busy ? null : onDownload,
      icon: const Icon(Icons.download_outlined),
      label: Text(l10n.documentDownloadAction),
    );
    final print = FilledButton.icon(
      key: const Key('document_print'),
      onPressed: busy ? null : onPrint,
      icon: const Icon(Icons.print_outlined),
      label: Text(l10n.documentPrintAction),
    );

    return Padding(
      key: const Key('document_action_bar'),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      // One band when there is room. When there is not (a phone, a large
      // text scale, a narrow tablet) it wraps, rather than overflowing:
      // zoom and the page in view first, then the two actions.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing.sm,
        runSpacing: spacing.xs,
        children: [
          zoom,
          indicator,
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: [download, print],
          ),
        ],
      ),
    );
  }
}
