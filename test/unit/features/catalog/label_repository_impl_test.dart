import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('LabelRepositoryImpl.list (picker/filter projection)', () {
    test('200 returns lightweight LabelItems, sorted by name', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              _labelJson(id: 2, name: 'Zeta'),
              _labelJson(id: 1, name: 'Alpha'),
            ],
            'total': 2,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.items.map((l) => l.name), ['Alpha', 'Zeta']);
    });
  });

  group('LabelRepositoryImpl.listDetailed (catalog list projection)', () {
    test('200 returns full Label entities including comment', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_labelJson(id: 1, name: 'Clearance', comment: 'Sale')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.listDetailed();

      expect(result.items.single.comment, 'Sale');
    });
  });

  group('LabelRepositoryImpl.get', () {
    test('200 maps to a Label', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_labelJson(id: 1, name: 'Clearance')),
          200,
          headers: _jsonHeaders,
        ),
      );

      final label = await repository.get(labelId: 1);

      expect(label.labelId, 1);
      expect(label.name, 'Clearance');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Label not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(labelId: 999),
        throwsA(const AppError.notFound('Label not found')),
      );
    });
  });

  group('LabelRepositoryImpl.create', () {
    test('201 returns the created Label', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_labelJson(id: 1, name: 'Featured')),
          201,
          headers: _jsonHeaders,
        ),
      );

      final label = await repository.create(name: 'Featured');

      expect(label.name, 'Featured');
    });

    test('422 duplicate name maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'name'],
                'msg': 'Name already in use',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(name: 'Featured'),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('LabelRepositoryImpl.update', () {
    test('200 returns the updated Label', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_labelJson(id: 1, name: 'Featured Updated')),
          200,
          headers: _jsonHeaders,
        ),
      );

      final label = await repository.update(
        labelId: 1,
        name: 'Featured Updated',
      );

      expect(label.name, 'Featured Updated');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Label not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(labelId: 999, name: 'Anything'),
        throwsA(const AppError.notFound('Label not found')),
      );
    });
  });

  group('LabelRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(labelId: 1), completes);
    });

    test(
      'a still-assigned rejection surfaces the server message (spec Edge Cases)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({'detail': 'Label is assigned to a product'}),
            400,
            headers: _jsonHeaders,
          ),
        );

        await expectLater(
          () => repository.delete(labelId: 1),
          throwsA(
            const AppError.server(
              statusCode: 400,
              message: 'Label is assigned to a product',
            ),
          ),
        );
      },
    );
  });

  group('allLabelsProvider', () {
    test('reflects a repository change after invalidation (FR-014)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_labelJson(id: 1, name: 'Original')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );
      final container = ProviderContainer(
        overrides: [labelRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final first = await container.read(allLabelsProvider.future);
      expect(first.single.name, 'Original');

      final updatedRepository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_labelJson(id: 1, name: 'Renamed')],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );
      container.updateOverrides([
        labelRepositoryProvider.overrideWithValue(updatedRepository),
      ]);
      container.invalidate(allLabelsProvider);

      final second = await container.read(allLabelsProvider.future);
      expect(second.single.name, 'Renamed');
    });
  });
}

Map<String, Object?> _labelJson({
  required int id,
  required String name,
  String? comment,
}) => {'label_id': id, 'name': name, 'comment': comment};

LabelRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return LabelRepositoryImpl(dio);
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => _handler(options);

  @override
  void close({bool force = false}) {}
}
