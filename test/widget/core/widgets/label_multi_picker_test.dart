import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/label_multi_picker.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label_item.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _labels = [
  LabelItem(labelId: 1, name: 'Trupper'),
  LabelItem(labelId: 2, name: 'DeWalt'),
  LabelItem(labelId: 3, name: 'Makita'),
];

void main() {
  Future<void> pumpPicker(
    WidgetTester tester, {
    List<int> selectedIds = const [],
    Set<int>? availableIds,
    ValueChanged<List<int>>? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LabelMultiPicker(
            labels: _labels,
            selectedIds: selectedIds,
            availableIds: availableIds,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool isInteractive(WidgetTester tester, String label) =>
      tester.widget<FilterChip>(find.widgetWithText(FilterChip, label)).onSelected != null;

  testWidgets(
    'with availableIds == null (unknown/loading/error), every chip stays '
    'interactive — fail open (spec 009 FR-010)',
    (tester) async {
      await pumpPicker(tester);

      expect(isInteractive(tester, 'Trupper'), isTrue);
      expect(isInteractive(tester, 'DeWalt'), isTrue);
      expect(isInteractive(tester, 'Makita'), isTrue);
    },
  );

  testWidgets(
    'a label absent from availableIds is disabled and not selectable '
    '(FR-004)',
    (tester) async {
      await pumpPicker(tester, availableIds: {1, 2});

      expect(isInteractive(tester, 'Trupper'), isTrue);
      expect(isInteractive(tester, 'DeWalt'), isTrue);
      expect(isInteractive(tester, 'Makita'), isFalse);
    },
  );

  testWidgets(
    'a selected label stays interactive even if not in availableIds, so it '
    'can be deselected (FR-006)',
    (tester) async {
      await pumpPicker(tester, selectedIds: [3], availableIds: {1, 2});

      expect(isInteractive(tester, 'Makita'), isTrue);
      expect(
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Makita')).selected,
        isTrue,
      );
    },
  );

  testWidgets('tapping a disabled chip does not invoke onChanged', (
    tester,
  ) async {
    List<int>? changed;
    await pumpPicker(
      tester,
      availableIds: {1},
      onChanged: (v) => changed = v,
    );

    await tester.tap(find.widgetWithText(FilterChip, 'Makita'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(changed, isNull);
  });

  testWidgets('tapping an available chip invokes onChanged with it added', (
    tester,
  ) async {
    List<int>? changed;
    await pumpPicker(
      tester,
      availableIds: {1, 2},
      onChanged: (v) => changed = v,
    );

    await tester.tap(find.widgetWithText(FilterChip, 'DeWalt'));
    await tester.pumpAndSettle();

    expect(changed, [2]);
  });
}
