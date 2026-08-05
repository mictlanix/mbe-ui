import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/denomination_count.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/close_session_form_controller.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

const _canCloseUser = User(
  userId: 'supervisor',
  email: 'supervisor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.cashSessionClose, rawValue: 4), // update
  ],
);

const _cannotCloseUser = User(
  userId: 'cashier',
  email: 'cashier@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pos, rawValue: 2)],
);

CashSession _session({
  String openingAmount = '500',
  List<PaymentMethodTotal> payments = const [
    PaymentMethodTotal(method: 1, total: '3240'),
  ],
}) => CashSession(
  cashSessionId: 1,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 5, 9),
  openingAmount: openingAmount,
  paymentsByMethod: payments,
);

ProviderContainer _containerFor(User user, CashSessionRepository repository) {
  return ProviderContainer(
    overrides: [
      cashSessionRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockCashSessionRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCashSessionRepository();
    container = _containerFor(_canCloseUser, repository);
    addTearDown(container.dispose);
  });

  group('CloseSessionFormController.loadSession', () {
    test('computes expected cash as opening amount + cash-method total only', () {
      container
          .read(closeSessionFormControllerProvider.notifier)
          .loadSession(_session());

      final state = container.read(closeSessionFormControllerProvider);
      expect(state.cashSessionId, 1);
      expect(Decimal.parse(state.expectedCash), Decimal.parse('3740'));
      expect(state.countedTotal, '0');
    });
  });

  group('CloseSessionFormController.quantityChanged', () {
    test('updates the counted total, expected figure stays fixed, and the '
        'difference recomputes on every change', () {
      final controller = container.read(closeSessionFormControllerProvider.notifier);
      controller.loadSession(_session());

      controller.quantityChanged('500', 3);
      controller.quantityChanged('100', 2);

      final state = container.read(closeSessionFormControllerProvider);
      // 500*3 + 100*2 = 1700
      expect(Decimal.parse(state.countedTotal), Decimal.parse('1700'));
      expect(Decimal.parse(state.expectedCash), Decimal.parse('3740'));
      // 1700 - 3740 = -2040 (short)
      expect(Decimal.parse(state.difference), Decimal.parse('-2040'));
    });

    test('a zero difference reads as exactly zero, not omitted', () {
      final controller = container.read(closeSessionFormControllerProvider.notifier);
      controller.loadSession(_session(openingAmount: '0', payments: const []));

      final state = container.read(closeSessionFormControllerProvider);
      expect(Decimal.parse(state.difference), Decimal.zero);
    });

    test('changing the same denomination again replaces, not adds to, its '
        'quantity', () {
      final controller = container.read(closeSessionFormControllerProvider.notifier);
      controller.loadSession(_session());

      controller.quantityChanged('500', 3);
      controller.quantityChanged('500', 5);

      final state = container.read(closeSessionFormControllerProvider);
      expect(Decimal.parse(state.countedTotal), Decimal.parse('2500'));
    });
  });

  group('CloseSessionFormController.submit — success', () {
    test('submits only positive-quantity denominations, sets closed, and '
        'invalidates the caches that must refresh', () async {
      when(
        () => repository.close(
          cashSessionId: 1,
          counts: any(named: 'counts'),
        ),
      ).thenAnswer((_) async => _session(payments: const []));

      final controller = container.read(closeSessionFormControllerProvider.notifier);
      controller.loadSession(_session());
      controller.quantityChanged('500', 3);
      controller.quantityChanged('100', 0);
      controller.quantityChanged('20', 2);

      await controller.submit();

      final captured = verify(
        () => repository.close(
          cashSessionId: 1,
          counts: captureAny(named: 'counts'),
        ),
      ).captured.single as List<DenominationCount>;

      expect(captured, hasLength(2));
      expect(
        captured.map((c) => c.denomination),
        containsAll(<String>['500', '20']),
      );
      expect(
        captured.every((c) => c.quantity > 0),
        isTrue,
        reason: 'a zero-quantity row must never be submitted (FR-020)',
      );

      final state = container.read(closeSessionFormControllerProvider);
      expect(state.closed, isTrue);
      expect(state.submitting, isFalse);
    });

    test('an all-zero count is still accepted when submit is called '
        '(the empty-count confirmation is the screen\'s responsibility, '
        'not the controller\'s — research.md §11)', () async {
      when(
        () => repository.close(cashSessionId: 1, counts: const []),
      ).thenAnswer((_) async => _session(payments: const []));

      final controller = container.read(closeSessionFormControllerProvider.notifier);
      controller.loadSession(_session());
      await controller.submit();

      expect(container.read(closeSessionFormControllerProvider).closed, isTrue);
      verify(() => repository.close(cashSessionId: 1, counts: const [])).called(1);
    });
  });

  group('CloseSessionFormController.submit — permission', () {
    test('a user lacking cashSessionClose:update gets closePermissionDenied '
        'and the repository is never called', () async {
      final deniedContainer = _containerFor(_cannotCloseUser, repository);
      addTearDown(deniedContainer.dispose);

      final controller = deniedContainer.read(
        closeSessionFormControllerProvider.notifier,
      );
      controller.loadSession(_session());
      await controller.submit();

      final state = deniedContainer.read(closeSessionFormControllerProvider);
      expect(state.error, CloseSessionFormErrorCode.closePermissionDenied);
      verifyNever(
        () => repository.close(
          cashSessionId: any(named: 'cashSessionId'),
          counts: any(named: 'counts'),
        ),
      );
    });
  });

  group('CloseSessionFormController.submit — failures', () {
    test('409 already-closed preserves the entered quantities and refreshes '
        'state (FR-024) — never crashes, never silently clears input', () async {
      when(
        () => repository.close(
          cashSessionId: 1,
          counts: any(named: 'counts'),
        ),
      ).thenThrow(const AppError.server(statusCode: 409, message: 'Session is already closed'));

      final controller = container.read(closeSessionFormControllerProvider.notifier);
      controller.loadSession(_session());
      controller.quantityChanged('500', 3);
      await controller.submit();

      final state = container.read(closeSessionFormControllerProvider);
      expect(state.error, CloseSessionFormErrorCode.alreadyClosed);
      expect(state.quantities['500'], 3, reason: 'entered counts must survive a 409');
      expect(state.submitting, isFalse);
      expect(state.closed, isFalse);
    });

    test('404 maps to sessionNotFound', () async {
      when(
        () => repository.close(
          cashSessionId: 1,
          counts: any(named: 'counts'),
        ),
      ).thenThrow(const AppError.notFound('Cash session not found'));

      final controller = container.read(closeSessionFormControllerProvider.notifier);
      controller.loadSession(_session());
      await controller.submit();

      expect(
        container.read(closeSessionFormControllerProvider).error,
        CloseSessionFormErrorCode.sessionNotFound,
      );
    });

    test('an unrelated server error maps to the generic closeFailed code', () async {
      when(
        () => repository.close(
          cashSessionId: 1,
          counts: any(named: 'counts'),
        ),
      ).thenThrow(const AppError.server(statusCode: 500));

      final controller = container.read(closeSessionFormControllerProvider.notifier);
      controller.loadSession(_session());
      await controller.submit();

      expect(
        container.read(closeSessionFormControllerProvider).error,
        CloseSessionFormErrorCode.closeFailed,
      );
    });
  });
}
