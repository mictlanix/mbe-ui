import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/supplier_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/supplier_agreements_section.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

const _editor = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 15)],
);

const _reader = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // read (2) only
  privileges: [Privilege(systemObject: SystemObject.suppliers, rawValue: 2)],
);

final _agreements = [
  SupplierAgreement(
    supplierAgreementId: 1,
    supplierId: 1,
    start: DateTime(2026, 3, 5),
    end: DateTime(2026, 12, 31),
    comment: 'Net 30',
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockSupplierRepository repository;

  setUp(() {
    repository = MockSupplierRepository();
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    int? supplierId = 1,
    bool readOnly = false,
    User user = _editor,
    List<SupplierAgreement> agreements = const [],
    Size size = const Size(1024, 800),
    String datePattern = 'yyyy-MM-dd',
  }) async {
    when(
      () => repository.listAgreements(supplierId: any(named: 'supplierId')),
    ).thenAnswer((_) async => agreements);
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          supplierRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(user)),
          appSettingsProvider.overrideWithValue(
            AppSettings(
              apiBaseUrl: 'http://test',
              photosBaseUrl: 'http://test',
              posDefaultCustomerId: 1,
              brand: const BrandConfig(displayName: 'Test'),
              defaultLocale: const Locale('es', 'MX'),
              formatting: FormattingSettings(datePattern: datePattern),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: SupplierAgreementsSection(
                supplierId: supplierId,
                readOnly: readOnly,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an empty section shows its empty state', (tester) async {
    await pumpSection(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.supplierAgreementsEmpty), findsOneWidget);
    expect(find.byKey(const Key('supplier_agreements_table')), findsNothing);
  });

  testWidgets('a populated table shows start, end and notes', (tester) async {
    await pumpSection(tester, agreements: _agreements);

    expect(find.byKey(const Key('supplier_agreements_table')), findsOneWidget);
    expect(find.text('Net 30'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('dates render through the configured display format (FR-003)', (
    tester,
  ) async {
    await pumpSection(
      tester,
      agreements: _agreements,
      datePattern: 'dd/MM/yyyy',
    );

    expect(find.text('05/03/2026'), findsOneWidget);
    expect(find.text('31/12/2026'), findsOneWidget);
    expect(find.text('2026-03-05'), findsNothing);
  });

  testWidgets('the compact tier drops the Notes column (R12)', (tester) async {
    await pumpSection(
      tester,
      agreements: _agreements,
      size: const Size(400, 800),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('Notes'), findsNothing);
    expect(find.text('Net 30'), findsNothing);
  });

  testWidgets('a null supplierId shows the after-save note and loads nothing '
      '(FR-015)', (tester) async {
    await pumpSection(tester, supplierId: null);

    expect(
      find.byKey(const Key('supplier_agreements_after_save_note')),
      findsOneWidget,
    );
    verifyNever(
      () => repository.listAgreements(supplierId: any(named: 'supplierId')),
    );
  });

  testWidgets('no add or edit controls appear when read-only', (tester) async {
    await pumpSection(tester, readOnly: true, agreements: _agreements);

    expect(find.byKey(const Key('add_agreement_button')), findsNothing);
    expect(find.byKey(const Key('edit_agreement_1')), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('with Update and not read-only: an add control and one Edit '
      'icon per row, no Delete (FR-013)', (tester) async {
    await pumpSection(tester, agreements: _agreements);

    expect(find.byKey(const Key('add_agreement_button')), findsOneWidget);
    expect(find.byKey(const Key('edit_agreement_1')), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('without Update there are no add or edit controls', (
    tester,
  ) async {
    await pumpSection(tester, user: _reader, agreements: _agreements);

    expect(find.byKey(const Key('add_agreement_button')), findsNothing);
    expect(find.byKey(const Key('edit_agreement_1')), findsNothing);
  });

  testWidgets('a null supplierId shows the note and no add control', (
    tester,
  ) async {
    await pumpSection(tester, supplierId: null);

    expect(
      find.byKey(const Key('supplier_agreements_after_save_note')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('add_agreement_button')), findsNothing);
  });

  testWidgets('Add and Edit open the agreement dialog', (tester) async {
    await pumpSection(tester, agreements: _agreements);

    await tester.tap(find.byKey(const Key('add_agreement_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('agreement_save_button')), findsOneWidget);
    expect(find.byKey(const Key('agreement_delete_button')), findsNothing);
    await tester.tap(find.byKey(const Key('agreement_cancel_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit_agreement_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('agreement_delete_button')), findsOneWidget);
  });
}
