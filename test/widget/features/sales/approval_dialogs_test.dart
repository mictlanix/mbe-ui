import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/approval_dialogs.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/approval_target.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Records each write and answers [outcome], optionally after [gate].
class _FakeActions extends DeliveryOrderActions {
  _FakeActions({this.outcome, this.gate});

  /// The answer, or the success a delivery's approval gives when `null`.
  ApprovalOutcome? outcome;
  Completer<void>? gate;
  final calls = <String>[];

  @override
  Future<ApprovalOutcome> approve(int id) async {
    calls.add('approve $id');
    await gate?.future;
    return outcome ?? (error: null, status: DeliveryOrderStatus.inPreparation);
  }

  @override
  Future<ApprovalOutcome> reject(int id, {required String reason}) async {
    calls.add('reject $id $reason');
    await gate?.future;
    return outcome ?? (error: null, status: DeliveryOrderStatus.draft);
  }
}

const _delivery = ApprovalTarget(
  id: 31,
  serial: 1541,
  customerId: 7,
  type: FulfillmentType.delivery,
  date: null,
);

final _pickup = ApprovalTarget(
  id: 32,
  serial: 1536,
  customerId: 7,
  type: FulfillmentType.counterPickup,
  date: DateTime(2026, 11, 15),
);

const _notPending = AppError.server(
  statusCode: 409,
  problem: ApiProblem(
    codeName: 'delivery_order.not_pending_approval',
    code: api.ErrorCode.deliveryOrderPeriodNotPendingApproval,
  ),
);

/// Spec 062 T016, contracts C3: the approve dialog on its own.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  /// Pumps a button that opens [open]; its answer lands in the returned list.
  Future<List<DeliveryOrderStatus?>> pumpOpener(
    WidgetTester tester, {
    required Future<DeliveryOrderStatus?> Function(BuildContext context) open,
    required _FakeActions actions,
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final results = <DeliveryOrderStatus?>[];
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          deliveryOrderActionsProvider.overrideWith(() => actions),
          customerDisplayNameProvider.overrideWith(
            (ref, id) async => 'Ferretería López',
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => results.add(await open(context)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  Finder key(String k) => find.byKey(Key(k));

  group('approve', () {
    testWidgets('names the customer, type and date and says where a delivery '
        'goes next', (tester) async {
      await pumpOpener(
        tester,
        actions: _FakeActions(),
        open: (context) => showApproveDeliveryOrderDialog(
          context,
          ApprovalTarget(
            id: 31,
            serial: 1541,
            customerId: 7,
            type: FulfillmentType.delivery,
            date: DateTime(2026, 11, 16),
          ),
        ),
      );

      expect(find.text(l10n.deliveryOrderApproveTitle('1541')), findsOneWidget);
      expect(find.text('Ferretería López'), findsOneWidget);
      expect(find.text('Entrega'), findsOneWidget);
      expect(find.text('2026-11-16'), findsOneWidget);
      expect(find.text(l10n.deliveryOrderApproveNextDelivery), findsOneWidget);
      expect(find.text(l10n.deliveryOrderApproveNextPickup), findsNothing);
    });

    testWidgets('says where a pickup goes next', (tester) async {
      await pumpOpener(
        tester,
        actions: _FakeActions(),
        open: (context) => showApproveDeliveryOrderDialog(context, _pickup),
      );

      expect(find.text('Recoge en tienda'), findsOneWidget);
      expect(find.text(l10n.deliveryOrderApproveNextPickup), findsOneWidget);
      expect(find.text(l10n.deliveryOrderApproveNextDelivery), findsNothing);
    });

    testWidgets('approving writes once and answers the status the server '
        'returned', (tester) async {
      final actions = _FakeActions(
        outcome: (error: null, status: DeliveryOrderStatus.approved),
      );
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showApproveDeliveryOrderDialog(context, _pickup),
      );

      await tester.tap(key('delivery_order_approve_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['approve 32']);
      expect(results.single, DeliveryOrderStatus.approved);
      expect(key('delivery_order_approve_dialog'), findsNothing);
    });

    testWidgets('a second tap while the write is in flight sends nothing '
        'more, and the dialog cannot be dismissed', (tester) async {
      final gate = Completer<void>();
      final actions = _FakeActions(gate: gate);
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showApproveDeliveryOrderDialog(context, _delivery),
      );

      await tester.tap(key('delivery_order_approve_submit'));
      await tester.pump();
      await tester.tap(
        key('delivery_order_approve_submit'),
        warnIfMissed: false,
      );
      await tester.pump();
      // The back button is disabled while busy.
      await tester.tap(
        find.text(l10n.deliveryOrderBackButton),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(actions.calls, ['approve 31']);
      expect(key('delivery_order_approve_dialog'), findsOneWidget);
      expect(results, isEmpty);

      gate.complete();
      await tester.pumpAndSettle();
      expect(results.single, DeliveryOrderStatus.inPreparation);
    });

    testWidgets('a refusal stays in the dialog with its message, and the '
        'primary button becomes "Cerrar"', (tester) async {
      final actions = _FakeActions(outcome: (error: _notPending, status: null));
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showApproveDeliveryOrderDialog(context, _delivery),
      );

      await tester.tap(key('delivery_order_approve_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_approve_dialog'), findsOneWidget);
      expect(key('delivery_order_refusal'), findsOneWidget);
      expect(
        find.text(l10n.apiErrorDeliveryOrderNotPendingApproval),
        findsOneWidget,
      );
      expect(key('delivery_order_approve_submit'), findsNothing);
      expect(find.text(l10n.deliveryOrderBackButton), findsNothing);

      await tester.tap(key('delivery_order_approve_close'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_approve_dialog'), findsNothing);
      expect(results.single, isNull);
      expect(actions.calls, ['approve 31'], reason: 'closing writes nothing');
    });

    testWidgets('a lost connection says the result is unknown, not that it '
        'failed', (tester) async {
      final actions = _FakeActions(
        outcome: (error: const AppError.network(), status: null),
      );
      await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showApproveDeliveryOrderDialog(context, _delivery),
      );

      await tester.tap(key('delivery_order_approve_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_action_unknown'), findsOneWidget);
      expect(find.text(l10n.deliveryOrderActionUnknown), findsOneWidget);
      expect(key('delivery_order_refusal'), findsNothing);
      expect(key('delivery_order_approve_close'), findsOneWidget);
    });

    testWidgets('backing out writes nothing and answers null', (tester) async {
      final actions = _FakeActions();
      final results = await pumpOpener(
        tester,
        actions: actions,
        open: (context) => showApproveDeliveryOrderDialog(context, _delivery),
      );

      await tester.tap(find.text(l10n.deliveryOrderBackButton));
      await tester.pumpAndSettle();

      expect(actions.calls, isEmpty);
      expect(results.single, isNull);
    });
  });

  group('reject', () {
    FilledButton submit(WidgetTester tester) =>
        tester.widget<FilledButton>(key('delivery_order_reject_submit'));

    Future<List<DeliveryOrderStatus?>> open(
      WidgetTester tester,
      _FakeActions actions,
    ) => pumpOpener(
      tester,
      actions: actions,
      open: (context) => showRejectDeliveryOrderDialog(context, _pickup),
    );

    testWidgets('names the folio, customer and date, and says the order goes '
        'back to its author', (tester) async {
      await open(tester, _FakeActions());

      expect(find.text(l10n.deliveryOrderRejectTitle('1536')), findsOneWidget);
      expect(
        tester.widget<Text>(key('delivery_order_reject_summary')).data,
        l10n.deliveryOrderRejectSummary('Ferretería López', '2026-11-15'),
      );
      expect(find.text(l10n.deliveryOrderRejectNote), findsOneWidget);
    });

    testWidgets('"Rechazar" is disabled for an empty or whitespace reason, and '
        'enabled once there is text', (tester) async {
      await open(tester, _FakeActions());

      expect(submit(tester).onPressed, isNull);
      await tester.enterText(key('delivery_order_reject_reason'), '   ');
      await tester.pump();
      expect(submit(tester).onPressed, isNull);
      await tester.enterText(key('delivery_order_reject_reason'), 'Dirección');
      await tester.pump();
      expect(submit(tester).onPressed, isNotNull);
    });

    testWidgets('the reason takes at most 500 characters, with a counter', (
      tester,
    ) async {
      await open(tester, _FakeActions());

      await tester.enterText(key('delivery_order_reject_reason'), 'x' * 600);
      await tester.pump();

      final field = tester.widget<TextField>(
        key('delivery_order_reject_reason'),
      );
      expect(field.maxLength, 500);
      expect(field.controller!.text.length, 500);
      expect(find.text('500/500'), findsOneWidget);
    });

    testWidgets('a valid reason is sent trimmed, and the dialog answers the '
        'draft status', (tester) async {
      final actions = _FakeActions();
      final results = await open(tester, actions);

      await tester.enterText(
        key('delivery_order_reject_reason'),
        '  Dirección equivocada  ',
      );
      await tester.pump();
      await tester.tap(key('delivery_order_reject_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, ['reject 32 Dirección equivocada']);
      expect(results.single, DeliveryOrderStatus.draft);
      expect(key('delivery_order_reject_dialog'), findsNothing);
    });

    testWidgets('a not_pending_approval refusal stays in the dialog, locks the '
        'reason and offers "Cerrar"', (tester) async {
      final actions = _FakeActions(outcome: (error: _notPending, status: null));
      final results = await open(tester, actions);

      await tester.enterText(key('delivery_order_reject_reason'), 'x');
      await tester.pump();
      await tester.tap(key('delivery_order_reject_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.apiErrorDeliveryOrderNotPendingApproval),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(key('delivery_order_reject_reason')).enabled,
        isFalse,
      );
      expect(key('delivery_order_reject_submit'), findsNothing);

      await tester.tap(key('delivery_order_reject_close'));
      await tester.pumpAndSettle();

      expect(results.single, isNull);
      expect(actions.calls, hasLength(1), reason: 'closing writes nothing');
    });

    testWidgets('a lost connection says the result is unknown', (tester) async {
      await open(
        tester,
        _FakeActions(outcome: (error: const AppError.network(), status: null)),
      );

      await tester.enterText(key('delivery_order_reject_reason'), 'x');
      await tester.pump();
      await tester.tap(key('delivery_order_reject_submit'));
      await tester.pumpAndSettle();

      expect(key('delivery_order_action_unknown'), findsOneWidget);
      expect(key('delivery_order_refusal'), findsNothing);
    });

    testWidgets('backing out writes nothing and answers null', (tester) async {
      final actions = _FakeActions();
      final results = await open(tester, actions);

      await tester.enterText(key('delivery_order_reject_reason'), 'x');
      await tester.pump();
      await tester.tap(find.text(l10n.deliveryOrderBackButton));
      await tester.pumpAndSettle();

      expect(actions.calls, isEmpty);
      expect(results.single, isNull);
    });
  });
}
