import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
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

/// Automates the checks of specs/053-quote-pdf-email/quickstart.md §2 that
/// the read-only quickstart driver can't: M8, M10 and M12. Real app (macOS),
/// live mbe-api whose mail IS configured.
///
///   caffeinate -dimsu flutter test \
///     integration_test/quote_pdf_email_live_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env \
///     --dart-define=MBE_QUOTE_EMAIL_TO=you@example.com  # an inbox you watch
///
/// Changes data and sends mail:
/// - M8 sends one real email, to `MBE_QUOTE_EMAIL_TO` only.
/// - M10 creates a throwaway quote (copying the customer and first product
///   of a recent confirmed quote), confirms it, and cancels it through the
///   API while the dialog is open, standing in for the other tab. Enviar is
///   pressed only after the API reports the quote cancelled, so a mail
///   arriving for that quote means the guard failed.
/// - M12 needs `MBE_NOQUOTES_USERNAME`/`_PASSWORD`: a non-admin account
///   without sales-quotes Read.
const _user = String.fromEnvironment('MBE_POS_USERNAME');
const _pass = String.fromEnvironment('MBE_POS_PASSWORD');
const _noQuotesUser = String.fromEnvironment('MBE_NOQUOTES_USERNAME');
const _noQuotesPass = String.fromEnvironment('MBE_NOQUOTES_PASSWORD');
const _recipient = String.fromEnvironment('MBE_QUOTE_EMAIL_TO');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  late AppLocalizations l10n;
  late SalesQuoteRepositoryImpl quotes;
  late Sale source;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    await initializeDateFormatting();
    if (_user.isEmpty || _pass.isEmpty) return;
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _user, password: _pass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    quotes = SalesQuoteRepositoryImpl(dio);
    final page = await quotes.listQuotes(
      status: SaleStatus.completed,
      limit: 20,
    );
    for (final q in page.items) {
      final full = await quotes.getById(quoteId: q.id);
      if (full.lines.isNotEmpty) {
        source = full;
        return;
      }
    }
    throw StateError('Tenant needs a confirmed quote with at least one line.');
  });

  Future<_App> boot(WidgetTester tester, String user, String pass) async {
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
    final app = _App(tester);
    await app.login(user, pass);
    return app;
  }

  testWidgets('M8: a real send to MBE_QUOTE_EMAIL_TO', (tester) async {
    if (_user.isEmpty || _recipient.isEmpty) {
      markTestSkipped('Needs MBE_POS_* and MBE_QUOTE_EMAIL_TO.');
      return;
    }
    final app = await boot(tester, _user, _pass);
    await app.openQuote(source.id);

    final clock = Stopwatch()..start();
    await app.openEmailDialog();
    await app.addRecipient(_recipient);
    await tester.tap(app.byKey('quote_email_send_button'));

    // While sending: progress label, Cancel disabled, Escape ignored.
    await app.pumpUntil(find.text(l10n.salesQuoteEmailSendingLabel));
    expect(
      tester
          .widget<ButtonStyleButton>(app.byKey('quote_email_cancel_button'))
          .onPressed,
      isNull,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 50));
    final stillSending = find
        .text(l10n.salesQuoteEmailSendingLabel)
        .evaluate()
        .isNotEmpty;
    if (stillSending) {
      expect(app.byKey('quote_email_dialog'), findsOneWidget);
    }

    // Then the dialog closes and a snackbar names the recipient.
    await app.pumpUntil(find.text(l10n.salesQuoteEmailSentMessage(_recipient)));
    clock.stop();
    // The snackbar shows while the dialog's exit animation is still running.
    await app.pumpUntilGone(app.byKey('quote_email_dialog'));
    // ignore: avoid_print
    print(
      'M8: quote ${source.id} sent to $_recipient in '
      '${clock.elapsedMilliseconds} ms (dialog open → snackbar); '
      'Escape checked while sending: $stillSending',
    );
    expect(clock.elapsed, lessThan(const Duration(seconds: 30)));
  });

  testWidgets('M10: quote cancelled while the email dialog is open', (
    tester,
  ) async {
    if (_user.isEmpty) {
      markTestSkipped('Needs MBE_POS_*.');
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

    final app = await boot(tester, _user, _pass);
    await app.openQuote(quote.id);
    await app.openEmailDialog();
    await app.addRecipient(
      _recipient.isEmpty ? 'qs053.m10@example.invalid' : _recipient,
    );

    // "Another tab" cancels the quote. Never press Enviar unless it took.
    final cancelled = await quotes.cancel(quoteId: quote.id);
    expect(cancelled.status, SaleStatus.cancelled);

    await app.tapKey('quote_email_send_button');
    await app.pumpUntil(app.byKey('quote_email_error_banner'));
    expect(find.text(l10n.salesQuoteEmailNotSendable), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    // On close, the screen catches up with the cancellation.
    await app.tapKey('quote_email_cancel_button');
    await app.pumpUntilGone(app.byKey('quote_email_dialog'));
    await app.pumpUntil(find.text(l10n.salesQuoteStatusCancelled));
    await app.pumpUntilGone(app.byKey('sales_quote_email_button'));
    expect(app.byKey('sales_quote_view_document_button'), findsOneWidget);
  });

  testWidgets('M12: a user without sales-quotes Read never sees the actions', (
    tester,
  ) async {
    if (_noQuotesUser.isEmpty || _noQuotesPass.isEmpty) {
      markTestSkipped('Needs MBE_NOQUOTES_USERNAME/_PASSWORD.');
      return;
    }
    final app = await boot(tester, _noQuotesUser, _noQuotesPass);
    expect(find.text(l10n.salesQuotesMenuTitle), findsNothing);

    for (final path in ['/sales/quotes/${source.id}', '/sales/quotes']) {
      app.router().go(path);
      await app.pumpFor(const Duration(seconds: 2));
      expect(app.location(), '/', reason: '$path was reachable');
      expect(app.byKey('sales_quote_view_document_button'), findsNothing);
      expect(app.byKey('sales_quote_email_button'), findsNothing);
    }
  });
}

/// The harness for one booted app.
class _App {
  _App(this.tester);

  final WidgetTester tester;

  GoRouter router() => ProviderScope.containerOf(
    tester.element(find.byType(App)),
  ).read(goRouterProvider);

  String location() =>
      router().routerDelegate.currentConfiguration.last.matchedLocation;

  Finder byKey(String k) => find.byKey(Key(k));

  Future<void> pumpFor(Duration d) async {
    final end = DateTime.now().add(d);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpUntilTrue(bool Function() cond, String what) async {
    final end = DateTime.now().add(const Duration(seconds: 40));
    while (true) {
      await tester.pump(const Duration(milliseconds: 50));
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

  Future<void> tapKey(String k) async {
    await pumpUntil(byKey(k));
    await tester.ensureVisible(byKey(k).first);
    await pumpFor(const Duration(milliseconds: 200));
    await tester.tap(byKey(k).first);
    await pumpFor(const Duration(milliseconds: 300));
  }

  Future<void> login(String user, String pass) async {
    await pumpUntil(byKey('login_username_field'));
    await tester.enterText(byKey('login_username_field'), user);
    await tester.enterText(byKey('login_password_field'), pass);
    await pumpFor(const Duration(milliseconds: 200));
    await tester.tap(byKey('login_password_field'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpUntilGone(byKey('login_username_field'));
    await pumpFor(const Duration(seconds: 1));
  }

  Future<void> openQuote(int id) async {
    router().go('/sales/quotes');
    await pumpFor(const Duration(milliseconds: 500));
    router().go('/sales/quotes/$id');
    await pumpUntil(byKey('sales_quote_more_details_toggle'));
    await pumpUntilTrue(
      () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
      'quote $id loaded',
    );
  }

  Future<void> openEmailDialog() async {
    await tapKey('sales_quote_email_button');
    await pumpUntil(byKey('quote_email_dialog'));
    await pumpFor(const Duration(seconds: 1));
  }

  /// Types [address] as the only recipient and checks it is selected.
  Future<void> addRecipient(String address) async {
    await tester.tap(byKey('quote_email_other_field'));
    await pumpFor(const Duration(milliseconds: 200));
    await tester.enterText(byKey('quote_email_other_field'), address);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpFor(const Duration(milliseconds: 300));
    final chip = byKey('quote_email_chip_${address.toLowerCase()}');
    expect(chip, findsOneWidget);
    expect(tester.widget<FilterChip>(chip).selected, isTrue);
  }
}
