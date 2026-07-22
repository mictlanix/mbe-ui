import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

void main() {
  group('FacilityType round-trip', () {
    test('fromApi/toApi map Store(0) and Production Site(1)', () {
      expect(FacilityType.fromValue(0), FacilityType.store);
      expect(FacilityType.fromValue(1), FacilityType.productionSite);
      expect(FacilityType.store.value, 0);
      expect(FacilityType.productionSite.value, 1);
      // An unrecognized code degrades to store rather than crashing.
      expect(FacilityType.fromValue(9), isNull);
    });
  });

  group('AddressType round-trip', () {
    test('names all five values', () {
      expect(AddressType.fromValue(0), AddressType.other);
      expect(AddressType.fromValue(1), AddressType.home);
      expect(AddressType.fromValue(2), AddressType.work);
      expect(AddressType.fromValue(3), AddressType.business);
      expect(AddressType.fromValue(4), AddressType.fiscal);
      expect(AddressType.fiscal.value, 4);
    });
  });

  group('Facility.fromResponse (via FacilityRepositoryImpl.get)', () {
    test('expands location and address, keeps taxpayer as the bare RFC '
        '(FR-034b, FR-035)', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_facilityJson()),
          200,
          headers: _jsonHeaders,
        ),
      );

      final facility = await repository.get(facilityId: 1);

      expect(facility.facilityId, 1);
      expect(facility.code, 'FAC-1');
      expect(facility.type, FacilityType.productionSite);
      // location expanded to its readable description (not the bare code).
      expect(facility.locationId, '01000');
      expect(facility.locationLabel, 'Álvaro Obregón');
      // address expanded to a readable line (FR-035), no per-row fetch.
      expect(facility.addressId, 42);
      expect(facility.addressLabel, contains('Reforma'));
      expect(facility.addressLabel, contains('Juárez'));
      // taxpayer stays the bare RFC — the response never expands the issuer.
      expect(facility.taxpayerRfc, 'AAA010101AAA');
      expect(facility.taxpayerName, isNull);
      expect(facility.status, EntityStatus.active);
    });

    test('an interior number is folded into the address line', () async {
      final repository = _repositoryWith(
        (options) async => ResponseBody.fromString(
          jsonEncode(_facilityJson(interiorNumber: '4B')),
          200,
          headers: _jsonHeaders,
        ),
      );

      final facility = await repository.get(facilityId: 1);

      expect(facility.addressLabel, contains('Int. 4B'));
    });
  });
}

Map<String, Object?> _facilityJson({String? interiorNumber}) => {
  'facility_id': 1,
  'code': 'FAC-1',
  'name': 'North Plant',
  'type': 1,
  'location': {'id': '01000', 'description': 'Álvaro Obregón'},
  'address': {
    'address_id': 42,
    'type': 4,
    'street': 'Reforma',
    'exterior_number': '100',
    'interior_number': interiorNumber,
    'postal_code': '06600',
    'neighborhood': 'Juárez',
    'borough': 'Cuauhtémoc',
    'state': 'CDMX',
    'country': 'México',
    'status': 0,
  },
  'taxpayer': 'AAA010101AAA',
  'status': 0,
};

FacilityRepositoryImpl _repositoryWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = _FakeHttpClientAdapter(handler);
  return FacilityRepositoryImpl(dio);
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
