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
    this.warehouseId,
  }) : assert(recordId > 0, 'recordId must be a real record id'),
       assert(
         warehouseId == null || warehouseId > 0,
         'warehouseId must be a real warehouse id',
       ),
       assert(
         warehouseId == null || kind == DocumentKind.deliveryTicket,
         'only a delivery ticket can be limited to a warehouse',
       );

  final DocumentKind kind;

  /// A sales order id for [DocumentKind.saleTicket] and
  /// [DocumentKind.salesOrder]; a cash session id for [DocumentKind.cashCut].
  final int recordId;

  /// The localized preview title, built by the call site.
  final String title;

  /// Limits a [DocumentKind.deliveryTicket] to the lines from this warehouse
  /// (spec 064 R2). Null prints every line. It is part of the identity: the
  /// tickets of one order for two warehouses are different documents.
  final int? warehouseId;

  @override
  bool operator ==(Object other) =>
      other is DocumentRef &&
      other.kind == kind &&
      other.recordId == recordId &&
      other.title == title &&
      other.warehouseId == warehouseId;

  @override
  int get hashCode => Object.hash(kind, recordId, title, warehouseId);

  @override
  String toString() =>
      'DocumentRef($kind, $recordId, "$title"'
      '${warehouseId == null ? '' : ', warehouse $warehouseId'})';
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
