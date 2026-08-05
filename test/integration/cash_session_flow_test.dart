import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/denomination_count.dart';

/// Golden-path integration test against a *real* mbe-api instance
/// (constitution §VII — no mocked/offline mode): open a session, observe a
/// second open on the same account is refused, submit a count, close, and
/// confirm it is no longer this cashier's open session (quickstart.md
/// "Integration test (live backend)").
///
/// Requires mbe-api running at [apiBaseUrl] (default `http://127.0.0.1:8000`)
/// and a user with `POS (44)` READ+CREATE, `CASH_SESSION_CLOSE (111)` UPDATE
/// and at least one cash drawer visible to them. Configure via
/// `--dart-define`:
///   --dart-define=MBE_CASH_SESSION_USERNAME=...
///   --dart-define=MBE_CASH_SESSION_PASSWORD=...
///
/// Skipped entirely when credentials aren't provided. A closed session is
/// terminal — there is no delete or reopen — so this test leaves a closed
/// session behind on every run; point it at a dev tenant, never production.
const _username = String.fromEnvironment('MBE_CASH_SESSION_USERNAME');
const _password = String.fromEnvironment('MBE_CASH_SESSION_PASSWORD');

const _canRun = _username != '' && _password != '';

void main() {
  test(
    'open a session → a second open on the same account is refused → count → '
    'close → no longer this cashier\'s open session',
    () async {
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      final token = await AuthRepositoryImpl(
        dio,
      ).login(username: _username, password: _password);
      dio.options.headers['Authorization'] = 'Bearer $token';

      final cashDrawerRepository = CashDrawerRepositoryImpl(dio);
      final cashSessionRepository = CashSessionRepositoryImpl(dio);

      // Discover a drawer at runtime rather than hardcoding an id.
      final drawers = await cashDrawerRepository.list(limit: 1);
      if (drawers.items.isEmpty) {
        markTestSkipped('no cash drawer visible to this account');
        return;
      }
      final cashDrawerId = drawers.items.first.cashDrawerId;

      // A leftover open session from a prior failed run would make the
      // golden path's first open ambiguous — skip rather than misreport.
      final before = await cashSessionRepository.getCurrent();
      if (before.state != SessionState.none) {
        markTestSkipped(
          'this account already has an open/stale session — close it '
          'manually before re-running',
        );
        return;
      }

      // 1. US1 — open a session.
      final session = await cashSessionRepository.open(
        cashDrawerId: cashDrawerId,
        openingAmount: '100.00',
      );
      expect(session.cashDrawerId, cashDrawerId);

      // 2. A second open on the same account is refused (409) — the
      // cashier-busy path (FR-005/FR-006), disambiguated by status only,
      // never by parsing `detail`.
      await expectLater(
        cashSessionRepository.open(
          cashDrawerId: cashDrawerId,
          openingAmount: '0',
        ),
        throwsA(isA<ServerError>().having((e) => e.statusCode, 'statusCode', 409)),
      );

      // 3. US2 — submit a count and close.
      final closed = await cashSessionRepository.close(
        cashSessionId: session.cashSessionId,
        counts: const [
          DenominationCount(denomination: '100', quantity: 1),
          DenominationCount(denomination: '0.50', quantity: 2),
        ],
      );
      expect(closed.cashSessionId, session.cashSessionId);

      // 4. It is no longer this cashier's open session.
      final after = await cashSessionRepository.getCurrent();
      expect(after.session?.cashSessionId, isNot(session.cashSessionId));
    },
    skip: !_canRun,
  );
}
