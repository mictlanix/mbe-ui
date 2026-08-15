import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_method_grid.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

/// Tiles for [PaymentMethodGrid] (spec 025 T017, contracts/
/// payment-surface.md §4): one tile per configured `PaymentMethodOption`
/// carrying the right secondary line, a selection shown by both a border and
/// a check icon (FR-014), the fallback set for a facility with no options,
/// and the loading/error passthrough unchanged.
void main() {
  late MockPaymentMethodOptionRepository optionRepository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    optionRepository = MockPaymentMethodOptionRepository();
  });

  PaymentMethodOption testOption({
    int id = 1,
    String name = 'Efectivo',
    int paymentMethod = 1,
    bool requiresReference = false,
  }) => PaymentMethodOption(
    paymentMethodOptionId: id,
    facilityId: 9,
    facilityName: 'Matriz',
    name: name,
    numberOfPayments: 1,
    displayOnTicket: true,
    paymentMethod: paymentMethod,
    status: EntityStatus.active,
    requiresReference: requiresReference,
  );

  void stubOptions(List<PaymentMethodOption> items) {
    when(
      () => optionRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => PaymentMethodOptionPage(items: items, total: items.length),
    );
  }

  Future<void> pumpGrid(WidgetTester tester) => pumpPos(
    tester,
    const PaymentMethodGrid(facilityId: 9),
    overrides: [
      paymentMethodOptionRepositoryProvider.overrideWithValue(optionRepository),
    ],
  );

  Container tileContainer(WidgetTester tester, Key tileKey) => tester.widget<Container>(
    find.descendant(of: find.byKey(tileKey), matching: find.byType(Container)),
  );

  group('configured options', () {
    testWidgets('one tile per option, each with the right secondary line', (
      tester,
    ) async {
      stubOptions([
        testOption(id: 1, name: 'Efectivo', requiresReference: false),
        testOption(
          id: 2,
          name: 'Tarjeta de crédito',
          paymentMethod: PaymentMethod.creditCard.code,
          requiresReference: true,
        ),
      ]);

      await pumpGrid(tester);

      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('Tarjeta de crédito'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('payment_option_1')),
          matching: find.text(l10n.posPaymentMethodNoReference),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('payment_option_2')),
          matching: find.text(l10n.posPaymentMethodRequiresReference),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'tapping a tile marks it selected via both border and check icon',
      (tester) async {
        stubOptions([
          testOption(id: 1, name: 'Efectivo'),
          testOption(id: 2, name: 'Tarjeta', requiresReference: true),
        ]);

        await pumpGrid(tester);

        final unselectedBorder =
            (tileContainer(tester, const Key('payment_option_1')).decoration
                    as BoxDecoration)
                .border!
                .top;
        expect(unselectedBorder.width, 1);
        expect(
          find.descendant(
            of: find.byKey(const Key('payment_option_1')),
            matching: find.byIcon(Icons.check_circle),
          ),
          findsNothing,
        );

        await tester.tap(find.byKey(const Key('payment_option_1')));
        await tester.pumpAndSettle();

        final selectedBorder =
            (tileContainer(tester, const Key('payment_option_1')).decoration
                    as BoxDecoration)
                .border!
                .top;
        expect(selectedBorder.width, 2);
        expect(
          find.descendant(
            of: find.byKey(const Key('payment_option_1')),
            matching: find.byIcon(Icons.check_circle),
          ),
          findsOneWidget,
        );

        // The other tile stays unselected.
        expect(
          find.descendant(
            of: find.byKey(const Key('payment_option_2')),
            matching: find.byIcon(Icons.check_circle),
          ),
          findsNothing,
        );
      },
    );
  });

  testWidgets(
    'a facility with no options renders the fallback tiles, none requiring '
    'a reference',
    (tester) async {
      stubOptions(const []);

      await pumpGrid(tester);

      for (final method in [
        PaymentMethod.cash,
        PaymentMethod.creditCard,
        PaymentMethod.debitCard,
        PaymentMethod.eft,
      ]) {
        expect(
          find.byKey(Key('payment_method_${method.code}')),
          findsOneWidget,
        );
      }
      expect(find.text(l10n.posPaymentMethodRequiresReference), findsNothing);
      expect(find.text(l10n.posPaymentMethodNoReference), findsNWidgets(4));
    },
  );

  testWidgets('shows a progress indicator while the options load', (
    tester,
  ) async {
    when(
      () => optionRepository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
      // Never resolves — the point is to observe the loading frame. A
      // `LinearProgressIndicator` animates indefinitely, so `pumpGrid`'s
      // `pumpAndSettle` (via `pumpPos`) would time out waiting for it to
      // stop; pump the tree directly and settle only the microtask queue
      // with a single frame instead.
    ).thenAnswer((_) => Completer<PaymentMethodOptionPage>().future);

    final container = ProviderContainer(
      overrides: [
        paymentMethodOptionRepositoryProvider.overrideWithValue(optionRepository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PaymentMethodGrid(facilityId: 9)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'renders nothing blocking on failure — the rest of the step stays usable',
    (tester) async {
      when(
        () => optionRepository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('boom'));

      await pumpGrid(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.byKey(Key('payment_method_${PaymentMethod.cash.code}')),
        findsNothing,
      );
    },
  );
}
