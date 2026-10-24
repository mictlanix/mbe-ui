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
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/settings/user_display_preferences_controller.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';

/// Automates specs/052-customer-discounts/quickstart.md §2 and §4 against
/// the REAL app (macOS desktop) and a live mbe-api.
///
///   caffeinate -dimsu flutter test \
///     integration_test/customer_discounts_quickstart_test.dart \
///     -d macos --dart-define-from-file=.env.settings \
///     --dart-define=MBE_CATALOG_TEST_USERNAME=... (and _PASSWORD)
///     --dart-define=MBE_READONLY_USERNAME=...     (and _PASSWORD)
///
/// Creates one customer (`QD<timestamp>`) through the app, gives it
/// discounts, and removes the discounts and the customer in a tear-down that
/// runs even when a step fails. Existing customers are only ever read.
/// §3 (sales lines start at the discount) is not repeated here: it leaves a
/// cancelled order that makes its customer undeletable, and it was checked
/// once against the dev API on 2026-10-24. Credentials are never printed.
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

  testWidgets('Customer discounts quickstart §2 and §4 (real app, live '
      'mbe-api)', (tester) async {
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
    final customerRepo = CustomerRepositoryImpl(dio);

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final testCode = 'QD${stamp % 10000000000}';
    final testName = 'QS 052 $stamp';
    int? testId;

    Future<int?> findTestCustomerId() async {
      if (testId != null) return testId;
      final page = await customerRepo.list(search: testCode, limit: 50);
      for (final c in page.items) {
        if (c.code == testCode || c.name == testName) return c.customerId;
      }
      return null;
    }

    // Cleanup first, so it runs even if anything below fails.
    addTearDown(() async {
      try {
        final cid = await findTestCustomerId();
        if (cid == null) return;
        for (final d in await customerRepo.listDiscounts(customerId: cid)) {
          try {
            await customerRepo.deleteDiscount(
              customerId: cid,
              customerDiscountId: d.customerDiscountId,
            );
          } catch (_) {}
        }
        try {
          await customerRepo.delete(customerId: cid);
          // ignore: avoid_print
          print('QS: test customer removed');
        } catch (e) {
          // ignore: avoid_print
          print('QS: test customer NOT removed: ${_short(e)}');
        }
      } catch (_) {}
    });

    // Runtime-discovered fixtures.
    final priceLists = await PriceListRepositoryImpl(dio).list(limit: 1);
    final productPage = await ProductRepositoryImpl(
      dio,
    ).list(status: EntityStatus.active, limit: 60);
    // Three products whose names and codes are unique in the sample, so a
    // text finder never matches two of them.
    final products = <ProductListItem>[];
    for (final p in productPage.items) {
      final clash = productPage.items.any(
        (o) =>
            o.productId != p.productId &&
            (o.name == p.name ||
                o.name.contains(p.code) ||
                o.code.contains(p.code)),
      );
      if (!clash && p.name.trim().isNotEmpty) products.add(p);
      if (products.length == 3) break;
    }
    if (priceLists.items.isEmpty || products.length < 3) {
      markTestSkipped('Tenant needs a price list and 3 active products.');
      return;
    }
    final priceList = priceLists.items.first;
    final productA = products[0];
    final productB = products[1];
    final productC = products[2];

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

    Future<void> pumpUntil(
      Finder f, {
      Duration timeout = const Duration(seconds: 25),
    }) => pumpUntilTrue(() => f.evaluate().isNotEmpty, '$f', timeout: timeout);

    Future<void> pumpUntilGone(
      Finder f, {
      Duration timeout = const Duration(seconds: 25),
    }) =>
        pumpUntilTrue(() => f.evaluate().isEmpty, 'gone: $f', timeout: timeout);

    Finder titled(String t) =>
        find.descendant(of: find.byType(AppBar), matching: find.text(t));
    Finder byKey(String k) => find.byKey(Key(k));
    Finder inTable(String text) => find.descendant(
      of: byKey('customer_discounts_table'),
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

    bool enabled(String k) =>
        tester.widget<ButtonStyleButton>(byKey(k)).onPressed != null;

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

    Future<void> openCustomers() async {
      router().go('/customers');
      await pumpUntil(byKey('customers_table'));
      await pumpUntilGone(byKey('customer_discounts_section'));
      await pumpFor(const Duration(milliseconds: 500));
    }

    /// Pushes the detail route on top of the list, as the app does, and
    /// waits for the discounts to finish loading.
    Future<void> openDetail(int id, {bool view = false}) async {
      await openCustomers();
      router().push('/customers/$id${view ? '?view=true' : ''}');
      await pumpUntil(byKey('customer_discounts_section'));
      await pumpUntilTrue(
        () =>
            find.byType(CircularProgressIndicator).evaluate().isEmpty &&
            byKey('code_field').evaluate().isNotEmpty,
        'customer $id loaded',
      );
      await pumpFor(const Duration(milliseconds: 500));
    }

    /// Types into a [CatalogEntityPicker] and taps the suggestion [label].
    Future<void> pick(String pickerKey, String query, String label) async {
      final field = find.descendant(
        of: byKey(pickerKey),
        matching: find.byType(TextFormField),
      );
      await pumpUntil(field);
      await ensureVisible(field);
      await tester.enterText(field, query);
      final option = find.descendant(
        of: find.byType(ListTile),
        matching: find.text(label),
      );
      final plain = find.text(label);
      await pumpUntilTrue(
        () => option.evaluate().isNotEmpty || plain.evaluate().length > 1,
        'suggestion "$label"',
        timeout: const Duration(seconds: 30),
      );
      await tester.tap(
        option.evaluate().isNotEmpty ? option.first : plain.last,
      );
      await pumpFor(const Duration(milliseconds: 500));
    }

    Future<void> openAddDialog() async {
      await tapKey('add_customer_discount_button');
      await pumpUntil(byKey('customer_discount_percent_field'));
    }

    Future<void> pickDiscountProduct(ProductListItem p) async {
      await pick('customer_discount_product_field', p.code, p.name);
      await pumpUntil(byKey('customer_discount_selected_product'));
    }

    Future<void> closeDialog() async {
      await tapKey('customer_discount_cancel_button');
      await pumpUntilGone(byKey('customer_discount_percent_field'));
    }

    Future<List<CustomerDiscount>> serverDiscounts() =>
        customerRepo.listDiscounts(customerId: testId!);

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

    // Existing customers that carry discounts (read-only), for the
    // spot-check. Bounded: the first 300 customers.
    final withDiscounts = <int, List<CustomerDiscount>>{};
    for (var skip = 0; skip < 300; skip += 100) {
      final page = await customerRepo.list(skip: skip, limit: 100);
      for (var i = 0; i < page.items.length; i += 20) {
        final batch = page.items.skip(i).take(20).toList();
        final lists = await Future.wait(
          batch.map(
            (c) => customerRepo.listDiscounts(customerId: c.customerId),
          ),
        );
        for (var j = 0; j < batch.length; j++) {
          if (lists[j].isNotEmpty) {
            withDiscounts[batch[j].customerId] = lists[j];
          }
        }
      }
      if (page.items.length < 100) break;
    }
    // ignore: avoid_print
    print('QS: ${withDiscounts.length} existing customers carry discounts');

    // ---- 2.1 / 2.2 spot-check ----
    await step(
      '2.1-2.2 existing discounts match the server (SC-001)',
      () async {
        if (withDiscounts.isEmpty) {
          throw TestFailure('no customer in the first 300 carries discounts');
        }
        final ids = withDiscounts.keys.toList()
          ..sort(
            (a, b) =>
                withDiscounts[b]!.length.compareTo(withDiscounts[a]!.length),
          );
        final sample = ids.take(10).toList();
        for (final id in sample) {
          final server = withDiscounts[id]!;
          await openDetail(id, view: true);
          await pumpUntil(byKey('customer_discounts_table'));
          expect(
            find.text('Descuentos (${server.length})'),
            findsOneWidget,
            reason: 'customer $id count',
          );
          // First page, in server order (by product code).
          for (final d in server.take(10)) {
            expect(
              inTable(d.productCode),
              findsWidgets,
              reason: 'customer $id row ${d.productCode}',
            );
          }
          expect(byKey('add_customer_discount_button'), findsNothing);
          expect(
            find.byWidgetPredicate((w) {
              final k = w.key;
              return k is ValueKey<String> &&
                  k.value.startsWith('edit_customer_discount_');
            }),
            findsNothing,
            reason: 'view mode has no row Edit',
          );
        }
        final most = withDiscounts[ids.first]!.length;
        // ignore: avoid_print
        print(
          'QS: spot-checked ${sample.length} customers; the most discounts is '
          '$most',
        );
      },
    );

    await step('2.x long list pages at 10 and the page scrolls', () async {
      final ids = withDiscounts.keys
          .where((id) => withDiscounts[id]!.length > 10)
          .toList();
      if (ids.isEmpty) {
        throw TestFailure('no customer with more than 10 discounts to page');
      }
      final id = ids.first;
      final server = withDiscounts[id]!;
      await openDetail(id, view: true);
      await pumpUntil(byKey('customer_discounts_table'));
      expect(inTable(server[10].productCode), findsNothing, reason: 'page 1');
      final next = find.descendant(
        of: byKey('customer_discounts_table'),
        matching: find.byIcon(Icons.chevron_right),
      );
      await tapFinder(next);
      await pumpUntil(inTable(server[10].productCode));
      expect(inTable(server.first.productCode), findsNothing, reason: 'page 2');
    }, soft: true);

    // ---- 2.13 / 2.12 create ----
    await step(
      '2.13 a new customer shows the after-save note, no add',
      () async {
        await openCustomers();
        await tapKey('new_customer_button');
        await pumpUntil(titled('Nuevo cliente'));
        await pumpUntil(byKey('customer_discounts_after_save_note'));
        expect(byKey('add_customer_discount_button'), findsNothing);
      },
    );

    await step(
      '2.12 saving a new customer stays on it, in edit mode',
      () async {
        if (location() != '/customers/new') {
          await openCustomers();
          await tapKey('new_customer_button');
          await pumpUntil(titled('Nuevo cliente'));
        }
        await enter('code_field', testCode);
        await enter('name_field', testName);
        await pick('price_list_field', priceList.name, priceList.name);
        await tapKey('save_button');
        await pumpUntilTrue(
          () => RegExp(r'^/customers/\d+$').hasMatch(location()),
          'route /customers/<id> after create',
        );
        testId = int.parse(location().split('/').last);
        await pumpUntil(titled('Editar cliente'));
        await pumpUntil(byKey('add_customer_discount_button'));
        expect(byKey('customer_discounts_after_save_note'), findsNothing);
        expect(find.text('customers list'), findsNothing);
      },
    );
    if (testId == null) {
      testId = await findTestCustomerId();
      if (testId == null) {
        fail('the test customer was not created; later steps need it');
      }
    }
    final cid = testId!;

    await step(
      '2.3 a customer with no discounts shows the empty state',
      () async {
        await openDetail(cid);
        expect(find.text('Sin descuentos por producto.'), findsOneWidget);
        expect(find.text('Descuentos'), findsOneWidget);
      },
    );

    // ---- 2.6 add ----
    var addSeconds = 0.0;
    await step('2.6 add a 10 % discount (SC-002 timing)', () async {
      await openDetail(cid);
      final watch = Stopwatch()..start();
      await openAddDialog();
      await pickDiscountProduct(productA);
      expect(
        find.descendant(
          of: byKey('customer_discount_selected_product'),
          matching: find.text(productA.code),
        ),
        findsOneWidget,
        reason: 'picked tile shows the code',
      );
      await enter('customer_discount_percent_field', '10');
      await tapKey('customer_discount_save_button');
      await pumpUntilGone(byKey('customer_discount_percent_field'));
      await pumpUntil(inTable(productA.code));
      watch.stop();
      addSeconds = watch.elapsedMilliseconds / 1000;
      expect(inTable('10.00 %'), findsOneWidget);
      expect(find.text('Descuentos (1)'), findsOneWidget);
      final server = await serverDiscounts();
      expect(server.single.productId, productA.productId);
      expect(double.parse(server.single.discount), closeTo(0.1, 1e-9));
      // ignore: avoid_print
      print('QS: add took ${addSeconds.toStringAsFixed(1)} s (automated)');
    });

    await step('2.6b the discount survives a reload', () async {
      await openDetail(cid);
      await pumpUntil(inTable(productA.code));
      expect(inTable('10.00 %'), findsOneWidget);
    });

    // ---- 2.4 exclusion ----
    await step(
      '2.4 the picker leaves out a product already discounted',
      () async {
        await openDetail(cid);
        await openAddDialog();
        final field = find.descendant(
          of: byKey('customer_discount_product_field'),
          matching: find.byType(TextFormField),
        );
        // Probe with another product first, so the search is known to work.
        await tester.enterText(field, productB.code);
        await pumpUntil(
          find.descendant(
            of: find.byType(ListTile),
            matching: find.text(productB.name),
          ),
          timeout: const Duration(seconds: 30),
        );
        await tester.enterText(field, productA.code);
        await pumpFor(const Duration(seconds: 3));
        expect(
          find.descendant(
            of: find.byType(ListTile),
            matching: find.text(productA.name),
          ),
          findsNothing,
        );
        await closeDialog();
      },
    );

    // ---- 2.5 validation ----
    await step('2.5 invalid percentages say why and block Save', () async {
      await openDetail(cid);
      await openAddDialog();
      await pickDiscountProduct(productB);
      const cases = {
        '-1': 'Debe estar entre 0 y 100.',
        '101': 'Debe estar entre 0 y 100.',
        '1.2.3': 'Ingresa un número, p. ej. 12.5.',
        '1.1234567': 'Máximo 6 decimales.',
        '': 'Ingresa un porcentaje.',
      };
      for (final entry in cases.entries) {
        await enter('customer_discount_percent_field', entry.key);
        expect(find.text(entry.value), findsOneWidget, reason: entry.key);
        expect(
          enabled('customer_discount_save_button'),
          isFalse,
          reason: entry.key,
        );
      }
      await enter('customer_discount_percent_field', '12.5');
      expect(enabled('customer_discount_save_button'), isTrue);
      await closeDialog();
      expect(await serverDiscounts(), hasLength(1), reason: 'nothing saved');
    });

    // ---- 2.7 independent of the customer's Save ----
    await step('2.7 a discount saves without touching unsaved customer '
        'edits (FR-010)', () async {
      await openDetail(cid);
      final zoneBefore = (await customerRepo.get(customerId: cid)).zone ?? '';
      await enter('zone_field', 'QS zone');
      await openAddDialog();
      await pickDiscountProduct(productB);
      await enter('customer_discount_percent_field', '5');
      await tapKey('customer_discount_save_button');
      await pumpUntilGone(byKey('customer_discount_percent_field'));
      await pumpUntil(inTable(productB.code));
      expect(fieldText('zone_field'), 'QS zone', reason: 'edit kept');
      expect(
        (await customerRepo.get(customerId: cid)).zone ?? '',
        zoneBefore,
        reason: 'the customer itself was not saved',
      );
      expect(await serverDiscounts(), hasLength(2));
    });

    // ---- 2.8 edit ----
    await step('2.8 edit: product read-only, full precision, saved', () async {
      await openDetail(cid);
      final a = (await serverDiscounts()).firstWhere(
        (d) => d.productId == productA.productId,
      );
      await tapKey('edit_customer_discount_${a.customerDiscountId}');
      await pumpUntil(byKey('customer_discount_percent_field'));
      expect(byKey('customer_discount_clear_product'), findsNothing);
      expect(
        find.descendant(
          of: byKey('customer_discount_selected_product'),
          matching: find.text(productA.code),
        ),
        findsOneWidget,
      );
      expect(fieldText('customer_discount_percent_field'), '10');
      await enter('customer_discount_percent_field', '12.5');
      await tapKey('customer_discount_save_button');
      await pumpUntilGone(byKey('customer_discount_percent_field'));
      await pumpUntil(inTable('12.50 %'));
      final server = (await serverDiscounts()).firstWhere(
        (d) => d.productId == productA.productId,
      );
      expect(double.parse(server.discount), closeTo(0.125, 1e-9));
    });

    // ---- 2.9 remove ----
    await step('2.9 remove asks first, then the row disappears', () async {
      await openDetail(cid);
      final a = (await serverDiscounts()).firstWhere(
        (d) => d.productId == productA.productId,
      );
      await tapKey('edit_customer_discount_${a.customerDiscountId}');
      await tapKey('customer_discount_delete_button');
      await pumpUntil(byKey('confirm_delete_customer_discount_button'));
      await tapKey('confirm_delete_customer_discount_button');
      await pumpUntilGone(byKey('customer_discount_percent_field'));
      await pumpUntilGone(inTable(productA.code));
      expect(
        (await serverDiscounts()).where(
          (d) => d.productId == productA.productId,
        ),
        isEmpty,
      );
    });

    // ---- 2.10 duplicate race ----
    await step('2.10 another user adds the product first: duplicate '
        'message, input kept, list refreshed', () async {
      await openDetail(cid);
      await openAddDialog();
      await pickDiscountProduct(productC);
      await enter('customer_discount_percent_field', '7');
      // "Tab B": someone else saves a discount on the same product.
      await customerRepo.createDiscount(
        customerId: cid,
        productId: productC.productId,
        discount: '0.03',
      );
      await tapKey('customer_discount_save_button');
      await pumpUntil(
        find.text('Este cliente ya tiene un descuento para ese producto.'),
      );
      expect(byKey('customer_discount_percent_field'), findsOneWidget);
      expect(fieldText('customer_discount_percent_field'), '7');
      await closeDialog();
      await pumpUntil(inTable(productC.code));
      expect(inTable('3.00 %'), findsOneWidget);
    });

    // ---- 2.11 removed elsewhere ----
    await step(
      '2.11 a discount removed elsewhere: message, row gone',
      () async {
        await openDetail(cid);
        final c = (await serverDiscounts()).firstWhere(
          (d) => d.productId == productC.productId,
        );
        await pumpUntil(inTable(productC.code));
        await customerRepo.deleteDiscount(
          customerId: cid,
          customerDiscountId: c.customerDiscountId,
        );
        await tapKey('edit_customer_discount_${c.customerDiscountId}');
        await enter('customer_discount_percent_field', '4');
        await tapKey('customer_discount_save_button');
        await pumpUntil(find.text('Este descuento ya no existe.'));
        await closeDialog();
        await pumpUntilGone(inTable(productC.code));
      },
    );

    // ---- compact tier ----
    await step('2.x compact tier: code folds into the product cell', () async {
      tester.view.physicalSize = _compact;
      try {
        await openDetail(cid);
        await pumpUntil(byKey('customer_discounts_table'));
        expect(inTable('${productB.code} · ${productB.name}'), findsOneWidget);
        expect(inTable('Código'), findsNothing);
        expect(byKey('add_customer_discount_button'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        tester.view.physicalSize = _wide;
        await pumpFor(const Duration(seconds: 1));
      }
    });

    // ---- English ----
    await step('2.x English: new strings translated', () async {
      try {
        await container()
            .read(userDisplayPreferencesControllerProvider.notifier)
            .setLocaleOverride(const Locale('en'));
        await pumpFor(const Duration(seconds: 1));
        await openDetail(cid);
        expect(find.text('Discounts (1)'), findsOneWidget);
        expect(find.text('Descuentos (1)'), findsNothing);
        await openAddDialog();
        expect(find.text('New discount'), findsOneWidget);
        expect(find.text('Discount (%)'), findsOneWidget);
        await closeDialog();
      } finally {
        await container()
            .read(userDisplayPreferencesControllerProvider.notifier)
            .setLocaleOverride(null);
        await pumpFor(const Duration(milliseconds: 500));
      }
    });

    // ---- 2.14 update returns to the list ----
    await step(
      '2.14 saving an existing customer returns to the list',
      () async {
        await openDetail(cid);
        await enter('zone_field', 'QS saved');
        await tapKey('save_button');
        await pumpUntilTrue(
          () => location() == '/customers',
          'back on /customers',
        );
        expect((await customerRepo.get(customerId: cid)).zone, 'QS saved');
      },
    );

    // ---- 2.15 #207 ----
    await step('2.15 New right after Back starts empty (mbe-ui#207)', () async {
      await openDetail(cid, view: true);
      expect(fieldText('code_field'), testCode);
      router().pop();
      await tester.pump();
      router().push('/customers/new');
      await pumpUntil(titled('Nuevo cliente'));
      await pumpFor(const Duration(seconds: 1));
      expect(fieldText('code_field'), isEmpty);
      expect(fieldText('name_field'), isEmpty);
    });

    // ---- §4 access ----
    if (_roUser.isEmpty || _roPass.isEmpty) {
      softFinding(
        '4.1 read-only account',
        'MBE_READONLY_USERNAME/_PASSWORD not supplied',
      );
    } else {
      await step('4.1 read-only account sees rows, no add or edit', () async {
        await container().read(authProvider.notifier).signOut();
        await pumpUntil(byKey('login_username_field'));
        await login(_roUser, _roPass);
        router().go('/customers');
        await pumpFor(const Duration(seconds: 4));
        if (byKey('customers_table').evaluate().isEmpty) {
          throw TestFailure(
            'MBE_READONLY account has no Customers Read (system_object 2): '
            'the Customers screen redirects to ${location()}',
          );
        }
        router().push('/customers/$cid?view=true');
        await pumpUntil(byKey('customer_discounts_table'));
        expect(inTable(productB.code), findsOneWidget);
        expect(byKey('add_customer_discount_button'), findsNothing);
        expect(
          find.byWidgetPredicate((w) {
            final k = w.key;
            return k is ValueKey<String> &&
                k.value.startsWith('edit_customer_discount_');
          }),
          findsNothing,
        );
        expect(byKey('save_button'), findsNothing);
      }, soft: true);
    }

    softFinding(
      '4.3 Customers Update without Products Read',
      'not automated: no such account in .env; covered by widget tests',
    );
    softFinding(
      '3 sales lines start at the discount',
      'not repeated: leaves an undeletable customer; verified once against '
          'the dev API on 2026-10-24 and pinned by regression tests',
    );
    softFinding(
      'SC-002 add time',
      'automated add took ${addSeconds.toStringAsFixed(1)} s (a person also '
          'reads and types; target < 30 s)',
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
