import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/signature_pad.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Widget _wrap(SignatureController controller, {double width = 480}) =>
    MaterialApp(
      locale: const Locale('es', 'MX'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: SignaturePad(controller: controller),
          ),
        ),
      ),
    );

Future<void> _scribble(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getTopLeft(find.byKey(const Key('signature_pad'))) +
        const Offset(20, 20),
  );
  await gesture.moveBy(const Offset(60, 10));
  await gesture.moveBy(const Offset(40, -30));
  await gesture.up();
  await tester.pump();
}

/// Spec 075 T026, research R9: the feature-local signature pad.
void main() {
  late SignatureController controller;

  setUp(() => controller = SignatureController());

  testWidgets('an empty pad is empty', (tester) async {
    await tester.pumpWidget(_wrap(controller));

    expect(controller.isEmpty, isTrue);
    expect(find.text('Firma aquí'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('signature_clear')))
          .onPressed,
      isNull,
      reason: 'nothing to clear yet',
    );
  });

  testWidgets('a stroke makes it non-empty', (tester) async {
    await tester.pumpWidget(_wrap(controller));

    await _scribble(tester);

    expect(controller.isEmpty, isFalse);
    expect(find.text('Firma aquí'), findsNothing);
  });

  testWidgets('a tap is a dot, and counts as a signature', (tester) async {
    await tester.pumpWidget(_wrap(controller));

    await tester.tapAt(
      tester.getCenter(find.byKey(const Key('signature_pad'))),
    );
    await tester.pump();

    expect(controller.isEmpty, isFalse);
  });

  testWidgets('"Borrar" clears it', (tester) async {
    await tester.pumpWidget(_wrap(controller));
    await _scribble(tester);

    await tester.tap(find.byKey(const Key('signature_clear')));
    await tester.pump();

    expect(controller.isEmpty, isTrue);
    expect(find.text('Firma aquí'), findsOneWidget);
  });

  testWidgets('it keeps the 8:3 ratio at any width', (tester) async {
    await tester.pumpWidget(_wrap(controller, width: 360));

    final size = tester.getSize(find.byKey(const Key('signature_pad')));

    expect(size.width / size.height, closeTo(1024 / 384, 0.01));
  });

  testWidgets('toPng returns a 1024 x 384 PNG under 2 MB', (tester) async {
    await tester.pumpWidget(_wrap(controller));
    await _scribble(tester);

    final png = (await tester.runAsync(controller.toPng))!;

    expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    expect(png.length, lessThan(2 * 1024 * 1024));
    // The IHDR chunk holds the size, big-endian, at bytes 16..24.
    final header = ByteData.sublistView(Uint8List.fromList(png), 16, 24);
    expect(header.getUint32(0), signatureImageWidth);
    expect(header.getUint32(4), signatureImageHeight);
  });

  testWidgets('a cleared pad draws nothing but is still a valid PNG', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(controller));
    await _scribble(tester);
    controller.clear();

    final png = (await tester.runAsync(controller.toPng))!;

    expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });
}
