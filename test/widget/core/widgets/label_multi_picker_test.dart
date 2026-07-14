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
    Map<int, int>? labelCounts,
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
            labelCounts: labelCounts,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Chip text may be "Name" or "Name (count)" depending on [labelCounts], so
  // finders match by the widget's label rather than its exact display text.
  Finder chipFinder(String labelName) => find.byWidgetPredicate(
        (w) =>
            w is FilterChip &&
            (w.label as Text).data!.startsWith(labelName),
      );

  bool isInteractive(WidgetTester tester, String label) =>
      tester.widget<FilterChip>(chipFinder(label)).onSelected != null;

  String chipText(WidgetTester tester, String label) =>
      (tester.widget<FilterChip>(chipFinder(label)).label as Text).data!;

  testWidgets(
    'with labelCounts == null (unknown/loading/error), every chip stays '
    'interactive and shows no count — fail open (spec 009 FR-010)',
    (tester) async {
      await pumpPicker(tester);

      expect(isInteractive(tester, 'Trupper'), isTrue);
      expect(isInteractive(tester, 'DeWalt'), isTrue);
      expect(isInteractive(tester, 'Makita'), isTrue);
      expect(chipText(tester, 'Trupper'), 'Trupper');
    },
  );

  testWidgets(
    'a label absent from labelCounts is disabled, not selectable, and shows '
    'no count (FR-004)',
    (tester) async {
      await pumpPicker(tester, labelCounts: {1: 42, 2: 7});

      expect(isInteractive(tester, 'Trupper'), isTrue);
      expect(isInteractive(tester, 'DeWalt'), isTrue);
      expect(isInteractive(tester, 'Makita'), isFalse);
      expect(chipText(tester, 'Makita'), 'Makita');
    },
  );

  testWidgets(
    'a label present in labelCounts shows "Name (count)"',
    (tester) async {
      await pumpPicker(tester, labelCounts: {1: 42, 2: 7});

      expect(chipText(tester, 'Trupper'), 'Trupper (42)');
      expect(chipText(tester, 'DeWalt'), 'DeWalt (7)');
    },
  );

  testWidgets(
    'a selected label stays interactive even if not in labelCounts, so it '
    'can be deselected (FR-006)',
    (tester) async {
      await pumpPicker(tester, selectedIds: [3], labelCounts: {1: 1, 2: 1});

      expect(isInteractive(tester, 'Makita'), isTrue);
      expect(
        tester.widget<FilterChip>(chipFinder('Makita')).selected,
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
      labelCounts: {1: 1},
      onChanged: (v) => changed = v,
    );

    await tester.tap(chipFinder('Makita'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(changed, isNull);
  });

  testWidgets('tapping an available chip invokes onChanged with it added', (
    tester,
  ) async {
    List<int>? changed;
    await pumpPicker(
      tester,
      labelCounts: {1: 1, 2: 1},
      onChanged: (v) => changed = v,
    );

    await tester.tap(chipFinder('DeWalt'));
    await tester.pumpAndSettle();

    expect(changed, [2]);
  });
}
