import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

const _rfc = 'XAXX010101000';

Map<String, Object?> _batchJson({
  int id = 7,
  String series = 'A',
  int type = 0,
  bool inUse = false,
}) => {
  'taxpayer_batch_id': id,
  'taxpayer': _rfc,
  'batch': series,
  'type': type,
  'in_use': inUse,
  'template': {
    'name': 'Factura',
    'logo': null,
    'header_height': 0,
    'footer_height': 15,
    'extra_info': [
      {
        'bank': 'BBVA',
        'account': '0123456789',
        'clabe': '012180001234567891',
        'currency': 'MXN',
      },
    ],
  },
};

TaxpayerBatchDraft _draft({
  String series = 'A',
  FiscalDocumentKind kind = FiscalDocumentKind.invoice,
  String? logo,
  List<TaxpayerBatchAccount> accounts = const [],
}) => TaxpayerBatchDraft(
  series: series,
  kind: kind,
  template: TaxpayerBatchTemplate(
    name: 'Factura',
    logo: logo,
    headerHeight: 3,
    footerHeight: 20,
    accounts: accounts,
  ),
);

ResponseBody _json(Object body, int status) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: _jsonHeaders);

void main() {
  group('listForIssuer', () {
    test('lists the issuer\'s series from its own endpoint', () async {
      late RequestOptions captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return _json([
          _batchJson(),
          _batchJson(id: 8, series: 'NC', type: 100, inUse: true),
        ], 200);
      });

      final batches = await repository.listForIssuer(_rfc);

      expect(captured.method, 'GET');
      expect(captured.path, '/api/v1/taxpayer-issuers/$_rfc/batches');
      expect(batches.map((b) => b.series), ['A', 'NC']);
      expect(batches[1].kind, FiscalDocumentKind.creditNote);
      expect(batches[1].inUse, isTrue);
    });

    test('a refusal surfaces as the AppError with its code intact', () async {
      final repository = _repositoryWith(
        (options) async => _json({
          'detail': 'Taxpayer issuer not found',
          'code': 'resource.not_found',
          'params': {'resource': 'taxpayer_issuer', 'id': _rfc},
        }, 404),
      );

      await expectLater(
        repository.listForIssuer(_rfc),
        throwsA(
          isA<NotFoundError>().having(
            (e) => e.problem?.code,
            'code',
            api.ErrorCode.resourcePeriodNotFound,
          ),
        ),
      );
    });
  });

  group('create', () {
    test('posts the series, the type as its wire number and the template, '
        'accounts in order', () async {
      late RequestOptions captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return _json(_batchJson(type: 100), 201);
      });

      final created = await repository.create(
        _rfc,
        _draft(
          series: 'NC',
          kind: FiscalDocumentKind.creditNote,
          logo: ' logo.png ',
          accounts: const [
            TaxpayerBatchAccount(bank: 'First', currency: 'MXN'),
            TaxpayerBatchAccount(bank: 'Second', clabe: '012'),
          ],
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.path, '/api/v1/taxpayer-issuers/$_rfc/batches');
      final body = captured.data as Map<String, dynamic>;
      expect(body['batch'], 'NC');
      expect(body['type'], 100);
      final template = body['template'] as Map<String, dynamic>;
      expect(template['name'], 'Factura');
      expect(template['logo'], 'logo.png');
      expect(template['header_height'], 3);
      expect(template['footer_height'], 20);
      final extra = template['extra_info'] as List<dynamic>;
      expect([for (final a in extra) (a as Map)['bank']], ['First', 'Second']);
      expect(created.taxpayerBatchId, 7);
    });

    test('sends a blank logo as no logo', () async {
      late RequestOptions captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return _json(_batchJson(), 201);
      });

      await repository.create(_rfc, _draft(logo: '   '));

      final template =
          (captured.data as Map<String, dynamic>)['template']
              as Map<String, dynamic>;
      expect(template['logo'], isNull);
    });

    test('maps every kind to its own wire number', () async {
      final sent = <int>[];
      final repository = _repositoryWith((options) async {
        sent.add((options.data as Map<String, dynamic>)['type'] as int);
        return _json(_batchJson(), 201);
      });

      for (final kind in FiscalDocumentKind.values) {
        await repository.create(_rfc, _draft(kind: kind));
      }

      expect(sent, [0, 1, 2, 3, 100, 101, 200]);
    });

    test('a duplicate series surfaces as resource.already_exists', () async {
      final repository = _repositoryWith(
        (options) async => _json({
          'detail': 'The issuer already has this series',
          'code': 'resource.already_exists',
          'params': {'resource': 'taxpayer_batch', 'field': 'batch'},
        }, 409),
      );

      await expectLater(
        repository.create(_rfc, _draft()),
        throwsA(
          isA<ServerError>()
              .having((e) => e.statusCode, 'status', 409)
              .having(
                (e) => e.problem?.code,
                'code',
                api.ErrorCode.resourcePeriodAlreadyExists,
              )
              .having(
                (e) => e.problem?.stringParam('resource'),
                'resource',
                'taxpayer_batch',
              ),
        ),
      );
    });
  });

  group('update', () {
    test('puts to the series\' own endpoint', () async {
      late RequestOptions captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return _json(_batchJson(series: 'B'), 200);
      });

      final updated = await repository.update(_rfc, 7, _draft(series: 'B'));

      expect(captured.method, 'PUT');
      expect(captured.path, '/api/v1/taxpayer-issuers/$_rfc/batches/7');
      expect((captured.data as Map<String, dynamic>)['batch'], 'B');
      expect(updated.series, 'B');
    });

    test('an in-use refusal keeps its code and action', () async {
      final repository = _repositoryWith(
        (options) async => _json({
          'detail': 'The series is in use: only its template can change',
          'code': 'taxpayer_batch.in_use',
          'params': {'action': 'update'},
        }, 409),
      );

      await expectLater(
        repository.update(_rfc, 7, _draft(series: 'B')),
        throwsA(
          isA<ServerError>()
              .having(
                (e) => e.problem?.code,
                'code',
                api.ErrorCode.taxpayerBatchPeriodInUse,
              )
              .having(
                (e) => e.problem?.stringParam('action'),
                'action',
                'update',
              ),
        ),
      );
    });
  });

  group('delete', () {
    test('deletes the series', () async {
      late RequestOptions captured;
      final repository = _repositoryWith((options) async {
        captured = options;
        return ResponseBody.fromString('', 204);
      });

      await repository.delete(_rfc, 7);

      expect(captured.method, 'DELETE');
      expect(captured.path, '/api/v1/taxpayer-issuers/$_rfc/batches/7');
    });

    test('an in-use refusal keeps its code and action', () async {
      final repository = _repositoryWith(
        (options) async => _json({
          'detail': 'The series is in use and cannot be deleted',
          'code': 'taxpayer_batch.in_use',
          'params': {'action': 'delete'},
        }, 409),
      );

      await expectLater(
        repository.delete(_rfc, 7),
        throwsA(
          isA<ServerError>().having(
            (e) => e.problem?.stringParam('action'),
            'action',
            'delete',
          ),
        ),
      );
    });
  });
}

TaxpayerBatchRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return TaxpayerBatchRepositoryImpl(dio);
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
