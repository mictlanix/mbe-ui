import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_origin.dart';

/// Settles research.md's U1/U2 against a live `GET /sales-orders`: what
/// `search` actually matches, and whether `date_to` includes its own day
/// (spec 023 contracts/pos-sales-list.md, research R … / Unresolved table).
/// The sales-list screen itself does not depend on the answer either way —
/// a `search` that matches nothing just shows the filtered-empty state — so
/// this is discovery, not a regression guard.
///
/// Requires mbe-api at [apiBaseUrl], the same `MBE_POS_*` account the other
/// POS live tests use, and an **already open cash session** on it. Leaves
/// the draft sales it opens behind (dev tenants only, same as its
/// siblings).
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');

const _canRun = _username != '' && _password != '';

void main() {
  test(
    'discovers what `search` matches and whether `date_to` is day-inclusive',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final sessions = CashSessionRepositoryImpl(dio);
      final salesOrders = SalesOrderRepositoryImpl(dio);

      if ((await sessions.getCurrent()).state == SessionState.none) {
        markTestSkipped('this account has no open cash session');
        return;
      }

      // A fresh draft to search for — its own id/serial are unambiguous
      // needles, and its customer is the walk-in "Público en general" every
      // dev tenant seeds, giving a name substring to probe with too.
      final probe = await salesOrders.open();
      addTearDown(() async {
        try {
          await salesOrders.cancel(saleId: probe.id);
        } on Object {
          // Best-effort cleanup; a probe left as an empty draft is
          // harmless and matches every other POS live test's own leftovers.
        }
      });

      Future<bool> foundBy({String? search, DateTime? dateFrom, DateTime? dateTo}) async {
        final page = await salesOrders.listSales(
          pointSale: probe.pointSale,
          search: search,
          dateFrom: dateFrom,
          dateTo: dateTo,
          limit: 100,
        );
        return page.items.any((s) => s.id == probe.id);
      }

      // ── U1: what does `search` match? ───────────────────────────────────
      final byId = await foundBy(search: probe.id.toString());
      final bySerial = probe.serial == null
          ? null
          : await foundBy(search: probe.serial.toString());
      final byCustomerName = await foundBy(search: 'público');

      // ignore: avoid_print
      print(
        'U1 — search matches: id=$byId serial=${bySerial ?? "n/a"} '
        'customerName(case-insensitive substring)=$byCustomerName',
      );

      // ── U2: is `date_to` inclusive of its own day? ──────────────────────
      final today = DateTime.now();
      final byTodayRange = await foundBy(dateFrom: today, dateTo: today);

      // ignore: avoid_print
      print('U2 — date_to inclusive of its own day: $byTodayRange');

      // Not asserted against a fixed expectation — there is no "wrong"
      // answer here, only an unknown one research.md records as such.
      // Reaching this line at all, with the prints above landing in the
      // test log, is what settles U1/U2: read the log, update research.md.
      expect(byId, isA<bool>());
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  // spec 041 US1/T013: the live proof of SC-001/SC-003 that no widget test
  // can give, since a widget test mocks the repository and so can never
  // show whether the *real* server actually excludes what was asked and
  // keeps what was not. Three probes carrying three different origins (one
  // deliberately omitted, to see how mbe-api records that) settle this
  // without depending on any pre-existing legacy row happening to be in the
  // dev database.
  test(
    'excludeOrigin: backOffice hides only back-office orders — a '
    'point-of-sale order and an order with no recorded origin both survive '
    'the filter (spec 041 FR-002, FR-005, SC-001, SC-003)',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final sessions = CashSessionRepositoryImpl(dio);
      final salesOrders = SalesOrderRepositoryImpl(dio);

      if ((await sessions.getCurrent()).state == SessionState.none) {
        markTestSkipped('this account has no open cash session');
        return;
      }

      final posProbe = await salesOrders.open(origin: SaleOrigin.pointOfSale);
      final officeProbe = await salesOrders.open(origin: SaleOrigin.backOffice);
      final unrecordedProbe = await salesOrders.open();
      addTearDown(() async {
        for (final probe in [posProbe, officeProbe, unrecordedProbe]) {
          try {
            await salesOrders.cancel(saleId: probe.id);
          } on Object {
            // Best-effort cleanup, matching this file's other probe.
          }
        }
      });

      // Confirms what omitting `origin` on create actually does server-side,
      // rather than assuming it — this is the fact FR-005's guarantee rests
      // on for every order raised before mbe-api#209 shipped.
      expect(
        unrecordedProbe.origin,
        isNull,
        reason: 'an order created without an explicit origin must record '
            'none — never silently default to either workflow',
      );

      Future<bool> foundInFilteredList(int saleId) async {
        final page = await salesOrders.listSales(
          pointSale: posProbe.pointSale,
          search: null,
          limit: 100,
          excludeOrigin: SaleOrigin.backOffice,
        );
        return page.items.any((s) => s.id == saleId);
      }

      expect(
        await foundInFilteredList(officeProbe.id),
        isFalse,
        reason: 'excludeOrigin: backOffice must remove every back-office '
            'order (FR-002)',
      );
      expect(
        await foundInFilteredList(posProbe.id),
        isTrue,
        reason: 'a point-of-sale order must survive the filter',
      );
      expect(
        await foundInFilteredList(unrecordedProbe.id),
        isTrue,
        reason: 'an order with no recorded origin must never be hidden by '
            'either list\'s origin filter (FR-005, SC-003)',
      );
    },
    skip: !_canRun,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
