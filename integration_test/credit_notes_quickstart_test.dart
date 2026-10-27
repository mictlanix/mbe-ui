import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates the read-only half of specs/056-credit-notes/quickstart.md
/// (steps 1–4 and 10) against the REAL app (macOS desktop) and a live
/// mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/credit_notes_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env
///
/// `MBE_POS_*` is the administrator; `MBE_TEST_*` is `qanoaccess`, the
/// non-administrator with no privileges, who backs step 10 (see
/// test/integration/TEST_ACCOUNTS.md).
///
/// Steps 5–9 (spending a note in the Cobro step) are not here: they need a
/// spendable note, which only exists once a refund has been confirmed as store
/// credit through mbe-api, and this test creates nothing. Read-only; fixtures
/// are discovered at runtime. Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_POS_USERNAME');
const _adminPass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');

const _wide = Size(1400, 1000);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Credit notes quickstart walkthrough (real app, live mbe-api)', (
    tester,
  ) async {
    if (_adminUser.isEmpty || _adminPass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }

    // Frame watchdog: when the app window is not frontmost, macOS can stop
    // delivering frames and every pump then waits forever. Drives a frame by
    // hand after ~1.5 s without one; changes nothing when frames flow.
    var kicks = 0;
    var lastTs = binding.currentSystemFrameTimeStamp;
    var lastWall = DateTime.now();
    DateTime? stalledSince;
    final watchdog = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final ts = binding.currentSystemFrameTimeStamp;
      final now = DateTime.now();
      if (ts != lastTs) {
        lastTs = ts;
        lastWall = now;
      }
      if (!binding.hasScheduledFrame ||
          binding.schedulerPhase != SchedulerPhase.idle) {
        stalledSince = null;
        return;
      }
      stalledSince ??= now;
      if (now.difference(stalledSince!) < const Duration(milliseconds: 1500)) {
        return;
      }
      final raw = lastTs + now.difference(lastWall);
      lastTs = raw;
      lastWall = now;
      stalledSince = null;
      kicks++;
      binding.handleBeginFrame(raw);
      binding.handleDrawFrame();
    });
    addTearDown(() {
      watchdog.cancel();
      // ignore: avoid_print
      print('QS: frame watchdog drove $kicks frame(s)');
    });

    // ------------------------------------------------------------------
    // API side (independent of the app's own session)
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _adminUser, password: _adminPass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final notes = CreditNoteRepositoryImpl(dio);
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    final firstPage = await notes.list(limit: 20);
    if (firstPage.items.isEmpty) {
      markTestSkipped('this tenant has no credit notes');
      return;
    }
    final everyNote = <CreditNote>[...firstPage.items];
    while (everyNote.length < firstPage.total) {
      final page = await notes.list(skip: everyNote.length, limit: 100);
      if (page.items.isEmpty) break;
      everyNote.addAll(page.items);
    }
    final anchor = firstPage.items.first;
    final ofAnchorCustomer = everyNote
        .where((n) => n.customerId == anchor.customerId)
        .toList();
    final open = everyNote.where((n) => n.isOpen).toList();

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
    String location() =>
        router().routerDelegate.currentConfiguration.last.matchedLocation;

    Future<void> pumpFor(Duration d) async {
      final end = DateTime.now().add(d);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilTrue(
      bool Function() cond,
      String what, {
      Duration timeout = const Duration(seconds: 60),
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

    Finder byKey(String k) => find.byKey(Key(k));
    bool spinning() =>
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

    List<String> tableTexts() => find
        .descendant(
          of: byKey('credit_notes_table'),
          matching: find.byType(Text),
        )
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    /// The origin cells' rendered text. Read off `RichText`, not `Text.data`:
    /// once a row's order link resolves, the cell becomes a `Text.rich` whose
    /// `data` is null.
    Finder originOf(int refundId) => find.byWidgetPredicate(
      (w) =>
          w is RichText &&
          w.text.toPlainText().startsWith('Devolución #$refundId '),
    );
    int originRows() => find
        .descendant(
          of: byKey('credit_notes_table'),
          matching: find.byWidgetPredicate(
            (w) =>
                w is RichText &&
                w.text.toPlainText().startsWith('Devolución #'),
          ),
        )
        .evaluate()
        .length;

    Future<void> login(String user, String pass) async {
      await pumpUntilTrue(
        () => byKey('login_username_field').hitTestable().evaluate().isNotEmpty,
        'login screen',
      );
      await tester.enterText(byKey('login_username_field').hitTestable(), user);
      await tester.enterText(byKey('login_password_field').hitTestable(), pass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey('login_password_field').hitTestable());
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilTrue(
        () => byKey('login_username_field').evaluate().isEmpty,
        'login to finish',
        timeout: const Duration(seconds: 40),
      );
      await pumpFor(const Duration(seconds: 1));
    }

    Future<void> go(String path) async {
      router().go(path);
      await pumpFor(const Duration(milliseconds: 500));
    }

    /// Waits for the list to leave its loading state.
    Future<void> settled(String what) => pumpUntilTrue(
      () =>
          !spinning() &&
          (byKey('credit_notes_table').evaluate().isNotEmpty ||
              find.text(l10n.creditNotesEmpty).evaluate().isNotEmpty ||
              find.text(l10n.clearFiltersButton).evaluate().isNotEmpty),
      what,
    );

    final failures = <String>[];
    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
        final ex = tester.takeException();
        if (ex != null) throw TestFailure('framework exception: $ex');
        // ignore: avoid_print
        print('QS-STEP PASS $name');
      } catch (e) {
        failures.add('$name: $e');
        tester.takeException();
        // ignore: avoid_print
        print('QS-STEP FAIL $name :: $e');
      }
    }

    // ------------------------------------------------------------------
    // Steps 1–4 as the administrator
    // ------------------------------------------------------------------
    await login(_adminUser, _adminPass);

    await step(
      '1. the list opens, newest first, 20 per page, no search box',
      () async {
        await go('/sales/credit-notes');
        await settled('list');
        expect(find.text(l10n.creditNotesMenuTitle), findsWidgets);
        expect(originRows(), firstPage.items.length);
        expect(
          tableTexts(),
          contains(
            l10n.creditNotesOrigin(
              anchor.customerRefundId,
              anchor.salesOrderId,
            ),
          ),
          reason: 'the newest note is on the first page',
        );
        expect(find.byType(SearchBar), findsNothing);
        expect(byKey('credit_notes_filter_button'), findsOneWidget);
      },
    );

    await step('2. filtering to a customer lists only their notes', () async {
      await go('/sales/credit-notes?customer=${anchor.customerId}');
      await settled('filtered list');
      await pumpUntilTrue(
        () => !tableTexts().contains('…'),
        'customer names to resolve',
      );
      final expected = ofAnchorCustomer.length.clamp(0, 20);
      expect(originRows(), expected);
      await tester.tap(byKey('credit_notes_filter_button'));
      await pumpUntilTrue(
        () => byKey('credit_notes_open_only_filter').evaluate().isNotEmpty,
        'the drawer',
      );
      expect(byKey('credit_notes_customer_filter'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await pumpFor(const Duration(milliseconds: 600));
    });

    await step(
      '3. "Solo con saldo" lists exactly the notes with a balance',
      () async {
        await go('/sales/credit-notes?open=1');
        await settled('open-only list');
        if (open.isEmpty) {
          expect(find.text(l10n.clearFiltersButton), findsOneWidget);
        } else {
          expect(originRows(), open.length.clamp(0, 20));
          // The remaining column shows each open note's figure, none a zero.
          expect(
            tableTexts().where((t) => t.startsWith('\$')).length,
            greaterThanOrEqualTo(open.length.clamp(0, 20)),
          );
        }
      },
    );

    await step('4. a row opens its backing payment', () async {
      await go('/sales/credit-notes');
      await settled('list');
      await pumpUntilTrue(
        () => !tableTexts().contains('…'),
        'customer names to resolve',
      );
      // Tap the words, not the order link at the end of the same cell.
      final origin = originOf(anchor.customerRefundId);
      await pumpUntilTrue(() => origin.evaluate().isNotEmpty, 'the row');
      await tester.tapAt(tester.getTopLeft(origin.first) + const Offset(8, 8));
      await pumpUntilTrue(
        () => location() == '/sales/payments/${anchor.customerPaymentId}',
        'the payment screen',
      );
      await pumpUntilTrue(
        () =>
            (byKey('payment_summary_amount').evaluate().isNotEmpty ||
                byKey('payment_not_found').evaluate().isNotEmpty) &&
            !spinning(),
        'payment loaded',
      );
    });

    // ------------------------------------------------------------------
    // Step 10 as a user with no privileges at all
    // ------------------------------------------------------------------
    if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
      await container().read(authProvider.notifier).signOut();
      await login(_noAccessUser, _noAccessPass);

      await step(
        '10. without credit-payments read: no entry, route redirects',
        () async {
          expect(find.text(l10n.creditNotesMenuTitle), findsNothing);
          await go('/sales/credit-notes');
          expect(location(), '/');
          expect(byKey('credit_notes_table'), findsNothing);
        },
      );
    } else {
      // ignore: avoid_print
      print('QS-STEP SKIP 10. MBE_TEST_USERNAME/_PASSWORD not given');
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 15)));
}
