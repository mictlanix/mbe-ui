import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/gender.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('EmployeeRepositoryImpl.list', () {
    test('200 returns lightweight EmployeeListItems', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({
            'items': [_employeeJson()],
            'total': 1,
          }),
          200,
          headers: _jsonHeaders,
        ),
      );

      final result = await repository.list();

      expect(result.total, 1);
      expect(result.items.single.employeeId, 1);
      expect(result.items.single.fullName, 'Jane Doe');
      expect(result.items.single.active, isTrue);
      expect(result.items.single.salesPerson, isTrue);
    });

    test(
      'forwards search/active/salesPerson/skip/limit as query params',
      () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode({'items': [], 'total': 0}),
            200,
            headers: _jsonHeaders,
          );
        });

        await repository.list(
          search: 'Jane',
          active: true,
          salesPerson: false,
          skip: 20,
          limit: 10,
        );

        expect(captured!.queryParameters['search'], 'Jane');
        expect(captured!.queryParameters['active'], true);
        expect(captured!.queryParameters['sales_person'], false);
        expect(captured!.queryParameters['skip'], 20);
        expect(captured!.queryParameters['limit'], 10);
      },
    );
  });

  group('EmployeeRepositoryImpl.get', () {
    test('200 maps Date fields to DateTime and int gender to Gender', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_employeeJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final employee = await repository.get(employeeId: 1);

      expect(employee.birthday, DateTime(1990, 5, 15));
      expect(employee.startJobDate, DateTime(2020, 1, 10));
      expect(employee.gender, Gender.female);
    });

    test(
      'an unknown gender code does not crash (falls back to null)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({..._employeeJson(), 'gender': 99}),
            200,
            headers: _jsonHeaders,
          ),
        );

        final employee = await repository.get(employeeId: 1);

        expect(employee.gender, isNull);
      },
    );

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Employee not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.get(employeeId: 999),
        throwsA(const AppError.notFound('Employee not found')),
      );
    });
  });

  group('EmployeeRepositoryImpl.create', () {
    test(
      '201 returns the created Employee, sending Date-encoded birthday/startJobDate',
      () async {
        RequestOptions? captured;
        final repository = _repositoryWith((options) async {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode(_employeeJson()),
            201,
            headers: _jsonHeaders,
          );
        });

        final employee = await repository.create(
          firstName: 'Jane',
          lastName: 'Doe',
          nickname: 'Janie',
          gender: 0,
          birthday: DateTime(1990, 5, 15),
          startJobDate: DateTime(2020, 1, 10),
        );

        expect(employee.firstName, 'Jane');
        final sentBody = _decodeBody(captured!.data);
        expect(sentBody['birthday'], '1990-05-15');
        expect(sentBody['start_job_date'], '2020-01-10');
      },
    );
  });

  group('EmployeeRepositoryImpl.update', () {
    test('200 returns the updated Employee', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({..._employeeJson(), 'nickname': 'JD'}),
          200,
          headers: _jsonHeaders,
        ),
      );

      final employee = await repository.update(employeeId: 1, nickname: 'JD');

      expect(employee.nickname, 'JD');
    });

    test('404 maps to AppError.notFound', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode({'detail': 'Employee not found'}),
          404,
          headers: _jsonHeaders,
        ),
      );

      await expectLater(
        () => repository.update(employeeId: 999, nickname: 'Anything'),
        throwsA(const AppError.notFound('Employee not found')),
      );
    });
  });

  group('EmployeeRepositoryImpl.delete', () {
    test('204 completes with no error', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString('', 204),
      );

      await expectLater(repository.delete(employeeId: 1), completes);
    });

    test(
      'a still-referenced rejection surfaces the server message (spec Edge Cases)',
      () async {
        final repository = _repositoryWith(
          (options) async => ResponseBody.fromString(
            jsonEncode({'detail': 'Employee is assigned as a salesperson'}),
            400,
            headers: _jsonHeaders,
          ),
        );

        await expectLater(
          () => repository.delete(employeeId: 1),
          throwsA(
            const AppError.server(
              statusCode: 400,
              message: 'Employee is assigned as a salesperson',
            ),
          ),
        );
      },
    );
  });
}

Map<String, Object?> _employeeJson() => {
  'employee_id': 1,
  'first_name': 'Jane',
  'last_name': 'Doe',
  'nickname': 'Janie',
  'gender': 0,
  'birthday': '1990-05-15',
  'taxpayer_id': null,
  'sales_person': true,
  'active': true,
  'personal_id': null,
  'start_job_date': '2020-01-10',
  'enroll_number': null,
  'comment': null,
};

Map<String, Object?> _decodeBody(Object? data) => data is String
    ? jsonDecode(data) as Map<String, Object?>
    : data as Map<String, Object?>;

EmployeeRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return EmployeeRepositoryImpl(dio);
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
