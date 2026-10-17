import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/product_photo_preview.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../helpers/network_image_stub.dart';

/// The enlarged product photo (046-catalog-improvements FR-014, FR-015,
/// contracts C4).
void main() {
  setUpAll(
    () => stubNetworkImages(isBroken: (url) => url.path.contains('broken')),
  );

  Future<void> openPreview(
    WidgetTester tester, {
    String url = 'https://example.com/photo.png',
    Size surface = const Size(800, 600),
  }) async {
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              key: const Key('open'),
              onPressed: () => showProductPhotoPreview(
                context,
                photoUrl: url,
                title: 'Clavo de acero 2"',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
    await pumpUntilImagesLoad(tester);
  }

  testWidgets('shows the product name and the photo, fitted', (tester) async {
    await openPreview(tester);

    expect(find.byKey(const Key('photo_preview_dialog')), findsOneWidget);
    expect(find.text('Clavo de acero 2"'), findsOneWidget);
    final image = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const Key('photo_preview_dialog')),
        matching: find.byType(Image),
      ),
    );
    expect((image.image as NetworkImage).url, 'https://example.com/photo.png');
    expect(image.fit, BoxFit.contain);
  });

  testWidgets('the close button dismisses it', (tester) async {
    await openPreview(tester);

    await tester.tap(find.byKey(const Key('photo_preview_close')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('photo_preview_dialog')), findsNothing);
  });

  testWidgets('Escape dismisses it', (tester) async {
    await openPreview(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('photo_preview_dialog')), findsNothing);
  });

  testWidgets('a click outside dismisses it', (tester) async {
    await openPreview(tester);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('photo_preview_dialog')), findsNothing);
  });

  testWidgets('a photo that fails to load shows the placeholder', (
    tester,
  ) async {
    await openPreview(tester, url: 'https://example.com/broken.png');

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });

  testWidgets('a tall dialog on a phone-sized screen fits without overflow '
      '(spec edge case: large or portrait photos)', (tester) async {
    await openPreview(tester, surface: const Size(360, 640));

    expect(tester.takeException(), isNull);
    final dialog = tester.getRect(
      find.byKey(const Key('photo_preview_dialog')),
    );
    expect(dialog.height, lessThanOrEqualTo(640));
    expect(dialog.width, lessThanOrEqualTo(360));
  });
}
