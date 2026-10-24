import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreement_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

final _existing = SupplierAgreement(
  supplierAgreementId: 7,
  supplierId: 1,
  start: DateTime(2026, 3, 5),
  end: DateTime(2026, 12, 31),
  comment: 'Net 30',
);

void main() {
  late MockSupplierRepository repository;

  setUp(() {
    repository = MockSupplierRepository();
    when(
      () => repository.listAgreements(supplierId: any(named: 'supplierId')),
    ).thenAnswer((_) async => const []);
  });

  Future<AppLocalizations> pumpDialog(
    WidgetTester tester, {
    SupplierAgreement? existing,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(1024, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          supplierRepositoryProvider.overrideWithValue(repository),
          appSettingsProvider.overrideWithValue(
            const AppSettings(
              apiBaseUrl: 'http://test',
              photosBaseUrl: 'http://test',
              posDefaultCustomerId: 1,
              brand: BrandConfig(displayName: 'Test'),
              defaultLocale: Locale('es', 'MX'),
              formatting: FormattingSettings(datePattern: 'dd/MM/yyyy'),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                key: const Key('open'),
                onPressed: () => showSupplierAgreementDialog(
                  context,
                  supplierId: 1,
                  existing: existing,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    return AppLocalizations.delegate.load(const Locale('en'));
  }

  Future<void> pickDay(WidgetTester tester, String key, String day) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(day));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(find.byKey(const Key('agreement_save_button')))
          .onPressed !=
      null;

  testWidgets('add mode: blank, titled "New", Save disabled, no Delete', (
    tester,
  ) async {
    final l10n = await pumpDialog(tester);

    expect(find.text(l10n.newAgreementDialogTitle), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    expect(find.byKey(const Key('agreement_delete_button')), findsNothing);
    expect(find.byKey(const Key('agreement_cancel_button')), findsOneWidget);
  });

  testWidgets('picked dates show in the configured format (FR-003) and '
      'enable Save', (tester) async {
    await pumpDialog(tester);

    await pickDay(tester, 'agreement_start_field', '10');
    await pickDay(tester, 'agreement_end_field', '20');

    final now = DateTime.now();
    String shown(int d) =>
        '${d.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    expect(find.text(shown(10)), findsOneWidget);
    expect(find.text(shown(20)), findsOneWidget);
    expect(saveEnabled(tester), isTrue);
  });

  testWidgets('an end before the start shows the error under End and keeps '
      'Save disabled', (tester) async {
    final l10n = await pumpDialog(tester);

    await pickDay(tester, 'agreement_start_field', '20');
    await pickDay(tester, 'agreement_end_field', '10');

    expect(
      find.text(l10n.supplierAgreementEndBeforeStartError),
      findsOneWidget,
    );
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('edit mode: prefilled, titled "Edit", with Delete', (
    tester,
  ) async {
    final l10n = await pumpDialog(tester, existing: _existing);

    expect(find.text(l10n.editAgreementDialogTitle), findsOneWidget);
    expect(find.text('05/03/2026'), findsOneWidget);
    expect(find.text('31/12/2026'), findsOneWidget);
    expect(find.text('Net 30'), findsOneWidget);
    expect(find.byKey(const Key('agreement_delete_button')), findsOneWidget);
    expect(saveEnabled(tester), isTrue);
  });

  testWidgets('Save in edit mode updates and closes the dialog', (
    tester,
  ) async {
    when(
      () => repository.updateAgreement(
        supplierId: 1,
        agreementId: 7,
        start: any(named: 'start'),
        end: any(named: 'end'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => _existing);
    await pumpDialog(tester, existing: _existing);

    await tester.tap(find.byKey(const Key('agreement_save_button')));
    await tester.pumpAndSettle();

    verify(
      () => repository.updateAgreement(
        supplierId: 1,
        agreementId: 7,
        start: _existing.start,
        end: _existing.end,
        comment: 'Net 30',
      ),
    ).called(1);
    expect(find.byKey(const Key('agreement_save_button')), findsNothing);
  });

  testWidgets('Delete asks first; Cancel keeps it, confirming deletes and '
      'closes', (tester) async {
    when(
      () => repository.deleteAgreement(supplierId: 1, agreementId: 7),
    ).thenAnswer((_) async {});
    final l10n = await pumpDialog(tester, existing: _existing);

    await tester.tap(find.byKey(const Key('agreement_delete_button')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.deleteAgreementConfirmTitle), findsOneWidget);
    expect(
      find.text(l10n.deleteAgreementConfirmMessage('05/03/2026', '31/12/2026')),
      findsOneWidget,
    );

    await tester.tap(find.text(l10n.cancelButton).last);
    await tester.pumpAndSettle();
    verifyNever(
      () => repository.deleteAgreement(
        supplierId: any(named: 'supplierId'),
        agreementId: any(named: 'agreementId'),
      ),
    );

    await tester.tap(find.byKey(const Key('agreement_delete_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete_agreement_button')));
    await tester.pumpAndSettle();

    verify(
      () => repository.deleteAgreement(supplierId: 1, agreementId: 7),
    ).called(1);
    expect(find.byKey(const Key('agreement_save_button')), findsNothing);
  });
}
