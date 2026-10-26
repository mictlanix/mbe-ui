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
import 'package:mbe_ui/core/documents/data/document_source_impl.dart';
import 'package:mbe_ui/core/documents/domain/document_kind.dart';
import 'package:mbe_ui/core/documents/domain/document_ref.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/quote_email.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/053-quote-pdf-email/quickstart.md §2 against the REAL app
/// (macOS desktop) and a live mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/quote_pdf_email_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define-from-file=.env
///
/// Read-only: it never confirms an edit, never changes a quote, and never
/// delivers mail. The one send it attempts (M9) runs against a deployment
/// whose mail is not configured, which mbe-api refuses with 503 before
/// anything goes out; if the deployment answers otherwise the step stops
/// rather than send. Every quote is discovered at runtime.
///
/// Not automated, and why:
/// - M8 delivers a real email — needs configured mail and an inbox.
/// - M10 needs a quote cancelled mid-flow (a data change), and on a
///   deployment without mail mbe-api answers 503 before it checks the
///   quote's state. It has its own opt-in driver:
///   `integration_test/quote_email_cancelled_mid_flow_test.dart`.
/// - M12 needs an account without sales-quotes read.
/// - Print and download open native dialogs; the preview is checked up to
///   the enabled buttons, and the file name is checked through the client.
const _user = String.fromEnvironment('MBE_POS_USERNAME');
const _pass = String.fromEnvironment('MBE_POS_PASSWORD');

const _wide = Size(1400, 1100);
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

  testWidgets('Quote PDF and email quickstart §2 (real app, live mbe-api)', (
    tester,
  ) async {
    if (_user.isEmpty || _pass.isEmpty) {
      markTestSkipped('MBE_POS_USERNAME/_PASSWORD dart-defines are required.');
      return;
    }
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));

    // ------------------------------------------------------------------
    // API side (independent of the app's own session): fixtures
    // ------------------------------------------------------------------
    final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final token = await AuthRepositoryImpl(
      dio,
    ).login(username: _user, password: _pass);
    dio.options.headers['Authorization'] = 'Bearer $token';
    final quotes = SalesQuoteRepositoryImpl(dio);
    final customers = CustomerRepositoryImpl(dio);

    // The chips the dialog should show for a customer: contacts, then fiscal
    // recipients, plausible addresses only, first spelling of each wins.
    Future<List<String>> expectedAddresses(int customerId) async {
      final c = await customers.get(customerId: customerId);
      final seen = <String>{};
      final out = <String>[];
      for (final raw in [
        ...c.contacts.map((x) => x.email),
        ...c.taxpayers.map((x) => x.email),
      ]) {
        final a = raw?.trim() ?? '';
        if (isPlausibleEmail(a) && seen.add(a.toLowerCase())) out.add(a);
      }
      return out;
    }

    // A confirmed quote whose customer offers at least two addresses.
    Sale? confirmed;
    var confirmedAddresses = <String>[];
    final confirmedPage = await quotes.listQuotes(
      status: SaleStatus.completed,
      limit: 40,
    );
    for (final q in confirmedPage.items) {
      final addresses = await expectedAddresses(q.customer);
      if (addresses.length >= 2 && addresses.length <= 8) {
        confirmed = await quotes.getById(quoteId: q.id);
        confirmedAddresses = addresses;
        break;
      }
    }
    final draftPage = await quotes.listQuotes(
      status: SaleStatus.draft,
      limit: 1,
    );
    final cancelledPage = await quotes.listQuotes(
      status: SaleStatus.cancelled,
      limit: 1,
    );
    if (confirmed == null ||
        draftPage.items.isEmpty ||
        cancelledPage.items.isEmpty) {
      markTestSkipped(
        'Tenant needs a draft quote, a cancelled quote, and a confirmed quote '
        'whose customer has 2–8 email addresses.',
      );
      return;
    }
    final confirmedQuote = confirmed;
    final draft = await quotes.getById(quoteId: draftPage.items.first.id);
    final cancelled = await quotes.getById(
      quoteId: cancelledPage.items.first.id,
    );
    // ignore: avoid_print
    print(
      'QS: confirmed=${confirmedQuote.id} (${confirmedAddresses.length} '
      'addresses) draft=${draft.id} cancelled=${cancelled.id}',
    );

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

    Finder byKey(String k) => find.byKey(Key(k));

    Future<void> pumpUntil(
      Finder f, {
      Duration timeout = const Duration(seconds: 25),
    }) => pumpUntilTrue(() => f.evaluate().isNotEmpty, '$f', timeout: timeout);

    Future<void> pumpUntilGone(
      Finder f, {
      Duration timeout = const Duration(seconds: 25),
    }) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f', timeout: timeout);

    Future<void> tapFinder(Finder f) async {
      await pumpUntil(f);
      await tester.ensureVisible(f.first);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(f.first);
      await pumpFor(const Duration(milliseconds: 300));
    }

    Future<void> tapKey(String k) => tapFinder(byKey(k));

    bool enabled(String k) =>
        tester.widget<ButtonStyleButton>(byKey(k)).onPressed != null;

    void check(bool condition, String what) {
      if (!condition) throw TestFailure(what);
    }

    String chipKey(String address) =>
        'quote_email_chip_${address.toLowerCase()}';

    bool chipSelected(String address) =>
        tester.widget<FilterChip>(byKey(chipKey(address))).selected;

    List<String> chipKeysOnScreen() => find
        .byType(FilterChip)
        .evaluate()
        .map((e) => (e.widget.key as ValueKey<String>?)?.value ?? '')
        .where((k) => k.startsWith('quote_email_chip_'))
        .toList();

    String counterText() =>
        tester.widget<Text>(byKey('quote_email_counter')).data ?? '';

    Future<void> login(String user, String pass) async {
      await pumpUntil(byKey('login_username_field'));
      await tester.enterText(byKey('login_username_field'), user);
      await tester.enterText(byKey('login_password_field'), pass);
      await pumpFor(const Duration(milliseconds: 200));
      await tester.tap(byKey('login_password_field'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntilGone(
        byKey('login_username_field'),
        timeout: const Duration(seconds: 40),
      );
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
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> openEmailDialog() async {
      await tapKey('sales_quote_email_button');
      await pumpUntil(byKey('quote_email_dialog'));
      // The chips arrive once the customer has loaded.
      await pumpUntilTrue(
        () => chipKeysOnScreen().length >= confirmedAddresses.length,
        'recipient chips',
      );
      await pumpFor(const Duration(milliseconds: 300));
    }

    Future<void> closeEmailDialog() async {
      final cancel = byKey('quote_email_cancel_button');
      if (cancel.evaluate().isNotEmpty) {
        await tapKey('quote_email_cancel_button');
      } else {
        await tapKey('responsive_dialog_close');
      }
      await pumpUntilGone(byKey('quote_email_dialog'));
    }

    // Like a user: click into the field first. On desktop a click elsewhere
    // (a chip, a button) takes the field's focus, and the harness's
    // enterText alone does not win it back.
    Future<void> focusOther() async {
      await tester.tap(byKey('quote_email_other_field'));
      await pumpFor(const Duration(milliseconds: 200));
    }

    Future<void> typeAddress(String text) async {
      await focusOther();
      await tester.enterText(byKey('quote_email_other_field'), text);
      await pumpFor(const Duration(milliseconds: 150));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpFor(const Duration(milliseconds: 300));
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
        try {
          final texts = find
              .byType(Text)
              .evaluate()
              .map((el) => (el.widget as Text).data ?? '')
              .where((t) => t.isNotEmpty)
              .take(40)
              .toList();
          // ignore: avoid_print
          print('QS-DBG loc=${location()} texts=$texts');
        } catch (_) {}
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

    // ------------------------------------------------------------------
    // Login
    // ------------------------------------------------------------------
    // ignore: avoid_print
    print('QS: logging in');
    await login(_user, _pass);

    // ------------------------------------------------------------------
    // M1 — Ver cotización on a confirmed quote
    // ------------------------------------------------------------------
    await step('M1 preview of a confirmed quote (title, pages, actions, '
        'file name, timing)', () async {
      await openQuote(confirmedQuote.id);
      final padded = confirmedQuote.id.toString().padLeft(8, '0');
      final watch = Stopwatch()..start();
      await tapKey('sales_quote_view_document_button');
      await pumpUntil(
        byKey('document_page_0'),
        timeout: const Duration(seconds: 20),
      );
      watch.stop();
      // ignore: avoid_print
      print('QS: preview on screen in ${watch.elapsedMilliseconds} ms');
      final title = tester.widget<Text>(byKey('document_preview_title')).data;
      check(
        title == l10n.documentSalesQuoteTitle(padded),
        'title was "$title"',
      );
      check(enabled('document_print'), 'Imprimir disabled');
      check(enabled('document_download'), 'Descargar disabled');
      check(
        watch.elapsed < const Duration(seconds: 3),
        'preview took ${watch.elapsedMilliseconds} ms (SC-001 target 3 s)',
      );
      await tapKey('document_preview_close');
      await pumpUntilGone(byKey('document_preview_surface'));
      // The name a download would use, through the same client code.
      final doc = await DocumentSourceImpl(dio).fetch(
        DocumentRef(
          kind: DocumentKind.salesQuote,
          recordId: confirmedQuote.id,
          title: 't',
        ),
      );
      check(
        doc.filename == 'cotizacion-$padded.pdf',
        'file name was ${doc.filename}',
      );
    });

    // ------------------------------------------------------------------
    // M2 — a draft with unconfirmed typed text asks first
    // ------------------------------------------------------------------
    // On desktop a click outside a text field takes its focus, and losing
    // focus discards unconfirmed text (the app's "blur is a discard" rule) —
    // so by the time "Ver cotización" fires the draft is already gone and no
    // prompt is needed. On touch the field keeps focus and the prompt asks.
    // Either way the PDF must match the screen and nothing may be saved.
    await step('M2 draft: unconfirmed comment never reaches the PDF or the '
        'server (prompt on touch, discard-on-blur on desktop)', () async {
      await openQuote(draft.id);
      final before = (await quotes.getById(quoteId: draft.id)).comment;
      await tapKey('sales_quote_more_details_toggle');
      final field = find.descendant(
        of: byKey('sales_quote_comment_field'),
        matching: find.byType(EditableText),
      );
      await pumpUntil(field);
      const typedComment = 'QS 053 — no confirmar';
      await tester.enterText(field, typedComment);
      await pumpFor(const Duration(milliseconds: 300));
      check(
        tester.widget<EditableText>(field).controller.text == typedComment,
        'the comment did not take the typed text',
      );
      await tapKey('sales_quote_view_document_button');
      await pumpUntilTrue(
        () =>
            find.text(l10n.posUnconfirmedChangesTitle).evaluate().isNotEmpty ||
            byKey('document_page_0').evaluate().isNotEmpty,
        'the prompt or the preview',
        timeout: const Duration(seconds: 20),
      );
      if (find.text(l10n.posUnconfirmedChangesTitle).evaluate().isNotEmpty) {
        // ignore: avoid_print
        print('QS: M2 took the prompt path');
        await tapFinder(find.text(l10n.posUnconfirmedChangesDiscard));
        await pumpUntil(
          byKey('document_page_0'),
          timeout: const Duration(seconds: 20),
        );
      } else {
        // ignore: avoid_print
        print('QS: M2 took the discard-on-blur path');
        check(
          tester.widget<EditableText>(field).controller.text != typedComment,
          'the preview opened while the field still showed unsaved text',
        );
      }
      await tapKey('document_preview_close');
      await pumpUntilGone(byKey('document_preview_surface'));
      final after = (await quotes.getById(quoteId: draft.id)).comment;
      check(after == before, 'comment changed on the server: "$after"');
      check(
        byKey('sales_quote_email_button').evaluate().isEmpty,
        'Enviar por correo offered on a draft',
      );
    });

    // ------------------------------------------------------------------
    // M3 — cancelled quote
    // ------------------------------------------------------------------
    await step('M3 cancelled quote: Ver cotización yes, Enviar no', () async {
      await openQuote(cancelled.id);
      check(
        byKey('sales_quote_view_document_button').evaluate().isNotEmpty,
        'Ver cotización missing',
      );
      check(
        byKey('sales_quote_email_button').evaluate().isEmpty,
        'Enviar por correo offered on a cancelled quote',
      );
      await tapKey('sales_quote_view_document_button');
      await pumpUntil(
        byKey('document_page_0'),
        timeout: const Duration(seconds: 20),
      );
      await tapKey('document_preview_close');
      await pumpUntilGone(byKey('document_preview_surface'));
    });

    // ------------------------------------------------------------------
    // M4–M7 — the email dialog's recipient rules (nothing is sent)
    // ------------------------------------------------------------------
    await step('M4 dialog lists the customer\'s addresses as chips, in '
        'order, none selected, Enviar disabled', () async {
      await openQuote(confirmedQuote.id);
      await openEmailDialog();
      final reference =
          confirmedQuote.serial?.toString() ??
          '#${confirmedQuote.provisionalReference}';
      check(
        find
            .text(l10n.salesQuoteEmailDialogTitle(reference))
            .evaluate()
            .isNotEmpty,
        'dialog title missing for reference $reference',
      );
      final onScreen = chipKeysOnScreen();
      final expected = confirmedAddresses.map(chipKey).toList();
      check(
        onScreen.join(',') == expected.join(','),
        'chips $onScreen, expected $expected',
      );
      for (final a in confirmedAddresses) {
        check(!chipSelected(a), '$a selected on open');
      }
      check(!enabled('quote_email_send_button'), 'Enviar enabled on open');
      check(
        counterText() == l10n.salesQuoteEmailLimitHint,
        'hint was "${counterText()}"',
      );
    });

    const typed = 'qs053.typed@example.invalid';
    await step('M5 select two chips, type one address, deselect it', () async {
      await tapKey(chipKey(confirmedAddresses[0]));
      await tapKey(chipKey(confirmedAddresses[1]));
      check(
        chipSelected(confirmedAddresses[0]) &&
            chipSelected(confirmedAddresses[1]),
        'chips not selected',
      );
      check(enabled('quote_email_send_button'), 'Enviar disabled');
      await typeAddress(typed);
      check(byKey(chipKey(typed)).evaluate().isNotEmpty, 'typed chip missing');
      check(chipSelected(typed), 'typed chip not selected');
      check(counterText() == l10n.salesQuoteEmailCounter(3), counterText());
      await tapKey(chipKey(typed));
      check(byKey(chipKey(typed)).evaluate().isNotEmpty, 'typed chip removed');
      check(!chipSelected(typed), 'typed chip still selected');
      check(counterText() == l10n.salesQuoteEmailCounter(2), counterText());
    });

    await step(
      'M6 an invalid address shows the field error, adds nothing',
      () async {
        final before = chipKeysOnScreen().length;
        await focusOther();
        await tester.enterText(byKey('quote_email_other_field'), 'pedro@');
        await pumpFor(const Duration(milliseconds: 150));
        await tapKey('quote_email_add_button');
        check(
          find.text(l10n.salesQuoteEmailInvalidAddress).evaluate().isNotEmpty,
          'no field error',
        );
        check(chipKeysOnScreen().length == before, 'a chip was added');
        await focusOther();
        await tester.enterText(byKey('quote_email_other_field'), '');
        await pumpFor(const Duration(milliseconds: 200));
      },
    );

    await step('M7 ten recipients at most', () async {
      for (final a in [...confirmedAddresses, typed]) {
        if (!chipSelected(a)) await tapKey(chipKey(a));
      }
      var n = 0;
      while (counterText() != l10n.salesQuoteEmailLimitReached) {
        await typeAddress('qs053.extra$n@example.invalid');
        n++;
        check(n < 12, 'never reached the limit: "${counterText()}"');
      }
      check(!enabled('quote_email_add_button'), 'Agregar enabled at the limit');
      final chips = chipKeysOnScreen().length;
      await focusOther();
      await tester.enterText(
        byKey('quote_email_other_field'),
        'qs053.eleventh@example.invalid',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpFor(const Duration(milliseconds: 300));
      check(chipKeysOnScreen().length == chips, 'an 11th chip was added');
      check(counterText() == l10n.salesQuoteEmailLimitReached, counterText());
      await closeEmailDialog();
    });

    // ------------------------------------------------------------------
    // M9 — mail not configured
    // ------------------------------------------------------------------
    await step('M9 a deployment without mail: the banner says so and the '
        'selection is kept', () async {
      // Never send for real: only proceed when this deployment refuses with
      // 503 (mail not configured) before sending anything.
      try {
        await quotes.email(
          quoteId: confirmedQuote.id,
          recipients: const ['qs053.probe@example.invalid'],
        );
        throw TestFailure('this deployment sends mail; M9 does not apply');
      } on ServerError catch (e) {
        if (e.statusCode != 503) {
          throw TestFailure('expected 503, got ${e.statusCode}; not sending');
        }
      }
      await openEmailDialog();
      await tapKey(chipKey(confirmedAddresses[0]));
      await tapKey('quote_email_send_button');
      await pumpUntil(byKey('quote_email_error_banner'));
      check(
        find.text(l10n.salesQuoteEmailMailUnavailable).evaluate().isNotEmpty,
        'cause text missing',
      );
      check(chipSelected(confirmedAddresses[0]), 'selection lost');
      check(enabled('quote_email_send_button'), 'Enviar not re-enabled');
      check(find.byType(SnackBar).evaluate().isEmpty, 'success shown');
      await closeEmailDialog();
      check(
        find.text(l10n.salesQuoteStatusCompleted).evaluate().isNotEmpty,
        'quote status changed',
      );
    });

    // ------------------------------------------------------------------
    // M11 — phone width
    // ------------------------------------------------------------------
    await step('M11 compact: ⋮ menu holds both actions; dialog is '
        'full-screen', () async {
      tester.view.physicalSize = _compact;
      await pumpFor(const Duration(milliseconds: 500));
      await openQuote(confirmedQuote.id);
      check(
        byKey('sales_quote_view_document_button').evaluate().isEmpty &&
            byKey('sales_quote_email_button').evaluate().isEmpty,
        'wide buttons shown on compact',
      );
      check(
        byKey('sales_quote_more_details_toggle').evaluate().isNotEmpty,
        'Más detalles missing',
      );
      final toggleY = tester
          .getCenter(byKey('sales_quote_more_details_toggle'))
          .dy;
      final menuY = tester
          .getCenter(byKey('sales_quote_more_actions_button'))
          .dy;
      check(
        (toggleY - menuY).abs() <= 1,
        'toggle and ⋮ on different lines ($toggleY vs $menuY)',
      );
      await tapKey('sales_quote_more_actions_button');
      check(
        byKey('sales_quote_view_document_menu_item').evaluate().isNotEmpty &&
            byKey('sales_quote_email_menu_item').evaluate().isNotEmpty,
        'menu items missing',
      );
      await tapKey('sales_quote_email_menu_item');
      await pumpUntil(byKey('quote_email_dialog'));
      check(
        byKey('responsive_dialog_close').evaluate().isNotEmpty,
        'not the full-screen variant',
      );
      final dialogSize = tester.getSize(byKey('quote_email_dialog'));
      check(dialogSize.width >= _compact.width - 1, 'dialog not full width');
      await tapKey('responsive_dialog_close');
      await pumpUntilGone(byKey('quote_email_dialog'));

      await openQuote(draft.id);
      await tapKey('sales_quote_more_actions_button');
      check(
        byKey('sales_quote_view_document_menu_item').evaluate().isNotEmpty &&
            byKey('sales_quote_email_menu_item').evaluate().isEmpty,
        'draft menu should hold only Ver cotización',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await pumpFor(const Duration(milliseconds: 300));
      tester.view.physicalSize = _wide;
      await pumpFor(const Duration(milliseconds: 500));
    });

    // ------------------------------------------------------------------
    // Wide header band (the FactStripRow fix)
    // ------------------------------------------------------------------
    await step('Wide header: the three controls share one line', () async {
      await openQuote(confirmedQuote.id);
      final ys = [
        'sales_quote_view_document_button',
        'sales_quote_email_button',
        'sales_quote_more_details_toggle',
      ].map((k) => tester.getCenter(byKey(k)).dy).toList();
      check(
        ys.every((y) => (y - ys.first).abs() <= 1),
        'controls on different lines: $ys',
      );
    });

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
