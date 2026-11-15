import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/sales/data/delivery_itinerary_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/pending_delivery.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_itinerary_repository.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_customer_controller.dart';
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_filter.dart';
import 'package:mbe_ui/features/sales/presentation/for_delivery/pending_deliveries_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class _MockRepository extends Mock implements DeliveryItineraryRepository {}

Customer _customer(int id) => Customer(
  customerId: id,
  code: 'C-$id',
  name: 'Cliente $id',
  creditLimit: '0',
  creditDays: 0,
  priceList: const PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
  addresses: [
    AddressListItem(
      addressId: 11,
      label: 'Av. Juárez 120, Centro',
      type: AddressType.business,
    ),
  ],
);

PendingDeliveryLine _line(
  int id, {
  int order = 31,
  int? serial = 1541,
  int priority = 2,
  DateTime? date,
  bool noDate = false,
  String quantity = '40.0000',
  String code = 'CEM-50',
  String name = 'Cemento gris 50 kg',
  int customer = 7,
}) => PendingDeliveryLine(
  deliveryOrderId: order,
  lineId: id,
  serial: serial,
  customerId: customer,
  shipToId: 11,
  scheduledDate: noDate ? null : (date ?? DateTime(2026, 11, 15, 9)),
  priority: priority,
  productId: 5,
  productCode: code,
  productName: name,
  warehouseId: 3,
  openQuantity: quantity,
);

PendingDeliveriesResult _response({
  Map<PendingDeliveryPeriod, List<PendingDeliveryLine>> lines = const {},
  Map<PendingDeliveryPeriod, int> totals = const {},
}) {
  const dates = {
    PendingDeliveryPeriod.yesterday: (2026, 11, 14),
    PendingDeliveryPeriod.today: (2026, 11, 15),
    PendingDeliveryPeriod.tomorrow: (2026, 11, 16),
    PendingDeliveryPeriod.dayAfter: (2026, 11, 17),
  };
  const defaults = {
    PendingDeliveryPeriod.earlier: 4,
    PendingDeliveryPeriod.yesterday: 2,
    PendingDeliveryPeriod.today: 12,
    PendingDeliveryPeriod.tomorrow: 7,
    PendingDeliveryPeriod.dayAfter: 3,
    PendingDeliveryPeriod.later: 9,
  };
  return {
    for (final p in PendingDeliveryPeriod.values)
      p: (
        date: dates[p] == null
            ? null
            : DateTime(dates[p]!.$1, dates[p]!.$2, dates[p]!.$3),
        total: totals[p] ?? lines[p]?.length ?? defaults[p]!,
        items: lines[p] ?? const [],
      ),
  };
}

/// Spec 063 US1–US3 (T015, T017, T019), contracts C2–C5: the "Por entregar"
/// queue. The route gate is covered in `app_router_test.dart`.
void main() {
  late _MockRepository repository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => repository = _MockRepository());

  void serve(PendingDeliveriesResult result) => when(
    () => repository.pendingDeliveries(
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => result);

  Override access({bool orders = false}) =>
      accessControlProvider.overrideWithValue(
        AccessControlService(
          AuthState.authenticated(
            token: 't',
            user: User(
              userId: 'a',
              email: 'a@example.com',
              administrator: false,
              status: EntityStatus.active,
              sessionVersion: 1,
              privileges: [
                const Privilege(
                  systemObject: SystemObject.forDeliver,
                  rawValue: 2,
                ),
                if (orders)
                  const Privilege(
                    systemObject: SystemObject.deliveryOrders,
                    rawValue: 2,
                  ),
              ],
            ),
          ),
        ),
      );

  Future<GoRouter> pump(
    WidgetTester tester, {
    bool orders = false,
    String location = forDeliveryPath,
    Size surface = const Size(1400, 1000),
    Future<String?> Function(int id)? customerName,
    Future<String?> Function(int id)? warehouseName,
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        access(orders: orders),
        deliveryItineraryRepositoryProvider.overrideWithValue(repository),
        customerDisplayNameProvider.overrideWith(
          (ref, id) => (customerName ?? (i) async => 'Cliente $i')(id),
        ),
        warehouseDisplayNameProvider.overrideWith(
          (ref, id) => (warehouseName ?? (i) async => 'Almacén $i')(id),
        ),
        saleCustomerControllerProvider.overrideWith(
          (ref, id) async => _customer(id),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: forDeliveryPath,
          builder: (context, state) => Scaffold(
            body: PendingDeliveriesScreen(query: ListQuery.fromUri(state.uri)),
          ),
        ),
        GoRoute(
          path: '/sales/delivery-orders/:id',
          builder: (context, s) => Scaffold(
            body: TextButton(
              key: const Key('order_back'),
              onPressed: () => context.pop(),
              child: Text('order-${s.pathParameters['id']}'),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Finder key(String k) => find.byKey(Key(k));

  Badge badge(WidgetTester tester) => tester.widget<Badge>(
    find.ancestor(
      of: key('for_delivery_filter_button'),
      matching: find.byType(Badge),
    ),
  );

  Future<void> openFilters(WidgetTester tester) async {
    await tester.tap(key('for_delivery_filter_button'));
    await tester.pumpAndSettle();
  }

  group('table (US1)', () {
    testWidgets('shows folio, customer, ship-to, date, priority, product, '
        'warehouse and open quantity, with the period total in the footer', (
      tester,
    ) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.today: [
              _line(900, quantity: '40.0000'),
              _line(
                901,
                order: 32,
                serial: 1538,
                priority: 0,
                code: 'VAR-38',
                name: 'Varilla 3/8"',
                quantity: '120.5000',
              ),
            ],
          },
          totals: {PendingDeliveryPeriod.today: 2},
        ),
      );

      await pump(tester);

      expect(key('for_delivery_table'), findsOneWidget);
      expect(find.text('1541'), findsOneWidget);
      expect(find.text('1538'), findsOneWidget);
      expect(find.text('Cliente 7'), findsNWidgets(2));
      expect(find.text('Av. Juárez 120, Centro'), findsNWidgets(2));
      expect(find.text('2026-11-15'), findsNWidgets(2));
      expect(find.text('CEM-50 Cemento gris 50 kg'), findsOneWidget);
      expect(find.text('VAR-38 Varilla 3/8"'), findsOneWidget);
      expect(find.text('Almacén 3'), findsNWidgets(2));
      expect(find.text('40'), findsOneWidget);
      expect(find.text('120.5'), findsOneWidget);
      expect(find.text(l10n.forDeliveryColumnPriority), findsOneWidget);
      expect(find.text(l10n.forDeliveryColumnOpenQuantity), findsOneWidget);
      expect(find.textContaining('de 2'), findsOneWidget);
    });

    testWidgets('opens on Hoy, asks for the first page and sends nothing '
        'else', (tester) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.today: [_line(900)],
            PendingDeliveryPeriod.tomorrow: [_line(901, serial: 1600)],
          },
        ),
      );

      await pump(tester);

      verify(() => repository.pendingDeliveries(skip: 0, limit: 20)).called(1);
      expect(find.text('1541'), findsOneWidget);
      // Tomorrow's line is in the same response but isn't shown.
      expect(find.text('1600'), findsNothing);
    });

    testWidgets('a line with no scheduled date says so, and a draft folio '
        'reads Borrador', (tester) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.later: [
              _line(900, noDate: true, serial: null),
            ],
          },
        ),
      );

      await pump(tester, location: '$forDeliveryPath?period=later');

      expect(find.text(l10n.forDeliveryNoDate), findsOneWidget);
      expect(find.text(l10n.deliveryOrderDraftFolio), findsOneWidget);
    });

    testWidgets("a name the user can't read falls back to its number", (
      tester,
    ) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.today: [_line(900)],
          },
        ),
      );

      await pump(
        tester,
        customerName: (_) async => null,
        warehouseName: (_) async => null,
      );

      expect(find.text('#7'), findsOneWidget);
      expect(find.text('#3'), findsOneWidget);
    });

    testWidgets('has no search box, no row actions and no tap affordance '
        'issues: the queue is read-only (FR-010, FR-011)', (tester) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.today: [_line(900)],
          },
        ),
      );

      await pump(tester);

      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    });

    testWidgets('the compact layout drops Destino', (tester) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.today: [_line(900)],
          },
        ),
      );

      await pump(tester, surface: const Size(500, 900));

      expect(find.text(l10n.deliveryOrderColumnDestination), findsNothing);
      expect(find.text('1541'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('an empty Hoy says so and offers no clear button', (
      tester,
    ) async {
      serve(_response(totals: {PendingDeliveryPeriod.today: 0}));

      await pump(tester);

      expect(find.text(l10n.forDeliveryEmpty), findsOneWidget);
      expect(find.text(l10n.clearFiltersButton), findsNothing);
    });

    testWidgets('an empty period other than Hoy offers to clear the filter, '
        'which goes back to Hoy', (tester) async {
      serve(_response(totals: {PendingDeliveryPeriod.tomorrow: 0}));

      final router = await pump(
        tester,
        location: '$forDeliveryPath?period=tomorrow',
      );

      // The shared filtered-empty state, as every filtered list shows.
      expect(key('list_state_filtered_empty'), findsOneWidget);
      expect(find.text(l10n.forDeliveryEmpty), findsNothing);
      await tester.tap(key('list_state_clear_filters_button'));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), forDeliveryPath);
    });

    testWidgets('a failed load shows the error, and retry asks again', (
      tester,
    ) async {
      var calls = 0;
      when(
        () => repository.pendingDeliveries(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const AppError.server();
        return _response(
          lines: {
            PendingDeliveryPeriod.today: [_line(900)],
          },
        );
      });

      await pump(tester);
      expect(find.text(l10n.retryButton), findsOneWidget);

      await tester.tap(find.text(l10n.retryButton));
      await tester.pumpAndSettle();

      expect(find.text('1541'), findsOneWidget);
      expect(calls, 2);
    });
  });

  group('period filter (US2)', () {
    testWidgets('no badge on Hoy', (tester) async {
      serve(_response());

      await pump(tester);

      expect(badge(tester).isLabelVisible, isFalse);
    });

    testWidgets('one badge on any other period', (tester) async {
      serve(_response());

      await pump(tester, location: '$forDeliveryPath?period=later');

      final b = badge(tester);
      expect(b.isLabelVisible, isTrue);
      expect(b.label, isA<Text>().having((t) => t.data, 'count', '1'));
    });

    testWidgets('the panel lists the six periods in order with counts, and '
        'dates on the single-day ones', (tester) async {
      serve(_response());
      await pump(tester);
      await openFilters(tester);

      // The closed dropdown shows the selected period.
      expect(find.text('Hoy · 2026-11-15 (12)'), findsOneWidget);

      await tester.tap(key('for_delivery_period_filter'));
      await tester.pumpAndSettle();

      final labels = [
        'Anteriores (4)',
        'Ayer · 2026-11-14 (2)',
        'Hoy · 2026-11-15 (12)',
        'Mañana · 2026-11-16 (7)',
        'Pasado mañana · 2026-11-17 (3)',
        'Posteriores (9)',
      ];
      final tops = [
        for (final label in labels) tester.getTopLeft(find.text(label).last).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      expect(find.text('Anteriores (4)'), findsOneWidget);
      expect(find.text('Posteriores (9)'), findsOneWidget);
    });

    testWidgets('picking a period goes to it on page 1, and Hoy drops the '
        'facet', (tester) async {
      serve(_response());
      final router = await pump(
        tester,
        location: '$forDeliveryPath?period=later&page=2',
      );
      await openFilters(tester);

      await tester.tap(key('for_delivery_period_filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mañana · 2026-11-16 (7)').last);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {'period': 'tomorrow'});

      await tester.tap(key('for_delivery_period_filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hoy · 2026-11-15 (12)').last);
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), forDeliveryPath);
    });

    testWidgets('the counts stay in the panel while a newly picked period '
        'loads', (tester) async {
      serve(_response());
      await pump(tester);
      await openFilters(tester);

      // Hold the next response so the new period stays loading.
      final gate = Completer();
      when(
        () => repository.pendingDeliveries(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {
        await gate.future;
        return _response();
      });

      await tester.tap(key('for_delivery_period_filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mañana · 2026-11-16 (7)').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Mañana · 2026-11-16 (7)'), findsWidgets);

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('"Limpiar filtros" in the panel returns to Hoy', (
      tester,
    ) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.earlier: [_line(900)],
          },
        ),
      );
      final router = await pump(
        tester,
        location: '$forDeliveryPath?period=earlier',
      );
      await openFilters(tester);

      await tester.tap(find.text(l10n.clearAllFilters));
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), forDeliveryPath);
    });

    testWidgets('Anteriores lists its lines with their scheduled date', (
      tester,
    ) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.earlier: [
              _line(900, date: DateTime(2026, 11, 10)),
            ],
          },
        ),
      );

      await pump(tester, location: '$forDeliveryPath?period=earlier');

      expect(find.text('2026-11-10'), findsOneWidget);
    });

    testWidgets('an unknown period in the URL shows Hoy', (tester) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.today: [_line(900)],
          },
        ),
      );

      await pump(tester, location: '$forDeliveryPath?period=bogus');

      expect(find.text('1541'), findsOneWidget);
      expect(badge(tester).isLabelVisible, isFalse);
    });

    testWidgets('a page change keeps the period', (tester) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.tomorrow: [
              for (var i = 0; i < 20; i++) _line(900 + i, order: 40 + i),
            ],
          },
          totals: {PendingDeliveryPeriod.tomorrow: 45},
        ),
      );

      final router = await pump(
        tester,
        location: '$forDeliveryPath?period=tomorrow',
      );
      expect(find.textContaining('de 45'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right).first);
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {
        'period': 'tomorrow',
        'page': '2',
      });
    });
  });

  group('row tap (US3)', () {
    testWidgets('with Delivery Orders read a tap opens that line\'s order, '
        'and back reloads the queue on the same period', (tester) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.tomorrow: [_line(900, order: 77)],
          },
        ),
      );

      final router = await pump(
        tester,
        orders: true,
        location: '$forDeliveryPath?period=tomorrow',
      );
      verify(() => repository.pendingDeliveries(skip: 0, limit: 20)).called(1);

      await tester.tap(find.text('1541'));
      await tester.pumpAndSettle();
      expect(find.text('order-77'), findsOneWidget);

      await tester.tap(key('order_back'));
      await tester.pumpAndSettle();

      expect(router.state.uri.queryParameters, {'period': 'tomorrow'});
      verify(() => repository.pendingDeliveries(skip: 0, limit: 20)).called(1);
    });

    testWidgets('without Delivery Orders read, rows are not tappable', (
      tester,
    ) async {
      serve(
        _response(
          lines: {
            PendingDeliveryPeriod.today: [_line(900, order: 77)],
          },
        ),
      );

      await pump(tester);
      await tester.tap(find.text('1541'));
      await tester.pumpAndSettle();

      expect(find.text('order-77'), findsNothing);
      expect(find.text('1541'), findsOneWidget);
    });
  });
}
