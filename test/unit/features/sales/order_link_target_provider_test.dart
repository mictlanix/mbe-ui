import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_link_providers.dart';

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

const _read = 2;

User _userWith(List<SystemObject> objects) => User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    for (final object in objects)
      Privilege(systemObject: object, rawValue: _read),
  ],
);

Sale _sale({SaleOrigin? origin}) => Sale(
  id: 5512,
  facility: 3,
  pointSale: 3,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  promiseDate: DateTime(2026, 10, 27),
  status: SaleStatus.completed,
  subtotal: '100',
  taxTotal: '16',
  total: '116',
  balance: '116',
  date: DateTime(2026, 10, 27),
  dueDate: DateTime(2026, 10, 27),
  priority: Priority.normal,
  origin: origin,
);

ProviderContainer _containerFor(User user, SalesOrderRepository repository) {
  return ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      salesOrderRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockSalesOrderRepository repository;

  setUp(() {
    repository = MockSalesOrderRepository();
  });

  group('orderLinkTargetProvider (FR-015, R8)', () {
    test('a back-office order opens in Pedidos', () async {
      when(
        () => repository.getById(saleId: 5512),
      ).thenAnswer((_) async => _sale(origin: SaleOrigin.backOffice));
      final container = _containerFor(
        _userWith([SystemObject.salesOrders]),
        repository,
      );
      addTearDown(container.dispose);

      expect(
        await container.read(orderLinkTargetProvider(5512).future),
        '/sales/orders/5512',
      );
    });

    test(
      'a register sale opens in the register for a user who can read it',
      () async {
        when(
          () => repository.getById(saleId: 5512),
        ).thenAnswer((_) async => _sale(origin: SaleOrigin.pointOfSale));
        final container = _containerFor(
          _userWith([SystemObject.salesOrders, SystemObject.pos]),
          repository,
        );
        addTearDown(container.dispose);

        expect(
          await container.read(orderLinkTargetProvider(5512).future),
          '/sales/pos/5512',
        );
      },
    );

    test('a register sale is plain text without POS read', () async {
      when(
        () => repository.getById(saleId: 5512),
      ).thenAnswer((_) async => _sale(origin: SaleOrigin.pointOfSale));
      final container = _containerFor(
        _userWith([SystemObject.salesOrders]),
        repository,
      );
      addTearDown(container.dispose);

      expect(
        await container.read(orderLinkTargetProvider(5512).future),
        isNull,
      );
    });

    test('an order with no origin that carries a payment reads as a register '
        'sale, as the order workspace itself does', () async {
      when(
        () => repository.getById(saleId: 5512),
      ).thenAnswer((_) async => _sale(origin: null).copyWith(balance: '0'));
      final container = _containerFor(
        _userWith([SystemObject.salesOrders, SystemObject.pos]),
        repository,
      );
      addTearDown(container.dispose);

      expect(
        await container.read(orderLinkTargetProvider(5512).future),
        '/sales/pos/5512',
      );
    });

    test(
      'without Sales Orders read it is plain text and nothing is fetched',
      () async {
        final container = _containerFor(
          _userWith([SystemObject.pos]),
          repository,
        );
        addTearDown(container.dispose);

        expect(
          await container.read(orderLinkTargetProvider(5512).future),
          isNull,
        );
        verifyNever(() => repository.getById(saleId: any(named: 'saleId')));
      },
    );

    test('a fetch error is plain text, not a failure', () async {
      when(
        () => repository.getById(saleId: 5512),
      ).thenThrow(const AppError.notFound());
      final container = _containerFor(
        _userWith([SystemObject.salesOrders]),
        repository,
      );
      addTearDown(container.dispose);

      expect(
        await container.read(orderLinkTargetProvider(5512).future),
        isNull,
      );
    });
  });
}
