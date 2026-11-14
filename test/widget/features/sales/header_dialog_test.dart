import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/header_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Records each header write, field by field.
class _FakeActions extends DeliveryOrderActions {
  final calls = <Map<String, Object?>>[];

  @override
  Future<AppError?> updateHeader(
    int id, {
    int? priority,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
  }) async {
    calls.add({
      'priority': priority,
      'shipTo': shipTo,
      'contact': contact,
      'date': date,
      'comment': comment,
    });
    return null;
  }
}

const _customer = Customer(
  customerId: 7,
  code: 'C-7',
  name: 'Ferretería López',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  addresses: [
    AddressListItem(
      addressId: 11,
      label: 'Av. Juárez 120, Centro',
      type: AddressType.business,
    ),
    AddressListItem(
      addressId: 13,
      label: 'Bodega Norte',
      type: AddressType.business,
    ),
  ],
  contacts: [Contact(contactId: 12, name: 'Luis López')],
);

DeliveryOrder _order({FulfillmentType type = FulfillmentType.delivery}) =>
    DeliveryOrder(
      id: 9,
      facilityId: 1,
      customerId: 7,
      shipToId: 11,
      contactId: 12,
      comment: 'Por la mañana',
      date: DateTime(2026, 11, 15, 9),
      priority: 2,
      status: DeliveryOrderStatus.draft,
      type: type,
      createdAt: DateTime(2026, 11, 14),
      modifiedAt: DateTime(2026, 11, 14),
      lines: [
        DeliveryOrderLine(
          id: 1,
          productId: 1,
          productCode: 'P-1',
          productName: 'Producto 1',
          warehouseId: 3,
          quantity: Decimal.one,
          committed: Decimal.zero,
          delivered: Decimal.zero,
          returned: Decimal.zero,
          open: Decimal.one,
        ),
      ],
    );

/// Spec 061 T027: the header dialog (C10, FR-012, research R7).
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<List<bool>> pumpDialog(
    WidgetTester tester,
    DeliveryOrder order,
    _FakeActions actions,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final results = <bool>[];
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          deliveryOrderActionsProvider.overrideWith(() => actions),
          customerDisplayNameProvider.overrideWith(
            (ref, id) async => 'Ferretería López',
          ),
          facilityDisplayNameProvider.overrideWith((ref, id) async => 'Centro'),
          saleCustomerControllerProvider.overrideWith(
            (ref, id) async => _customer,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => results.add(
                  await showDeliveryOrderHeaderDialog(context, order),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  Finder key(String k) => find.byKey(Key(k));

  VoidCallback? saveAction(WidgetTester tester) =>
      tester.widget<FilledButton>(key('delivery_order_header_save')).onPressed;

  testWidgets('Guardar is disabled until something changes', (tester) async {
    await pumpDialog(tester, _order(), _FakeActions());

    expect(
      find.descendant(
        of: key('delivery_order_header_ship_to'),
        matching: find.text('Av. Juárez 120, Centro'),
      ),
      findsOneWidget,
    );
    expect(saveAction(tester), isNull);

    await tester.enterText(key('delivery_order_header_comment'), ' ');
    await tester.pump();
    // Blank can't clear the comment, so it isn't a change either.
    expect(saveAction(tester), isNull);
  });

  testWidgets('sends only the changed fields', (tester) async {
    final actions = _FakeActions();
    final results = await pumpDialog(tester, _order(), actions);

    await tester.enterText(key('delivery_order_header_priority'), '5');
    await tester.pump();
    await tester.tap(key('delivery_order_header_save'));
    await tester.pumpAndSettle();

    expect(actions.calls, [
      {
        'priority': 5,
        'shipTo': null,
        'contact': null,
        'date': null,
        'comment': null,
      },
    ]);
    expect(results, [true]);
  });

  testWidgets('a new ship-to comes from the customer\'s addresses', (
    tester,
  ) async {
    final actions = _FakeActions();
    await pumpDialog(tester, _order(), actions);

    await tester.tap(key('delivery_order_header_ship_to'));
    await tester.pumpAndSettle();
    await tester.tap(key('address_option_13'));
    await tester.pumpAndSettle();
    expect(find.text('Bodega Norte'), findsOneWidget);
    await tester.tap(key('delivery_order_header_save'));
    await tester.pumpAndSettle();

    expect(actions.calls.single['shipTo'], 13);
    expect(actions.calls.single['priority'], isNull);
    expect(actions.calls.single['comment'], isNull);
  });

  testWidgets('a pickup\'s ship-to is read-only, as the store', (tester) async {
    await pumpDialog(
      tester,
      _order(type: FulfillmentType.counterPickup),
      _FakeActions(),
    );

    expect(key('delivery_order_header_ship_to'), findsNothing);
    expect(
      find.text(l10n.deliveryOrderHeaderPickupDestination('Centro')),
      findsOneWidget,
    );
  });

  testWidgets('priority rejects negatives', (tester) async {
    await pumpDialog(tester, _order(), _FakeActions());

    await tester.enterText(key('delivery_order_header_priority'), '-1');
    await tester.pump();

    expect(find.text(l10n.deliveryOrderHeaderPriorityInvalid), findsOneWidget);
    expect(saveAction(tester), isNull);
  });
}
