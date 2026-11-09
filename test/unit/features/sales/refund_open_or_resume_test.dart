import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_refund_repository.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refund_open_or_resume.dart';

import '../../../widget/features/sales/pos_test_harness.dart';

void main() {
  late MockCustomerRefundRepository refunds;
  late MockSalesOrderRepository orders;

  setUp(() {
    refunds = MockCustomerRefundRepository();
    orders = MockSalesOrderRepository();
    when(
      () => refunds.list(
        salesOrderId: any(named: 'salesOrderId'),
        status: any(named: 'status'),
        customerId: any(named: 'customerId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const RefundListResult(items: [], total: 0));
  });

  /// Runs [openOrResume] with a real `WidgetRef` captured from a Consumer.
  Future<WidgetRef> pump(WidgetTester tester) async {
    late WidgetRef captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerRefundOverride(refunds),
          salesOrderOverride(orders),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return captured;
  }

  Future<RefundStart> run(WidgetTester tester, int orderId) async =>
      openOrResume(await pump(tester), orderId);

  void stubOrder(SaleStatus status) => when(
    () => orders.getById(saleId: any(named: 'saleId')),
  ).thenAnswer((_) async => testSale(status: status));

  testWidgets('an existing draft resumes without a POST', (tester) async {
    when(
      () => refunds.list(
        salesOrderId: 42,
        status: RefundStatus.draft,
        skip: 0,
        limit: 1,
      ),
    ).thenAnswer(
      (_) async => const RefundListResult(
        items: [
          CustomerRefundSummary(
            id: 9,
            salesOrderId: 42,
            currency: Currency.mxn,
            status: RefundStatus.draft,
            total: '0.00',
          ),
        ],
        total: 1,
      ),
    );

    final result = await run(tester, 42) as RefundOpened;

    expect(result.refundId, 9);
    expect(result.resumed, isTrue);
    verifyNever(() => refunds.open(any()));
    verifyNever(() => orders.getById(saleId: any(named: 'saleId')));
  });

  testWidgets('a paid order with no draft opens a new refund', (tester) async {
    stubOrder(SaleStatus.paid);
    when(() => refunds.open(42)).thenAnswer((_) async => testRefund(id: 11));

    final result = await run(tester, 42) as RefundOpened;

    expect(result.refundId, 11);
    expect(result.resumed, isFalse);
    verify(() => refunds.open(42)).called(1);
  });

  testWidgets('a draft order gives notCompleted', (tester) async {
    stubOrder(SaleStatus.draft);

    final result = await run(tester, 42) as RefundRefused;

    expect(result.reason, RefundRefusal.notCompleted);
    verifyNever(() => refunds.open(any()));
  });

  testWidgets('a completed but unpaid order gives notPaid', (tester) async {
    stubOrder(SaleStatus.completed);

    final result = await run(tester, 42) as RefundRefused;

    expect(result.reason, RefundRefusal.notPaid);
    verifyNever(() => refunds.open(any()));
  });

  testWidgets('a 404 on the order gives orderNotFound', (tester) async {
    when(
      () => orders.getById(saleId: any(named: 'saleId')),
    ).thenThrow(const AppError.notFound());

    final result = await run(tester, 42) as RefundRefused;

    expect(result.reason, RefundRefusal.orderNotFound);
    verifyNever(() => refunds.open(any()));
  });

  testWidgets('a 409 on the POST gives nothingToReturn with the detail', (
    tester,
  ) async {
    stubOrder(SaleStatus.paid);
    when(() => refunds.open(42)).thenThrow(
      const AppError.server(statusCode: 409, message: 'No refundable items'),
    );

    final result = await run(tester, 42) as RefundRefused;

    expect(result.reason, RefundRefusal.nothingToReturn);
    expect(result.serverDetail, 'No refundable items');
  });

  testWidgets('any other error is rethrown', (tester) async {
    stubOrder(SaleStatus.paid);
    when(
      () => refunds.open(42),
    ).thenThrow(const AppError.server(statusCode: 500, message: 'boom'));

    final ref = await pump(tester);
    await expectLater(
      openOrResume(ref, 42),
      throwsA(isA<ServerError>().having((e) => e.statusCode, 'status', 500)),
    );
  });
}
