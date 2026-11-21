import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/layout/breakpoints.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    final base = AppTheme.of(const BrandConfig(displayName: 'X')).light;
    await tester.pumpWidget(
      MaterialApp(
        theme: base,
        builder: (context, child) => Theme(
          data: DesignTheme.forTier(Theme.of(context), LayoutTier.expanded),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('renders its text in the mono recordId role', (tester) async {
    await pump(tester, const RecordIdText('SABE5513950918'));
    final style = tester.widget<Text>(find.text('SABE5513950918')).style!;
    expect(style.fontFamily, TypeRoles.monoFamily);
    expect(style.fontSize, 14);
  });

  testWidgets('a color override keeps the mono family', (tester) async {
    await pump(
      tester,
      const RecordIdText('00337298', color: Color(0xFF123456)),
    );
    final style = tester.widget<Text>(find.text('00337298')).style!;
    expect(style.fontFamily, TypeRoles.monoFamily);
    expect(style.color, const Color(0xFF123456));
  });

  testWidgets('forwards alignment, maxLines and overflow', (tester) async {
    await pump(
      tester,
      const RecordIdText(
        '00337298',
        textAlign: TextAlign.end,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final text = tester.widget<Text>(find.text('00337298'));
    expect(text.textAlign, TextAlign.end);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('inherit keeps the surrounding size and only goes mono', (
    tester,
  ) async {
    await pump(
      tester,
      const DefaultTextStyle(
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        child: RecordIdText.inherit('Pago 12'),
      ),
    );
    final style = tester.widget<Text>(find.text('Pago 12')).style!;
    expect(style.fontFamily, TypeRoles.monoFamily);
    expect(style.fontSize, 22);
    expect(style.fontWeight, FontWeight.w600);
  });
}
