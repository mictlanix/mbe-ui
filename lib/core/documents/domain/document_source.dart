import 'document_ref.dart';

/// Fetches the PDF mbe-api renders for a [DocumentRef].
///
/// Throws an `AppError` (`NotFoundError`, `ServerError` for 403/409/5xx,
/// `NetworkError`, `AuthError`) carrying the server's detail (FR-030).
abstract interface class DocumentSource {
  Future<RenderedDocument> fetch(DocumentRef ref);
}
