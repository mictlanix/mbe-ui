import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_editor_controller.dart';

import '../../../widget/features/sales/pos_test_harness.dart';

class _MockCashSessions extends Mock implements CashSessionRepository {}

CashSession _session() => CashSession(
  cashSessionId: 77,
  cashDrawerId: 1,
  cashDrawerName: 'Caja',
  cashDrawerCode: 'C1',
  cashierId: 5,
  cashierName: 'Ana',
  start: DateTime(2026, 10, 27),
  openingAmount: '0.00',
);

void main() {
  late MockCustomerRefundRepository refunds;
  late _MockCashSessions sessions;
  late ProviderContainer container;

  setUpAll(() => registerFallbackValue(RefundPayout.cash));

  setUp(() {
    refunds = MockCustomerRefundRepository();
    sessions = _MockCashSessions();
    when(
      () => sessions.getCurrent(),
    ).thenAnswer((_) async => const CurrentSession(state: SessionState.open));
  });

  /// A draft of one line (id 1, quantity 2 of 5) with the given total.
  CustomerRefund draft({String quantity = '2', String total = '20.00'}) =>
      testRefund(
        total: total,
        lines: [testRefundLine(quantity: quantity, total: total)],
      );

  Future<RefundEditorController> load(CustomerRefund initial) async {
    when(() => refunds.getById(9)).thenAnswer((_) async => initial);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerRefundOverride(refunds),
        cashSessionRepositoryProvider.overrideWithValue(sessions),
      ],
    );
    addTearDown(container.dispose);
    container.listen(refundEditorControllerProvider(9), (_, _) {});
    await container.read(refundEditorControllerProvider(9).future);
    return container.read(refundEditorControllerProvider(9).notifier);
  }

  CustomerRefund current() =>
      container.read(refundEditorControllerProvider(9)).requireValue;

  Future<RefundConfirmResult> confirmWith(
    RefundEditorController c,
    CustomerRefund result,
  ) {
    when(() => refunds.confirm(9, any())).thenAnswer((_) async => result);
    return c.confirm(RefundPayout.cash);
  }

  test('a quantity write publishes the totals the server returned', () async {
    final c = await load(draft(quantity: '0', total: '0.00'));
    when(
      () => refunds.updateLine(9, 1, quantity: '3'),
    ).thenAnswer((_) async => draft(quantity: '3', total: '30.00'));

    await c.setQuantity(1, '3');

    expect(current().total, '30.00');
    expect(current().lines.single.quantity, '3');
  });

  test('two quick writes run one after the other', () async {
    final c = await load(draft(quantity: '0', total: '0.00'));
    final first = Completer<CustomerRefund>();
    when(
      () => refunds.updateLine(9, 1, quantity: '1'),
    ).thenAnswer((_) => first.future);
    when(
      () => refunds.updateLine(9, 1, quantity: '2'),
    ).thenAnswer((_) async => draft(quantity: '2', total: '20.00'));

    final a = c.setQuantity(1, '1');
    final b = c.setQuantity(1, '2');
    await Future<void>.delayed(Duration.zero);

    verify(() => refunds.updateLine(9, 1, quantity: '1')).called(1);
    verifyNever(() => refunds.updateLine(9, 1, quantity: '2'));

    first.complete(draft(quantity: '1', total: '10.00'));
    await Future.wait([a, b]);

    verify(() => refunds.updateLine(9, 1, quantity: '2')).called(1);
    expect(current().total, '20.00');
  });

  test('a refused write rethrows and leaves the state unchanged', () async {
    final c = await load(draft());
    when(() => refunds.updateLine(9, 1, quantity: '9')).thenThrow(
      const AppError.validation([], 'Return quantity exceeds refundable'),
    );

    await expectLater(c.setQuantity(1, '9'), throwsA(isA<ValidationError>()));

    expect(current().lines.single.quantity, '2');
    expect(current().total, '20.00');
  });

  test(
    'confirm with no session returns sessionInvalid and sends nothing',
    () async {
      final c = await load(draft());
      when(
        () => sessions.getCurrent(),
      ).thenAnswer((_) async => const CurrentSession(state: SessionState.none));

      final result = await c.confirm(RefundPayout.cash);

      expect(result, isA<RefundSessionInvalid>());
      expect((result as RefundSessionInvalid).staleSessionId, isNull);
      verifyNever(() => refunds.confirm(any(), any()));
    },
  );

  test('confirm with a stale session names it and sends nothing', () async {
    final c = await load(draft());
    when(() => sessions.getCurrent()).thenAnswer(
      (_) async =>
          CurrentSession(state: SessionState.stale, session: _session()),
    );

    final result = await c.confirm(RefundPayout.cash);

    expect(result, isA<RefundSessionInvalid>());
    expect((result as RefundSessionInvalid).staleSessionId, 77);
    verifyNever(() => refunds.confirm(any(), any()));
  });

  test('confirm sets adjusted when the response lowers a line', () async {
    final c = await load(draft(quantity: '2'));

    final result = await confirmWith(
      c,
      testRefund(
        status: RefundStatus.completed,
        serial: 5,
        total: '10.00',
        lines: [testRefundLine(quantity: '1', total: '10.00')],
      ),
    );

    expect((result as RefundConfirmed).adjusted, isTrue);
    expect(c.adjusted, isTrue);
    expect(current().status, RefundStatus.completed);
  });

  test('confirm sets adjusted when the response drops a line', () async {
    final c = await load(
      testRefund(
        total: '30.00',
        lines: [
          testRefundLine(id: 1, quantity: '2', total: '20.00'),
          testRefundLine(id: 2, quantity: '1', total: '10.00'),
        ],
      ),
    );

    final result = await confirmWith(
      c,
      testRefund(
        status: RefundStatus.completed,
        serial: 5,
        total: '20.00',
        lines: [testRefundLine(id: 1, quantity: '2', total: '20.00')],
      ),
    );

    expect((result as RefundConfirmed).adjusted, isTrue);
  });

  test('confirm does not set adjusted when quantities are unchanged', () async {
    final c = await load(draft(quantity: '2'));

    final result = await confirmWith(
      c,
      testRefund(
        status: RefundStatus.completed,
        serial: 5,
        total: '20.00',
        lines: [testRefundLine(quantity: '2', total: '20.00')],
      ),
    );

    expect((result as RefundConfirmed).adjusted, isFalse);
    expect(c.adjusted, isFalse);
  });

  test('a network error during confirm re-reads the refund and publishes '
      'a completed one', () async {
    final c = await load(draft());
    when(
      () => refunds.confirm(9, any()),
    ).thenThrow(const AppError.network('timeout'));
    final completed = testRefund(
      status: RefundStatus.completed,
      serial: 5,
      total: '20.00',
    );
    when(() => refunds.getById(9)).thenAnswer((_) async => completed);

    await expectLater(
      c.confirm(RefundPayout.cash),
      throwsA(isA<NetworkError>()),
    );

    // One read to load, one re-read after the failure.
    verify(() => refunds.getById(9)).called(2);
    expect(current().status, RefundStatus.completed);
    expect(current().serial, 5);
  });
}
