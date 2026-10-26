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
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/053-quote-pdf-email/quickstart.md §2 M10 — the quote is
/// cancelled while the email dialog is open — against the REAL app (macOS)
/// and a live mbe-api whose mail IS configured (without mail, mbe-api
/// answers 503 before it checks the quote's state).
///
///   caffeinate -dimsu flutter test \
///     integration_test/quote_email_cancelled_mid_flow_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env
///
/// Changes data: it creates a throwaway quote (copying the customer and
/// first product of a recent confirmed quote), confirms it, and cancels it
/// through the API while the dialog is open — standing in for the other
/// tab. Enviar is pressed only after the API reports the quote cancelled.
/// The one recipient is `MBE_QUOTE_EMAIL_TO` (an inbox you watch: a mail
/// arriving means the guard failed), else an undeliverable address.
const _user = String.fromEnvironment('MBE_POS_USERNAME');
const _pass = String.fromEnvironment('MBE_POS_PASSWORD');
const _recipient = String.fromEnvironment(
  'MBE_QUOTE_EMAIL_TO',
  defaultValue: 'qs053.m10@example.invalid',
);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('M10: quote cancelled while the email dialog is open', (
    tester,
  ) async {
    if (_user.isEmpty || _pass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    // API side: a throwaway confirmed quote.
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _user, password: _pass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final quotes = SalesQuoteRepositoryImpl(dio);

    Sale? source;
    final page = await quotes.listQuotes(
      status: SaleStatus.completed,
      limit: 20,
    );
    for (final q in page.items) {
      final full = await quotes.getById(quoteId: q.id);
      if (full.lines.isNotEmpty) {
        source = full;
        break;
      }
    }
    if (source == null) {
      markTestSkipped('Tenant needs a confirmed quote with at least one line.');
      return;
    }
    final opened = await quotes.open(customer: source.customer);
    await quotes.addLine(
      quoteId: opened.id,
      product: source.lines.first.product,
      quantity: '1',
    );
    final quote = await quotes.confirm(quoteId: opened.id);
    // ignore: avoid_print
    print('M10: throwaway quote ${quote.id} (copied from ${source.id})');

    // App boot (mirrors lib/main.dart).
    await initializeDateFormatting();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await TokenStorage().clear();

    tester.view.physicalSize = const Size(1400, 1100);
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

    GoRouter router() => ProviderScope.containerOf(
      tester.element(find.byType(App)),
    ).read(goRouterProvider);

    Future<void> pumpFor(Duration d) async {
      final end = DateTime.now().add(d);
      while (DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilTrue(bool Function() cond, String what) async {
      final end = DateTime.now().add(const Duration(seconds: 30));
      while (true) {
        await tester.pump(const Duration(milliseconds: 100));
        if (cond()) return;
        if (DateTime.now().isAfter(end)) {
          throw TestFailure('Timed out waiting for: $what');
        }
      }
    }

    Finder byKey(String k) => find.byKey(Key(k));
    Future<void> pumpUntil(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isNotEmpty, '$f');
    Future<void> pumpUntilGone(Finder f) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f');

    Future<void> tapKey(String k) async {
      await pumpUntil(byKey(k));
      await tester.ensureVisible(byKey(k).first);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey(k).first);
      await pumpFor(const Duration(milliseconds: 300));
    }

    // Log in.
    await pumpUntil(byKey('login_username_field'));
    await tester.enterText(byKey('login_username_field'), _user);
    await tester.enterText(byKey('login_password_field'), _pass);
    await pumpFor(const Duration(milliseconds: 200));
    await tester.tap(byKey('login_password_field'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpUntilGone(byKey('login_username_field'));
    await pumpFor(const Duration(seconds: 1));

    // Open the confirmed quote and its email dialog.
    router().go('/sales/quotes');
    await pumpFor(const Duration(milliseconds: 500));
    router().go('/sales/quotes/${quote.id}');
    await pumpUntil(byKey('sales_quote_more_details_toggle'));
    await pumpUntilTrue(
      () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
      'quote loaded',
    );
    await tapKey('sales_quote_email_button');
    await pumpUntil(byKey('quote_email_dialog'));
    await pumpFor(const Duration(seconds: 1));

    // Address the mail to an undeliverable recipient only.
    await tester.tap(byKey('quote_email_other_field'));
    await pumpFor(const Duration(milliseconds: 200));
    await tester.enterText(byKey('quote_email_other_field'), _recipient);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFor(const Duration(milliseconds: 300));
    final chip = byKey('quote_email_chip_$_recipient');
    expect(chip, findsOneWidget);
    expect(tester.widget<FilterChip>(chip).selected, isTrue);

    // "Another tab" cancels the quote. Never press Enviar unless it took.
    final cancelled = await quotes.cancel(quoteId: quote.id);
    expect(cancelled.status, SaleStatus.cancelled);

    await tapKey('quote_email_send_button');
    await pumpUntil(byKey('quote_email_error_banner'));
    expect(find.text(l10n.salesQuoteEmailNotSendable), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    // On close, the screen catches up with the cancellation.
    await tapKey('quote_email_cancel_button');
    await pumpUntilGone(byKey('quote_email_dialog'));
    await pumpUntil(find.text(l10n.salesQuoteStatusCancelled));
    await pumpUntilGone(byKey('sales_quote_email_button'));
    expect(byKey('sales_quote_view_document_button'), findsOneWidget);
  });
}
