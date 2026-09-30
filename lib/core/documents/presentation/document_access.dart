import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/errors/app_error.dart';

/// Whether the current user may open [kind] — what call sites use to hide an
/// action (FR-040). The gates match what mbe-api enforces, so a button never
/// leads to a 403 for a user the client could have ruled out.
bool canOpenDocument(AccessControlService access, DocumentKind kind) =>
    access.can(kind.gateObject, kind.gateRight);

/// The re-check made immediately before a fetch (FR-041): a user without the
/// gate gets the same 403 the server would give, and no request is made.
void requireDocumentAccess(AccessControlService access, DocumentKind kind) {
  if (!canOpenDocument(access, kind)) {
    throw const AppError.server(
      statusCode: 403,
      message: 'Insufficient privileges',
    );
  }
}
