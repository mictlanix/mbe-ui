import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

const _wide = Size(2200, 1000);
const _path = '/commissions/settings?section=labels';

bool enabled(WidgetTester tester, String k) =>
    tester.widget<TextFormField>(find.byKey(Key(k))).enabled;

void main() {
  late CommissionHarness h;

  setUpAll(() => registerFallbackValue(d('0')));

  setUp(() {
    h = CommissionHarness();
    when(() => h.repo.listLabels()).thenAnswer((_) async => [aLabel()]);
  });

  Future<void> pump(WidgetTester tester, {int commissions = 15}) => h.pump(
    tester,
    who: CommissionHarness.user(commissions: commissions),
    location: _path,
    surface: _wide,
  );

  testWidgets('a row shows name, rate as a percentage and comment', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('5.00 %'), findsOneWidget);
  });

  testWidgets('actions follow the right of each call', (tester) async {
    // Create + read: "+ Nueva etiqueta" but no edit icon.
    await pump(tester, commissions: 3);
    expect(key('commission_new_label_button'), findsOneWidget);
    expect(key('commission_label_edit_3'), findsNothing);
  });

  testWidgets('update + read: the edit icon but no create', (tester) async {
    await pump(tester, commissions: 6);
    expect(key('commission_new_label_button'), findsNothing);
    expect(key('commission_label_edit_3'), findsOneWidget);
  });

  testWidgets('read only: nothing to act on, and the panel is text', (
    tester,
  ) async {
    await pump(tester, commissions: 2);
    expect(key('commission_new_label_button'), findsNothing);
    expect(key('commission_label_edit_3'), findsNothing);

    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();
    expect(find.text('Ver etiqueta de comisión'), findsOneWidget);
    expect(key('commission_label_edit_button'), findsNothing);
    expect(key('commission_label_save_button'), findsNothing);
    expect(key('commission_label_delete_button'), findsNothing);
  });

  testWidgets('a row click opens read-only, Edit makes it editable', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();

    expect(enabled(tester, 'commission_label_name_field'), isFalse);
    expect(key('commission_label_save_button'), findsNothing);
    expect(key('commission_label_delete_button'), findsNothing);
    // Filled as a percentage, no symbol.
    expect(
      tester
          .widget<TextFormField>(key('commission_label_rate_field'))
          .initialValue,
      '5',
    );

    await tester.tap(key('commission_label_edit_button'));
    await tester.pumpAndSettle();
    expect(enabled(tester, 'commission_label_name_field'), isTrue);
    expect(key('commission_label_save_button'), findsOneWidget);
    expect(key('commission_label_delete_button'), findsOneWidget);
  });

  testWidgets('creating sends the rate as a fraction and refreshes', (
    tester,
  ) async {
    when(
      () => h.repo.createLabel(
        name: any(named: 'name'),
        rate: any(named: 'rate'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => aLabel(id: 4));
    await pump(tester);

    await tester.tap(key('commission_new_label_button'));
    await tester.pumpAndSettle();
    await tester.enterText(key('commission_label_name_field'), 'Nueva');
    await tester.enterText(key('commission_label_rate_field'), '2.5');
    await tester.tap(key('commission_label_save_button'));
    await tester.pumpAndSettle();

    verify(
      () => h.repo.createLabel(name: 'Nueva', rate: d('0.025'), comment: null),
    ).called(1);
    expect(key('commission_label_save_button'), findsNothing);
    verify(() => h.repo.listLabels()).called(2);
  });

  testWidgets('a bad rate is refused in the field', (tester) async {
    await pump(tester);
    await tester.tap(key('commission_new_label_button'));
    await tester.pumpAndSettle();
    await tester.enterText(key('commission_label_name_field'), 'Nueva');
    await tester.enterText(key('commission_label_rate_field'), '120');
    await tester.tap(key('commission_label_save_button'));
    await tester.pumpAndSettle();

    expect(find.text('Debe estar entre 0 y 100.'), findsOneWidget);
    verifyNever(
      () => h.repo.createLabel(
        name: any(named: 'name'),
        rate: any(named: 'rate'),
        comment: any(named: 'comment'),
      ),
    );
  });

  testWidgets('deleting a label in use shows the translated refusal', (
    tester,
  ) async {
    when(() => h.repo.deleteLabel(3)).thenThrow(
      aRefusal(
        api.ErrorCode.resourcePeriodStillReferenced,
        'resource.still_referenced',
        {
          'references': [
            {'resource': 'sales_order', 'count': 12},
          ],
          'more': 0,
        },
      ),
    );
    await pump(tester);

    await tester.tap(key('commission_label_edit_3'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_label_delete_button'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_label_confirm_delete_button'));
    await tester.pumpAndSettle();

    expect(key('commission_label_error'), findsOneWidget);
    expect(
      find.textContaining('todavía está en uso: 12 pedidos'),
      findsOneWidget,
    );
    expect(find.text('SERVER TEXT'), findsNothing);
    // The label stays in the table behind the panel.
    expect(find.text('Premium'), findsWidgets);
  });

  testWidgets('the search narrows the rows on the client', (tester) async {
    when(() => h.repo.listLabels()).thenAnswer(
      (_) async => [
        aLabel(),
        CommissionLabel(id: 4, name: 'Otra', rate: d('0.1')),
      ],
    );
    await pump(tester);
    expect(find.text('Otra'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: key('commission_labels_search_field'),
        matching: find.byType(TextField),
      ),
      'otra',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Premium'), findsNothing);
    expect(find.text('Otra'), findsOneWidget);
  });
}
