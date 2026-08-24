import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/orders/sales_orders_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

User _user({
  bool canCreate = true,
  bool canUpdate = true,
  int? facilityId = 9,
}) => User(
  userId: 'salesperson-1',
  email: 'salesperson@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: facilityId == null ? null : UserSettings(facilityId: facilityId),
  privileges: [
    Privilege(
      systemObject: SystemObject.salesOrders,
      rawValue: (canCreate ? 1 : 0) | (canUpdate ? 4 : 0),
    ),
  ],
);

void stubListOrders(MockSalesOrderRepository repository, {required OpenSalePage page}) {
  when(
    () => repository.listOrders(
      mine: any(named: 'mine'),
      facility: any(named: 'facility'),
      salesperson: any(named: 'salesperson'),
      status: any(named: 'status'),
      dateFrom: any(named: 'dateFrom'),
      dateTo: any(named: 'dateTo'),
      search: any(named: 'search'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => page);
}

void main() {
  late MockSalesOrderRepository salesOrders;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
  });

  Future<ProviderContainer> pumpList(
    WidgetTester tester, {
    User? user,
    ListQuery query = const ListQuery(),
  }) => pumpPos(
    tester,
    SalesOrdersListScreen(query: query),
    overrides: [
      authNotifierProvider.overrideWith(
        () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: user ?? _user())),
      ),
      salesOrderOverride(salesOrders),
    ],
  );

  group('the default view (FR-005, FR-006)', () {
    testWidgets('shows the six columns for a mine=true request', (tester) async {
      stubListOrders(
        salesOrders,
        page: testSalesPage([
          testOpenSale(id: 337427, status: SaleStatus.draft, total: '17962.00'),
        ]),
      );

      await pumpList(tester);
      await tester.pumpAndSettle();

      verify(
        () => salesOrders.listOrders(
          mine: true,
          facility: null,
          salesperson: null,
          status: null,
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          search: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);

      expect(find.text(l10n.salesOrdersColumnReference), findsOneWidget);
      expect(find.text(l10n.salesOrdersColumnDate), findsOneWidget);
      expect(find.text(l10n.salesOrdersColumnCustomer), findsOneWidget);
      expect(find.text(l10n.salesOrdersColumnStatus), findsOneWidget);
      expect(find.text(l10n.salesOrdersColumnTotal), findsOneWidget);
      expect(find.text(l10n.salesOrdersColumnBalance), findsOneWidget);
      expect(find.text('337427'), findsOneWidget);
    });

    testWidgets('New order is absent without create rights', (tester) async {
      stubListOrders(salesOrders, page: testSalesPage(const []));

      await pumpList(tester, user: _user(canCreate: false));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sales_orders_new_order_button')), findsNothing);
    });

    testWidgets('Edit row action is absent without update rights', (tester) async {
      stubListOrders(
        salesOrders,
        page: testSalesPage([testOpenSale(id: 1, status: SaleStatus.draft)]),
      );

      await pumpList(tester, user: _user(canUpdate: false));
      await tester.pumpAndSettle();

      expect(find.byTooltip(l10n.editActionTooltip), findsNothing);
    });

    testWidgets('Edit row action is absent for a confirmed order — draft '
        'only', (tester) async {
      stubListOrders(
        salesOrders,
        page: testSalesPage([testOpenSale(id: 1, status: SaleStatus.completed)]),
      );

      await pumpList(tester);
      await tester.pumpAndSettle();

      expect(find.byTooltip(l10n.editActionTooltip), findsNothing);
    });
  });

  group('no facility configured (Edge Cases)', () {
    testWidgets('issues no request at all and shows the blocked state', (
      tester,
    ) async {
      await pumpList(tester, user: _user(facilityId: null));
      await tester.pumpAndSettle();

      verifyNever(
        () => salesOrders.listOrders(
          mine: any(named: 'mine'),
          facility: any(named: 'facility'),
          salesperson: any(named: 'salesperson'),
          status: any(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
      expect(find.byKey(const Key('sales_orders_no_facility')), findsOneWidget);
    });
  });
}
