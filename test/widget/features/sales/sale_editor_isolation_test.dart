import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';

import 'pos_test_harness.dart';

/// The refactor's two worst failure modes (spec 029 FR-030, FR-038,
/// research §R1) — neither shows up as a compile error, so both are
/// asserted directly: an order open on the back-office screen and a sale
/// held by the register are (1) two different [Sale]s, and (2) their
/// outstanding-writes/unconfirmed-edits scopes never affect each other.
void main() {
  late MockSalesOrderRepository salesOrders;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
  });

  Future<ProviderContainer> pumpBoth(WidgetTester tester) => pumpPos(
    tester,
    const SizedBox.shrink(),
    overrides: [salesOrderOverride(salesOrders)],
  );

  group('the sale itself is not shared (FR-030)', () {
    testWidgets(
      'PosSaleController and OrderEditorController hold independent Sale '
      'instances — mutating one leaves the other untouched',
      (tester) async {
        final container = await pumpBoth(tester);

        when(
          () => anyOpen(salesOrders),
        ).thenAnswer((_) async => testSale(id: 1));
        when(
          () => salesOrders.getById(saleId: 2),
        ).thenAnswer((_) async => testSale(id: 2));

        await container.read(posSaleControllerProvider.notifier).ensureOpen();
        await container.read(orderEditorControllerProvider(2).future);

        expect(container.read(posSaleControllerProvider).valueOrNull?.id, 1);
        expect(
          container.read(orderEditorControllerProvider(2)).valueOrNull?.id,
          2,
        );

        // Mutating the register's sale must not touch the order, and
        // vice versa — the direct expression of "neither may overwrite or
        // close the other" (FR-030).
        when(
          () => salesOrders.updateLine(
            saleId: 1,
            lineId: any(named: 'lineId'),
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            discountRate: any(named: 'discountRate'),
            taxRate: any(named: 'taxRate'),
            warehouse: any(named: 'warehouse'),
            comment: any(named: 'comment'),
          ),
        ).thenAnswer((_) async => testSale(id: 1, total: '999.00'));

        await container
            .read(posSaleControllerProvider.notifier)
            .updateLine(lineId: 5, quantity: '3');

        expect(
          container.read(posSaleControllerProvider).valueOrNull?.total,
          '999.00',
        );
        expect(
          container.read(orderEditorControllerProvider(2)).valueOrNull?.id,
          2,
          reason: 'the order is still exactly what it was — untouched',
        );
      },
    );
  });

  group('the write gate is not shared (FR-038)', () {
    testWidgets(
      'holding one scope\'s pendingWrites above zero leaves the other\'s '
      'at zero',
      (tester) async {
        final container = await pumpBoth(tester);

        final posGate = container.read(
          pendingWritesProvider(posWritesScope).notifier,
        );
        final orderGate = container.read(
          pendingWritesProvider(salesOrderWritesScope).notifier,
        );

        // Hold the register's gate open with an in-flight write.
        final unblock = Completer<void>();
        final tracked = posGate.track(() => unblock.future);

        expect(container.read(pendingWritesProvider(posWritesScope)), 1);
        expect(
          container.read(pendingWritesProvider(salesOrderWritesScope)),
          0,
          reason:
              'the order screen\'s gate is untouched by the register\'s write',
        );

        unblock.complete();
        await tracked;
        expect(container.read(pendingWritesProvider(posWritesScope)), 0);

        // And the reverse: the order screen's own write must not touch
        // the register's gate.
        final unblock2 = Completer<void>();
        final tracked2 = orderGate.track(() => unblock2.future);

        expect(container.read(pendingWritesProvider(salesOrderWritesScope)), 1);
        expect(
          container.read(pendingWritesProvider(posWritesScope)),
          0,
          reason:
              'the register\'s gate is untouched by the order screen\'s write',
        );

        unblock2.complete();
        await tracked2;
      },
    );
  });

  // spec 039 US4 / contracts/shared-step-seam.md §6 invariant 3 — "the
  // single most important test this feature adds". `confirmBeforePayableAction`
  // (pos_confirm.dart) commits whichever document `saleEditorProvider`
  // resolves to; this proves that resolution genuinely differs by scope,
  // not merely by construction, with both documents open in the same
  // session at once.
  group(
    'creating a destination commits the order, not the register (FR-044)',
    () {
      testWidgets(
        'confirming through the seam inside the workspace\'s nested scope '
        'commits the order and leaves a register sale, open at the same '
        'time, a draft — untouched',
        (tester) async {
          late ProviderContainer orderContainer;
          final container = await pumpPos(
            tester,
            ProviderScope(
              overrides: [
                // The exact four-provider override block
                // `OrderWorkspaceScreen.build()` installs
                // (contracts/shared-step-seam.md §5) — reproduced here
                // rather than mounting the real screen, since this
                // invariant is about the seam's resolution, not the
                // workspace's own UI.
                saleEditorProvider.overrideWith(
                  (ref) => ref.watch(orderEditorControllerProvider(2).notifier),
                ),
                saleWritesScopeProvider.overrideWithValue(
                  salesOrderWritesScope,
                ),
                saleConfirmErrorProvider.overrideWith((ref) => null),
                saleConfirmFailureProvider.overrideWith((ref) => (_) {}),
              ],
              child: Builder(
                builder: (context) {
                  orderContainer = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
            overrides: [salesOrderOverride(salesOrders)],
          );

          when(
            () => anyOpen(salesOrders),
          ).thenAnswer((_) async => testSale(id: 1, lines: [testLine()]));
          when(
            () => salesOrders.getById(saleId: 2),
          ).thenAnswer((_) async => testSale(id: 2, lines: [testLine()]));
          when(() => salesOrders.confirm(saleId: 2)).thenAnswer(
            (_) async => testSale(
              id: 2,
              lines: [testLine()],
              status: SaleStatus.completed,
            ),
          );

          // Both open at once, exactly as a cashier and a back-office user
          // would have them in the same running app.
          await container.read(posSaleControllerProvider.notifier).ensureOpen();
          await orderContainer.read(orderEditorControllerProvider(2).future);

          // The trigger a real destination create fires — resolved through
          // the seam inside the *nested* scope, so it reaches the order's
          // own controller, never the register's.
          await orderContainer.read(saleEditorProvider).confirm();

          verify(() => salesOrders.confirm(saleId: 2)).called(1);
          verifyNever(() => salesOrders.confirm(saleId: 1));
          expect(
            orderContainer
                .read(orderEditorControllerProvider(2))
                .valueOrNull
                ?.status,
            SaleStatus.completed,
            reason: 'the order is committed',
          );
          expect(
            container.read(posSaleControllerProvider).valueOrNull?.status,
            SaleStatus.draft,
            reason: 'the register sale, open at the same time, is untouched',
          );
        },
      );
    },
  );
}
