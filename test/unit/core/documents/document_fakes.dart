import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:flutter/painting.dart' show MemoryImage;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/documents/domain/document_source.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';

/// A 1×1 transparent PNG, for pages whose pixels do not matter.
final Uint8List kTinyPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
  0x00, 0x05, 0xFE, 0x02, 0xFE, 0xA7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// A document whose bytes start as a PDF does.
RenderedDocument fakeDocument({
  String filename = 'ticket-00000042.pdf',
  List<int> tail = const [1, 2, 3],
}) => RenderedDocument(
  bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, ...tail]),
  filename: filename,
);

DocumentPage fakePage({double width = 204, double height = 600}) =>
    DocumentPage(image: MemoryImage(kTinyPng), size: Size(width, height));

/// A `DocumentSource` that records its calls. [handler] decides each answer;
/// by default every fetch succeeds with [fakeDocument].
class FakeDocumentSource implements DocumentSource {
  FakeDocumentSource({this.handler});

  Future<RenderedDocument> Function(DocumentRef ref)? handler;
  final List<DocumentRef> fetched = [];

  @override
  Future<RenderedDocument> fetch(DocumentRef ref) {
    fetched.add(ref);
    return handler?.call(ref) ?? Future.value(fakeDocument());
  }
}

/// A `DocumentOutput` that records what it was asked to do.
class FakeDocumentOutput implements DocumentOutput {
  FakeDocumentOutput({List<DocumentPage>? pages, this.rasterHandler})
    : pages = pages ?? [fakePage()];

  List<DocumentPage> pages;
  Stream<DocumentPage> Function(RenderedDocument document)? rasterHandler;
  Future<void> Function(RenderedDocument document)? printHandler;

  final List<RenderedDocument> printed = [];
  final List<RenderedDocument> saved = [];
  final List<RenderedDocument> rastered = [];

  @override
  Future<void> print(RenderedDocument document) {
    printed.add(document);
    return printHandler?.call(document) ?? Future.value();
  }

  @override
  Future<void> save(RenderedDocument document) {
    saved.add(document);
    return Future.value();
  }

  @override
  Stream<DocumentPage> raster(RenderedDocument document) {
    rastered.add(document);
    return rasterHandler?.call(document) ?? Stream.fromIterable(pages);
  }
}

User _user(List<Privilege> privileges, {bool administrator = false}) => User(
  userId: 'tester',
  email: 'tester@example.com',
  administrator: administrator,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: privileges,
);

const _read = 2;

/// Reads sales orders but has no point-of-sale privilege.
final User salesOrdersReader = _user(const [
  Privilege(systemObject: SystemObject.salesOrders, rawValue: _read),
]);

/// Reads the point of sale but not sales orders.
final User posReader = _user(const [
  Privilege(systemObject: SystemObject.pos, rawValue: _read),
]);

/// Holds neither privilege.
final User noPrivileges = _user(const []);

/// Administrators pass every check.
final User administrator = _user(const [], administrator: true);

AccessControlService accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

/// A container wired with fakes, for a user holding [user]'s privileges.
ProviderContainer documentContainer({
  required User user,
  FakeDocumentSource? source,
  FakeDocumentOutput? output,
}) {
  final container = ProviderContainer(
    overrides: [
      accessControlProvider.overrideWithValue(accessFor(user)),
      documentSourceProvider.overrideWithValue(source ?? FakeDocumentSource()),
      documentOutputProvider.overrideWithValue(output ?? FakeDocumentOutput()),
    ],
  );
  return container;
}
