import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/invoicing/data/fiscal_document_repository_impl.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/features/invoicing/presentation/fiscal_document_candidate_picker.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class _MockRepository extends Mock implements FiscalDocumentRepository {}

/// Spec 072 C22: the picker shared by the relation dialog and the cancel
/// dialog.
void main() {
  late _MockRepository repository;
  late AppLocalizations l10n;
  late List<FiscalDocumentSummary> picked;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() {
    repository = _MockRepository();
    picked = [];
  });

  FiscalDocumentSummary row(int id, {String recipient = 'XEXX010101000'}) =>
      FiscalDocumentSummary(
        id: id,
        typeCode: 0,
        version: '4.0',
        series: 'GR',
        serial: 100 + id,
        issuerRfc: 'XAXX010101000',
        recipientRfc: recipient,
        recipientName: 'Receptor',
        issued: DateTime(2026, 11, 15, 10, 30),
        stampUuid: 'UUID-$id',
        status: FiscalDocumentStatus.issued,
        total: Decimal.parse('232'),
      );

  void stub(
    List<FiscalDocumentSummary> Function(String? search, int skip) answer, {
    int? total,
  }) {
    when(
      () => repository.list(
        search: any(named: 'search'),
        issuer: any(named: 'issuer'),
        type: any(named: 'type'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((i) async {
      final items = answer(
        i.namedArguments[#search] as String?,
        i.namedArguments[#skip] as int,
      );
      return FiscalDocumentPage(items: items, total: total ?? items.length);
    });
  }

  Future<void> pump(
    WidgetTester tester, {
    FiscalDocumentStatus status = FiscalDocumentStatus.issued,
    int? excludeId,
    String initialSearch = '',
    String? recipientRfc,
    bool enabled = true,
    String keyPrefix = 'candidate',
  }) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        fiscalDocumentRepositoryProvider.overrideWithValue(repository),
        inputDebounceProvider.overrideWithValue(
          const Duration(milliseconds: 100),
        ),
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
          home: Scaffold(
            body: SingleChildScrollView(
              child: FiscalDocumentCandidatePicker(
                keyPrefix: keyPrefix,
                issuerRfc: 'XAXX010101000',
                status: status,
                emptyMessage: 'Sin candidatos',
                excludeId: excludeId,
                initialSearch: initialSearch,
                recipientRfc: recipientRfc,
                enabled: enabled,
                onPicked: picked.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder key(String k) => find.byKey(Key(k));

  testWidgets('lists the requested issuer and status and uses its key '
      'prefix', (tester) async {
    stub((_, _) => [row(1), row(2)]);
    await pump(tester, status: FiscalDocumentStatus.cancelled, keyPrefix: 'x');

    expect(key('x_row_1'), findsOneWidget);
    expect(key('x_row_2'), findsOneWidget);
    expect(key('x_search'), findsOneWidget);
    expect(key('candidate_row_1'), findsNothing);
    final call = verify(
      () => repository.list(
        search: captureAny(named: 'search'),
        issuer: captureAny(named: 'issuer'),
        type: any(named: 'type'),
        status: captureAny(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).captured;
    expect(call, [null, 'XAXX010101000', FiscalDocumentStatus.cancelled]);
  });

  testWidgets('never offers the excluded document', (tester) async {
    stub((_, _) => [row(1), row(7), row(2)]);
    await pump(tester, excludeId: 7);

    expect(key('candidate_row_1'), findsOneWidget);
    expect(key('candidate_row_7'), findsNothing);
    expect(key('candidate_row_2'), findsOneWidget);
  });

  testWidgets('starts the search as the initial text, and a recipient drops '
      "another recipient's rows", (tester) async {
    stub((_, _) => [row(1), row(2, recipient: 'OTRO010101AAA')]);
    await pump(
      tester,
      initialSearch: 'XEXX010101000',
      recipientRfc: 'XEXX010101000',
    );

    expect(
      tester.widget<TextField>(key('candidate_search')).controller?.text,
      'XEXX010101000',
    );
    expect(key('candidate_row_1'), findsOneWidget);
    expect(key('candidate_row_2'), findsNothing);
  });

  testWidgets('without a recipient, rows of any recipient stay (the relation '
      'dialog)', (tester) async {
    stub((_, _) => [row(1), row(2, recipient: 'OTRO010101AAA')]);
    await pump(tester);

    expect(key('candidate_row_2'), findsOneWidget);
  });

  testWidgets('searches as the user types, after the debounce', (tester) async {
    stub((search, _) => search == 'GR9' ? [row(9)] : [row(1)]);
    await pump(tester);

    await tester.enterText(key('candidate_search'), 'GR9');
    await tester.pump(const Duration(milliseconds: 50));
    verifyNever(
      () => repository.list(
        search: 'GR9',
        issuer: any(named: 'issuer'),
        type: any(named: 'type'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(key('candidate_row_9'), findsOneWidget);
    expect(key('candidate_row_1'), findsNothing);
  });

  testWidgets('loads more while the server has more', (tester) async {
    stub(
      (_, skip) => skip == 0
          ? [for (var i = 1; i <= 20; i++) row(i)]
          : [for (var i = 21; i <= 25; i++) row(i)],
      total: 25,
    );
    await pump(tester);
    expect(key('candidate_row_20'), findsOneWidget);
    expect(key('candidate_row_21'), findsNothing);

    await tester.ensureVisible(key('candidate_load_more'));
    await tester.tap(key('candidate_load_more'));
    await tester.pumpAndSettle();

    expect(key('candidate_row_21'), findsOneWidget);
    expect(key('candidate_row_1'), findsOneWidget);
    expect(key('candidate_load_more'), findsNothing);
  });

  testWidgets('shows the empty message when nothing matches', (tester) async {
    stub((_, _) => const []);
    await pump(tester);

    expect(key('candidate_empty'), findsOneWidget);
    expect(find.text('Sin candidatos'), findsOneWidget);
  });

  testWidgets('a row tap hands the document over, unless disabled', (
    tester,
  ) async {
    stub((_, _) => [row(1)]);
    await pump(tester);
    await tester.tap(key('candidate_row_1'));
    expect(picked.map((d) => d.id), [1]);
  });

  testWidgets('a disabled picker ignores taps', (tester) async {
    stub((_, _) => [row(1)]);
    await pump(tester, enabled: false);
    await tester.tap(key('candidate_row_1'));
    expect(picked, isEmpty);
  });

  testWidgets('a load failure offers retry, which loads again', (tester) async {
    var calls = 0;
    when(
      () => repository.list(
        search: any(named: 'search'),
        issuer: any(named: 'issuer'),
        type: any(named: 'type'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const AppError.server();
      return FiscalDocumentPage(items: [row(1)], total: 1);
    });
    await pump(tester);
    expect(key('candidate_row_1'), findsNothing);

    await tester.tap(find.text(l10n.retryButton));
    await tester.pumpAndSettle();

    expect(key('candidate_row_1'), findsOneWidget);
  });
}
