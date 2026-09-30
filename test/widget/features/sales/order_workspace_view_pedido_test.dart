import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/data/printing_document_output.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/presentation/document_preview_dialog.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_repository.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_header_panel.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/core/documents/document_fakes.dart';
import 'pos_test_harness.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockDeliveryOrderRepository extends Mock
    implements DeliveryOrderRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Reads and updates sales orders: may open a pedido.
const _readerUser = User(
  userId: 'order-reader',
  email: 'order-reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 6)],
);

/// Updates but does not read: the workspace's existing tests' user.
const _updaterOnlyUser = User(
  userId: 'order-updater',
  email: 'order-updater@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.salesOrders, rawValue: 4)],
);

Customer _customer() => const Customer(
  customerId: 7,
  code: 'C-7',
  name: 'PÚBLICO EN GENERAL',
  creditLimit: '0',
  creditDays: 0,
  priceList: PriceListRef(id: 1, name: 'Mostrador'),
  status: EntityStatus.active,
);

/// Spec 044 US5: "Ver pedido" in the order workspace header.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockCustomerRepository customers;
  late MockCustomerPaymentRepository payments;
  late MockWarehouseRepository warehouses;
  late MockDeliveryOrderRepository deliveries;
  late FakeDocumentSource source;
  late FakeDocumentOutput output;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    customers = MockCustomerRepository();
    payments = MockCustomerPaymentRepository();
    warehouses = MockWarehouseRepository();
    deliveries = MockDeliveryOrderRepository();
    source = FakeDocumentSource();
    output = FakeDocumentOutput();

    when(
      () => customers.get(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => _customer());
    when(
      () =>
          payments.outstandingBalanceFor(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => '0');
    // A completed order opens on the delivery step, which lists its
    // deliveries.
    when(
      () => deliveries.listForSale(salesOrder: any(named: 'salesOrder')),
    ).thenAnswer((_) async => const []);
  });

  void stubOrder(SaleStatus status) {
    when(() => salesOrders.getById(saleId: 42)).thenAnswer(
      (_) async => testSale(
        id: 42,
        serial: 1001,
        status: status,
        lines: [testLine()],
        origin: SaleOrigin.backOffice,
      ),
    );
  }

  Future<ProviderContainer> pumpOrder(
    WidgetTester tester, {
    User user = _readerUser,
  }) async {
    final (_, container) = await pumpOrdersRouted(
      tester,
      initialLocation: '/sales/orders/42',
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(
            AuthState.authenticated(token: 't', user: user),
          ),
        ),
        salesOrderOverride(salesOrders),
        warehouseOverride(warehouses),
        customerRepositoryProvider.overrideWithValue(customers),
        customerPaymentOverride(payments),
        deliveryOrderRepositoryProvider.overrideWithValue(deliveries),
        documentSourceProvider.overrideWithValue(source),
        documentOutputProvider.overrideWithValue(output),
      ],
    );
    return container;
  }

  final button = find.byKey(const Key('sales_order_view_pedido_button'));

  group('availability (FR-004, FR-040)', () {
    for (final status in SaleStatus.values) {
      testWidgets('is offered for an order that is $status', (tester) async {
        stubOrder(status);
        await pumpOrder(tester);

        expect(button, findsOneWidget);
        expect(find.text('Ver pedido'), findsOneWidget);
      });
    }

    testWidgets('is absent — not disabled — without sales-orders read', (
      tester,
    ) async {
      stubOrder(SaleStatus.draft);
      await pumpOrder(tester, user: _updaterOnlyUser);

      expect(button, findsNothing);
    });

    testWidgets('is a body action inside the header panel, never in the app '
        'bar (constitution §VI)', (tester) async {
      stubOrder(SaleStatus.draft);
      await pumpOrder(tester);

      expect(
        find.descendant(of: find.byType(OrderHeaderPanel), matching: button),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(AppBar), matching: button),
        findsNothing,
      );
    });
  });

  group('opening it (US5-2)', () {
    testWidgets('with nothing pending or unconfirmed, opens the pedido in '
        'the preview at once', (tester) async {
      stubOrder(SaleStatus.completed);
      await pumpOrder(tester);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched, hasLength(1));
      expect(source.fetched.single.kind, DocumentKind.salesOrder);
      expect(source.fetched.single.recordId, 42);
      expect(source.fetched.single.title, 'Pedido · 00000042');
    });
  });

  group('edits still being saved (FR-009)', () {
    testWidgets('is disabled while a write is pending, and enabled again '
        'when it lands', (tester) async {
      stubOrder(SaleStatus.draft);
      final container = await pumpOrder(tester);
      final writes = container.read(
        pendingWritesProvider(salesOrderWritesScope).notifier,
      );
      expect(tester.widget<OutlinedButton>(button).onPressed, isNotNull);

      final hold = writes.begin();
      await tester.pump();
      expect(tester.widget<OutlinedButton>(button).onPressed, isNull);

      writes.end(hold);
      await tester.pump();
      expect(tester.widget<OutlinedButton>(button).onPressed, isNotNull);
    });
  });

  group('unconfirmed typed text (FR-009, US5-3)', () {
    late int confirmed;
    late int discarded;
    late int resumed;

    setUp(() {
      confirmed = discarded = resumed = 0;
    });

    /// Registers a field holding text the user typed and did not confirm.
    void registerUnconfirmedEdit(ProviderContainer container) {
      container
          .read(unconfirmedEditsProvider(salesOrderWritesScope).notifier)
          .put(
            UnconfirmedEdit(
              id: 'comment',
              text: 'Entregar por la tarde',
              confirm: () async {
                confirmed++;
                return true;
              },
              discard: () => discarded++,
              resume: () => resumed++,
            ),
          );
    }

    testWidgets('asks first, using the workspace\'s existing prompt', (
      tester,
    ) async {
      stubOrder(SaleStatus.draft);
      final container = await pumpOrder(tester);
      registerUnconfirmedEdit(container);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text(l10n.posUnconfirmedChangesTitle), findsOneWidget);
      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(source.fetched, isEmpty, reason: 'nothing is fetched until asked');
    });

    testWidgets('"Seguir editando" cancels: no preview, no fetch, and the '
        'draft is kept', (tester) async {
      stubOrder(SaleStatus.draft);
      final container = await pumpOrder(tester);
      registerUnconfirmedEdit(container);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesKeepEditing));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(source.fetched, isEmpty);
      expect(resumed, 1);
      expect(confirmed, 0);
      expect(discarded, 0);
    });

    testWidgets('"Conservar" saves the text first, then opens the pedido', (
      tester,
    ) async {
      stubOrder(SaleStatus.draft);
      final container = await pumpOrder(tester);
      registerUnconfirmedEdit(container);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
      await tester.pumpAndSettle();

      expect(confirmed, 1);
      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
      expect(source.fetched.single.recordId, 42);
    });

    testWidgets('"Descartar" drops the text, then opens the pedido', (
      tester,
    ) async {
      stubOrder(SaleStatus.draft);
      final container = await pumpOrder(tester);
      registerUnconfirmedEdit(container);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesDiscard));
      await tester.pumpAndSettle();

      expect(discarded, 1);
      expect(confirmed, 0);
      expect(find.byType(DocumentPreviewDialog), findsOneWidget);
    });

    testWidgets('a failed "Conservar" (the server refused the text) does not '
        'open the pedido', (tester) async {
      stubOrder(SaleStatus.draft);
      final container = await pumpOrder(tester);
      container
          .read(unconfirmedEditsProvider(salesOrderWritesScope).notifier)
          .put(
            UnconfirmedEdit(
              id: 'comment',
              text: 'x',
              confirm: () async => false,
              discard: () {},
              resume: () {},
            ),
          );

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.posUnconfirmedChangesKeep));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentPreviewDialog), findsNothing);
      expect(source.fetched, isEmpty);
    });
  });
}
