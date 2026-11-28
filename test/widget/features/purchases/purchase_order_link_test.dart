import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_link.dart';

import 'purchases_harness.dart';

/// Spec 080 US3 (T025, FR-030): the order number other screens show.
void main() {
  Future<GoRouter> pumpLink(WidgetTester tester, User who) async {
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (_, _) =>
              const Scaffold(body: PurchaseOrderLink(orderId: 5531)),
        ),
        GoRoute(
          path: '/purchases/orders/:orderId',
          builder: (_, s) => Scaffold(
            body: Text(
              'order ${s.pathParameters['orderId']}',
              key: const Key('order_stand_in'),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(token: 't', user: who),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('with read on 20 it is a link that pushes the order', (
    tester,
  ) async {
    final router = await pumpLink(
      tester,
      PurchasesHarness.user(requestRights: 0, orderRights: 2),
    );

    expect(key('purchase_order_link_5531'), findsOneWidget);
    expect(find.text('5531'), findsOneWidget);
    await tester.tap(key('purchase_order_link_5531'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/purchases/orders/5531');
    expect(find.text('order 5531'), findsOneWidget);
    // Pushed, so Back returns to the screen that showed the number.
    expect(router.canPop(), isTrue);
  });

  testWidgets('without read on 20 it is plain text', (tester) async {
    await pumpLink(tester, PurchasesHarness.user(requestRights: 2));

    expect(key('purchase_order_link_5531'), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(tester.widget<RecordIdText>(find.byType(RecordIdText)).text, '5531');
  });
}
