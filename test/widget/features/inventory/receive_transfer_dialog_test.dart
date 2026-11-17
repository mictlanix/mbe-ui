import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 069 US3 (T021): receiving a transfer in whole or in part.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
  });

  setUp(() => h = InventoryHarness());

  // P1 has 3 outstanding of 8 (5 already received), P2 has 3 of 3, P3 is
  // complete and is not offered.
  final inTransit = aTransfer(
    serial: 77,
    status: InventoryTransferStatus.inTransit,
    lines: [
      aTransferLine(quantity: '8', received: '5', outstanding: '3'),
      aTransferLine(id: 901, productId: 8, quantity: '3', outstanding: '3'),
      aTransferLine(id: 902, productId: 9, quantity: '2', received: '2'),
    ],
  );

  final received = aTransfer(
    serial: 77,
    status: InventoryTransferStatus.received,
    lines: [aTransferLine(quantity: '8', received: '8')],
  );

  Future<void> open(WidgetTester tester, {InventoryTransfer? transfer}) async {
    await h.pumpTransfer(tester, transfer ?? inTransit);
    await tester.tap(key('inventory_transfer_receive'));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, int lineId, String text) async {
    await tester.enterText(
      key('inventory_transfer_receive_field_$lineId'),
      text,
    );
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(key('inventory_transfer_receive_submit'));
    await tester.pumpAndSettle();
  }

  bool submitEnabled(WidgetTester tester) => tester
      .widget<ButtonStyleButton>(key('inventory_transfer_receive_submit'))
      .enabled;

  Map<int, Decimal> sentLines() =>
      verify(
            () => h.transfers.receive(412, lines: captureAny(named: 'lines')),
          ).captured.single
          as Map<int, Decimal>;

  group('the dialog', () {
    testWidgets('lists only lines with something outstanding, each prefilled '
        'with its outstanding quantity', (tester) async {
      await open(tester);

      expect(
        find.text(l10n.inventoryTransferReceiveTitle('77')),
        findsOneWidget,
      );
      expect(key('inventory_transfer_receive_field_900'), findsOneWidget);
      expect(key('inventory_transfer_receive_field_901'), findsOneWidget);
      expect(key('inventory_transfer_receive_field_902'), findsNothing);
      expect(
        tester
            .widget<TextField>(key('inventory_transfer_receive_field_900'))
            .controller!
            .text,
        '3',
      );
      expect(find.text(l10n.inventoryTransferReceiveHint), findsOneWidget);
      expect(submitEnabled(tester), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unchanged submit receives everything with no lines', (
      tester,
    ) async {
      when(
        () => h.transfers.receive(412, lines: any(named: 'lines')),
      ).thenAnswer((_) async => received);
      await open(tester);

      await submit(tester);

      verify(() => h.transfers.receive(412, lines: null)).called(1);
      expect(key('inventory_transfer_receive_dialog'), findsNothing);
      expect(key('inventory_transfer_status_chip'), findsOneWidget);
      expect(
        find.descendant(
          of: key('inventory_transfer_status_chip'),
          matching: find.text(l10n.inventoryTransferStatusReceived),
        ),
        findsOneWidget,
      );
      expect(key('inventory_transfer_receive'), findsNothing);
    });

    testWidgets('lowering one row sends every row above 0, the untouched one '
        'at its prefilled quantity', (tester) async {
      when(
        () => h.transfers.receive(412, lines: any(named: 'lines')),
      ).thenAnswer((_) async => inTransit);
      await open(tester);

      await type(tester, 900, '2');
      await submit(tester);

      expect(sentLines(), {900: Decimal.parse('2'), 901: Decimal.parse('3')});
    });

    testWidgets('a row at 0 is left out', (tester) async {
      when(
        () => h.transfers.receive(412, lines: any(named: 'lines')),
      ).thenAnswer((_) async => inTransit);
      await open(tester);

      await type(tester, 900, '0');
      await submit(tester);

      expect(sentLines(), {901: Decimal.parse('3')});
    });

    testWidgets('a fractional quantity parses', (tester) async {
      when(
        () => h.transfers.receive(412, lines: any(named: 'lines')),
      ).thenAnswer((_) async => inTransit);
      await open(tester);

      await type(tester, 900, '2.5');
      await submit(tester);

      expect(sentLines()[900], Decimal.parse('2.5'));
    });

    testWidgets('every row at 0 disables Recibir', (tester) async {
      await open(tester);

      await type(tester, 900, '0');
      await type(tester, 901, '0');

      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('a quantity above Pendiente shows "Máximo n" and disables '
        'Recibir', (tester) async {
      await open(tester);

      await type(tester, 900, '4');

      expect(
        find.text('A-100 · ${l10n.inventoryTransferReceiveMax('3')}'),
        findsOneWidget,
      );
      expect(submitEnabled(tester), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty or negative quantity shows a field error and '
        'disables Recibir', (tester) async {
      await open(tester);

      await type(tester, 900, '');
      expect(submitEnabled(tester), isFalse);
      await type(tester, 900, '-1');
      expect(submitEnabled(tester), isFalse);
      expect(
        find.text('A-100 · ${l10n.inventoryTransferReceiveInvalid}'),
        findsOneWidget,
      );
    });

    testWidgets('over_received closes the dialog and leaves the Spanish '
        'message in the detail banner with the transfer reloaded', (
      tester,
    ) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryTransferPeriodOverReceived,
        'inventory_transfer.over_received',
        {'product_code': 'A-100', 'received': '5', 'outstanding': '3'},
      );
      when(
        () => h.transfers.receive(412, lines: any(named: 'lines')),
      ).thenAnswer((_) async => throw refusal);
      await open(tester);

      await submit(tester);

      expect(key('inventory_transfer_receive_dialog'), findsNothing);
      expect(
        find.text(
          refusal.localizedMessage(l10n, h.container.read(formattersProvider))!,
        ),
        findsOneWidget,
      );
      expect(find.text('SERVER TEXT'), findsNothing);
      verify(() => h.transfers.get(412)).called(2);
    });

    testWidgets('lock.busy stays in the dialog', (tester) async {
      final refusal = aRefusal(api.ErrorCode.lockPeriodBusy, 'lock.busy', {
        'retry_after': 1,
      });
      when(
        () => h.transfers.receive(412, lines: any(named: 'lines')),
      ).thenAnswer((_) async => throw refusal);
      await open(tester);

      await submit(tester);

      expect(key('inventory_transfer_receive_dialog'), findsOneWidget);
      expect(key('inventory_transfer_dialog_refusal'), findsOneWidget);
    });
  });

  group('Recibir on the detail screen', () {
    testWidgets('shows only in transit with update on 17, last in the '
        'action area', (tester) async {
      await h.pumpTransfer(tester, inTransit);

      expect(key('inventory_transfer_receive'), findsOneWidget);
      final actions = tester.widgetList<Widget>(
        find.descendant(
          of: key('inventory_transfer_actions'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(actions, isNotEmpty);
      final receive = tester.getTopLeft(key('inventory_transfer_receive'));
      for (final button
          in find
              .descendant(
                of: key('inventory_transfer_actions'),
                matching: find.byType(OutlinedButton),
              )
              .evaluate()) {
        expect(
          tester.getTopLeft(find.byWidget(button.widget)).dx,
          lessThan(receive.dx),
        );
      }
    });

    testWidgets('is absent without update on 17', (tester) async {
      await h.pumpTransfer(
        tester,
        inTransit,
        who: InventoryHarness.transferUser(transfers: 2),
      );

      expect(key('inventory_transfer_receive'), findsNothing);
    });

    for (final other in [
      aTransfer(),
      received,
      aTransfer(serial: 77, status: InventoryTransferStatus.cancelled),
    ]) {
      testWidgets('is absent on a ${other.status.name} transfer', (
        tester,
      ) async {
        await h.pumpTransfer(tester, other);

        expect(key('inventory_transfer_receive'), findsNothing);
      });
    }

    testWidgets('an in-transit transfer shows Enviado, Recibido and '
        'Pendiente per line', (tester) async {
      await h.pumpTransfer(tester, inTransit);

      expect(
        tester.widget<Text>(key('inventory_transfer_line_sent_900')).data,
        '8',
      );
      expect(
        tester.widget<Text>(key('inventory_transfer_line_received_900')).data,
        '5',
      );
      expect(
        tester
            .widget<Text>(key('inventory_transfer_line_outstanding_900'))
            .data,
        '3',
      );
    });

    testWidgets('a received transfer shows Pendiente 0', (tester) async {
      await h.pumpTransfer(tester, received);

      expect(
        tester
            .widget<Text>(key('inventory_transfer_line_outstanding_900'))
            .data,
        '0',
      );
    });
  });
}
