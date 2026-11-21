import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/app/theme/app_theme.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/widgets/inline_error_text.dart';

void main() {
  final theme = AppTheme.of(const BrandConfig(displayName: 'X')).light;

  Future<void> pump(WidgetTester tester, Widget child, {double? width}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(width: width, child: child),
          ),
        ),
      );

  testWidgets('shows an error icon and the message in the error color', (
    tester,
  ) async {
    await pump(tester, const InlineErrorText('El RFC debe tener 12 o 13'));
    final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    final text = tester.widget<Text>(find.text('El RFC debe tener 12 o 13'));
    expect(icon.color, theme.colorScheme.error);
    expect(text.style!.color, theme.colorScheme.error);
  });

  testWidgets('a style override keeps the error color', (tester) async {
    await pump(
      tester,
      const InlineErrorText('x', style: TextStyle(fontSize: 20)),
    );
    final text = tester.widget<Text>(find.text('x'));
    expect(text.style!.fontSize, 20);
    expect(text.style!.color, theme.colorScheme.error);
  });

  testWidgets('wraps a long message instead of overflowing', (tester) async {
    await pump(
      tester,
      InlineErrorText('mensaje de error muy largo ' * 12),
      width: 200,
    );
    expect(tester.takeException(), isNull);
  });
}
