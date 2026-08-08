import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/number_pad.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

Future<TextEditingController> _pump(
  WidgetTester tester, {
  required Size surface,
}) async {
  final controller = TextEditingController();
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        // A Column stretches its child across the pane, which is exactly the
        // situation the pad has to survive — it is how `PaymentAmountField`
        // lays it out.
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [NumberPad(controller: controller)],
        ),
      ),
    ),
  );
  return controller;
}

Size _keySize(WidgetTester tester, String key) =>
    tester.getSize(find.byKey(Key('number_pad_$key')));

/// The pad must not grow with the pane it is dropped into.
///
/// `GridView.count` derives cell height from the width it is handed, so a
/// full-width pad on a desktop pane drew ~550x300 px keys and pushed the
/// submit button below the fold — driving the real app, every digit needed a
/// scroll first and taps landed late enough to enter `1288` for `128`.
void main() {
  const phone = Size(390, 900);
  const desktop = Size(1680, 1000);

  group('NumberPad sizing', () {
    testWidgets('a wide pane does not stretch the keys', (tester) async {
      await _pump(tester, surface: desktop);

      // `NumberPad` itself fills the pane — it aligns the pad within it — so
      // the grid of keys is what has to stay bounded.
      final pad = tester.getSize(
        find.descendant(
          of: find.byType(NumberPad),
          matching: find.byType(GridView),
        ),
      );
      expect(
        pad.width,
        lessThanOrEqualTo(NumberPad.maxPadWidth),
        reason: 'the pad is a fixed-purpose control, not a filler',
      );

      final key = _keySize(tester, '7');
      expect(key.width, lessThan(140));
      expect(key.height, lessThan(90));
    });

    testWidgets('the phone keeps the size the pad was drawn for — a desktop '
        'key is no bigger than a phone key', (tester) async {
      await _pump(tester, surface: phone);
      final onPhone = _keySize(tester, '7');

      await _pump(tester, surface: desktop);
      final onDesktop = _keySize(tester, '7');

      expect(onDesktop.width, lessThanOrEqualTo(onPhone.width));
      expect(onDesktop.height, lessThanOrEqualTo(onPhone.height));
    });

    testWidgets('every key stays a usable target at both tiers', (
      tester,
    ) async {
      for (final surface in [phone, desktop]) {
        await _pump(tester, surface: surface);
        for (final key in ['7', '8', '9', '0', '.', 'backspace']) {
          final size = _keySize(tester, key);
          expect(
            size.shortestSide,
            greaterThanOrEqualTo(44),
            reason: '$key is too small to hit at $surface',
          );
        }
      }
    });
  });

  group('NumberPad entry still works once constrained', () {
    testWidgets('digits append and backspace removes the last one', (
      tester,
    ) async {
      final controller = await _pump(tester, surface: desktop);

      for (final key in ['1', '2', '8']) {
        await tester.tap(find.byKey(Key('number_pad_$key')));
      }
      await tester.pump();
      expect(
        controller.text,
        '128',
        reason: 'no scrolling needed to reach any digit',
      );

      await tester.tap(find.byKey(const Key('number_pad_backspace')));
      await tester.pump();
      expect(controller.text, '12');
    });

    testWidgets('a second decimal point is refused', (tester) async {
      final controller = await _pump(tester, surface: desktop);

      await tester.tap(find.byKey(const Key('number_pad_1')));
      await tester.tap(find.byKey(const Key('number_pad_.')));
      await tester.tap(find.byKey(const Key('number_pad_5')));
      await tester.tap(find.byKey(const Key('number_pad_.')));
      await tester.pump();

      expect(controller.text, '1.5');
    });
  });
}
