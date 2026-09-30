import 'package:flutter/material.dart' show BuildContext, showDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/presentation/document_access.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';

export 'package:mbe_ui/core/documents/presentation/document_access.dart'
    show canOpenDocument;

final documentActionsProvider = Provider<DocumentActions>((ref) {
  return DocumentActions(ref);
});

/// The only entry points call sites use to print or preview a document
/// (spec 044 contracts/document-module.md).
///
/// Call sites depend on this and on `DocumentRef`, never on the `printing`
/// package or the generated APIs, so a future server-side "send to printer"
/// (FR-015) is a different `printDirect` behind the same call.
class DocumentActions {
  DocumentActions(this._ref);

  final Ref _ref;

  /// Documents being fetched and printed right now (FR-032, contract G1).
  final Set<DocumentRef> _printing = {};

  /// Documents whose preview dialog is open (FR-032).
  final Set<DocumentRef> _previewing = {};

  /// Opens the shared preview dialog for [ref] over [context] (FR-010) and
  /// completes when it is closed.
  ///
  /// A repeated call for a document whose preview is already open is ignored
  /// (FR-032). The gate is re-checked before anything is fetched (FR-041), by
  /// the dialog's own controller: a user without it sees the permission error
  /// in the dialog's error state, so this never throws and call sites need no
  /// error handling.
  Future<void> preview(BuildContext context, DocumentRef ref) async {
    if (!_previewing.add(ref)) return;
    try {
      await showDialog<void>(
        context: context,
        builder: (_) => DocumentPreviewDialog(document: ref),
      );
    } finally {
      _previewing.remove(ref);
    }
  }

  /// Fetches [ref] and opens the device print dialog with it, with no
  /// preview. Only the POS completion dialog uses this (FR-002).
  ///
  /// Re-checks the gate before touching the network (FR-041): a user without
  /// it gets the same 403 the server would give. A repeated call for the same
  /// document while one is in flight is ignored (FR-032). Throws [AppError]
  /// for the caller to show inline.
  Future<void> printDirect(DocumentRef ref) async {
    requireDocumentAccess(_ref.read(accessControlProvider), ref.kind);
    if (!_printing.add(ref)) return;
    try {
      final document = await _ref.read(documentSourceProvider).fetch(ref);
      await _ref.read(documentOutputProvider).print(document);
    } finally {
      _printing.remove(ref);
    }
  }
}
