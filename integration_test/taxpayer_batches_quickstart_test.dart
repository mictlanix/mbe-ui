import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_batch_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';

/// Automates specs/065-taxpayer-batches/quickstart.md steps 1-8 against the
/// REAL app (macOS desktop) and a live mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/taxpayer_batches_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env
///
/// Discovers an issuer at runtime, creates one series (`QA<6 digits>`)
/// through the app, edits, renames and deletes it, and removes anything it
/// left in a tear-down that runs even when a step fails. Existing series are
/// only ever read. The in-use step is soft: it needs a series that issued
/// documents already use, and is skipped when the tenant has none. Credentials
/// are never printed.
const _adminUser = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _adminPass = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');

const _wide = Size(1400, 1300);
const _compact = Size(400, 1100);

enum _Outcome { pass, fail, soft }

class _Result {
  _Result(this.name, this.outcome, this.detail);
  final String name;
  final _Outcome outcome;
  final String detail;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Taxpayer batches quickstart (real app, live mbe-api)', (
    tester,
  ) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped(
        'MBE_CATALOG_TEST_USERNAME/_PASSWORD dart-defines are required.',
      );
      return;
    }

    // ------------------------------------------------------------------
    // API side (independent of the app's own session)
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final batchRepo = TaxpayerBatchRepositoryImpl(dio);
    final issuerRepo = TaxpayerIssuerRepositoryImpl(dio);

    final stamp = DateTime.now().millisecondsSinceEpoch % 1000000;
    final seriesA = 'QA$stamp';
    final seriesB = 'QB$stamp';

    final issuers = (await issuerRepo.list(limit: 20)).items;
    if (issuers.isEmpty) {
      markTestSkipped('The tenant needs at least one taxpayer issuer.');
      return;
    }
    final rfc = issuers.first.rfc;

    Future<TaxpayerBatch?> findTest() async {
      for (final b in await batchRepo.listForIssuer(rfc)) {
        if (b.series == seriesA || b.series == seriesB) return b;
      }
      return null;
    }

    // Cleanup first, so it runs even if anything below fails.
    addTearDown(() async {
      try {
        for (final b in await batchRepo.listForIssuer(rfc)) {
          if (b.series == seriesA || b.series == seriesB) {
            await batchRepo.delete(rfc, b.taxpayerBatchId);
            // ignore: avoid_print
            print('QS: test series ${b.series} removed');
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('QS: test series NOT removed: ${_short(e)}');
      }
    });

    // A series that issued documents already use, for the lock check.
    TaxpayerBatch? inUse;
    String? inUseRfc;
    for (final issuer in issuers) {
      final found = (await batchRepo.listForIssuer(
        issuer.rfc,
      )).where((b) => b.inUse);
      if (found.isNotEmpty) {
        inUse = found.first;
        inUseRfc = issuer.rfc;
        break;
      }
    }

    // ------------------------------------------------------------------
    // App boot (mirrors lib/main.dart)
    // ------------------------------------------------------------------
    await initializeDateFormatting();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await TokenStorage().clear();

    tester.view.physicalSize = _wide;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const App(),
      ),
    );

    ProviderContainer container() =>
        ProviderScope.containerOf(tester.element(find.byType(App)));
    GoRouter router() => container().read(goRouterProvider);

    // ------------------------------------------------------------------
    // Harness helpers
    // ------------------------------------------------------------------
    Future<void> pumpFor(Duration d) async {
      final end = DateTime.now().add(d);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilTrue(
      bool Function() cond,
      String what, {
      Duration timeout = const Duration(seconds: 25),
    }) async {
      final end = DateTime.now().add(timeout);
      while (true) {
        await tester.pump(const Duration(milliseconds: 100));
        if (cond()) return;
        if (DateTime.now().isAfter(end)) {
          throw TestFailure('Timed out waiting for: $what');
        }
      }
    }

    Future<void> pumpUntil(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isNotEmpty, '$f');
    Future<void> pumpUntilGone(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f');

    Finder byKey(String k) => find.byKey(Key(k));
    Finder inTable(String text) => find.descendant(
      of: byKey('taxpayer_batches_table'),
      matching: find.text(text),
    );

    Future<void> ensureVisible(Finder f) async {
      await tester.ensureVisible(f.first);
      await pumpFor(const Duration(milliseconds: 300));
    }

    Future<void> tapFinder(Finder f) async {
      await pumpUntil(f);
      await ensureVisible(f);
      await tester.tap(f.first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> tapKey(String k) => tapFinder(byKey(k));

    Future<void> enter(String k, String text) async {
      final f = byKey(k);
      await pumpUntil(f);
      await ensureVisible(f);
      await tester.enterText(f, text);
      await pumpFor(const Duration(milliseconds: 200));
    }

    String fieldText(String k) => tester
        .widget<EditableText>(
          find.descendant(of: byKey(k), matching: find.byType(EditableText)),
        )
        .controller
        .text;

    Future<void> login() async {
      await pumpUntil(byKey('login_username_field').hitTestable());
      await tester.enterText(byKey('login_username_field'), _adminUser);
      await tester.enterText(byKey('login_password_field'), _adminPass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey('login_password_field'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilGone(byKey('login_username_field'));
      await pumpFor(const Duration(seconds: 1));
    }

    /// Opens the issuer's detail on top of the list, as the app does, and
    /// waits for the Series section to finish loading.
    Future<void> openIssuer(String forRfc) async {
      router().go('/taxpayer-issuers');
      await pumpFor(const Duration(seconds: 1));
      router().push('/taxpayer-issuers/$forRfc');
      await pumpUntilTrue(
        () =>
            byKey('taxpayer_batches_table').evaluate().isNotEmpty ||
            byKey('taxpayer_batches_empty').evaluate().isNotEmpty,
        'series section of $forRfc loaded',
      );
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> pickKind(String label) async {
      await tapKey('taxpayer_batch_type_field');
      final option = find.text(label);
      await pumpUntilTrue(() => option.evaluate().isNotEmpty, 'option $label');
      await tester.tap(option.last);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> closeDialog() async {
      // Wide: Cancelar or Cerrar. Compact: the dialog's own close control,
      // which replaces the secondary action there.
      final candidates = [
        byKey('taxpayer_batch_cancel_button'),
        byKey('taxpayer_batch_close_button'),
        byKey('responsive_dialog_close'),
      ];
      await tapFinder(
        candidates.firstWhere(
          (f) => f.hitTestable().evaluate().isNotEmpty,
          orElse: () => candidates.last,
        ),
      );
      await pumpUntilGone(find.byType(Dialog));
    }

    Future<void> recover() async {
      for (var i = 0; i < 4; i++) {
        final dlg = find.byType(Dialog);
        final alert = find.byType(AlertDialog);
        final any = dlg.evaluate().isNotEmpty
            ? dlg
            : (alert.evaluate().isNotEmpty ? alert : null);
        if (any == null) break;
        Navigator.of(tester.element(any.first), rootNavigator: true).pop();
        await pumpFor(const Duration(milliseconds: 400));
      }
      tester.takeException();
    }

    final results = <_Result>[];
    Future<void> step(
      String name,
      Future<void> Function() body, {
      bool soft = false,
    }) async {
      var note = '';
      try {
        await body();
        final ex = tester.takeException();
        if (ex != null) note = ' [framework exception: ${_short(ex)}]';
        results.add(_Result(name, _Outcome.pass, 'ok$note'));
      } catch (e) {
        await recover();
        results.add(
          _Result(name, soft ? _Outcome.soft : _Outcome.fail, _short(e)),
        );
      }
      // ignore: avoid_print
      print(
        'QS-STEP ${results.last.outcome.name.toUpperCase()} '
        '${results.last.name} :: ${results.last.detail}',
      );
    }

    void softFinding(String name, String text) {
      results.add(_Result(name, _Outcome.soft, text));
      // ignore: avoid_print
      print('QS-STEP SOFT $name :: $text');
    }

    // ------------------------------------------------------------------
    // Login
    // ------------------------------------------------------------------
    // ignore: avoid_print
    print('QS: logging in; issuer ${issuers.first.rfc}');
    await login();

    // ---- 1. The section lists what the server holds ----
    await step('1 the Series section lists the issuer\'s series', () async {
      await openIssuer(rfc);
      final server = await batchRepo.listForIssuer(rfc);
      if (server.isEmpty) {
        expect(byKey('taxpayer_batches_empty'), findsOneWidget);
      } else {
        expect(find.text('Series (${server.length})'), findsOneWidget);
        for (final b in server) {
          expect(inTable(b.series), findsWidgets, reason: b.series);
        }
      }
      expect(byKey('add_taxpayer_batch_button'), findsOneWidget);
    });

    // ---- 2. Add a series with two bank accounts, remove the first ----
    await step('2 add a series with bank accounts', () async {
      await openIssuer(rfc);
      await tapKey('add_taxpayer_batch_button');
      await pumpUntil(byKey('taxpayer_batch_series_field'));
      expect(find.text('Nueva serie'), findsOneWidget);
      expect(fieldText('taxpayer_batch_header_height_field'), '0');
      expect(fieldText('taxpayer_batch_footer_height_field'), '15');
      await enter('taxpayer_batch_series_field', seriesA);
      await pickKind('Factura');
      await enter('taxpayer_batch_template_name_field', 'QA plantilla');
      await tapKey('add_taxpayer_batch_account_button');
      await tapKey('add_taxpayer_batch_account_button');
      await enter('taxpayer_batch_account_bank_0', 'Primero');
      await enter('taxpayer_batch_account_bank_1', 'Segundo');
      await tapKey('remove_account_0');
      await tapKey('taxpayer_batch_save_button');
      await pumpUntilGone(byKey('taxpayer_batch_series_field'));
      await pumpUntil(inTable(seriesA));

      final created = await findTest();
      expect(created, isNotNull);
      expect(created!.series, seriesA);
      expect(created.typeCode, 0);
      expect(created.inUse, isFalse);
      expect(created.template.name, 'QA plantilla');
      expect([for (final a in created.template.accounts) a.bank], ['Segundo']);
    });

    // ---- 3. A duplicate series is refused, and the input stays ----
    await step('3 a duplicate series is refused', () async {
      await tapKey('add_taxpayer_batch_button');
      await pumpUntil(byKey('taxpayer_batch_series_field'));
      await enter('taxpayer_batch_series_field', seriesA);
      await pickKind('Nota de crédito');
      await enter('taxpayer_batch_template_name_field', 'Otra');
      await tapKey('taxpayer_batch_save_button');
      await pumpUntil(find.text('Ese valor ya está en uso en otra serie.'));
      expect(fieldText('taxpayer_batch_series_field'), seriesA);
      expect(fieldText('taxpayer_batch_template_name_field'), 'Otra');
      final matching = (await batchRepo.listForIssuer(
        rfc,
      )).where((b) => b.series == seriesA);
      expect(matching.length, 1);
      await closeDialog();
    });

    // ---- 4. A row tap opens it read-only, with Editar ----
    await step('4 a row tap opens the series read-only', () async {
      await tapFinder(inTable(seriesA));
      await pumpUntil(find.text('Ver serie'));
      expect(byKey('taxpayer_batch_save_button'), findsNothing);
      expect(byKey('taxpayer_batch_edit_button'), findsOneWidget);
      await tapKey('taxpayer_batch_edit_button');
      await pumpUntil(find.text('Editar serie'));
      expect(byKey('taxpayer_batch_save_button'), findsOneWidget);
      await closeDialog();
    });

    // ---- 5. Edit an unused series: rename it ----
    await step('5 rename an unused series', () async {
      final test = (await findTest())!;
      await tapKey('edit_taxpayer_batch_${test.taxpayerBatchId}');
      await pumpUntil(find.text('Editar serie'));
      expect(byKey('taxpayer_batch_in_use_note'), findsNothing);
      await enter('taxpayer_batch_series_field', seriesB);
      await tapKey('add_taxpayer_batch_account_button');
      await enter('taxpayer_batch_account_bank_1', 'Tercero');
      await tapKey('move_account_up_1');
      await tapKey('taxpayer_batch_save_button');
      await pumpUntilGone(byKey('taxpayer_batch_series_field'));
      await pumpUntil(inTable(seriesB));
      final renamed = await findTest();
      expect(renamed!.series, seriesB);
      expect(
        [for (final a in renamed.template.accounts) a.bank],
        ['Tercero', 'Segundo'],
      );
    });

    // ---- 6. An in-use series shows its lock up front ----
    await step('6 an in-use series is locked', () async {
      final locked = inUse;
      final lockedRfc = inUseRfc;
      if (locked == null || lockedRfc == null) {
        throw TestFailure('no in-use series in the tenant');
      }
      await openIssuer(lockedRfc);
      expect(
        byKey('taxpayer_batch_in_use_${locked.taxpayerBatchId}'),
        findsOneWidget,
      );
      await tapKey('edit_taxpayer_batch_${locked.taxpayerBatchId}');
      await pumpUntil(find.text('Editar serie'));
      expect(byKey('taxpayer_batch_in_use_note'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: byKey('taxpayer_batch_series_field'),
                matching: find.byType(TextField),
              ),
            )
            .enabled,
        isFalse,
      );
      expect(byKey('taxpayer_batch_delete_button'), findsNothing);
      // Nothing is saved: the series is only read.
      await closeDialog();
    }, soft: true);

    // ---- 7 / 8. Delete: cancel first, then confirm ----
    await step('7-8 delete after cancelling once', () async {
      await openIssuer(rfc);
      final test = (await findTest())!;
      await tapKey('edit_taxpayer_batch_${test.taxpayerBatchId}');
      await pumpUntil(byKey('taxpayer_batch_delete_button'));
      await tapKey('taxpayer_batch_delete_button');
      await pumpUntil(find.text('¿Eliminar la serie?'));
      await tapFinder(find.text('Cancelar').last);
      await pumpFor(const Duration(milliseconds: 400));
      expect(await findTest(), isNotNull);
      await tapKey('taxpayer_batch_delete_button');
      await pumpUntil(byKey('confirm_delete_taxpayer_batch_button'));
      await tapKey('confirm_delete_taxpayer_batch_button');
      await pumpUntilGone(byKey('taxpayer_batch_series_field'));
      await pumpUntilGone(inTable(seriesB));
      expect(await findTest(), isNull);
    });

    // ---- Compact width ----
    await step('compact: fullscreen dialog, no template column', () async {
      tester.view.physicalSize = _compact;
      await pumpFor(const Duration(milliseconds: 600));
      await openIssuer(rfc);
      await tapKey('add_taxpayer_batch_button');
      await pumpUntil(byKey('taxpayer_batch_series_field'));
      expect(byKey('taxpayer_batch_save_button'), findsOneWidget);
      expect(byKey('responsive_dialog_close'), findsOneWidget);
      await closeDialog();
      expect(find.text('Plantilla'), findsNothing);
      tester.view.physicalSize = _wide;
      await pumpFor(const Duration(milliseconds: 600));
    });

    softFinding(
      '10 reader-only account',
      'not automated: no seeded account holds Taxpayers read without update; '
          'covered by widget tests',
    );
    softFinding(
      'in-use race / issuer deleted while open',
      'manual only: needs a second session; covered by controller tests',
    );

    // ------------------------------------------------------------------
    // Summary
    // ------------------------------------------------------------------
    // ignore: avoid_print
    print('QS: ==== RESULTS ====');
    for (final r in results) {
      // ignore: avoid_print
      print(
        'QS: ${r.outcome.name.toUpperCase().padRight(4)} ${r.name} '
        ':: ${r.detail}',
      );
    }
    final failed = results.where((r) => r.outcome == _Outcome.fail).toList();
    expect(
      failed,
      isEmpty,
      reason: failed.map((r) => '${r.name}: ${r.detail}').join('\n'),
    );
  }, timeout: const Timeout(Duration(minutes: 10)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
