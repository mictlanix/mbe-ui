import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/fact_strip_row.dart';

/// Spec 049 FR-016–FR-019 / C4: the facts take the width the trailing control
/// doesn't need, the control sits on the trailing edge, and nothing overflows
/// at a phone width or a large text scale.
void main() {
  const trailingKey = Key('trailing');

  Future<void> pumpRow(
    WidgetTester tester, {
    required double width,
    double textScale = 1,
    String trailingLabel = 'Más detalles',
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.of(const BrandConfig(displayName: 'Test')).light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Theme(
            data: DesignTheme.forTier(
              Theme.of(context),
              LayoutBreakpoints.tierOfContext(context),
            ),
            child: child!,
          ),
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FactStripRow(
              facts: [
                for (final label in [
                  'Ref 2225',
                  'Estado Ok',
                  'Fecha 09-28',
                  'Vence 09-28',
                  'Moneda MXN',
                ])
                  Text(label, key: Key(label)),
              ],
              trailing: TextButton(
                key: trailingKey,
                onPressed: () {},
                child: Text(trailingLabel),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // The test font draws every glyph as a full-width square, so the labels
  // are kept short to stand for realistic widths.
  testWidgets('at desktop width every fact shares one line and the control '
      'is on the trailing edge', (tester) async {
    await pumpRow(tester, width: 1440);

    final tops = {
      for (final label in [
        'Ref 2225',
        'Estado Ok',
        'Fecha 09-28',
        'Vence 09-28',
        'Moneda MXN',
      ])
        tester.getTopLeft(find.byKey(Key(label))).dy,
    };
    expect(tops, hasLength(1));
    // The scaffold padding is 16 on each side.
    expect(tester.getRect(find.byKey(trailingKey)).right, 1440 - 16);
    expect(tester.takeException(), isNull);
  });

  testWidgets('at 390 px with a large text scale nothing overflows and the '
      'control stays on screen', (tester) async {
    for (final label in ['Más detalles', 'Menos detalles']) {
      await pumpRow(tester, width: 390, textScale: 2, trailingLabel: label);

      expect(tester.takeException(), isNull);
      final rect = tester.getRect(find.byKey(trailingKey));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
    }
  });

  testWidgets('the facts wrap onto more lines before the control gives up '
      'width', (tester) async {
    await pumpRow(tester, width: 360);

    final tops = {
      for (final label in ['Ref 2225', 'Moneda MXN'])
        tester.getTopLeft(find.byKey(Key(label))).dy,
    };
    expect(tops.length, greaterThan(1));
    expect(tester.takeException(), isNull);
  });
}
