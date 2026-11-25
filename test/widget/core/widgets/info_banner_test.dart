import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/widgets/info_banner.dart';

void main() {
  testWidgets('renders the message beside an info icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(body: InfoBanner(message: 'Live, not final')),
      ),
    );

    expect(find.text('Live, not final'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });
}
