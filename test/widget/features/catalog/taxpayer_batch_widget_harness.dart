import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_batch_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_batches_section.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Shared harness for the Series section and dialog widget tests (spec 065).

class MockTaxpayerBatchRepository extends Mock
    implements TaxpayerBatchRepository {}

const batchRfc = 'XAXX010101000';

/// A non-administrator holding exactly [rights] on Taxpayers (the bit sum of
/// create 1, read 2, update 4, delete 8).
User taxpayersUser(int rights) => User(
  userId: 'u$rights',
  email: 'u$rights@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.taxpayers, rawValue: rights),
  ],
);

final fullUser = taxpayersUser(15);
final createReadUser = taxpayersUser(3);
final readUser = taxpayersUser(2);
final updateReadUser = taxpayersUser(6);

TaxpayerBatch aBatch({
  int id = 1,
  String series = 'A',
  int typeCode = 0,
  bool inUse = false,
  String templateName = 'Factura estándar',
  String? logo,
  int headerHeight = 0,
  int footerHeight = 15,
  List<TaxpayerBatchAccount> accounts = const [],
}) => TaxpayerBatch(
  taxpayerBatchId: id,
  taxpayer: batchRfc,
  series: series,
  typeCode: typeCode,
  kind: FiscalDocumentKind.fromCode(typeCode),
  template: TaxpayerBatchTemplate(
    name: templateName,
    logo: logo,
    headerHeight: headerHeight,
    footerHeight: footerHeight,
    accounts: accounts,
  ),
  inUse: inUse,
);

AccessControlService accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

/// Pumps the Series section for [batchRfc] over [repository]. With [settle]
/// false it returns after the first frame, for a test that watches loading.
Future<void> pumpBatchesSection(
  WidgetTester tester, {
  required MockTaxpayerBatchRepository repository,
  required User signedInAs,
  bool readOnly = false,
  Size? size,
  bool settle = true,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        taxpayerBatchRepositoryProvider.overrideWithValue(repository),
        accessControlProvider.overrideWithValue(accessFor(signedInAs)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TaxpayerBatchesSection(rfc: batchRfc, readOnly: readOnly),
          ),
        ),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

/// The English strings the tests assert on.
Future<AppLocalizations> englishStrings() =>
    AppLocalizations.delegate.load(const Locale('en'));
