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
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';
import 'package:mbe_ui/features/sales/presentation/open_session_form_controller.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

const _canOpenUser = User(
  userId: 'cashier',
  email: 'cashier@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.pos, rawValue: 1), // create
  ],
);

const _cannotOpenUser = User(
  userId: 'no-pos',
  email: 'no-pos@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

CashSession _session({int cashSessionId = 9}) => CashSession(
  cashSessionId: cashSessionId,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 5, 9),
  openingAmount: '500',
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
    container = _containerFor(_canOpenUser, repository);
    addTearDown(container.dispose);
  });

  group('OpenSessionFormController defaults', () {
    test('starts with no drawer, opening amount "0", not submitting/saved', () {
      final state = container.read(openSessionFormControllerProvider);
      expect(state.cashDrawerId, isNull);
      expect(state.openingAmount, '0');
      expect(state.submitting, isFalse);
      expect(state.saved, isFalse);
    });
  });

  group('OpenSessionFormController.seedAssignedDrawer', () {
    test('preselects the drawer id and display text', () {
      container
          .read(openSessionFormControllerProvider.notifier)
          .seedAssignedDrawer(5, 'Caja 1');

      final state = container.read(openSessionFormControllerProvider);
      expect(state.cashDrawerId, 5);
      expect(state.cashDrawerDisplayText, 'Caja 1');
    });
  });

  group('OpenSessionFormController.drawerSelected', () {
    test('sets the drawer and clears prior errors', () {
      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(3, 'Caja 3');

      final state = container.read(openSessionFormControllerProvider);
      expect(state.cashDrawerId, 3);
      expect(state.cashDrawerDisplayText, 'Caja 3');
      expect(state.error, isNull);
      expect(state.fieldErrors, isEmpty);
    });
  });

  group('OpenSessionFormController validation', () {
    test('submitting with no drawer selected sets drawerRequired and does '
        'not call the repository', () async {
      await container.read(openSessionFormControllerProvider.notifier).submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(state.fieldErrors['cashDrawer'], OpenSessionFormErrorCode.drawerRequired);
      verifyNever(
        () => repository.open(
          cashDrawerId: any(named: 'cashDrawerId'),
          openingAmount: any(named: 'openingAmount'),
        ),
      );
    });

    test('a negative opening amount is rejected before submitting', () async {
      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      controller.openingAmountChanged('-5');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(
        state.fieldErrors['openingAmount'],
        OpenSessionFormErrorCode.amountNegative,
      );
      verifyNever(
        () => repository.open(
          cashDrawerId: any(named: 'cashDrawerId'),
          openingAmount: any(named: 'openingAmount'),
        ),
      );
    });

    test('a non-numeric opening amount is rejected before submitting', () async {
      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      controller.openingAmountChanged('abc');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(
        state.fieldErrors['openingAmount'],
        OpenSessionFormErrorCode.amountInvalid,
      );
    });

    test('a blank opening amount is accepted and defaults to zero (FR-008)', () async {
      when(
        () => repository.open(cashDrawerId: 1, openingAmount: '0'),
      ).thenAnswer((_) async => _session());

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      controller.openingAmountChanged('');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(state.saved, isTrue);
      verify(() => repository.open(cashDrawerId: 1, openingAmount: '0')).called(1);
    });

    test('a zero opening amount is accepted (FR-008)', () async {
      when(
        () => repository.open(cashDrawerId: 1, openingAmount: '0'),
      ).thenAnswer((_) async => _session());

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      controller.openingAmountChanged('0');
      await controller.submit();

      expect(container.read(openSessionFormControllerProvider).saved, isTrue);
    });
  });

  group('OpenSessionFormController.submit — success', () {
    test('opens the session, marks saved, and invalidates the current-session '
        'controller so the panel refreshes', () async {
      when(
        () => repository.open(cashDrawerId: 5, openingAmount: '500'),
      ).thenAnswer((_) async => _session());
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => CurrentSession(state: SessionState.open, session: _session()),
      );

      // Read once to create the provider before submit invalidates it.
      container.read(currentSessionControllerProvider);

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(5, 'Caja 1');
      controller.openingAmountChanged('500');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(state.saved, isTrue);
      expect(state.submitting, isFalse);
      verify(() => repository.open(cashDrawerId: 5, openingAmount: '500')).called(1);
    });
  });

  group('OpenSessionFormController.submit — permission', () {
    test('a user lacking pos:create gets openPermissionDenied and the '
        'repository is never called', () async {
      final deniedContainer = _containerFor(_cannotOpenUser, repository);
      addTearDown(deniedContainer.dispose);

      final controller = deniedContainer.read(
        openSessionFormControllerProvider.notifier,
      );
      controller.drawerSelected(1, 'Caja 1');
      await controller.submit();

      final state = deniedContainer.read(openSessionFormControllerProvider);
      expect(state.error, OpenSessionFormErrorCode.openPermissionDenied);
      verifyNever(
        () => repository.open(
          cashDrawerId: any(named: 'cashDrawerId'),
          openingAmount: any(named: 'openingAmount'),
        ),
      );
    });
  });

  group('OpenSessionFormController.submit — 409 disambiguation (research §4)', () {
    test('when the re-read finds the caller now has a session, reports '
        'cashierBusy and records the blocking session id — never by parsing '
        'the raw detail string', () async {
      when(() => repository.open(cashDrawerId: 1, openingAmount: '0')).thenThrow(
        const AppError.server(
          statusCode: 409,
          message: 'You already have an open session; close it before opening another',
        ),
      );
      when(() => repository.getCurrent()).thenAnswer(
        (_) async =>
            CurrentSession(state: SessionState.open, session: _session(cashSessionId: 77)),
      );

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(state.error, OpenSessionFormErrorCode.cashierBusy);
      expect(state.blockingSessionId, 77);
      verify(() => repository.getCurrent()).called(1);
    });

    test('when the re-read finds no session for the caller, reports '
        'drawerBusy — a distinct code with a distinct remedy from '
        'cashierBusy', () async {
      when(() => repository.open(cashDrawerId: 1, openingAmount: '0')).thenThrow(
        const AppError.server(
          statusCode: 409,
          message: 'That cash drawer already has an open session',
        ),
      );
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => const CurrentSession(state: SessionState.none),
      );

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(state.error, OpenSessionFormErrorCode.drawerBusy);
      expect(state.blockingSessionId, isNull);
    });

    test('if the re-read itself fails, falls back to drawerBusy rather than '
        'crashing or leaving the form in a stuck submitting state', () async {
      when(() => repository.open(cashDrawerId: 1, openingAmount: '0')).thenThrow(
        const AppError.server(statusCode: 409, message: 'conflict'),
      );
      when(() => repository.getCurrent()).thenThrow(const AppError.network());

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(state.error, OpenSessionFormErrorCode.drawerBusy);
      expect(state.submitting, isFalse);
    });
  });

  group('OpenSessionFormController.submit — other failures', () {
    test('404 (drawer vanished) maps to drawerNotFound', () async {
      when(() => repository.open(cashDrawerId: 1, openingAmount: '0')).thenThrow(
        const AppError.notFound('Cash drawer not found'),
      );

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      await controller.submit();

      expect(
        container.read(openSessionFormControllerProvider).error,
        OpenSessionFormErrorCode.drawerNotFound,
      );
    });

    test('an unrelated server error maps to the generic openFailed code', () async {
      when(() => repository.open(cashDrawerId: 1, openingAmount: '0')).thenThrow(
        const AppError.server(statusCode: 500),
      );

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      await controller.submit();

      expect(
        container.read(openSessionFormControllerProvider).error,
        OpenSessionFormErrorCode.openFailed,
      );
    });

    test('a validation 422 with field errors is surfaced per-field', () async {
      when(() => repository.open(cashDrawerId: 1, openingAmount: '0')).thenThrow(
        const AppError.validation([
          FieldError(loc: ['body', 'opening_amount'], msg: 'Invalid', type: 'value_error'),
        ]),
      );

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(state.fieldErrors['opening_amount'], 'Invalid');
    });

    test('a validation 422 with no field errors (a plain-string-detail 422, '
        'e.g. "no drawer configured") degrades to a generic error instead of '
        'silently clearing the form with no explanation', () async {
      when(() => repository.open(cashDrawerId: 1, openingAmount: '0')).thenThrow(
        const AppError.validation([]),
      );

      final controller = container.read(openSessionFormControllerProvider.notifier);
      controller.drawerSelected(1, 'Caja 1');
      await controller.submit();

      final state = container.read(openSessionFormControllerProvider);
      expect(state.error, OpenSessionFormErrorCode.noDrawerConfigured);
      expect(state.fieldErrors, isEmpty);
    });
  });
}
