import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_card.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_line_row.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_detail_view.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';

import 'pos_test_harness.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);

  final AuthState _state;

  @override
  Future<AuthState> build() async => _state;
}

/// spec 048 contracts C3 — the read-only detail of a paid sale.
void main() {
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late _MockCustomerRepository customers;

  setUp(() {
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    customers = _MockCustomerRepository();
    when(() => customers.get(customerId: any(named: 'customerId'))).thenAnswer(
      (_) async => const Customer(
        customerId: 7,
        code: 'C-7',
        name: 'Ana Compradora',
        creditLimit: '0',
        creditDays: 0,
        priceList: PriceListRef(id: 1, name: 'Mostrador'),
        status: EntityStatus.active,
      ),
    );
    when(
      () => warehouses.list(facilityId: any(named: 'facilityId'), limit: 100),
    ).thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));
    when(() => payments.listForOrder(saleId: any(named: 'saleId'))).thenAnswer(
      (_) async => [
        SalePayment(
          id: 1,
          customerPayment: 500,
          amount: '200.00',
          methodCode: 1,
          currency: Currency.mxn,
          changeAmount: '84.00',
          cancelled: false,
          type: PaymentType.immediate,
          paymentDate: DateTime(2026, 8, 5, 14, 30),
        ),
      ],
    );
  });

  Future<void> pumpDetail(
    WidgetTester tester, {
    bool canReadPayments = true,
    bool canReadSalesOrders = true,
    String? salespersonName = 'Luis Vendedor',
    Size surface = const Size(1440, 900),
  }) => pumpPos(
    tester,
    PosSaleDetailView(
      sale: testSale(
        status: SaleStatus.paid,
        balance: '0',
        serial: 1234,
        lines: [testLine()],
      ),
    ),
    surface: surface,
    overrides: <Override>[
      authProvider.overrideWith(
        () => _FixedAuthNotifier(
          AuthState.authenticated(
            token: 't',
            user: User(
              userId: 'cashier-1',
              email: 'cashier@example.com',
              administrator: false,
              status: EntityStatus.active,
              sessionVersion: 1,
              settings: const UserSettings(
                pointSaleId: 3,
                pointSaleName: 'Caja 1',
              ),
              privileges: [
                if (canReadPayments)
                  const Privilege(
                    systemObject: SystemObject.customerPayments,
                    rawValue: 2,
                  ),
                if (canReadSalesOrders)
                  const Privilege(
                    systemObject: SystemObject.salesOrders,
                    rawValue: 2,
                  ),
              ],
            ),
          ),
        ),
      ),
      customerRepositoryProvider.overrideWithValue(customers),
      customerPaymentOverride(payments),
      warehouseOverride(warehouses),
      employeeDisplayNameProvider.overrideWith(
        (ref, id) async => salespersonName,
      ),
    ],
  );

  testWidgets(
    'the facts strip names customer, date, register and salesperson',
    (tester) async {
      await pumpDetail(tester);
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      final facts = find.byKey(const Key('pos_sale_detail_facts'));

      for (final text in [
        l10n.posCustomerNameLabel,
        'Ana Compradora',
        l10n.posSaleDetailDateLabel,
        l10n.posSaleDetailRegisterLabel,
        'Caja 1',
        l10n.salesOrderSalespersonLabel,
        'Luis Vendedor',
      ]) {
        expect(
          find.descendant(of: facts, matching: find.text(text)),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('the salesperson falls back to the id when the name is unknown', (
    tester,
  ) async {
    await pumpDetail(tester, salespersonName: null);

    expect(
      find.descendant(
        of: find.byKey(const Key('pos_sale_detail_facts')),
        matching: find.text('100'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('lines are disabled, and there is no selector, track or action', (
    tester,
  ) async {
    await pumpDetail(tester);

    final row = tester.widget<SaleLineRow>(find.byType(SaleLineRow));
    expect(row.enabled, isFalse);
    expect(find.byIcon(Icons.undo), findsNothing);
    expect(find.byKey(const Key('pos_continue_to_payment')), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byKey(const Key('pos_step_indicator')), findsNothing);
    expect(find.byKey(const Key('pos_open_sales_selector')), findsNothing);
    expect(
      tester.widget<SaleTotalsBar>(find.byType(SaleTotalsBar)).showAction,
      isFalse,
    );
  });

  testWidgets('payments show method, amount, change and date', (tester) async {
    await pumpDetail(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    final section = find.byKey(const Key('pos_sale_detail_payments'));

    expect(
      find.descendant(of: section, matching: find.text(r'$200.00')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: section,
        matching: find.textContaining('${l10n.posPaymentChangeLabel}: '),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: section,
        matching: find.textContaining('${l10n.posPaymentDateLabel}: '),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.undo), findsNothing);
  });

  testWidgets('without customer-payments read the forbidden text shows and the '
      'payments are never fetched', (tester) async {
    await pumpDetail(tester, canReadPayments: false);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.text(l10n.posSaleDetailPaymentsForbidden), findsOneWidget);
    verifyNever(() => payments.listForOrder(saleId: any(named: 'saleId')));
  });

  testWidgets('a 403 from the payments call shows the same text', (
    tester,
  ) async {
    when(() => payments.listForOrder(saleId: any(named: 'saleId'))).thenThrow(
      const AppError.server(
        statusCode: 403,
        message: 'Insufficient privileges',
      ),
    );
    await pumpDetail(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    expect(find.text(l10n.posSaleDetailPaymentsForbidden), findsOneWidget);
  });

  testWidgets('the ticket button shows with canOpenDocument', (tester) async {
    await pumpDetail(tester);
    expect(find.byKey(const Key('pos_sale_detail_ticket')), findsOneWidget);
  });

  testWidgets('the ticket button is absent without canOpenDocument', (
    tester,
  ) async {
    await pumpDetail(tester, canReadSalesOrders: false);
    expect(find.byKey(const Key('pos_sale_detail_ticket')), findsNothing);
  });

  testWidgets(
    'at 390 px it is one column with cards and no horizontal scroll',
    (tester) async {
      await pumpDetail(tester, surface: const Size(390, 844));

      expect(tester.takeException(), isNull);
      expect(find.byType(SaleLineCard), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          // A text field's own scrollable is horizontal; a layout's is not.
          (w) =>
              w is Scrollable &&
              w.axis == Axis.horizontal &&
              w.restorationId != 'editable',
        ),
        findsNothing,
      );
      expect(find.byKey(const Key('pos_sale_detail_payments')), findsOneWidget);
    },
  );
}
