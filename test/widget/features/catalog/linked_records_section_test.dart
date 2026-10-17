import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/presentation/widgets/linked_records_section.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

typedef _Rec = ({int id, String label, EntityStatus status});

const _a = (id: 1, label: 'Alpha', status: EntityStatus.active);
const _b = (id: 2, label: 'Beta', status: EntityStatus.inactive);
const _c = (id: 3, label: 'Gamma', status: EntityStatus.active);

/// The shared customer-form section (046-catalog-improvements contracts C1).
void main() {
  Future<void> pumpSection(
    WidgetTester tester, {
    required List<_Rec> items,
    bool editable = true,
    Future<Iterable<_Rec>> Function(String)? search,
    Future<_Rec?> Function()? onCreateNew,
    List<_Rec>? linked,
    List<_Rec>? unlinked,
    Size surface = const Size(800, 600),
  }) async {
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [inputDebounceProvider.overrideWithValue(Duration.zero)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: LinkedRecordsSection<_Rec>(
                sectionId: 'things',
                title: 'Things',
                emptyText: 'Nothing linked.',
                items: items,
                idOf: (r) => r.id,
                labelOf: (r) => r.label,
                subtitleOf: (r) => 'sub ${r.id}',
                statusOf: (r) => r.status,
                editable: editable,
                searchExisting: search,
                onLinked: linked?.add,
                onUnlinked: unlinked?.add,
                onCreateNew: onCreateNew,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists each record with its subtitle, a count, and the shared '
      'chip for a non-active one', (tester) async {
    await pumpSection(tester, items: [_a, _b]);

    expect(find.text('Things (2)'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('sub 2'), findsOneWidget);
    expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
    expect(find.text('Nothing linked.'), findsNothing);
  });

  testWidgets('each row is set off by a hairline below it', (tester) async {
    await pumpSection(tester, items: [_a, _b]);

    final row = tester.getRect(
      find.byKey(const ValueKey('linked_row_things_1')),
    );
    final line = tester.getRect(
      find.byKey(const ValueKey('linked_divider_things_1')),
    );
    expect(line.top, moreOrLessEquals(row.bottom, epsilon: 0.5));
    expect(
      find.byKey(const ValueKey('linked_divider_things_2')),
      findsOneWidget,
    );
  });

  testWidgets('shows the empty text when nothing is linked', (tester) async {
    await pumpSection(tester, items: const []);

    expect(find.text('Things'), findsOneWidget);
    expect(find.text('Nothing linked.'), findsOneWidget);
  });

  testWidgets('unlink reports the record', (tester) async {
    final unlinked = <_Rec>[];
    await pumpSection(tester, items: [_a, _b], unlinked: unlinked);

    await tester.tap(find.byKey(const Key('unlink_things_2')));

    expect(unlinked, [_b]);
  });

  testWidgets('the search leaves out records already linked, and picking one '
      'links it', (tester) async {
    final linked = <_Rec>[];
    await pumpSection(
      tester,
      items: [_a],
      search: (_) async => [_a, _c],
      linked: linked,
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('linked_picker_things_0')),
        matching: find.byType(TextFormField),
      ),
      'a',
    );
    await tester.pumpAndSettle();

    // 'Alpha' is shown once: in its row, not as an option.
    expect(find.text('Alpha'), findsOneWidget);
    await tester.tap(find.text('Gamma'));
    await tester.pumpAndSettle();

    expect(linked, [_c]);
  });

  testWidgets('"New" links whatever the create callback returns, and nothing '
      'when it is cancelled', (tester) async {
    final linked = <_Rec>[];
    final results = <_Rec?>[_c, null];
    await pumpSection(
      tester,
      items: const [],
      onCreateNew: () async => results.removeAt(0),
      linked: linked,
    );

    await tester.tap(find.byKey(const Key('linked_new_things')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('linked_new_things')));
    await tester.pumpAndSettle();

    expect(linked, [_c]);
  });

  testWidgets('a created record that is already linked is not linked twice', (
    tester,
  ) async {
    final linked = <_Rec>[];
    await pumpSection(
      tester,
      items: [_c],
      onCreateNew: () async => _c,
      linked: linked,
    );

    await tester.tap(find.byKey(const Key('linked_new_things')));
    await tester.pumpAndSettle();

    expect(linked, isEmpty);
  });

  testWidgets('read-only shows the rows but no unlink, search or "New"', (
    tester,
  ) async {
    await pumpSection(
      tester,
      items: [_a],
      editable: false,
      search: (_) async => const [],
      onCreateNew: () async => null,
      unlinked: [],
    );

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.byKey(const Key('unlink_things_1')), findsNothing);
    expect(find.byKey(const Key('linked_picker_things_0')), findsNothing);
    expect(find.byKey(const Key('linked_new_things')), findsNothing);
  });

  testWidgets('twenty records at a phone width lay out without overflow', (
    tester,
  ) async {
    await pumpSection(
      tester,
      items: [
        for (var i = 0; i < 20; i++)
          (
            id: i,
            label: 'Record $i with a fairly long label',
            status: EntityStatus.active,
          ),
      ],
      unlinked: [],
      onCreateNew: () async => null,
      surface: const Size(360, 640),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Things (20)'), findsOneWidget);
  });
}
