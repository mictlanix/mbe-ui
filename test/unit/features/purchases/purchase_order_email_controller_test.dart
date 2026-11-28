import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/contact.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_email_controller.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_email_controller.dart'
    show AddTypedResult, RecipientOrigin, RecipientToggleResult;

class MockPurchaseOrderRepository extends Mock
    implements PurchaseOrderRepository {}

class MockSupplierRepository extends Mock implements SupplierRepository {}

User _user({bool suppliersRead = true}) => User(
  userId: 'buyer',
  email: 'buyer@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: const UserSettings(),
  privileges: [
    const Privilege(systemObject: SystemObject.purchasesOrders, rawValue: 15),
    if (suppliersRead)
      const Privilege(systemObject: SystemObject.suppliers, rawValue: 2),
  ],
);

AppError _coded(api.ErrorCode code, String codeName) => AppError.server(
  statusCode: 502,
  message: 'SERVER TEXT',
  problem: ApiProblem(codeName: codeName, code: code, detail: 'SERVER TEXT'),
);

/// Spec 080 research R14 (T027).
void main() {
  late MockPurchaseOrderRepository orders;
  late MockSupplierRepository suppliers;
  late ProviderContainer container;
  final provider = purchaseOrderEmailControllerProvider(5531);

  final supplier = Supplier(
    supplierId: 12,
    code: 'FN',
    name: 'Ferretera del Norte',
    creditLimit: '0',
    creditDays: 0,
    contacts: const [
      Contact(contactId: 1, name: 'Ventas', email: 'ventas@fn.mx'),
      Contact(contactId: 2, name: 'Sin correo'),
      Contact(contactId: 3, name: 'Roto', email: 'no-es-correo'),
      Contact(contactId: 4, name: 'Jorge Luna', email: 'j.luna@fn.mx'),
      // The same address in another case is one chip.
      Contact(contactId: 5, name: 'Duplicado', email: 'VENTAS@fn.mx'),
    ],
  );

  void boot({bool suppliersRead = true}) {
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseOrderRepositoryProvider.overrideWithValue(orders),
        supplierRepositoryProvider.overrideWithValue(suppliers),
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(
              token: 't',
              user: _user(suppliersRead: suppliersRead),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Keeps the autodispose family alive, as the open dialog does.
    container.listen(provider, (_, _) {});
  }

  PurchaseOrderEmailController controller() =>
      container.read(provider.notifier);
  PurchaseOrderEmailState state() => container.read(provider);

  setUp(() {
    orders = MockPurchaseOrderRepository();
    suppliers = MockSupplierRepository();
  });

  group('suggestions', () {
    test('are the supplier contacts with a valid email, once each', () async {
      when(
        () => suppliers.get(supplierId: 12),
      ).thenAnswer((_) async => supplier);
      boot();

      await controller().loadSuggestions(12);

      expect(state().suggestions, EmailSuggestions.loaded);
      expect(state().chips.map((c) => c.address), [
        'ventas@fn.mx',
        'j.luna@fn.mx',
      ]);
      expect(state().chips.first.owner, 'Ventas');
      expect(state().chips.first.origin, RecipientOrigin.contact);
      // Suggested, not selected.
      expect(state().selected, isEmpty);
    });

    test('are not fetched without read on Suppliers', () async {
      boot(suppliersRead: false);

      await controller().loadSuggestions(12);

      expect(state().suggestions, EmailSuggestions.none);
      expect(state().chips, isEmpty);
      verifyNever(() => suppliers.get(supplierId: any(named: 'supplierId')));
    });

    test('are not fetched for an order without a supplier', () async {
      boot();

      await controller().loadSuggestions(null);

      expect(state().suggestions, EmailSuggestions.none);
    });

    test('a failure leaves typing working', () async {
      when(
        () => suppliers.get(supplierId: 12),
      ).thenAnswer((_) async => throw const AppError.network());
      boot();

      await controller().loadSuggestions(12);

      expect(state().suggestions, EmailSuggestions.failed);
      expect(controller().addTyped('otro@fn.mx'), AddTypedResult.added);
      expect(state().recipients, ['otro@fn.mx']);
    });
  });

  group('recipients', () {
    test('a typed address is added selected; removing deselects it', () {
      boot();

      expect(controller().addTyped('  compras@fn.mx '), AddTypedResult.added);
      expect(state().recipients, ['compras@fn.mx']);

      expect(
        controller().toggle('compras@fn.mx'),
        RecipientToggleResult.toggled,
      );
      expect(state().recipients, isEmpty);
      // The chip stays to be picked again.
      expect(state().chips, hasLength(1));
    });

    test('a typed address already shown selects that chip', () {
      boot();
      controller().seed(supplier.contacts);

      expect(
        controller().addTyped('Ventas@FN.mx'),
        AddTypedResult.selectedExisting,
      );
      expect(state().chips, hasLength(2));
      expect(state().recipients, ['ventas@fn.mx']);
    });

    test('an invalid address is refused', () {
      boot();

      expect(controller().addTyped('no-es-correo'), AddTypedResult.invalid);
      expect(state().chips, isEmpty);
    });

    test('an eleventh recipient is refused', () {
      boot();
      for (var i = 0; i < 10; i++) {
        expect(controller().addTyped('r$i@fn.mx'), AddTypedResult.added);
      }

      expect(state().atLimit, isTrue);
      expect(controller().addTyped('r10@fn.mx'), AddTypedResult.limitReached);
      controller().seed(supplier.contacts);
      expect(
        controller().toggle('ventas@fn.mx'),
        RecipientToggleResult.limitReached,
      );
      expect(state().selected, hasLength(10));
      expect(state().canSend, isTrue);
    });

    test('nothing selected cannot be sent', () {
      boot();
      expect(state().canSend, isFalse);
    });
  });

  group('send', () {
    final receipt = OrderEmailReceipt(
      recipients: const ['ventas@fn.mx'],
      sentAt: DateTime(2026, 11, 27, 10),
    );

    void stubSend(Future<OrderEmailReceipt> Function() answer) => when(
      () => orders.email(
        5531,
        recipients: any(named: 'recipients'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) => answer());

    test('passes the recipients and the message through', () async {
      stubSend(() async => receipt);
      boot();
      controller().addTyped('ventas@fn.mx');
      controller().setMessage('  Favor de confirmar la entrega.  ');

      expect(await controller().send(), receipt);
      verify(
        () => orders.email(
          5531,
          recipients: ['ventas@fn.mx'],
          message: 'Favor de confirmar la entrega.',
        ),
      ).called(1);
      expect(state().sending, isFalse);
      expect(state().failure, isNull);
    });

    test('a blank message is sent as none', () async {
      stubSend(() async => receipt);
      boot();
      controller().addTyped('ventas@fn.mx');
      controller().setMessage('   ');

      await controller().send();

      verify(
        () => orders.email(5531, recipients: ['ventas@fn.mx'], message: null),
      ).called(1);
    });

    test('a message over 1000 characters cannot be sent', () {
      boot();
      controller().addTyped('ventas@fn.mx');
      controller().setMessage('x' * 1001);

      expect(state().canSend, isFalse);
    });

    for (final (code, codeName, failure) in [
      (
        api.ErrorCode.emailPeriodSendFailed,
        'email.send_failed',
        PurchaseOrderEmailFailure.sendFailed,
      ),
      (
        api.ErrorCode.emailPeriodNotConfigured,
        'email.not_configured',
        PurchaseOrderEmailFailure.notConfigured,
      ),
      (
        api.ErrorCode.purchaseOrderPeriodNotConfirmed,
        'purchase_order.not_confirmed',
        PurchaseOrderEmailFailure.notConfirmed,
      ),
    ]) {
      test('$codeName is recognized by its code and keeps the input', () async {
        // Every refusal answers the same status here: only the code tells
        // them apart.
        final error = _coded(code, codeName);
        stubSend(() async => throw error);
        boot();
        controller().addTyped('ventas@fn.mx');
        controller().setMessage('Hola');

        expect(await controller().send(), isNull);

        expect(state().failure, failure);
        expect(state().failureError, error);
        expect(state().recipients, ['ventas@fn.mx']);
        expect(state().message, 'Hola');
        expect(state().sending, isFalse);
        expect(
          state().sawNotConfirmed,
          failure == PurchaseOrderEmailFailure.notConfirmed,
        );
      });
    }

    test('an uncoded failure is "other"', () async {
      stubSend(() async => throw const AppError.network());
      boot();
      controller().addTyped('ventas@fn.mx');

      await controller().send();

      expect(state().failure, PurchaseOrderEmailFailure.other);
      controller().clearFailure();
      expect(state().failure, isNull);
      expect(state().failureError, isNull);
    });
  });
}
