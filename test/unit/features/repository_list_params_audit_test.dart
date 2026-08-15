import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards FR-015 (017-ui-consistency-filters,
/// contracts/filter-backfill.md §5): a standing audit that a catalog
/// repository's `list()` parameters match what the generated OpenAPI client
/// actually accepts, per entity. Both sides are parsed fresh from source, not
/// hand-copied — so a new facet appearing upstream in
/// `lib/generated/openapi` changes the client-side set and fails this test,
/// forcing an explicit decision (wire it, or record the gap below with a
/// reason) instead of silent drift.
///
/// Boilerplate present on every generated client method (`skip`, `limit`,
/// `cancelToken`, `headers`, `extra`, `validateStatus`, `onSendProgress`,
/// `onReceiveProgress`) is pagination/Dio plumbing, not a facet, and is
/// excluded from both sides before comparing.
const _boilerplate = {
  'skip',
  'limit',
  'cancelToken',
  'headers',
  'extra',
  'validateStatus',
  'onSendProgress',
  'onReceiveProgress',
};

/// One audited entity: where its repository and generated-client `list`-style
/// method live, and how repository parameter names map to client parameter
/// names (they differ for a few FK facets, e.g. repo `facilityId` vs client
/// `facility` — a deliberate naming choice, not a gap).
class _Entity {
  const _Entity({
    required this.name,
    required this.repoPath,
    required this.repoMarker,
    required this.clientPath,
    required this.clientMarker,
    required this.paramMap,
    this.repoOnlyParams = const {},
  });

  final String name;
  final String repoPath;
  final String repoMarker;
  final String clientPath;
  final String clientMarker;

  /// repo parameter name -> client parameter name, for every facet wired
  /// end-to-end.
  final Map<String, String> paramMap;

  /// Repo parameters with **no** client-side counterpart today — a
  /// documented, deliberate gap (FR-015's "recorded, with a reason"), not an
  /// oversight this test should catch.
  final Set<String> repoOnlyParams;
}

const _clientDir = 'lib/generated/openapi/lib/src/api';

final _entities = [
  const _Entity(
    name: 'Vehicles',
    repoPath:
        'lib/features/catalog/domain/repositories/vehicle_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/vehicles_api.dart',
    clientMarker: 'listVehiclesApiV1VehiclesGet({',
    paramMap: {'search': 'search', 'status': 'status'},
  ),
  const _Entity(
    name: 'Vehicle Operators',
    repoPath:
        'lib/features/catalog/domain/repositories/vehicle_operator_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/vehicle_operators_api.dart',
    clientMarker: 'listVehicleOperatorsApiV1VehicleOperatorsGet({',
    // Repo names the driver facet `driverId` for domain clarity; the
    // generated client (and the API) calls it `employee`.
    paramMap: {'search': 'search', 'driverId': 'employee', 'status': 'status'},
  ),
  const _Entity(
    name: 'Users',
    repoPath: 'lib/features/auth/domain/repositories/user_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/users_api.dart',
    clientMarker: 'listUsersApiV1UsersGet({',
    // profileId: 024-user-profiles FR-028 — narrows to accounts
    // provisioned from a given profile.
    paramMap: {
      'search': 'search',
      'status': 'status',
      'profileId': 'profileId',
    },
  ),
  const _Entity(
    name: 'Products',
    repoPath:
        'lib/features/catalog/domain/repositories/product_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/products_api.dart',
    clientMarker: 'listProductsApiV1ProductsGet({',
    paramMap: {
      'search': 'search',
      'status': 'status',
      'stockable': 'stockable',
      'salable': 'salable',
      'purchasable': 'purchasable',
      'supplier': 'supplier',
      // Repo takes a `List<int> labels`; the client's singular `label` param
      // is itself a `BuiltList<int>` under the hood (plural facet, singular
      // name upstream).
      'labels': 'label',
    },
  ),
  const _Entity(
    name: 'Customers',
    repoPath:
        'lib/features/catalog/domain/repositories/customer_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/customers_api.dart',
    clientMarker: 'listCustomersApiV1CustomersGet({',
    paramMap: {
      'search': 'search',
      'status': 'status',
      'priceList': 'priceList',
      'salesperson': 'salesperson',
    },
  ),
  const _Entity(
    name: 'Employees',
    repoPath:
        'lib/features/catalog/domain/repositories/employee_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/employees_api.dart',
    clientMarker: 'listEmployeesApiV1EmployeesGet({',
    paramMap: {
      'search': 'search',
      'status': 'status',
      'salesPerson': 'salesPerson',
    },
  ),
  const _Entity(
    name: 'Warehouses',
    repoPath:
        'lib/features/catalog/domain/repositories/warehouse_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/warehouses_api.dart',
    clientMarker: 'listWarehousesApiV1WarehousesGet({',
    paramMap: {
      'search': 'search',
      'facilityId': 'facility',
      'status': 'status',
    },
  ),
  const _Entity(
    name: 'Cash Drawers',
    repoPath:
        'lib/features/catalog/domain/repositories/cash_drawer_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/cash_drawers_api.dart',
    clientMarker: 'listCashDrawersApiV1CashDrawersGet({',
    paramMap: {
      'search': 'search',
      'facilityId': 'facility',
      'status': 'status',
    },
  ),
  const _Entity(
    name: 'Points of Sale',
    repoPath:
        'lib/features/catalog/domain/repositories/point_sale_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/points_of_sale_api.dart',
    clientMarker: 'listPointsOfSaleApiV1PointsOfSaleGet({',
    paramMap: {
      'search': 'search',
      'facilityId': 'facility',
      'warehouseId': 'warehouse',
      'status': 'status',
    },
  ),
  const _Entity(
    name: 'Facilities',
    repoPath:
        'lib/features/catalog/domain/repositories/facility_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/facilities_api.dart',
    clientMarker: 'listFacilitiesApiV1FacilitiesGet({',
    paramMap: {'search': 'search', 'status': 'status'},
  ),
  const _Entity(
    name: 'Payment Method Options',
    repoPath:
        'lib/features/catalog/domain/repositories/payment_method_option_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/payment_method_options_api.dart',
    clientMarker: 'listPaymentMethodOptionsApiV1PaymentMethodOptionsGet({',
    paramMap: {'facilityId': 'facility', 'status': 'status'},
    // The generated client's list endpoint exposes no `search` param yet.
    // The repo declares (and the screen wires) it anyway, unforwarded to the
    // network call, so nothing has to change on the call sites once the
    // upstream capability ships (research.md §15,
    // payment_method_option_repository_impl.dart).
    repoOnlyParams: {'search'},
  ),
  const _Entity(
    name: 'Exchange Rates',
    repoPath:
        'lib/features/pricing/domain/repositories/exchange_rate_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/exchange_rates_api.dart',
    clientMarker: 'listExchangeRatesApiV1ExchangeRatesGet({',
    // The client names the base-currency param `base_` — `base` collides
    // with a Dart/generator-reserved identifier upstream.
    paramMap: {
      'dateFrom': 'dateFrom',
      'dateTo': 'dateTo',
      'base': 'base_',
      'target': 'target',
    },
  ),
  const _Entity(
    name: 'Labels',
    repoPath: 'lib/features/catalog/domain/repositories/label_repository.dart',
    // The list screen is backed by `listDetailed`, not the lightweight
    // `list` the product-form picker uses (both hit the same endpoint).
    repoMarker: 'listDetailed({',
    clientPath: '$_clientDir/labels_api.dart',
    clientMarker: 'listLabelsApiV1LabelsGet({',
    paramMap: {'search': 'search'},
  ),
  const _Entity(
    name: 'Suppliers',
    repoPath:
        'lib/features/catalog/domain/repositories/supplier_repository.dart',
    repoMarker: 'listDetailed({',
    clientPath: '$_clientDir/suppliers_api.dart',
    clientMarker: 'listSuppliersApiV1SuppliersGet({',
    paramMap: {'search': 'search'},
  ),
  const _Entity(
    name: 'Expenses',
    repoPath:
        'lib/features/catalog/domain/repositories/expense_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/expenses_api.dart',
    clientMarker: 'listExpensesApiV1ExpensesGet({',
    paramMap: {'search': 'search'},
  ),
  const _Entity(
    name: 'Price Lists',
    repoPath:
        'lib/features/pricing/domain/repositories/price_list_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/price_lists_api.dart',
    clientMarker: 'listPriceListsApiV1PriceListsGet({',
    paramMap: {'search': 'search'},
  ),
  const _Entity(
    name: 'Taxpayer Recipients',
    repoPath:
        'lib/features/catalog/domain/repositories/taxpayer_recipient_repository.dart',
    repoMarker: 'list({',
    clientPath: '$_clientDir/taxpayer_recipients_api.dart',
    clientMarker: 'listTaxpayerRecipientsApiV1TaxpayerRecipientsGet({',
    paramMap: {'search': 'search'},
  ),
  const _Entity(
    name: 'Taxpayer Issuers',
    repoPath:
        'lib/features/catalog/domain/repositories/taxpayer_issuer_repository.dart',
    // The list screen is backed by `listDetail` (full entity, so the table
    // can show postal code/regime), not the lightweight `list`.
    repoMarker: 'listDetail({',
    clientPath: '$_clientDir/taxpayer_issuers_api.dart',
    clientMarker: 'listTaxpayerIssuersApiV1TaxpayerIssuersGet({',
    paramMap: {'search': 'search'},
  ),
];

/// Splits a parameter-list body on top-level commas — i.e. not commas nested
/// inside a generic type like `Map<String, dynamic>? headers`.
List<String> _splitTopLevel(String body) {
  final parts = <String>[];
  var depth = 0;
  final buffer = StringBuffer();
  for (final ch in body.split('')) {
    if ('<(['.contains(ch)) depth++;
    if ('>)]'.contains(ch)) depth--;
    if (ch == ',' && depth == 0) {
      parts.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(ch);
    }
  }
  if (buffer.toString().trim().isNotEmpty) parts.add(buffer.toString());
  return parts;
}

/// Extracts the named-parameter names declared in the `{...}` block that
/// immediately follows [marker] in the file at [path] (e.g. marker
/// `'list({'` finds `list({ String? search, ... })`), excluding boilerplate.
Set<String> _paramsAfter(String path, String marker) {
  final source = File(path).readAsStringSync();
  final start = source.indexOf(marker);
  if (start == -1) {
    fail('Could not find `$marker` in $path — has the signature changed?');
  }
  final braceOpen = start + marker.length - 1;
  var depth = 1;
  var i = braceOpen + 1;
  while (depth > 0) {
    final ch = source[i];
    if (ch == '{') depth++;
    if (ch == '}') depth--;
    i++;
  }
  final body = source.substring(braceOpen + 1, i - 1);

  final params = <String>{};
  for (final rawPart in _splitTopLevel(body)) {
    final part = rawPart.trim();
    if (part.isEmpty) continue;
    final beforeDefault = part.split('=').first.trim();
    final name = beforeDefault.split(RegExp(r'\s+')).last;
    if (!_boilerplate.contains(name)) params.add(name);
  }
  return params;
}

void main() {
  for (final entity in _entities) {
    test('${entity.name}: repository list() params match the generated '
        'client\'s, 1:1 by the documented mapping', () {
      final repoParams = _paramsAfter(entity.repoPath, entity.repoMarker);
      final clientParams = _paramsAfter(entity.clientPath, entity.clientMarker);

      final expectedRepoParams = {
        ...entity.paramMap.keys,
        ...entity.repoOnlyParams,
      };
      final expectedClientParams = entity.paramMap.values.toSet();

      expect(
        repoParams,
        equals(expectedRepoParams),
        reason:
            '${entity.repoPath} `list()` parameters changed — update the '
            'audit\'s paramMap/repoOnlyParams for ${entity.name}, with a '
            'reason if the change is a deliberate gap.',
      );
      expect(
        clientParams,
        equals(expectedClientParams),
        reason:
            '${entity.clientPath} gained/lost a parameter upstream for '
            '${entity.name} — decide whether to wire it into the '
            'repository, then update this audit either way (FR-015).',
      );
    });
  }
}
