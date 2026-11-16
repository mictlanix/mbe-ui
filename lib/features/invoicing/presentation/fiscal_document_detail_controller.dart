import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';

part 'fiscal_document_detail_controller.g.dart';

/// One fiscal document for its detail screen, keyed by id (spec 066 R5).
///
/// Writes go through `FiscalDocumentActions`, which invalidates this provider
/// so the screen refetches what the server now holds.
@riverpod
Future<FiscalDocument> fiscalDocumentDetail(Ref ref, int id) =>
    ref.watch(fiscalDocumentRepositoryProvider).getById(id);
