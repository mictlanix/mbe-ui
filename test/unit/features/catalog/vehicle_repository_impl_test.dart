import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('VehicleRepositoryImpl.list', () {
    test('200 maps to Vehicle entities', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [
              _vehicleJson(
                id: 1,
                plate: 'ABC-123',
                name: 'Freightliner',
                nickname: 'Big Red',
                tonsCapacity: 10,
                status: 0,
              ),
            ],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      final vehicle = result.items.single;
      expect(vehicle.licensePlate, 'ABC-123');
      expect(vehicle.tonsCapacity, 10);
      expect(vehicle.status, EntityStatus.active);
      expect(result.total, 1);
    });

    test('forwards the search query param', () async {
      String? capturedSearch;
      final repository = _repositoryWith((options) async {
        capturedSearch = options.queryParameters['search'] as String?;
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(search: 'ABC-123');

      expect(capturedSearch, 'ABC-123');
    });
  });

  group('VehicleRepositoryImpl.get', () {
    test('200 maps to a Vehicle', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_vehicleJson(id: 1, plate: 'ABC-123')),
          200,
          headers: _jsonHeaders,
        ),
      );

      final vehicle = await repository.get(vehicleId: 1);

      expect(vehicle.vehicleId, 1);
      expect(vehicle.licensePlate, 'ABC-123');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Vehicle not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(vehicleId: 999),
        throwsA(const AppError.notFound('Vehicle not found')),
      );
    });
  });

  group('VehicleRepositoryImpl.create', () {
    test('201 returns the created Vehicle with tonsCapacity as int', () async {
      dynamic capturedBody;
      final repository = _repositoryWith((options) async {
        capturedBody = options.data;
        return ResponseBody.fromString(
          jsonEncode(_vehicleJson(id: 1, plate: 'ABC-123', tonsCapacity: 5)),
          201,
          headers: _jsonHeaders,
        );
      });

      final vehicle = await repository.create(
        licensePlate: 'ABC-123',
        name: 'Freightliner',
        nickname: 'Big Red',
        tonsCapacity: 5,
      );

      expect(vehicle.tonsCapacity, 5);
      final sentBody = capturedBody is String
          ? jsonDecode(capturedBody as String) as Map<String, dynamic>
          : capturedBody as Map<String, dynamic>;
      expect(sentBody['tons_capacity'], 5);
      expect(sentBody['tons_capacity'], isA<int>());
    });

    test('422 duplicate plate maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'license_plate'],
                'msg': 'License plate already in use',
                'type': 'value_error',
              },
            ],
          }),
          422,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.create(
          licensePlate: 'ABC-123',
          name: 'Freightliner',
          nickname: 'Big Red',
          tonsCapacity: 5,
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('VehicleRepositoryImpl.update', () {
    test('200 returns the updated Vehicle', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_vehicleJson(id: 1, plate: 'ABC-123', status: 1)),
          200,
          headers: _jsonHeaders,
        ),
      );

      final vehicle = await repository.update(
        vehicleId: 1,
        status: EntityStatus.inactive,
      );

      expect(vehicle.status, EntityStatus.inactive);
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Vehicle not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(vehicleId: 999, name: 'Anything'),
        throwsA(const AppError.notFound('Vehicle not found')),
      );
    });
  });

  group('VehicleRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(vehicleId: 1), completes);
    });

    test('a still-referenced rejection surfaces the server message', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Vehicle is assigned to a route'}),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(vehicleId: 1),
        throwsA(
          const AppError.server(
            statusCode: 400,
            message: 'Vehicle is assigned to a route',
          ),
        ),
      );
    });
  });
}

Map<String, Object?> _vehicleJson({
  required int id,
  required String plate,
  String name = 'Freightliner',
  String nickname = 'Big Red',
  int tonsCapacity = 10,
  int status = 0,
}) => {
  'vehicle_id': id,
  'license_plate': plate,
  'name': name,
  'nickname': nickname,
  'tons_capacity': tonsCapacity,
  'status': status,
};

VehicleRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return VehicleRepositoryImpl(dio);
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
