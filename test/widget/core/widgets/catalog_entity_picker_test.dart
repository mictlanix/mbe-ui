import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';

class _Item {
  const _Item(this.id, this.name, {this.photo, this.subtitle});

  final int id;
  final String name;
  final String? photo;
  final String? subtitle;
}

void main() {
  Future<void> pumpPicker(
    WidgetTester tester, {
    String? Function(_Item)? optionImageUrl,
    String? Function(_Item)? optionSubtitle,
    required Future<Iterable<_Item>> Function(String) optionsBuilder,
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: Scaffold(
            body: CatalogEntityPicker<_Item>(
              label: 'Item',
              displayStringForOption: (item) => item.name,
              optionsBuilder: optionsBuilder,
              onSelected: (_) {},
              optionImageUrl: optionImageUrl,
              optionSubtitle: optionSubtitle,
            ),
          ),
        ),
      ),
    );
  }

  // The picker debounces optionsBuilder by `inputDebounceProvider`
  // (default 300ms, catalog_entity_picker.dart) — waiting a little past
  // whatever that resolves to in this test's container proves the options
  // arrive on the *configured* delay rather than a hardcoded one (spec 036
  // SC-008).
  Future<void> typeAndWaitForOptions(
    WidgetTester tester,
    String text, {
    Duration debounce = const Duration(milliseconds: 300),
  }) async {
    await tester.enterText(find.byType(TextFormField), text);
    await tester.pump(debounce + const Duration(milliseconds: 50));
    await tester.pump();
  }

  testWidgets('renders text-only options when neither optionImageUrl nor '
      'optionSubtitle is provided (unchanged existing behavior)', (
    tester,
  ) async {
    await pumpPicker(
      tester,
      optionsBuilder: (query) async => const [_Item(1, 'Widget')],
    );

    await typeAndWaitForOptions(tester, 'wid');

    expect(find.text('Widget'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(ProductPhoto), findsNothing);
  });

  testWidgets('renders a ListTile with a thumbnail and subtitle when both '
      'optionImageUrl and optionSubtitle are provided', (tester) async {
    await pumpPicker(
      tester,
      optionsBuilder: (query) async => const [
        _Item(1, 'Widget', photo: 'http://test/widget.png', subtitle: 'SKU-1'),
      ],
      optionImageUrl: (item) => item.photo,
      optionSubtitle: (item) => item.subtitle,
    );

    await typeAndWaitForOptions(tester, 'wid');

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Widget'), findsOneWidget);
    expect(find.text('SKU-1'), findsOneWidget);
    final photo = tester.widget<ProductPhoto>(find.byType(ProductPhoto));
    expect(photo.photoUrl, 'http://test/widget.png');
  });

  testWidgets(
    'renders the placeholder thumbnail for an option with no photo URL',
    (tester) async {
      await pumpPicker(
        tester,
        optionsBuilder: (query) async => const [
          _Item(1, 'Widget', subtitle: 'SKU-1'),
        ],
        optionSubtitle: (item) => item.subtitle,
      );

      await typeAndWaitForOptions(tester, 'wid');

      expect(find.byType(ListTile), findsOneWidget);
      final photo = tester.widget<ProductPhoto>(find.byType(ProductPhoto));
      expect(photo.photoUrl, isNull);
    },
  );

  testWidgets('selecting a rich option invokes onSelected with that option', (
    tester,
  ) async {
    _Item? selected;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CatalogEntityPicker<_Item>(
              label: 'Item',
              displayStringForOption: (item) => item.name,
              optionsBuilder: (query) async => const [
                _Item(1, 'Widget', subtitle: 'SKU-1'),
              ],
              onSelected: (item) => selected = item,
              optionSubtitle: (item) => item.subtitle,
            ),
          ),
        ),
      ),
    );

    await typeAndWaitForOptions(tester, 'wid');
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(selected?.id, 1);
  });

  // spec 036 SC-008: changing the search-debounce setting changes this
  // picker's delay, from one place, with no field left on its own hardcoded
  // literal.
  testWidgets(
    'overriding inputDebounceProvider changes when options actually appear',
    (tester) async {
      const overriddenDebounce = Duration(milliseconds: 900);

      await pumpPicker(
        tester,
        overrides: [inputDebounceProvider.overrideWithValue(overriddenDebounce)],
        optionsBuilder: (query) async => const [_Item(1, 'Widget')],
      );

      await tester.enterText(find.byType(TextFormField), 'wid');
      // Still short of the overridden (longer) delay: options must not have
      // arrived yet, proving the default 300ms is no longer in effect.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Widget'), findsNothing);

      await tester.pump(const Duration(milliseconds: 550));
      await tester.pump();
      expect(find.text('Widget'), findsOneWidget);
    },
  );
}
