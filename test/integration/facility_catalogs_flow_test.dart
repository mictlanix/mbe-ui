import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/sat_catalog_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode): create a facility (with a
/// new inline address and a taxpayer picked from the issuer autocomplete),
/// create a warehouse under it, create a point of sale drawing from that
/// warehouse, and create a cash drawer under the facility (quickstart.md
/// "Golden path"; spec.md US1–US4).
///
/// Requires mbe-api running at [apiBaseUrl] (default `http://127.0.0.1:8000`)
/// and a user with create+delete rights on `Facilities`/`Warehouses`/
/// `PointsOfSale`/`CashDrawers`/`Addresses` plus read on `Taxpayers`, in an
/// environment already seeded with at least one taxpayer issuer and one SAT
/// postal code. Configure via `--dart-define`:
///   --dart-define=MBE_CATALOG_TEST_USERNAME=...
///   --dart-define=MBE_CATALOG_TEST_PASSWORD=...
///
/// Skipped entirely when credentials aren't provided — this test creates and
/// then deletes real records, so it must never run unattended against an
/// unknown environment.
const _username = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _password = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');

const _canRun = _username != '' && _password != '';

void main() {
  test('create facility (inline address + picked taxpayer) → warehouse → '
      'point of sale → cash drawer', () async {
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';

    final addressRepository = AddressRepositoryImpl(dio);
    final satRepository = SatCatalogRepositoryImpl(dio);
    final taxpayerRepository = TaxpayerIssuerRepositoryImpl(dio);
    final facilityRepository = FacilityRepositoryImpl(dio);
    final warehouseRepository = WarehouseRepositoryImpl(dio);
    final pointSaleRepository = PointSaleRepositoryImpl(dio);
    final cashDrawerRepository = CashDrawerRepositoryImpl(dio);
    final addressesApi = AddressesApi(dio, standardSerializers);

    final suffix = DateTime.now().millisecondsSinceEpoch;

    // Prerequisites the seeded environment must provide (US4 depends on both).
    final postalCode = (await satRepository.listPostalCodes()).items.first;
    final taxpayer = (await taxpayerRepository.list()).items.first;

    // 1. US4 — create a new address inline (FR-031).
    final address = await addressRepository.create(
      AddressCreatePayload(
        street: 'Integration Street',
        exteriorNumber: '$suffix',
        postalCode: postalCode.code,
        neighborhood: 'Centro',
        borough: 'Cuauhtémoc',
        addressState: 'CDMX',
        country: 'México',
      ),
    );

    // 2. US4 — create a facility using that address + a picked taxpayer.
    final facility = await facilityRepository.create(
      code: 'FAC-$suffix',
      name: 'Integration Facility',
      location: postalCode.code,
      address: address.addressId,
      taxpayer: taxpayer.rfc,
    );
    expect(facility.code, 'FAC-$suffix');
    expect(facility.addressId, address.addressId);
    expect(facility.taxpayerRfc, taxpayer.rfc);

    // 3. US1 — create a warehouse under the facility.
    final warehouse = await warehouseRepository.create(
      facilityId: facility.facilityId,
      code: 'WH-$suffix',
      name: 'Integration Warehouse',
    );
    expect(warehouse.facilityId, facility.facilityId);
    expect(warehouse.facilityName, 'Integration Facility');

    // 4. US3 — create a point of sale picking that warehouse (the pairing
    // the backend validates, mbe-api#102).
    final pointSale = await pointSaleRepository.create(
      facilityId: facility.facilityId,
      code: 'POS-$suffix',
      name: 'Integration POS',
      warehouseId: warehouse.warehouseId,
    );
    expect(pointSale.warehouseId, warehouse.warehouseId);
    expect(pointSale.warehouseName, 'Integration Warehouse');

    // 5. US2 — create a cash drawer under the facility.
    final cashDrawer = await cashDrawerRepository.create(
      facilityId: facility.facilityId,
      code: 'CD-$suffix',
      name: 'Integration Cash Drawer',
    );
    expect(cashDrawer.facilityId, facility.facilityId);

    // 6. The new facility is immediately listable (SC-010: selectable in the
    // other catalogs' pickers, which read this same list).
    final facilities = await facilityRepository.list(search: 'FAC-$suffix');
    expect(
      facilities.items.map((f) => f.facilityId),
      contains(facility.facilityId),
    );

    // Cleanup: delete in reverse dependency order, leaving no test data
    // behind. The address is deleted via the generated API directly, since
    // the feature's own AddressRepository is intentionally list+create only
    // (FR-031) — the taxpayer issuer is pre-existing and left untouched.
    await pointSaleRepository.delete(pointSaleId: pointSale.pointSaleId);
    await cashDrawerRepository.delete(cashDrawerId: cashDrawer.cashDrawerId);
    await warehouseRepository.delete(warehouseId: warehouse.warehouseId);
    await facilityRepository.delete(facilityId: facility.facilityId);
    await addressesApi.deleteAddressApiV1AddressesAddressIdDelete(
      addressId: address.addressId,
    );
  }, skip: !_canRun);
}
