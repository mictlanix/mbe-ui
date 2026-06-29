import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/product_photo.dart';

void main() {
  testWidgets('renders the network image for a non-null photo URL (FR-001)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductPhoto(photoUrl: 'https://example.com/photo.png'),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect(
      (image.image as NetworkImage).url,
      'https://example.com/photo.png',
    );
    expect(find.byIcon(Icons.inventory_2_outlined), findsNothing);
  });

  testWidgets('renders the placeholder for a null photo URL (FR-002)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProductPhoto(photoUrl: null))),
    );

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets(
      'renders the placeholder when the network image fails to load '
      '(FR-002)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductPhoto(photoUrl: 'https://example.com/broken.png'),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final fallback = image.errorBuilder!(
      tester.element(find.byType(Image)),
      Object(),
      StackTrace.empty,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: fallback)),
    );

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });
}
