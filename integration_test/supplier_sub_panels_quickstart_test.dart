import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mbe_api_client/mbe_api_client.dart' show BankAccountsApi;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/app/app.dart';
import 'package:mbe_ui/app/router/app_router.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/bank_account_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/contact_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Automates specs/050-supplier-sub-panels/quickstart.md §2 and §3 against
/// the REAL app (macOS desktop) and a live mbe-api.
///
///   flutter test integration_test/supplier_sub_panels_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_CATALOG_TEST_USERNAME=... (and _PASSWORD)
///     --dart-define=MBE_READONLY_USERNAME=...     (and _PASSWORD)
///
/// Creates one supplier (`QS<timestamp>`) and one bank account, and removes
/// both in a tear-down that runs even when a step fails. Existing suppliers
/// are only ever read. Credentials are never printed.
const _adminUser = String.fromEnvironment('MBE_CATALOG_TEST_USERNAME');
const _adminPass = String.fromEnvironment('MBE_CATALOG_TEST_PASSWORD');
const _roUser = String.fromEnvironment('MBE_READONLY_USERNAME');
const _roPass = String.fromEnvironment('MBE_READONLY_PASSWORD');

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

  testWidgets('Supplier sub-panels quickstart §2 and §3 (real app, live mbe-api)', (
    tester,
  ) async {
    if (_adminUser.isEmpty ||
        _adminPass.isEmpty ||
        _roUser.isEmpty ||
        _roPass.isEmpty) {
      markTestSkipped(
        'MBE_CATALOG_TEST_USERNAME/_PASSWORD and MBE_READONLY_USERNAME/'
        '_PASSWORD dart-defines are required.',
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
    final supplierRepo = SupplierRepositoryImpl(dio);
    final addressRepo = AddressRepositoryImpl(dio);
    final contactRepo = ContactRepositoryImpl(dio);
    final bankRepo = BankAccountRepositoryImpl(dio);

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final testCode = 'QS$stamp'; // 15 chars
    final testName = 'QS 050 $stamp';
    final bankName = 'QS050 $stamp';
    int? testId;

    Future<int?> findTestSupplierId() async {
      if (testId != null) return testId;
      final page = await supplierRepo.listDetailed(
        search: testCode,
        limit: 100,
      );
      for (final s in page.items) {
        if (s.code == testCode || s.name == testName) return s.supplierId;
      }
      return null;
    }

    // Cleanup first, so it runs even if anything below fails.
    addTearDown(() async {
      try {
        final sid = await findTestSupplierId();
        if (sid != null) {
          try {
            for (final a in await supplierRepo.listAgreements(
              supplierId: sid,
            )) {
              await supplierRepo.deleteAgreement(
                supplierId: sid,
                agreementId: a.supplierAgreementId,
              );
            }
          } catch (_) {}
          try {
            await supplierRepo.update(
              supplierId: sid,
              addressIds: const [],
              contactIds: const [],
              bankAccountIds: const [],
            );
          } catch (_) {}
          try {
            await supplierRepo.delete(supplierId: sid);
          } catch (_) {}
        }
        final banks = await bankRepo.list(search: bankName, limit: 100);
        for (final b in banks.items.where((b) => b.bankName == bankName)) {
          try {
            await BankAccountsApi(
              dio,
              appSerializers,
            ).deleteBankAccountApiV1BankAccountsBankAccountIdDelete(
              bankAccountId: b.bankAccountId,
            );
          } catch (_) {}
        }
      } catch (_) {}
    });

    final totalBefore = (await supplierRepo.listDetailed(limit: 1)).total;
    // ignore: avoid_print
    print('QS: supplier total before run = $totalBefore');

    // Runtime-discovered fixtures.
    final addrPage = await addressRepo.list(
      status: EntityStatus.active,
      limit: 20,
    );
    final contacts = await contactRepo.list(limit: 20);
    if (addrPage.items.length < 2 || contacts.isEmpty) {
      markTestSkipped('Tenant needs >= 2 active addresses and 1 contact.');
      return;
    }
    final addrA = addrPage.items[0]; // linked in step 7
    final addrB = addrPage.items[1]; // used as the "other" option in step 6
    final contactA = contacts.first;

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

    Future<void> pumpUntil(
      Finder f, {
      Duration timeout = const Duration(seconds: 25),
    }) => pumpUntilTrue(
      () => f.evaluate().isNotEmpty,
      f.toString(),
      timeout: timeout,
    );

    Future<void> pumpUntilGone(
      Finder f, {
      Duration timeout = const Duration(seconds: 25),
    }) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f', timeout: timeout);

    Finder titled(String t) =>
        find.descendant(of: find.byType(AppBar), matching: find.text(t));

    Finder byKey(String k) => find.byKey(Key(k));
    Finder byPrefix(String p) => find.byWidgetPredicate((w) {
      final k = w.key;
      return k is ValueKey<String> && k.value.startsWith(p);
    }, description: 'key prefix "$p"');
    int count(String prefix) => byPrefix(prefix).evaluate().length;

    Future<void> ensureVisible(Finder f) async {
      await tester.ensureVisible(f.first);
      await pumpFor(const Duration(milliseconds: 300));
    }

    Future<void> tapFinder(Finder f) async {
      await pumpUntil(f);
      await ensureVisible(f);
      await tester.tap(f.first);
      await pumpFor(const Duration(milliseconds: 300));
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

    AppLocalizations l10n() =>
        AppLocalizations.of(tester.element(find.byType(Scaffold).last))!;

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

    Future<void> openSuppliers() async {
      router().go('/suppliers');
      await pumpUntil(byKey('suppliers_table'));
      await pumpUntilGone(byKey('supplier_agreements_section'));
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> searchSupplier(String text) async {
      await pumpUntil(byKey('suppliers_search_field'));
      for (var attempt = 0; attempt < 3; attempt++) {
        await pumpFor(const Duration(seconds: 1));
        if (attempt == 2) {
          // Typed search kept ending up with an empty box in some runs;
          // fall back to the equivalent URL the search submit navigates to.
          router().go('/suppliers?search=${Uri.encodeQueryComponent(text)}');
        } else {
          await tester.enterText(byKey('suppliers_search_field'), text);
        }
        await pumpFor(const Duration(milliseconds: 200));
        if (attempt < 2) {
          await tester.testTextInput.receiveAction(TextInputAction.search);
        }
        try {
          await pumpUntilTrue(
            () => find.text(text).evaluate().length >= 2, // field + code cell
            'search results for "$text"',
            timeout: const Duration(seconds: 10),
          );
          return;
        } catch (_) {
          // ignore: avoid_print
          print(
            'QS-DBG search attempt $attempt uri=${router().routerDelegate.currentConfiguration.uri} '
            'field=${fieldText('suppliers_search_field')} '
            'tables=${byKey('suppliers_table').evaluate().length} '
            'searchFields=${byKey('suppliers_search_field').evaluate().length}',
          );
          if (attempt == 2) rethrow;
        }
      }
    }

    /// Real user path: list -> search -> click the row.
    Future<void> openRowFromList(String code) async {
      await openSuppliers();
      await searchSupplier(code);
      final cell = find.descendant(
        of: byKey('suppliers_table'),
        matching: find.text(code),
      );
      await pumpUntil(cell);
      await tester.tap(cell.first);
      await pumpFor(const Duration(milliseconds: 500));
    }

    /// Pushes the detail route on top of the list, as the app does.
    Future<void> openDetail(int id, {bool view = false}) async {
      await openSuppliers();
      router().push('/suppliers/$id${view ? '?view=true' : ''}');
      await pumpUntil(byKey('supplier_agreements_section'));
    }

    Future<void> waitLoaded(String code) => pumpUntilTrue(
      () =>
          byKey('code_field').evaluate().isNotEmpty &&
          fieldText('code_field') == code,
      'form loaded with code $code',
    );

    Future<void> pickDay(int day) async {
      final dlg = find.byType(DatePickerDialog);
      await pumpUntil(dlg);
      await tester.tap(
        find.descendant(of: dlg, matching: find.text('$day')).first,
      );
      await pumpFor(const Duration(milliseconds: 300));
      await tester.tap(
        find.descendant(of: dlg, matching: find.byType(TextButton)).last,
      );
      await pumpUntilGone(dlg);
    }

    Finder pickerField(String sectionKey) => find.descendant(
      of: byKey(sectionKey),
      matching: find.byType(TextFormField),
    );

    Future<void> linkViaPicker(
      String sectionKey,
      String label,
      String rowPrefix,
    ) async {
      final before = count(rowPrefix);
      final field = pickerField(sectionKey);
      await pumpUntil(field);
      await ensureVisible(field);
      await tester.tap(field);
      await pumpFor(const Duration(milliseconds: 300));
      final option = find.text(label);
      await pumpUntil(option, timeout: const Duration(seconds: 30));
      await tester.tap(option.last);
      await pumpUntilTrue(
        () => count(rowPrefix) == before + 1,
        'row linked ($rowPrefix)',
      );
    }

    Future<void> tapBack() async {
      await tester.tap(find.byType(BackButton).first);
      await pumpFor(const Duration(milliseconds: 400));
    }

    Future<void> save() async {
      await tapKey('save_button');
    }

    Future<void> recover() async {
      for (var i = 0; i < 4; i++) {
        final dlg = find.byType(Dialog);
        if (dlg.evaluate().isEmpty) break;
        Navigator.of(tester.element(dlg.first), rootNavigator: true).pop();
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
          print(
            'QS-DBG loc=${router().routerDelegate.currentConfiguration.last.matchedLocation} '
            'texts=$texts',
          );
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

    void softFinding(String name, String text) {
      results.add(_Result(name, _Outcome.soft, text));
      // ignore: avoid_print
      print('QS-STEP SOFT $name :: $text');
    }

    // ------------------------------------------------------------------
    // Login (admin)
    // ------------------------------------------------------------------
    // ignore: avoid_print
    print('QS: logging in');
    await login(_adminUser, _adminPass);
    // ignore: avoid_print
    print('QS: logged in');

    // Pre-compute server state of all existing suppliers (read-only).
    final existing = <Supplier>[];
    var skip = 0;
    while (true) {
      final p = await supplierRepo.listDetailed(skip: skip, limit: 100);
      existing.addAll(p.items);
      skip += 100;
      if (skip >= p.total || p.items.isEmpty) break;
    }
    final details = <int, Supplier>{};
    for (var i = 0; i < existing.length; i += 25) {
      final batch = existing.skip(i).take(25).toList();
      final got = await Future.wait(
        batch.map((s) => supplierRepo.get(supplierId: s.supplierId)),
      );
      for (final d in got) {
        details[d.supplierId] = d;
      }
    }
    // ignore: avoid_print
    print('QS: fetched ${details.length} details');
    int linksOf(Supplier s) =>
        s.addresses.length + s.contacts.length + s.bankAccounts.length;
    final byLinks = details.values.toList()
      ..sort((a, b) => linksOf(b).compareTo(linksOf(a)));
    final mostLinked = byLinks.first;
    // Uniquely-coded existing supplier for the row-click and duplicate-code
    // checks.
    final rowSupplier = details.values.firstWhere(
      (s) => details.values.where((o) => o.code.contains(s.code)).length == 1,
      orElse: () => byLinks.last,
    );
    final dupCode = rowSupplier.code;

    // ---- Step 1 ----
    await step('2.1 row click opens "Ver proveedor" detail page', () async {
      await openRowFromList(rowSupplier.code);
      await pumpUntil(titled('Ver proveedor'));
      await waitLoaded(rowSupplier.code);
      for (final k in [
        'supplier_addresses_section',
        'supplier_contacts_section',
        'supplier_bank_accounts_section',
        'supplier_agreements_section',
      ]) {
        expect(byKey(k), findsOneWidget, reason: 'section $k');
      }
      final uri =
          router().routerDelegate.currentConfiguration.last.matchedLocation;
      expect(
        uri,
        '/suppliers/${rowSupplier.supplierId}',
        reason: 'full page route',
      );
      expect(
        byKey('filter_sheet_close_button'),
        findsNothing,
        reason: 'no side sheet',
      );
      expect(byKey('edit_supplier_button'), findsOneWidget);
    });

    // ---- Step 2 ----
    await step('2.2 spot-check 12 suppliers (incl. most-linked)', () async {
      final picks = <Supplier>[mostLinked];
      final rest = byLinks.where((s) => s != mostLinked).toList();
      // Spread across the ranking: some with many links, some with none.
      for (var i = 0; i < 11 && rest.isNotEmpty; i++) {
        picks.add(
          rest[(i * (rest.length - 1) ~/ 10).clamp(0, rest.length - 1)],
        );
      }
      final seen = <int>{};
      picks.retainWhere((s) => seen.add(s.supplierId));
      expect(picks.length, greaterThanOrEqualTo(10));
      final problems = <String>[];
      for (final s in picks) {
        await openDetail(s.supplierId);
        await waitLoaded(s.code);
        final agreements = await supplierRepo.listAgreements(
          supplierId: s.supplierId,
        );
        final got = [
          count('linked_row_addresses_'),
          count('linked_row_contacts_'),
          count('linked_row_bank_accounts_'),
        ];
        final want = [
          s.addresses.length,
          s.contacts.length,
          s.bankAccounts.length,
        ];
        try {
          await pumpUntilTrue(
            () => count('edit_agreement_') == agreements.length,
            'agreement rows == ${agreements.length}',
            timeout: const Duration(seconds: 15),
          );
        } catch (_) {
          problems.add(
            '${s.code}: agreements ui=${count('edit_agreement_')} '
            'api=${agreements.length}',
          );
        }
        if (got.join(',') != want.join(',')) {
          problems.add('${s.code}: links ui=$got api=$want');
        }
      }
      // ignore: avoid_print
      print(
        'QS: spot-checked ${picks.length} suppliers; most-linked '
        '${mostLinked.code} has ${linksOf(mostLinked)} links',
      );
      expect(problems, isEmpty, reason: problems.join('; '));
    });

    // ---- Step 7 (creates the test supplier) ----
    await step('2.7 Nuevo proveedor: empty form, link address, Guardar '
        'stays open in edit mode', () async {
      await openSuppliers();
      await tapKey('new_supplier_button');
      await pumpUntil(byKey('code_field'));
      expect(titled('Nuevo proveedor'), findsOneWidget);
      expect(fieldText('code_field'), isEmpty, reason: 'code starts empty');
      expect(count('linked_row_'), 0, reason: 'no linked rows');
      expect(byKey('supplier_agreements_after_save_note'), findsOneWidget);
      expect(byKey('add_agreement_button'), findsNothing);
      await enter('code_field', testCode);
      await enter('name_field', testName);
      await linkViaPicker(
        'supplier_addresses_section',
        addrA.label,
        'linked_row_addresses_',
      );
      expect(byKey('linked_row_addresses_${addrA.addressId}'), findsOneWidget);
      await save();
      await pumpUntil(titled('Editar proveedor'));
      await pumpUntil(byKey('add_agreement_button'));
      final sid = await findTestSupplierId();
      expect(sid, isNotNull, reason: 'server has the new supplier');
      testId = sid;
      final s = await supplierRepo.get(supplierId: sid!);
      expect(s.code, testCode);
      expect(s.addresses.map((a) => a.addressId), [addrA.addressId]);
    });

    // ---- Step 3 ----
    await step('2.3 link existing contact, Guardar -> list; reopen shows '
        'contact', () async {
      final sid = testId!;
      await openDetail(sid);
      await waitLoaded(testCode);
      await linkViaPicker(
        'supplier_contacts_section',
        contactA.name,
        'linked_row_contacts_',
      );
      await save();
      await pumpUntil(byKey('suppliers_table'));
      await pumpUntilGone(byKey('supplier_agreements_section'));
      await openRowFromList(testCode);
      await pumpUntil(titled('Ver proveedor'));
      await waitLoaded(testCode);
      expect(
        byKey('linked_row_contacts_${contactA.contactId}'),
        findsOneWidget,
        reason: 'contact shown after reopen',
      );
      final s = await supplierRepo.get(supplierId: sid);
      expect(s.contacts.map((c) => c.contactId), [contactA.contactId]);
      expect(s.addresses.map((a) => a.addressId), [addrA.addressId]);
    });

    // ---- Step 4 ----
    await step(
      '2.4 "+ Nueva" bank account -> Crear -> Guardar links it',
      () async {
        final sid = testId!;
        await openDetail(sid);
        await waitLoaded(testCode);
        await tapKey('linked_new_bank_accounts');
        await enter('bank_account_bank_name_field', bankName);
        await enter('bank_account_number_field', '$stamp');
        await enter('bank_account_reference_field', 'qs ref');
        await tapKey('bank_account_save_button');
        await pumpUntilGone(byKey('bank_account_save_button'));
        await pumpUntilTrue(
          () => count('linked_row_bank_accounts_') == 1,
          'new bank account row',
        );
        await save();
        await pumpUntil(byKey('suppliers_table'));
        final s = await supplierRepo.get(supplierId: sid);
        expect(s.bankAccounts, hasLength(1));
        expect(s.bankAccounts.single.bankName, bankName);
        expect(s.bankAccounts.single.accountNumber, '$stamp');
      },
    );

    // ---- Step 5 ----
    await step(
      '2.5 unlink address, back, confirm discard: still linked',
      () async {
        final sid = testId!;
        await openRowFromList(testCode);
        await pumpUntil(titled('Ver proveedor'));
        await waitLoaded(testCode);
        await tapKey('edit_supplier_button');
        await pumpUntil(titled('Editar proveedor'));
        await waitLoaded(testCode);
        await tapKey('unlink_addresses_${addrA.addressId}');
        expect(count('linked_row_addresses_'), 0, reason: 'unlinked locally');
        await tapBack();
        await tapKey('record_sheet_discard_confirm');
        await pumpUntil(byKey('suppliers_table'));
        await openRowFromList(testCode);
        await pumpUntil(titled('Ver proveedor'));
        await waitLoaded(testCode);
        expect(
          byKey('linked_row_addresses_${addrA.addressId}'),
          findsOneWidget,
          reason: 'address still linked after discard',
        );
        final s = await supplierRepo.get(supplierId: sid);
        expect(s.addresses.map((a) => a.addressId), [addrA.addressId]);
      },
    );

    // ---- Step 6 ----
    await step('2.6 edit-mode address picker does not offer a linked '
        'address', () async {
      final sid = testId!;
      await openDetail(sid);
      await waitLoaded(testCode);
      final linkedLabelCount = find.text(addrA.label).evaluate().length;
      final field = pickerField('supplier_addresses_section');
      await ensureVisible(field);
      await tester.tap(field);
      await pumpFor(const Duration(milliseconds: 300));
      // The other address appears once the options have loaded.
      await pumpUntil(
        find.text(addrB.label),
        timeout: const Duration(seconds: 30),
      );
      expect(
        find.text(addrA.label).evaluate().length,
        linkedLabelCount,
        reason: 'linked address must not be repeated as an option',
      );
      // Close the options overlay without linking anything.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      FocusManager.instance.primaryFocus?.unfocus();
      await pumpFor(const Duration(milliseconds: 300));
    });

    // ---- Step 8 ----
    final now = DateTime.now();
    await step(
      '2.8 agreement end before start: Guardar disabled + error',
      () async {
        final sid = testId!;
        await openDetail(sid);
        await waitLoaded(testCode);
        await tapKey('add_agreement_button');
        await tapKey('agreement_start_field');
        await pickDay(20);
        await tapKey('agreement_end_field');
        await pickDay(10);
        final saveBtn = tester.widget<FilledButton>(
          byKey('agreement_save_button'),
        );
        expect(saveBtn.onPressed, isNull, reason: 'save disabled');
        expect(
          find.text(l10n().supplierAgreementEndBeforeStartError),
          findsOneWidget,
        );
      },
    );

    // ---- Step 9 (continues in the same open dialog) ----
    await step('2.9 agreement with equal start and end is accepted', () async {
      final sid = testId!;
      if (byKey('agreement_save_button').evaluate().isEmpty) {
        // Step 8 failed before leaving a dialog open: rebuild its state.
        await openDetail(sid);
        await waitLoaded(testCode);
        await tapKey('add_agreement_button');
        await tapKey('agreement_start_field');
        await pickDay(20);
      }
      await tapKey('agreement_end_field');
      await pickDay(20);
      final saveBtn = tester.widget<FilledButton>(
        byKey('agreement_save_button'),
      );
      expect(saveBtn.onPressed, isNotNull, reason: 'save enabled');
      await tapKey('agreement_save_button');
      await pumpUntilGone(byKey('agreement_save_button'));
      await pumpUntilTrue(
        () => count('edit_agreement_') == 1,
        'agreement row appears',
      );
      final list = await supplierRepo.listAgreements(supplierId: sid);
      expect(list, hasLength(1));
      expect(list.single.start, DateTime(now.year, now.month, 20));
      expect(list.single.end, DateTime(now.year, now.month, 20));
    });

    // ---- Step 10 ----
    await step(
      '2.10 edit agreement end while supplier has unsaved edit',
      () async {
        final sid = testId!;
        await openDetail(sid);
        await waitLoaded(testCode);
        await pumpUntilTrue(
          () => count('edit_agreement_') == 1,
          'agreement row',
        );
        await enter('zone_field', 'QS-UNSAVED');
        final agreementId = (await supplierRepo.listAgreements(
          supplierId: sid,
        )).single.supplierAgreementId;
        await tapKey('edit_agreement_$agreementId');
        await tapKey('agreement_end_field');
        await pickDay(25);
        await tapKey('agreement_save_button');
        await pumpUntilGone(byKey('agreement_save_button'));
        final list = await supplierRepo.listAgreements(supplierId: sid);
        expect(list.single.end, DateTime(now.year, now.month, 25));
        final shown = container()
            .read(formattersProvider)
            .display
            .date(DateTime(now.year, now.month, 25));
        await pumpUntil(
          find.descendant(
            of: byKey('supplier_agreements_table'),
            matching: find.text(shown),
          ),
        );
        expect(
          fieldText('zone_field'),
          'QS-UNSAVED',
          reason: 'unsaved supplier edit kept',
        );
        // Server must not have the unsaved zone.
        expect(
          (await supplierRepo.get(supplierId: sid)).zone,
          isNot('QS-UNSAVED'),
        );
      },
    );

    // ---- Step 11 ----
    await step('2.11 agreement Eliminar from edit dialog; rows have no '
        'delete icon', () async {
      final sid = testId!;
      await openDetail(sid);
      await waitLoaded(testCode);
      final agreementId = (await supplierRepo.listAgreements(
        supplierId: sid,
      )).single.supplierAgreementId;
      await pumpUntil(byKey('edit_agreement_$agreementId'));
      final table = byKey('supplier_agreements_table');
      expect(
        find.descendant(of: table, matching: find.byIcon(Icons.delete)),
        findsNothing,
      );
      expect(
        find.descendant(of: table, matching: find.byIcon(Icons.delete_outline)),
        findsNothing,
      );
      expect(byPrefix('delete_agreement'), findsNothing);
      expect(count('edit_agreement_'), 1, reason: 'only edit_agreement_*');
      await tapKey('edit_agreement_$agreementId');
      await tapKey('agreement_delete_button');
      await tapKey('confirm_delete_agreement_button');
      await pumpUntilGone(byKey('agreement_save_button'));
      await pumpUntilTrue(
        () => count('edit_agreement_') == 0,
        'agreement row gone',
      );
      expect(await supplierRepo.listAgreements(supplierId: sid), isEmpty);
    });

    // ---- Step 12 ----
    await step(
      '2.12 delete supplier with links -> conflict banner, kept',
      () async {
        final sid = testId!;
        await openDetail(sid);
        await waitLoaded(testCode);
        await tapKey('delete_supplier_button');
        await tapKey('confirm_delete_supplier_button');
        await pumpUntil(byKey('supplier_delete_conflict_banner'));
        final s = await supplierRepo.get(supplierId: sid);
        expect(s.code, testCode, reason: 'supplier still on the server');
      },
    );

    // ---- Step 13 ----
    await step('2.13 duplicate supplier code on save (SOFT: server may '
        'accept)', () async {
      final sid = testId!;
      await openDetail(sid);
      await waitLoaded(testCode);
      await enter('code_field', dupCode);
      await save();
      await pumpUntilTrue(
        () =>
            byKey('supplier_save_conflict_banner').evaluate().isNotEmpty ||
            byKey('suppliers_table').evaluate().isNotEmpty ||
            byKey('supplier_agreements_section').evaluate().isEmpty,
        'conflict banner or successful save',
      );
      final banner = byKey(
        'supplier_save_conflict_banner',
      ).evaluate().isNotEmpty;
      if (banner) {
        expect(fieldText('code_field'), dupCode, reason: 'edits kept');
        expect(
          (await supplierRepo.get(supplierId: sid)).code,
          testCode,
          reason: 'server unchanged',
        );
        // Leave: discard.
        await tapBack();
        await tapKey('record_sheet_discard_confirm');
        await pumpFor(const Duration(milliseconds: 400));
        softFinding(
          '2.13b outcome',
          'server rejected duplicate code with a conflict; banner shown',
        );
      } else {
        final now13 = await supplierRepo.get(supplierId: sid);
        final accepted = now13.code == dupCode;
        // Restore the test supplier's own code.
        await supplierRepo.update(supplierId: sid, code: testCode);
        softFinding(
          '2.13b outcome',
          accepted
              ? 'server accepts duplicate supplier codes; FR-011\'s '
                    'duplicate-code half cannot trigger (save succeeded, '
                    'code restored)'
              : 'save returned without banner but code not changed '
                    '(unexpected)',
        );
      }
    });

    // ---- Step 14 ----
    await step('2.14 compact width: no Notes column, sections stack', () async {
      final sid = testId!;
      // Restore own code defensively and give the supplier an agreement.
      await supplierRepo.update(supplierId: sid, code: testCode);
      await supplierRepo.createAgreement(
        supplierId: sid,
        start: DateTime(now.year, now.month, 20),
        end: DateTime(now.year, now.month, 25),
        comment: 'qs note',
      );
      // Wide first (baseline).
      await openDetail(sid);
      await waitLoaded(testCode);
      await pumpUntilTrue(() => count('edit_agreement_') == 1, 'agreement');
      expect(find.text(l10n().supplierAgreementColumnNotes), findsWidgets);
      final a = tester.getTopLeft(byKey('supplier_addresses_section'));
      final c = tester.getTopLeft(byKey('supplier_contacts_section'));
      expect(c.dx, greaterThan(a.dx), reason: 'wide: side by side');

      tester.view.physicalSize = _compact;
      await pumpFor(const Duration(seconds: 1));
      await openDetail(sid);
      await waitLoaded(testCode);
      await pumpUntilTrue(() => count('edit_agreement_') == 1, 'agreement');
      // ignore: avoid_print
      print(
        'QS-DBG width=${MediaQuery.of(tester.element(find.byType(Scaffold).last)).size.width} tables=${byKey('supplier_agreements_table').evaluate().length} notasInTable=${find.descendant(of: byKey('supplier_agreements_table'), matching: find.text('Notas')).evaluate().length} sections=${byKey('supplier_agreements_section').evaluate().length}',
      );
      final t = l10n();
      expect(
        find.descendant(
          of: byKey('supplier_agreements_table'),
          matching: find.text(t.supplierAgreementColumnNotes),
        ),
        findsNothing,
        reason: 'Notes column dropped',
      );
      expect(find.text(t.supplierAgreementColumnStart), findsWidgets);
      expect(find.text(t.supplierAgreementColumnEnd), findsWidgets);
      expect(count('edit_agreement_'), 1, reason: 'edit icon remains');
      await ensureVisible(byKey('supplier_contacts_section'));
      final a2 = tester.getTopLeft(byKey('supplier_addresses_section'));
      final c2 = tester.getTopLeft(byKey('supplier_contacts_section'));
      expect(c2.dx, a2.dx, reason: 'compact: same column');
      expect(
        tester.getTopLeft(byKey('supplier_contacts_section')).dy,
        isNot(a2.dy),
        reason: 'compact: stacked',
      );
    });
    tester.view.physicalSize = _wide;
    await pumpFor(const Duration(seconds: 1));

    // ---- Step 15 ----
    await step('2.15 English: new strings translated', () async {
      final sid = testId!;
      try {
        await container()
            .read(userDisplayPreferencesControllerProvider.notifier)
            .setLocaleOverride(const Locale('en'));
        await pumpFor(const Duration(seconds: 1));
        await openDetail(sid);
        await waitLoaded(testCode);
        for (final s in [
          'Addresses',
          'Contacts',
          'Bank accounts',
          'Agreements',
        ]) {
          expect(find.textContaining(s), findsWidgets, reason: 'English "$s"');
        }
        expect(titled('Edit supplier'), findsOneWidget);
        expect(find.textContaining('Direcciones'), findsNothing);
        expect(find.textContaining('Convenios'), findsNothing);
      } finally {
        await container()
            .read(userDisplayPreferencesControllerProvider.notifier)
            .setLocaleOverride(null);
        await pumpFor(const Duration(milliseconds: 500));
      }
    });

    // ---- §3 read-only ----
    await step('3.1 read-only account sees 4 sections, no mutating '
        'controls', () async {
      final sid = testId!;
      await container().read(authProvider.notifier).signOut();
      await pumpUntil(byKey('login_username_field'));
      await login(_roUser, _roPass);
      router().go('/suppliers');
      await pumpFor(const Duration(seconds: 4));
      if (byKey('suppliers_table').evaluate().isEmpty) {
        final loc =
            router().routerDelegate.currentConfiguration.last.matchedLocation;
        expect(loc.startsWith('/suppliers'), isFalse, reason: 'redirected');
        throw TestFailure(
          'MBE_READONLY account has no Suppliers Read (system_object 3): '
          'the Suppliers screen is route-gated and redirects to $loc, so '
          'the read-only detail view cannot be exercised with it',
        );
      }
      await openRowFromList(testCode);
      await pumpUntil(titled('Ver proveedor'));
      await waitLoaded(testCode);
      await pumpFor(const Duration(seconds: 2));
      for (final k in [
        'supplier_addresses_section',
        'supplier_contacts_section',
        'supplier_bank_accounts_section',
        'supplier_agreements_section',
      ]) {
        expect(byKey(k), findsOneWidget, reason: 'section $k visible');
      }
      final s = await supplierRepo.get(supplierId: sid);
      expect(count('linked_row_addresses_'), s.addresses.length);
      expect(count('linked_row_contacts_'), s.contacts.length);
      expect(count('linked_row_bank_accounts_'), s.bankAccounts.length);
      expect(count('linked_row_'), greaterThan(0));
      final forbidden = <String>[];
      for (final p in [
        'edit_supplier_button',
        'save_button',
        'delete_supplier_button',
        'unlink_',
        'linked_new_',
        'linked_picker_',
        'add_agreement_button',
        'edit_agreement_',
      ]) {
        if (count(p) > 0) forbidden.add(p);
      }
      expect(forbidden, isEmpty, reason: 'present for read-only: $forbidden');
    });

    softFinding(
      '3.2 profile privilege edit (Bank Accounts Read removal)',
      'not automated: needs an administrator to edit privileges; covered '
          'by widget tests',
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
  }, timeout: const Timeout(Duration(minutes: 8)));
}

String _short(Object e) {
  final s = e.toString().replaceAll('\n', ' ');
  return s.length > 400 ? '${s.substring(0, 400)}...' : s;
}
