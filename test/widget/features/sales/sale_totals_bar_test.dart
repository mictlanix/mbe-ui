import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/features/sales/presentation/capture/sale_totals_bar.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

void main() {
  Finder labelText(String label) => find.text(label.toUpperCase());

  Future<void> pumpBar(
    WidgetTester tester, {
    required VoidCallback? onContinue,
    bool confirming = false,
    bool compact = false,
    String total = '116.00',
  }) => pumpPos(
    tester,
    SaleTotalsBar(
      sale: testSale(lines: [testLine()], total: total),
      onContinue: onContinue,
      confirming: confirming,
      compact: compact,
    ),
  );

  group('the band is its own surface (spec 023 contracts §5)', () {
    testWidgets('a raised fill under a top hairline, and no rounded corners — '
        'a full-width band pinned to the bottom edge has none to round', (
      tester,
    ) async {
      await pumpBar(tester, onContinue: () {});
      final theme = Theme.of(tester.element(find.byType(SaleTotalsBar)));

      final decoration = tester
          .widget<Container>(find.byKey(const Key('pos_totals_footer')))
          .decoration! as BoxDecoration;

      // The same plane the line cards sit on, so the summary reads as a
      // statement about them rather than as one more item among them.
      expect(decoration.color, theme.elevations.raised.surfaceColor);
      expect(decoration.borderRadius, isNull);
      expect(
        decoration.border,
        Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      );
    });

    testWidgets('the counts are ruled off from the money by a single divider, '
        'not one between every figure', (tester) async {
      await pumpBar(tester, onContinue: () {});
      expect(find.byKey(const Key('pos_totals_divider')), findsOneWidget);
    });
  });

  group('labelled groups (spec 023 contracts/capture-surface.md §5)', () {
    testWidgets('shows Artículos, Subtotal and IVA groups, each with a figure', (
      tester,
    ) async {
      await pumpBar(tester, onContinue: () {});
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(labelText(l10n.posTotalsArticlesLabel), findsOneWidget);
      expect(labelText(l10n.posTotalsSubtotalLabel), findsOneWidget);
      expect(labelText(l10n.posTotalsTaxLabel), findsOneWidget);
      expect(find.text(l10n.posTotalsCounts(1, '2')), findsOneWidget);
      expect(find.text(r'$100.00'), findsOneWidget); // subtotal
      expect(find.text(r'$16.00'), findsOneWidget); // IVA
    });

    testWidgets('omits the Descuentos group entirely when there is no discount', (
      tester,
    ) async {
      await pumpBar(tester, onContinue: () {});
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(labelText(l10n.posTotalsDiscountLabel), findsNothing);
    });

    testWidgets('shows the Descuentos group, with its figure, when a discount '
        'brings the total below subtotal + tax', (tester) async {
      // Fixture's subtotal/tax are fixed at 100.00/16.00; a lower total
      // implies a discount of 11.60 (contracts §5, FR-047's addAmounts/
      // subtractAmounts derivation).
      await pumpBar(tester, onContinue: () {}, total: '104.40');
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(labelText(l10n.posTotalsDiscountLabel), findsOneWidget);
      expect(find.text('−\$11.60'), findsOneWidget);
    });

    testWidgets('the total is right-aligned, visually dominant, and states its '
        'own currency', (tester) async {
      await pumpBar(tester, onContinue: () {});

      final totalFigure = tester.widget<Text>(find.text(r'$116.00'));
      final subtotalFigure = tester.widget<Text>(find.text(r'$100.00'));
      expect(
        totalFigure.style!.fontSize,
        greaterThan(subtotalFigure.style!.fontSize!),
        reason: 'the total figure uses the larger metricValue role',
      );

      final totalLabel = tester.widget<Column>(
        find.ancestor(
          of: find.text(r'$116.00'),
          matching: find.byType(Column),
        ),
      );
      expect(totalLabel.crossAxisAlignment, CrossAxisAlignment.end);
    });
  });

  group('the primary action (spec 023 contracts/pos-workspace.md §3.1)', () {
    testWidgets('renders on the same band as the stats, key '
        'pos_continue_to_payment', (tester) async {
      await pumpBar(tester, onContinue: () {});

      expect(find.byKey(const Key('pos_totals_footer')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('pos_totals_footer')),
          matching: find.byKey(const Key('pos_continue_to_payment')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('disabled with a null onContinue — the zero-lines case', (
      tester,
    ) async {
      await pumpBar(tester, onContinue: null);

      final button = tester.widget<FloatingActionButton>(
        find.byKey(const Key('pos_continue_to_payment')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows a spinner instead of its label while confirming', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      // Not pumpBar/pumpPos: the spinner is an indeterminate animation, so
      // pumpAndSettle would time out waiting for it to stop.
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SaleTotalsBar(
              sale: testSale(lines: [testLine()]),
              onContinue: () {},
              confirming: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.posStepCobro), findsNothing);
    });
  });

  group('no sale yet (spec 020 — only Venta can render that)', () {
    testWidgets('renders the button, disabled, with no stats at all', (
      tester,
    ) async {
      await pumpPos(
        tester,
        const SaleTotalsBar(sale: null, onContinue: null, confirming: false),
      );
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(find.byKey(const Key('pos_continue_to_payment')), findsOneWidget);
      expect(labelText(l10n.posTotalsTotalLabel), findsNothing);
    });
  });
}
