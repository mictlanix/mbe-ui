import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';

CashSession _sessionWith({required DateTime start, DateTime? end}) => CashSession(
  cashSessionId: 1,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 1,
  cashierName: 'Ana López',
  start: start,
  end: end,
  openingAmount: '0',
);

void main() {
  group('cashSessionStatusOf', () {
    test('a session with an end time is closed, regardless of when it '
        'started', () {
      final session = _sessionWith(
        start: DateTime(2026, 8, 1, 9),
        end: DateTime(2026, 8, 1, 17),
      );
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 1));
      expect(status, CashSessionStatus.closed);
    });

    test('an open session started today is open', () {
      final session = _sessionWith(start: DateTime(2026, 8, 5, 9));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5, 23, 59));
      expect(status, CashSessionStatus.open);
    });

    test('an open session started yesterday is stale', () {
      final session = _sessionWith(start: DateTime(2026, 8, 4, 9));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5));
      expect(status, CashSessionStatus.stale);
    });

    test('a session started one second before midnight is stale when '
        'viewed the next morning — the exact edge case the derivation must '
        'get right, per date not per elapsed duration', () {
      final session = _sessionWith(start: DateTime(2026, 8, 4, 23, 59, 59));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5, 0, 0, 1));
      expect(status, CashSessionStatus.stale);
    });

    test('a session started at the first instant of today is open, not '
        'stale', () {
      final session = _sessionWith(start: DateTime(2026, 8, 5, 0, 0, 0));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5, 0, 0, 1));
      expect(status, CashSessionStatus.open);
    });

    test('a session started many days ago and never closed is stale, not '
        'some fourth state', () {
      final session = _sessionWith(start: DateTime(2026, 7, 1, 9));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5));
      expect(status, CashSessionStatus.stale);
    });
  });

  group(
    'cashSessionStatusOf, through the real wire mapping (spec 043, '
    'mictlanix/mbe-ui#176)',
    () {
      test(
        'a session opened after 18:00 the previous day and never closed reads '
        'stale, not open — this disagreed with mbe-api before this feature, '
        "since Iso8601DateTimeSerializer shifted the evening start's date "
        'into the next calendar day (FR-008)',
        () {
          // mbe-api sends naive local wall-clock time with no offset — this
          // is the wire form, not a hand-built DateTime.
          final response = appSerializers.deserializeWith(
            api.CashSessionResponse.serializer,
            {
              'cash_session_id': 1,
              'cash_drawer': {
                'cash_drawer_id': 1,
                'facility': 1,
                'code': 'CJ1',
                'name': 'Caja 1',
                'comment': null,
                'status': 0,
              },
              'cashier': {
                'employee_id': 100,
                'first_name': 'Ana',
                'last_name': 'López',
                'nickname': 'Ana',
                'gender': 0,
                'birthday': '1990-01-01',
                'taxpayer_id': null,
                'sales_person': false,
                'status': 0,
                'personal_id': null,
                'start_job_date': '2020-01-01',
                'enroll_number': null,
                'comment': null,
              },
              'start': '2026-09-25T19:00:00',
              'end': null,
              'cash_supervisor': null,
              'opening_amount': '500.00',
              'payments_by_method': <Object?>[],
            },
          )!;
          final session = CashSession.fromResponse(response);

          expect(
            session.start,
            DateTime(2026, 9, 25, 19),
            reason: 'the wire\'s own fields, unshifted (FR-001) — the '
                'precondition for this test to mean anything',
          );
          expect(
            cashSessionStatusOf(session, today: DateTime(2026, 9, 26)),
            CashSessionStatus.stale,
          );
        },
      );
    },
  );
}
