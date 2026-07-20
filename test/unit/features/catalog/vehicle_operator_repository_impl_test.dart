import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('VehicleOperatorRepositoryImpl.list', () {
    test('maps the pre-expanded driver EmployeeResponse to driverId/driverName '
        'and passes daysUntilExpiry through', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_operatorJson(id: 1, driverId: 7, daysUntilExpiry: 30)],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      final op = result.items.single;
      expect(op.driverId, 7);
      expect(op.driverName, 'Jane Doe');
      expect(op.daysUntilExpiry, 30);
    });

    test('forwards search and driverId (employee) query params', () async {
      String? capturedSearch;
      String? capturedEmployee;
      final repository = _repositoryWith((options) async {
        capturedSearch = options.queryParameters['search'] as String?;
        capturedEmployee = options.queryParameters['employee']?.toString();
        return ResponseBody.fromString(
          jsonEncode({'items': [], 'total': 0}),
          200,
          headers: _jsonHeaders,
        );
      });

      await repository.list(search: 'Jane', driverId: 7);

      expect(capturedSearch, 'Jane');
      expect(capturedEmployee, '7');
    });
  });

  group('VehicleOperatorRepositoryImpl.get', () {
    test('maps Date fields to DateTime', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_operatorJson(id: 1, driverId: 7)),
          200,
          headers: _jsonHeaders,
        ),
      );

      final op = await repository.get(vehicleOperatorId: 1);

      expect(op.issueDate, DateTime(2026, 1, 1));
      expect(op.expirationDate, DateTime(2027, 1, 1));
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Vehicle operator not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(vehicleOperatorId: 999),
        throwsA(const AppError.notFound('Vehicle operator not found')),
      );
    });
  });

  group('VehicleOperatorRepositoryImpl.create', () {
    test('sends DateTime as a Date (year/month/day) on write', () async {
      dynamic capturedBody;
      final repository = _repositoryWith((options) async {
        capturedBody = options.data;
        return ResponseBody.fromString(
          jsonEncode(_operatorJson(id: 1, driverId: 7)),
          201,
          headers: _jsonHeaders,
        );
      });

      await repository.create(
        driverId: 7,
        licenseType: 'A',
        driverLicenseNumber: 'LN-1',
        issueDate: DateTime(2026, 3, 15),
        expirationDate: DateTime(2030, 3, 15),
        issuingLocation: 'CDMX',
      );

      final sentBody = capturedBody is String
          ? jsonDecode(capturedBody as String) as Map<String, dynamic>
          : capturedBody as Map<String, dynamic>;
      expect(sentBody['issue_date'], '2026-03-15');
      expect(sentBody['expiration_date'], '2030-03-15');
    });

    test('422 maps to AppError.validation', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': [
              {
                'loc': ['body', 'driver'],
                'msg': 'Driver not found',
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
          driverId: 999,
          licenseType: 'A',
          driverLicenseNumber: 'LN-1',
          issueDate: DateTime(2026, 3, 15),
          expirationDate: DateTime(2030, 3, 15),
          issuingLocation: 'CDMX',
        ),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('VehicleOperatorRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(vehicleOperatorId: 1), completes);
    });

    test('a still-referenced rejection surfaces the server message', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'detail': 'Vehicle operator is referenced by a service order',
          }),
          400,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.delete(vehicleOperatorId: 1),
        throwsA(
          const AppError.server(
            statusCode: 400,
            message: 'Vehicle operator is referenced by a service order',
          ),
        ),
      );
    });
  });
}

Map<String, Object?> _operatorJson({
  required int id,
  required int driverId,
  int? daysUntilExpiry,
}) => {
  'vehicle_operator_id': id,
  'driver': {
    'employee_id': driverId,
    'first_name': 'Jane',
    'last_name': 'Doe',
    'nickname': 'Janie',
    'gender': 0,
    'birthday': '1990-01-01',
    'start_job_date': '2020-01-01',
    'sales_person': false,
    'active': true,
  },
  'license_type': 'A',
  'driver_license_number': 'LN-1',
  'issue_date': '2026-01-01',
  'expiration_date': '2027-01-01',
  'issuing_location': 'CDMX',
  'creation_time': '2026-01-01T00:00:00Z',
  'modification_time': '2026-01-01T00:00:00Z',
  'creator': {
    'employee_id': 1,
    'first_name': 'Admin',
    'last_name': 'User',
    'nickname': 'Admin',
    'gender': 0,
    'birthday': '1990-01-01',
    'start_job_date': '2020-01-01',
    'sales_person': false,
    'active': true,
  },
  'updater': {
    'employee_id': 1,
    'first_name': 'Admin',
    'last_name': 'User',
    'nickname': 'Admin',
    'gender': 0,
    'birthday': '1990-01-01',
    'start_job_date': '2020-01-01',
    'sales_person': false,
    'active': true,
  },
  'active': true,
  'days_until_expiry': daysUntilExpiry,
};

VehicleOperatorRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return VehicleOperatorRepositoryImpl(dio);
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
