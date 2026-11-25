import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

import 'commission_harness.dart';

const _wide = Size(2200, 1000);
const _path = '/commissions/settings?section=participations';
const _p = CommissionParticipation(id: 2, name: 'CANALIZACION');

void main() {
  late CommissionHarness h;

  setUp(() {
    h = CommissionHarness();
    when(() => h.repo.listParticipations()).thenAnswer((_) async => [_p]);
  });

  Future<void> pump(WidgetTester tester, {int commissions = 15}) => h.pump(
    tester,
    who: CommissionHarness.user(commissions: commissions),
    location: _path,
    surface: _wide,
  );

  testWidgets('lists the types and offers create and edit with the rights', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('CANALIZACION'), findsOneWidget);
    expect(key('commission_new_participation_button'), findsOneWidget);
    expect(key('commission_participation_edit_2'), findsOneWidget);
  });

  testWidgets('read only shows no actions and a text panel', (tester) async {
    await pump(tester, commissions: 2);
    expect(key('commission_new_participation_button'), findsNothing);
    expect(key('commission_participation_edit_2'), findsNothing);

    await tester.tap(find.text('CANALIZACION'));
    await tester.pumpAndSettle();
    expect(find.text('Ver participación'), findsOneWidget);
    expect(key('commission_participation_edit_button'), findsNothing);
  });

  testWidgets('a new participation needs a name, then is created', (
    tester,
  ) async {
    when(() => h.repo.createParticipation('Campo')).thenAnswer((_) async => _p);
    await pump(tester);

    await tester.tap(key('commission_new_participation_button'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_participation_save_button'));
    await tester.pumpAndSettle();
    expect(find.text('El nombre es obligatorio.'), findsOneWidget);

    await tester.enterText(key('commission_participation_name_field'), 'Campo');
    await tester.tap(key('commission_participation_save_button'));
    await tester.pumpAndSettle();
    verify(() => h.repo.createParticipation('Campo')).called(1);
    expect(key('commission_participation_save_button'), findsNothing);
  });

  testWidgets('removing one in use shows the translated refusal', (
    tester,
  ) async {
    when(() => h.repo.deleteParticipation(2)).thenThrow(
      aRefusal(
        api.ErrorCode.resourcePeriodStillReferenced,
        'resource.still_referenced',
        {
          'references': [
            {'resource': 'sales_order', 'count': 3},
          ],
          'more': 0,
        },
      ),
    );
    await pump(tester);

    await tester.tap(key('commission_participation_edit_2'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_participation_delete_button'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_participation_confirm_delete_button'));
    await tester.pumpAndSettle();

    expect(key('commission_participation_error'), findsOneWidget);
    expect(find.textContaining('todavía está en uso'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
  });
}
