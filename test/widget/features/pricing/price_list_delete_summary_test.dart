import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list_delete_preview.dart';
import 'package:mbe_ui/features/pricing/presentation/widgets/price_list_delete_summary.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester,
  PriceListDeletePreview preview, {
  VoidCallback? onViewCustomers,
}) async {
  // formattersProvider (spec 028) reads through resolvedLocaleProvider,
  // which needs a real SharedPreferences instance.
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PriceListDeleteSummary(
              preview: preview,
              onViewCustomers: onViewCustomers,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('marks product prices as destroyed and customers as moved', (
    tester,
  ) async {
    await _pump(
      tester,
      const PriceListDeletePreview(
        categories: [
          PriceListDeleteCategory(key: 'product_price.list', count: 4312),
          PriceListDeleteCategory(key: 'customer.price_list', count: 12),
        ],
        total: 4324,
      ),
    );

    expect(find.text('Product prices'), findsOneWidget);
    expect(find.text('(deleted permanently)'), findsOneWidget);
    expect(find.text('4,312'), findsOneWidget);

    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('(moved to the replacement)'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    expect(
      tester
          .widget<Text>(find.byKey(const Key('price_list_delete_total')))
          .data,
      '4,324',
    );
  });

  testWidgets('marks a blocking category distinctly from destroyed/moved', (
    tester,
  ) async {
    await _pump(
      tester,
      const PriceListDeletePreview(
        categories: [
          PriceListDeleteCategory(key: 'product_price.list', count: 4312),
          PriceListDeleteCategory(key: 'sales_order.price_list', count: 38),
        ],
        total: 4350,
      ),
    );

    expect(find.text('(deleted permanently)'), findsOneWidget);
    expect(find.text('(blocks deletion — clear these first)'), findsOneWidget);
  });

  testWidgets(
    'renders the server total even when it does not equal the sum of the '
    'given rows — never re-summed client-side',
    (tester) async {
      await _pump(
        tester,
        const PriceListDeletePreview(
          categories: [
            PriceListDeleteCategory(key: 'product_price.list', count: 4312),
          ],
          // A total that deliberately disagrees with the single row's count,
          // to prove the widget renders the server's figure verbatim rather
          // than summing `categories` itself.
          total: 999999,
        ),
      );

      expect(
        tester
            .widget<Text>(find.byKey(const Key('price_list_delete_total')))
            .data,
        '999,999',
      );
    },
  );

  testWidgets(
    'shows an unrecognized category under a humanized label and still '
    'counts it in the total',
    (tester) async {
      await _pump(
        tester,
        const PriceListDeletePreview(
          categories: [
            // A relation added to the data model after this feature shipped.
            PriceListDeleteCategory(key: 'sales_order.price_list', count: 38),
          ],
          total: 38,
        ),
      );

      expect(find.text('Sales order'), findsOneWidget);
      // '38' appears both in the row and the total footer here (a single
      // category equals the total), so both matches are expected.
      expect(find.text('38'), findsNWidgets(2));
      expect(
        tester
            .widget<Text>(find.byKey(const Key('price_list_delete_total')))
            .data,
        '38',
        reason: 'an unlabelled category must not fall out of the total',
      );
    },
  );

  testWidgets(
    'the customers row exposes a navigation affordance only when the '
    'callback is given',
    (tester) async {
      var tapped = false;
      await _pump(
        tester,
        const PriceListDeletePreview(
          categories: [
            PriceListDeleteCategory(key: 'customer.price_list', count: 12),
          ],
          total: 12,
        ),
        onViewCustomers: () => tapped = true,
      );

      final link = find.byKey(const Key('price_list_delete_customers_link'));
      expect(link, findsOneWidget);
      await tester.tap(link);
      expect(tapped, isTrue);
    },
  );

  testWidgets(
    'a destroyed-only row (no customers) exposes no navigation affordance',
    (tester) async {
      await _pump(
        tester,
        const PriceListDeletePreview(
          categories: [
            PriceListDeleteCategory(key: 'product_price.list', count: 4312),
          ],
          total: 4312,
        ),
        onViewCustomers: () {},
      );

      expect(
        find.byKey(const Key('price_list_delete_customers_link')),
        findsNothing,
      );
    },
  );
}
