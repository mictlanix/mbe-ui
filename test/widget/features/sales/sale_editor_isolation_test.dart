import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/async/critical_action_guard.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_write_scope.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/quote_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/sale_editor.dart';
import 'package:mbe_ui/features/sales/presentation/sales_order_write_scope.dart';
import 'package:mbe_ui/features/sales/presentation/sales_quote_write_scope.dart';

import 'pos_test_harness.dart';

/// The refactor's worst failure modes (spec 029 FR-030, FR-038; spec 040
/// research.md R3) — none show up as a compile error, so each is asserted
/// directly, across all **three** capture hosts (register, back-office
/// order, quote): (1) each holds an independent [Sale] — mutating one
/// leaves the others untouched; (2) their outstanding-writes/unconfirmed-
/// edits scopes never affect each other; (3) a confirm resolved through the
/// seam commits the right document with all three open at once; (4) a
/// confirm-failure banner written in one host's nested scope never paints
/// in another's.
///
/// Generalized from a POS↔order-only pair (spec 039) to all three hosts
/// (spec 040) — the override block and the pump helper are now
/// parametrized rather than hardcoded to two.
void main() {
  late MockSalesOrderRepository salesOrders;
  late MockSalesQuoteRepository salesQuotes;

  setUp(() {
    salesOrders = MockSalesOrderRepository();
    salesQuotes = MockSalesQuoteRepository();
  });

  /// Pumps with all three repositories mocked in one container — the
  /// register's `PosSaleController`, `OrderEditorController(id)` and
  /// `QuoteEditorController(id)` are all reachable directly from it, since
  /// none of the three groups below needs a nested seam scope: each
  /// controller is read by name, exactly as a real screen's own controller
  /// would be, before any `saleEditorProvider` override enters the picture.
  Future<ProviderContainer> pumpAllHosts(WidgetTester tester) => pumpPos(
    tester,
    const SizedBox.shrink(),
    overrides: [
      salesOrderOverride(salesOrders),
      salesQuoteOverride(salesQuotes),
    ],
  );

  group('the document itself is not shared (FR-030, spec 040 FR-042)', () {
    testWidgets(
      'PosSaleController and OrderEditorController hold independent Sale '
      'instances — mutating one leaves the other untouched',
      (tester) async {
        final container = await pumpAllHosts(tester);

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

    testWidgets(
      'PosSaleController and QuoteEditorController hold independent Sale '
      'instances — mutating one leaves the other untouched',
      (tester) async {
        final container = await pumpAllHosts(tester);

        when(
          () => anyOpen(salesOrders),
        ).thenAnswer((_) async => testSale(id: 1));
        when(
          () => salesQuotes.getById(quoteId: 3),
        ).thenAnswer((_) async => testQuote(id: 3));

        await container.read(posSaleControllerProvider.notifier).ensureOpen();
        await container.read(quoteEditorControllerProvider(3).future);

        expect(container.read(posSaleControllerProvider).valueOrNull?.id, 1);
        expect(
          container.read(quoteEditorControllerProvider(3)).valueOrNull?.id,
          3,
        );

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
          container.read(quoteEditorControllerProvider(3)).valueOrNull?.id,
          3,
          reason: 'the quote is still exactly what it was — untouched',
        );
      },
    );

    testWidgets(
      'OrderEditorController and QuoteEditorController hold independent '
      'Sale instances — mutating one leaves the other untouched',
      (tester) async {
        final container = await pumpAllHosts(tester);

        when(
          () => salesOrders.getById(saleId: 2),
        ).thenAnswer((_) async => testSale(id: 2));
        when(
          () => salesQuotes.getById(quoteId: 3),
        ).thenAnswer((_) async => testQuote(id: 3));

        await container.read(orderEditorControllerProvider(2).future);
        await container.read(quoteEditorControllerProvider(3).future);

        when(
          () => salesQuotes.updateLine(
            quoteId: 3,
            lineId: any(named: 'lineId'),
            quantity: any(named: 'quantity'),
            price: any(named: 'price'),
            priceAdjustment: any(named: 'priceAdjustment'),
            discountRate: any(named: 'discountRate'),
            comment: any(named: 'comment'),
          ),
        ).thenAnswer((_) async => testQuote(id: 3, total: '999.00'));

        await container
            .read(quoteEditorControllerProvider(3).notifier)
            .updateLine(lineId: 5, quantity: '3');

        expect(
          container.read(quoteEditorControllerProvider(3)).valueOrNull?.total,
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

  group('the write gate is not shared (FR-038, spec 040 FR-041)', () {
    /// Holds [scope]'s gate open with an in-flight write, asserts every
    /// *other* scope in [others] reads zero throughout, then releases it.
    Future<void> checkGateIsolated(
      ProviderContainer container,
      String scope,
      List<String> others,
    ) async {
      final gate = container.read(pendingWritesProvider(scope).notifier);
      final unblock = Completer<void>();
      final tracked = gate.track(() => unblock.future);

      expect(container.read(pendingWritesProvider(scope)), 1);
      for (final other in others) {
        expect(
          container.read(pendingWritesProvider(other)),
          0,
          reason: '$other\'s gate is untouched by $scope\'s write',
        );
      }

      unblock.complete();
      await tracked;
      expect(container.read(pendingWritesProvider(scope)), 0);
    }

    testWidgets(
      'holding any one scope\'s pendingWrites above zero leaves the other '
      'two at zero, for every scope in turn',
      (tester) async {
        final container = await pumpAllHosts(tester);
        const scopes = [posWritesScope, salesOrderWritesScope, salesQuoteWritesScope];
        for (final scope in scopes) {
          await checkGateIsolated(
            container,
            scope,
            scopes.where((s) => s != scope).toList(),
          );
        }
      },
    );
  });

  group('unconfirmed edits are not shared (contracts/quote-capture-host.md §4)', () {
    UnconfirmedEdit fixedEdit(Object id) => UnconfirmedEdit(
      id: id,
      text: 'draft',
      confirm: () async => true,
      discard: () {},
      resume: () {},
    );

    testWidgets(
      'registering an unconfirmed edit in any one scope leaves the other '
      'two empty, for every scope in turn',
      (tester) async {
        final container = await pumpAllHosts(tester);
        const scopes = [posWritesScope, salesOrderWritesScope, salesQuoteWritesScope];
        for (final scope in scopes) {
          container
              .read(unconfirmedEditsProvider(scope).notifier)
              .put(fixedEdit('field-in-$scope'));

          expect(container.read(unconfirmedEditsProvider(scope)), hasLength(1));
          for (final other in scopes.where((s) => s != scope)) {
            expect(
              container.read(unconfirmedEditsProvider(other)),
              isEmpty,
              reason: '$other\'s unconfirmed edits are untouched by $scope\'s',
            );
          }

          container
              .read(unconfirmedEditsProvider(scope).notifier)
              .remove('field-in-$scope');
        }
      },
    );
  });

  // spec 039 US4 / contracts/shared-step-seam.md §6 invariant 3, extended to
  // a third host by spec 040 — "the single most important test this feature
  // adds". `confirmBeforePayableAction`/a quote's own confirm both resolve
  // through whichever document `saleEditorProvider` resolves to inside their
  // own nested scope; this proves that resolution genuinely differs by
  // scope, not merely by construction, with all three documents open in the
  // same session at once.
  group(
    'confirming through the seam resolves to the right document, with all '
    'three open at once (FR-044, spec 040 FR-042)',
    () {
      testWidgets(
        'confirming inside the order workspace\'s nested scope commits the '
        'order and leaves the register sale and an open quote untouched',
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
            overrides: [
              salesOrderOverride(salesOrders),
              salesQuoteOverride(salesQuotes),
            ],
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
          when(
            () => salesQuotes.getById(quoteId: 3),
          ).thenAnswer((_) async => testQuote(id: 3, lines: [testQuoteLine()]));

          // All three open at once, exactly as a cashier, a back-office
          // user and a salesperson writing a quote would have them in the
          // same running app.
          await container.read(posSaleControllerProvider.notifier).ensureOpen();
          await orderContainer.read(orderEditorControllerProvider(2).future);
          await container.read(quoteEditorControllerProvider(3).future);

          // The trigger a real destination create fires — resolved through
          // the seam inside the *nested* scope, so it reaches the order's
          // own controller, never the register's or the quote's.
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
          expect(
            container.read(quoteEditorControllerProvider(3)).valueOrNull?.status,
            SaleStatus.draft,
            reason: 'the open quote, untouched, is not confirmed either',
          );
        },
      );

      testWidgets(
        'confirming inside a quote screen\'s nested scope confirms the '
        'quote and leaves the register sale and an open order untouched',
        (tester) async {
          late ProviderContainer quoteContainer;
          final container = await pumpPos(
            tester,
            ProviderScope(
              overrides: [
                // The quote screen's own four-provider override block
                // (contracts/quote-capture-host.md §1).
                saleEditorProvider.overrideWith(
                  (ref) => ref.watch(quoteEditorControllerProvider(3).notifier),
                ),
                saleWritesScopeProvider.overrideWithValue(
                  salesQuoteWritesScope,
                ),
                saleConfirmErrorProvider.overrideWith((ref) => null),
                saleConfirmFailureProvider.overrideWith((ref) => (_) {}),
              ],
              child: Builder(
                builder: (context) {
                  quoteContainer = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
            overrides: [
              salesOrderOverride(salesOrders),
              salesQuoteOverride(salesQuotes),
            ],
          );

          when(
            () => anyOpen(salesOrders),
          ).thenAnswer((_) async => testSale(id: 1, lines: [testLine()]));
          when(
            () => salesOrders.getById(saleId: 2),
          ).thenAnswer((_) async => testSale(id: 2, lines: [testLine()]));
          when(
            () => salesQuotes.getById(quoteId: 3),
          ).thenAnswer((_) async => testQuote(id: 3, lines: [testQuoteLine()]));
          when(() => salesQuotes.confirm(quoteId: 3)).thenAnswer(
            (_) async => testQuote(
              id: 3,
              lines: [testQuoteLine()],
              status: SaleStatus.completed,
            ),
          );

          await container.read(posSaleControllerProvider.notifier).ensureOpen();
          await container.read(orderEditorControllerProvider(2).future);
          await quoteContainer.read(quoteEditorControllerProvider(3).future);

          await quoteContainer.read(saleEditorProvider).confirm();

          verify(() => salesQuotes.confirm(quoteId: 3)).called(1);
          verifyNever(() => salesOrders.confirm(saleId: any(named: 'saleId')));
          expect(
            quoteContainer
                .read(quoteEditorControllerProvider(3))
                .valueOrNull
                ?.status,
            SaleStatus.completed,
            reason: 'the quote is confirmed',
          );
          expect(
            container.read(posSaleControllerProvider).valueOrNull?.status,
            SaleStatus.draft,
            reason: 'the register sale, open at the same time, is untouched',
          );
          expect(
            container.read(orderEditorControllerProvider(2)).valueOrNull?.status,
            SaleStatus.draft,
            reason: 'the open order, untouched, is not confirmed either',
          );
        },
      );
    },
  );

  group(
    'the confirm-failure banner is not shared (contracts/quote-capture-host.md §4)',
    () {
      testWidgets(
        'writing saleConfirmErrorProvider inside one nested scope leaves a '
        'sibling nested scope\'s own copy null',
        (tester) async {
          late ProviderContainer orderContainer;
          late ProviderContainer quoteContainer;

          final container = await pumpPos(
            tester,
            Row(
              children: [
                ProviderScope(
                  overrides: [
                    saleEditorProvider.overrideWith(
                      (ref) => ref.watch(orderEditorControllerProvider(2).notifier),
                    ),
                    saleWritesScopeProvider.overrideWithValue(salesOrderWritesScope),
                    saleConfirmErrorProvider.overrideWith((ref) => null),
                    saleConfirmFailureProvider.overrideWith((ref) => (_) {}),
                  ],
                  child: Builder(
                    builder: (context) {
                      orderContainer = ProviderScope.containerOf(context, listen: false);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                ProviderScope(
                  overrides: [
                    saleEditorProvider.overrideWith(
                      (ref) => ref.watch(quoteEditorControllerProvider(3).notifier),
                    ),
                    saleWritesScopeProvider.overrideWithValue(salesQuoteWritesScope),
                    saleConfirmErrorProvider.overrideWith((ref) => null),
                    saleConfirmFailureProvider.overrideWith((ref) => (_) {}),
                  ],
                  child: Builder(
                    builder: (context) {
                      quoteContainer = ProviderScope.containerOf(context, listen: false);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
            overrides: [
              salesOrderOverride(salesOrders),
              salesQuoteOverride(salesQuotes),
            ],
          );

          orderContainer.read(saleConfirmErrorProvider.notifier).state =
              const AppError.server(message: 'refused');

          expect(
            orderContainer.read(saleConfirmErrorProvider),
            isNotNull,
            reason: 'the order workspace\'s own banner is set',
          );
          expect(
            quoteContainer.read(saleConfirmErrorProvider),
            isNull,
            reason: 'the quote screen\'s own banner is untouched',
          );
          expect(
            container.read(saleConfirmErrorProvider),
            isNull,
            reason: 'the register\'s own banner (the root default) is untouched',
          );
        },
      );
    },
  );
}
