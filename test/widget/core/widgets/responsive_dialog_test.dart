import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/responsive_dialog.dart';

import '../../../golden/golden_harness.dart';

const _closeKey = Key('responsive_dialog_close');
const _primaryKey = Key('primary');
const _secondaryKey = Key('secondary');

/// A spinner animates forever, so `pumpAndSettle` would time out while busy.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Pumps a page with an "Open" button that shows a [ResponsiveDialog] through
/// [showResponsiveDialog], then opens it, so the real route and barrier
/// behaviour is exercised.
Future<void> _open(
  WidgetTester tester, {
  required double width,
  bool dismissible = true,
  bool busy = false,
  VoidCallback? onPrimary,
  bool withSecondary = true,
}) async {
  await pumpGoldenScenario(
    tester,
    Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showResponsiveDialog<void>(
          context,
          builder: (_) => ResponsiveDialog(
            title: 'Send quote',
            body: const Text('Dialog body'),
            dismissible: dismissible,
            primaryAction: ResponsiveDialogAction(
              key: _primaryKey,
              label: 'Send',
              busy: busy,
              onPressed: onPrimary,
            ),
            secondaryAction: withSecondary
                ? ResponsiveDialogAction(
                    key: _secondaryKey,
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
          ),
        ),
        child: const Text('Open'),
      ),
    ),
    brightness: Brightness.light,
    width: width,
  );
  await tester.tap(find.text('Open'));
  await _settle(tester);
}

bool Function() _isOpen(WidgetTester tester) =>
    () => find.byType(ResponsiveDialog).evaluate().isNotEmpty;

void main() {
  setUpAll(loadGoldenFonts);

  group('wide surface', () {
    testWidgets('renders a plain Dialog with title, body and action row', (
      tester,
    ) async {
      await _open(tester, width: 1024, onPrimary: () {});

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.insetPadding, isNot(EdgeInsets.zero));
      expect(find.byKey(const Key('responsive_dialog_title')), findsOneWidget);
      expect(find.text('Send quote'), findsOneWidget);
      expect(find.text('Dialog body'), findsOneWidget);
      expect(find.byKey(_closeKey), findsNothing);

      final secondary = tester.getTopLeft(find.byKey(_secondaryKey));
      final primary = tester.getTopLeft(find.byKey(_primaryKey));
      expect(secondary.dx, lessThan(primary.dx));
      expect(secondary.dy, primary.dy);
    });
  });

  group('compact surface', () {
    testWidgets('renders full screen with the primary action in the top bar', (
      tester,
    ) async {
      await _open(tester, width: 500, onPrimary: () {});

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.insetPadding, EdgeInsets.zero);
      expect(tester.getSize(find.byType(Dialog)), const Size(500, 900));

      final close = tester.getCenter(find.byKey(_closeKey));
      final title = tester.getCenter(find.text('Send quote'));
      final primary = tester.getCenter(find.byKey(_primaryKey));
      expect(close.dx, lessThan(title.dx));
      expect(title.dx, lessThan(primary.dx));
      // All three share the top bar, well above the body's bottom.
      expect(primary.dy, lessThan(100));
      expect(close.dy, primary.dy);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byKey(_secondaryKey), findsNothing);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Dialog body'), findsOneWidget);
    });

    testWidgets('the close control closes the dialog', (tester) async {
      await _open(tester, width: 500, onPrimary: () {});

      await tester.tap(find.byKey(_closeKey));
      await _settle(tester);

      expect(_isOpen(tester)(), isFalse);
    });
  });

  group('primary action', () {
    for (final width in [1024.0, 500.0]) {
      final label = width > 600 ? 'wide' : 'compact';

      testWidgets('busy shows a spinner and disables it ($label)', (
        tester,
      ) async {
        var pressed = 0;
        await _open(
          tester,
          width: width,
          busy: true,
          onPrimary: () => pressed++,
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Send'), findsOneWidget);
        final button = tester.widget<ButtonStyleButton>(
          find.byKey(_primaryKey),
        );
        expect(button.onPressed, isNull);
        await tester.tap(find.byKey(_primaryKey), warnIfMissed: false);
        expect(pressed, 0);
      });

      testWidgets('not busy shows no spinner and fires onPressed ($label)', (
        tester,
      ) async {
        var pressed = 0;
        await _open(tester, width: width, onPrimary: () => pressed++);

        expect(find.byType(CircularProgressIndicator), findsNothing);
        await tester.tap(find.byKey(_primaryKey));
        expect(pressed, 1);
      });

      testWidgets('a null onPressed disables it ($label)', (tester) async {
        await _open(tester, width: width);

        final button = tester.widget<ButtonStyleButton>(
          find.byKey(_primaryKey),
        );
        expect(button.onPressed, isNull);
      });
    }
  });

  group('dismissible: false', () {
    for (final width in [1024.0, 500.0]) {
      final label = width > 600 ? 'wide' : 'compact';

      testWidgets('Escape, back and the barrier do not pop ($label)', (
        tester,
      ) async {
        await _open(tester, width: width, dismissible: false, busy: true);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await _settle(tester);
        expect(_isOpen(tester)(), isTrue, reason: 'Escape');

        await tester.binding.handlePopRoute();
        await _settle(tester);
        expect(_isOpen(tester)(), isTrue, reason: 'back');

        await tester.tapAt(const Offset(2, 2));
        await _settle(tester);
        expect(_isOpen(tester)(), isTrue, reason: 'barrier');
      });
    }

    testWidgets('disables the compact close control', (tester) async {
      await _open(tester, width: 500, dismissible: false, busy: true);

      final close = tester.widget<IconButton>(find.byKey(_closeKey));
      expect(close.onPressed, isNull);
    });

    testWidgets('disables the wide secondary action', (tester) async {
      await _open(tester, width: 1024, dismissible: false, busy: true);

      final secondary = tester.widget<ButtonStyleButton>(
        find.byKey(_secondaryKey),
      );
      expect(secondary.onPressed, isNull);
      await tester.tap(find.byKey(_secondaryKey), warnIfMissed: false);
      await _settle(tester);
      expect(_isOpen(tester)(), isTrue);
    });
  });

  group('dismissible: true', () {
    for (final width in [1024.0, 500.0]) {
      final label = width > 600 ? 'wide' : 'compact';

      testWidgets('Escape closes it ($label)', (tester) async {
        await _open(tester, width: width, onPrimary: () {});

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await _settle(tester);

        expect(_isOpen(tester)(), isFalse);
      });

      testWidgets('back closes it ($label)', (tester) async {
        await _open(tester, width: width, onPrimary: () {});

        await tester.binding.handlePopRoute();
        await _settle(tester);

        expect(_isOpen(tester)(), isFalse);
      });
    }

    testWidgets('a tap on the barrier closes the wide dialog', (tester) async {
      await _open(tester, width: 1024, onPrimary: () {});

      await tester.tapAt(const Offset(2, 2));
      await _settle(tester);

      expect(_isOpen(tester)(), isFalse);
    });

    testWidgets('the wide secondary action closes it', (tester) async {
      await _open(tester, width: 1024, onPrimary: () {});

      await tester.tap(find.byKey(_secondaryKey));
      await _settle(tester);

      expect(_isOpen(tester)(), isFalse);
    });
  });
}
