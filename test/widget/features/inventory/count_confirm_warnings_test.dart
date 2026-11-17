import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/widgets/error_banner.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_confirm_notice.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';

/// Spec 070 US4 (T027), FR-013: the warnings band a confirm leaves.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows both sections with their figures', (tester) async {
    await pump(
      tester,
      CountWarningsBand(warnings: someCountWarnings(), onClose: () {}),
    );

    expect(find.text(l10n.inventoryCountWarningsTitle), findsOneWidget);
    expect(
      find.text(l10n.inventoryCountWarningsNegativeHeading),
      findsOneWidget,
    );
    expect(
      find.text('A-100  contado 2 · apartado 5 · disponible -3'),
      findsOneWidget,
    );
    expect(
      find.text(l10n.inventoryCountWarningsCorrectedHeading),
      findsOneWidget,
    );
    expect(find.text('B-200  conteo 57'), findsOneWidget);
  });

  testWidgets('a section with no items is left out', (tester) async {
    await pump(
      tester,
      CountWarningsBand(
        warnings: someCountWarnings(negativeAvailable: const []),
        onClose: () {},
      ),
    );

    expect(find.text(l10n.inventoryCountWarningsNegativeHeading), findsNothing);
    expect(
      find.text(l10n.inventoryCountWarningsCorrectedHeading),
      findsOneWidget,
    );
  });

  testWidgets('another count with no folio shows its draft folio', (
    tester,
  ) async {
    await pump(
      tester,
      CountWarningsBand(
        warnings: someCountWarnings(
          negativeAvailable: const [],
          correctedByOtherCounts: const [
            CorrectedByOtherCountItem(
              productId: 8,
              productCode: 'B-200',
              otherCountId: 409,
            ),
          ],
        ),
        onClose: () {},
      ),
    );

    expect(find.text('B-200  Borrador #409'), findsOneWidget);
  });

  testWidgets('uses the warning tone, not the error banner', (tester) async {
    await pump(
      tester,
      CountWarningsBand(warnings: someCountWarnings(), onClose: () {}),
    );

    final scheme = Theme.of(
      tester.element(find.byKey(const Key('count_confirm_warnings'))),
    ).colorScheme;
    final band = tester.widget<Material>(
      find.byKey(const Key('count_confirm_warnings')),
    );
    expect(band.color, scheme.tertiaryContainer);
    expect(band.color, isNot(scheme.errorContainer));
    expect(find.byType(ErrorBanner), findsNothing);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('✕ calls onClose', (tester) async {
    var closed = false;
    await pump(
      tester,
      CountWarningsBand(
        warnings: someCountWarnings(),
        onClose: () => closed = true,
      ),
    );

    await tester.tap(find.byKey(const Key('count_confirm_warnings_close')));
    expect(closed, isTrue);
    expect(find.byTooltip(l10n.inventoryCountWarningsDismiss), findsOneWidget);
  });

  testWidgets('empty warnings build nothing', (tester) async {
    await pump(
      tester,
      CountWarningsBand(warnings: const CountWarnings(), onClose: () {}),
    );

    expect(find.byKey(const Key('count_confirm_warnings')), findsNothing);
  });
}
