import 'dart:typed_data';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

import 'document_kind.dart';

/// An immutable request for one document (spec 044 data-model.md).
///
/// Equality is by value so it can key a provider family.
@immutable
class DocumentRef {
  const DocumentRef({
    required this.kind,
    required this.recordId,
    required this.title,
  }) : assert(recordId > 0, 'recordId must be a real record id');

  final DocumentKind kind;

  /// A sales order id for [DocumentKind.saleTicket] and
  /// [DocumentKind.salesOrder]; a cash session id for [DocumentKind.cashCut].
  final int recordId;

  /// The localized preview title, built by the call site.
  final String title;

  @override
  bool operator ==(Object other) =>
      other is DocumentRef &&
      other.kind == kind &&
      other.recordId == recordId &&
      other.title == title;

  @override
  int get hashCode => Object.hash(kind, recordId, title);

  @override
  String toString() => 'DocumentRef($kind, $recordId, "$title")';
}

/// The bytes mbe-api returned, exactly as returned (FR-020, FR-021).
///
/// Held only while a preview is open or a print is running; never stored or
/// cached across opens (FR-022).
@immutable
class RenderedDocument {
  const RenderedDocument({required this.bytes, required this.filename});

  final Uint8List bytes;

  /// From the response's `Content-Disposition`, or the kind's fallback.
  final String filename;
}

/// One rasterized page. [size] is the page's size in PDF points (1/72 inch), not
/// in raster pixels: it sets the aspect ratio the preview draws, and how wide a
/// page that is narrower than the preview (a 72 mm ticket) is shown (FR-011).
@immutable
class DocumentPage {
  const DocumentPage({required this.image, required this.size});

  final ImageProvider image;
  final Size size;
}
