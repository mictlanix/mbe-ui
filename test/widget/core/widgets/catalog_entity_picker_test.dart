import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  }) async {
    await tester.pumpWidget(
      MaterialApp(
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
    );
  }

  Future<void> typeAndWaitForOptions(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextFormField), text);
    // The picker debounces optionsBuilder by 300ms (catalog_entity_picker.dart).
    await tester.pump(const Duration(milliseconds: 350));
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
      MaterialApp(
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
    );

    await typeAndWaitForOptions(tester, 'wid');
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(selected?.id, 1);
  });
}
