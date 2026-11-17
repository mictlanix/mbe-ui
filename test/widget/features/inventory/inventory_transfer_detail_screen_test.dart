import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 069 US2 (T018): the transfer detail screen.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
  });

  setUp(() => h = InventoryHarness());

  final dispatched = aTransfer(
    serial: 77,
    status: InventoryTransferStatus.inTransit,
    lines: [aTransferLine(received: '3', outstanding: '5')],
  );

  String title(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(of: find.byType(AppBar), matching: find.byType(Text)),
      )
      .data!;

  /// The text the screen shows for [error]: its code, localized.
  String localized(AppError error) =>
      error.localizedMessage(l10n, h.container.read(formattersProvider))!;

  Future<void> dispatch(WidgetTester tester) async {
    await tester.tap(key('inventory_transfer_dispatch'));
    await tester.pumpAndSettle();
    await tester.tap(key('inventory_transfer_dispatch_submit'));
    await tester.pumpAndSettle();
  }

  group('a draft', () {
    testWidgets('is titled "Traspaso · Borrador #id" with no folio and shows '
        'its facts, the simple lines table and the actions', (tester) async {
      await h.pumpTransfer(tester, aTransfer(comment: 'Reposición'));

      expect(title(tester), l10n.inventoryTransferTitleDraft('412'));
      expect(key('inventory_transfer_status_chip'), findsOneWidget);
      expect(tester.widget<Text>(key('inventory_transfer_serial')).data, '—');
      expect(find.text('Almacén 3'), findsOneWidget);
      expect(find.text('Almacén 4'), findsOneWidget);
      expect(find.text('Sucursal 2'), findsOneWidget);
      expect(find.text('Reposición'), findsOneWidget);
      expect(find.text('Empleado 5'), findsNWidgets(2));
      expect(find.text('A-100'), findsOneWidget);
      expect(find.text(l10n.inventoryTransferLineColQuantity), findsOneWidget);
      expect(find.text(l10n.inventoryTransferLineColSent), findsNothing);
      expect(
        tester.widget<Text>(key('inventory_transfer_line_quantity_900')).data,
        '8',
      );
      expect(key('inventory_transfer_line_edit_900'), findsOneWidget);
      expect(key('inventory_transfer_line_remove_900'), findsOneWidget);
      expect(key('inventory_transfer_add_product'), findsOneWidget);
      expect(key('inventory_transfer_dispatch'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('with no lines says to add the products to transfer', (
      tester,
    ) async {
      await h.pumpTransfer(tester, aTransfer(lines: const []));

      expect(find.text(l10n.inventoryTransferLinesEmpty), findsOneWidget);
    });

    testWidgets('Agregar producto needs Products read', (tester) async {
      await h.pumpTransfer(
        tester,
        aTransfer(),
        who: InventoryHarness.transferUser(productsRead: false),
      );

      expect(key('inventory_transfer_add_product'), findsNothing);
      expect(key('inventory_transfer_dispatch'), findsOneWidget);
    });

    testWidgets('a read-only user sees no actions and no line icons', (
      tester,
    ) async {
      await h.pumpTransfer(
        tester,
        aTransfer(),
        who: InventoryHarness.transferUser(transfers: 2),
      );

      expect(key('inventory_transfer_actions'), findsNothing);
      expect(key('inventory_transfer_line_edit_900'), findsNothing);
      expect(key('inventory_transfer_line_remove_900'), findsNothing);
    });
  });

  testWidgets('a dispatched transfer shows its folio and the three-quantity '
      'table with no row icons or edit actions', (tester) async {
    await h.pumpTransfer(tester, dispatched);

    expect(title(tester), l10n.inventoryTransferTitle('77'));
    expect(tester.widget<Text>(key('inventory_transfer_serial')).data, '77');
    for (final header in [
      l10n.inventoryTransferLineColCode,
      l10n.inventoryTransferLineColProduct,
      l10n.inventoryTransferLineColSent,
      l10n.inventoryTransferLineColReceived,
      l10n.inventoryTransferLineColOutstanding,
    ]) {
      expect(find.text(header), findsOneWidget, reason: header);
    }
    expect(find.text(l10n.inventoryTransferLineColQuantity), findsNothing);
    expect(
      tester.widget<Text>(key('inventory_transfer_line_sent_900')).data,
      '8',
    );
    expect(
      tester.widget<Text>(key('inventory_transfer_line_received_900')).data,
      '3',
    );
    expect(
      tester.widget<Text>(key('inventory_transfer_line_outstanding_900')).data,
      '5',
    );
    expect(key('inventory_transfer_line_edit_900'), findsNothing);
    expect(key('inventory_transfer_line_remove_900'), findsNothing);
    expect(key('inventory_transfer_add_product'), findsNothing);
    expect(key('inventory_transfer_dispatch'), findsNothing);
  });

  group('dispatch', () {
    testWidgets('shows the folio and En tránsito, and is no longer editable', (
      tester,
    ) async {
      when(() => h.transfers.dispatch(412)).thenAnswer(
        (_) async => aTransfer(
          serial: 77,
          status: InventoryTransferStatus.inTransit,
          lines: [aTransferLine(outstanding: '8')],
        ),
      );
      await h.pumpTransfer(tester, aTransfer());

      await dispatch(tester);

      expect(title(tester), l10n.inventoryTransferTitle('77'));
      expect(find.text(l10n.inventoryTransferStatusInTransit), findsOneWidget);
      expect(key('inventory_transfer_dispatch'), findsNothing);
      expect(key('inventory_transfer_line_edit_900'), findsNothing);
      expect(key('inventory_transfer_refusal'), findsNothing);
    });

    testWidgets('insufficient_stock shows the Spanish message plus the '
        'product code and the warehouse named by the error, not the '
        'transfer\'s origin; the transfer stays a draft', (tester) async {
      // Warehouse 9 is neither the origin (3) nor the destination (4).
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodInsufficientStock,
        'inventory_document.insufficient_stock',
        {
          'product_id': 7,
          'warehouse_id': 9,
          'requested': '8',
          'available': '2',
        },
      );
      when(
        () => h.transfers.dispatch(412),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpTransfer(tester, aTransfer());

      await dispatch(tester);

      expect(find.text(localized(refusal)), findsOneWidget);
      expect(
        find.text(
          l10n.inventoryTransferRefusalProductWarehouse('A-100', 'Almacén 9'),
        ),
        findsOneWidget,
      );
      expect(find.text('Producto: A-100 · Almacén: Almacén 9'), findsOneWidget);
      expect(find.textContaining('Almacén: Almacén 3'), findsNothing);
      expect(find.text('SERVER TEXT'), findsNothing);
      expect(title(tester), l10n.inventoryTransferTitleDraft('412'));
      expect(find.text(l10n.inventoryTransferStatusDraft), findsOneWidget);
      expect(key('inventory_transfer_dispatch'), findsOneWidget);
    });

    testWidgets('a product or warehouse the lookup can\'t resolve falls back '
        'to "#id"', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodInsufficientStock,
        'inventory_document.insufficient_stock',
        {
          'product_id': 99,
          'warehouse_id': 9,
          'requested': '8',
          'available': '2',
        },
      );
      when(
        () => h.transfers.dispatch(412),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpTransfer(tester, aTransfer());

      await dispatch(tester);

      expect(find.text('Producto: #99 · Almacén: Almacén 9'), findsOneWidget);
    });

    testWidgets('no_lines shows "El traspaso no tiene partidas."', (
      tester,
    ) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodNoLines,
        'inventory_document.no_lines',
        {'resource': 'inventory_transfer'},
      );
      when(
        () => h.transfers.dispatch(412),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpTransfer(tester, aTransfer(lines: const []));

      await dispatch(tester);

      expect(find.text('El traspaso no tiene partidas.'), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });

    for (final (code, name, params) in [
      (
        api.ErrorCode.facilityPeriodNoInTransitLocation,
        'facility.no_in_transit_location',
        <String, Object?>{'facility_id': 2},
      ),
      (
        api.ErrorCode.facilityPeriodOtherFacility,
        'facility.other_facility',
        <String, Object?>{'resource': 'inventory_transfer'},
      ),
    ]) {
      testWidgets('$name shows in Spanish', (tester) async {
        final refusal = aRefusal(code, name, params);
        when(
          () => h.transfers.dispatch(412),
        ).thenAnswer((_) async => throw refusal);
        await h.pumpTransfer(tester, aTransfer());

        await dispatch(tester);

        expect(key('inventory_transfer_refusal'), findsOneWidget);
        expect(find.text(localized(refusal)), findsOneWidget);
        expect(find.text('SERVER TEXT'), findsNothing);
      });
    }

    testWidgets('the refusal clears on the next action', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodNoLines,
        'inventory_document.no_lines',
        {'resource': 'inventory_transfer'},
      );
      when(
        () => h.transfers.dispatch(412),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpTransfer(tester, aTransfer());
      await dispatch(tester);
      expect(key('inventory_transfer_refusal'), findsOneWidget);

      await tester.tap(key('inventory_transfer_dispatch'));
      await tester.pumpAndSettle();

      expect(key('inventory_transfer_refusal'), findsNothing);
    });

    testWidgets('lock.busy shows its message and re-fetches the transfer', (
      tester,
    ) async {
      final refusal = aRefusal(api.ErrorCode.lockPeriodBusy, 'lock.busy', {
        'resource': 'inventory_transfer',
      });
      when(
        () => h.transfers.dispatch(412),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpTransfer(tester, aTransfer());
      // Someone else dispatched it meanwhile: the re-fetch shows that.
      h.stubTransfer(dispatched);

      await dispatch(tester);

      expect(find.text(localized(refusal)), findsOneWidget);
      verify(() => h.transfers.get(412)).called(2);
      expect(title(tester), l10n.inventoryTransferTitle('77'));
    });
  });

  // The two lines of an in-transit transfer: 3 and 0 outstanding.
  final partial = aTransfer(
    serial: 77,
    status: InventoryTransferStatus.inTransit,
    lines: [
      aTransferLine(quantity: '8', received: '5', outstanding: '3'),
      aTransferLine(id: 901, productId: 8, quantity: '2', received: '2'),
    ],
  );
  final receivedTransfer = aTransfer(
    serial: 77,
    status: InventoryTransferStatus.received,
    lines: [aTransferLine(quantity: '8', received: '8')],
  );
  final cancelled = aTransfer(
    serial: 77,
    status: InventoryTransferStatus.cancelled,
    lines: [aTransferLine(quantity: '8', received: '5')],
  );

  Future<void> tapAndSubmit(
    WidgetTester tester,
    String button,
    String submit,
  ) async {
    await tester.tap(key(button));
    await tester.pumpAndSettle();
    await tester.tap(key(submit));
    await tester.pumpAndSettle();
  }

  group('close (Cerrar pendiente)', () {
    testWidgets('the prompt counts the lines still outstanding and names the '
        'origin', (tester) async {
      await h.pumpTransfer(tester, partial);

      await tester.tap(key('inventory_transfer_close'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.inventoryTransferCloseBody(1, 'Almacén 3')),
        findsOneWidget,
      );
    });

    testWidgets('closing shows Recibido, keeps the received figure and shows '
        'Pendiente 0', (tester) async {
      when(() => h.transfers.close(412)).thenAnswer(
        (_) async => aTransfer(
          serial: 77,
          status: InventoryTransferStatus.received,
          lines: [aTransferLine(quantity: '8', received: '5')],
        ),
      );
      await h.pumpTransfer(tester, partial);

      await tapAndSubmit(
        tester,
        'inventory_transfer_close',
        'inventory_transfer_close_submit',
      );

      expect(
        tester.widget<Text>(key('inventory_transfer_line_received_900')).data,
        '5',
      );
      expect(
        tester
            .widget<Text>(key('inventory_transfer_line_outstanding_900'))
            .data,
        '0',
      );
      expect(key('inventory_transfer_close'), findsNothing);
      expect(key('inventory_transfer_refusal'), findsNothing);
    });

    testWidgets('is present with delete on 17, in transit only', (
      tester,
    ) async {
      await h.pumpTransfer(tester, partial);
      expect(key('inventory_transfer_close'), findsOneWidget);
    });

    testWidgets('is absent without delete on 17', (tester) async {
      await h.pumpTransfer(
        tester,
        partial,
        who: InventoryHarness.transferUser(transfers: 7),
      );
      expect(key('inventory_transfer_close'), findsNothing);
    });

    for (final other in [aTransfer(), receivedTransfer, cancelled]) {
      testWidgets('is absent on a ${other.status.name} transfer', (
        tester,
      ) async {
        await h.pumpTransfer(tester, other);
        expect(key('inventory_transfer_close'), findsNothing);
      });
    }

    for (final (code, name) in [
      (
        api.ErrorCode.inventoryTransferPeriodNotInTransit,
        'inventory_transfer.not_in_transit',
      ),
      (api.ErrorCode.facilityPeriodOtherFacility, 'facility.other_facility'),
    ]) {
      testWidgets('$name shows in Spanish in the banner', (tester) async {
        final refusal = aRefusal(code, name, {
          'resource': 'inventory_transfer',
        });
        when(
          () => h.transfers.close(412),
        ).thenAnswer((_) async => throw refusal);
        await h.pumpTransfer(tester, partial);

        await tapAndSubmit(
          tester,
          'inventory_transfer_close',
          'inventory_transfer_close_submit',
        );

        expect(find.text(localized(refusal)), findsOneWidget);
        expect(find.text('SERVER TEXT'), findsNothing);
        // Only a stale refusal re-fetches.
        verify(() => h.transfers.get(412)).called(
          code == api.ErrorCode.inventoryTransferPeriodNotInTransit ? 2 : 1,
        );
      });
    }
  });

  group('cancel (Cancelar)', () {
    testWidgets('a draft reads "Cancelar el borrador"', (tester) async {
      await h.pumpTransfer(tester, aTransfer());

      await tester.tap(key('inventory_transfer_cancel'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.inventoryTransferCancelDraftBody), findsOneWidget);
    });

    testWidgets('an in-transit transfer with nothing received names the folio '
        'and the origin only', (tester) async {
      await h.pumpTransfer(
        tester,
        dispatched.copyWith(lines: [aTransferLine(outstanding: '8')]),
      );

      await tester.tap(key('inventory_transfer_cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.inventoryTransferCancelDispatchedBody('77', 'Almacén 3'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('ya recibió'), findsNothing);
    });

    testWidgets('a transfer with something received adds what the '
        'destination already received', (tester) async {
      await h.pumpTransfer(tester, partial);

      await tester.tap(key('inventory_transfer_cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.inventoryTransferCancelDispatchedReceivedBody(
            '77',
            'Almacén 3',
            'Almacén 4',
          ),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('ya recibió'), findsOneWidget);
    });

    testWidgets('a received transfer can be cancelled, with the received '
        'wording', (tester) async {
      await h.pumpTransfer(tester, receivedTransfer);

      await tester.tap(key('inventory_transfer_cancel'));
      await tester.pumpAndSettle();

      expect(find.textContaining('ya recibió'), findsOneWidget);
    });

    testWidgets('cancelling a draft shows Cancelado, keeps the draft title '
        'and the simple table, and leaves no actions', (tester) async {
      when(() => h.transfers.cancel(412)).thenAnswer(
        (_) async => aTransfer(status: InventoryTransferStatus.cancelled),
      );
      await h.pumpTransfer(tester, aTransfer());

      await tapAndSubmit(
        tester,
        'inventory_transfer_cancel',
        'inventory_transfer_cancel_submit',
      );

      expect(title(tester), l10n.inventoryTransferTitleDraft('412'));
      expect(find.text(l10n.inventoryTransferStatusCancelled), findsOneWidget);
      expect(find.text(l10n.inventoryTransferLineColQuantity), findsOneWidget);
      expect(key('inventory_transfer_actions'), findsNothing);
    });

    testWidgets('a cancelled transfer keeps its received figures and shows '
        'no actions', (tester) async {
      await h.pumpTransfer(tester, cancelled);

      expect(find.text(l10n.inventoryTransferStatusCancelled), findsOneWidget);
      expect(
        tester.widget<Text>(key('inventory_transfer_line_received_900')).data,
        '5',
      );
      expect(key('inventory_transfer_cancel'), findsNothing);
      expect(key('inventory_transfer_actions'), findsNothing);
    });

    testWidgets('is absent without delete on 17', (tester) async {
      await h.pumpTransfer(
        tester,
        aTransfer(),
        who: InventoryHarness.transferUser(transfers: 7),
      );
      expect(key('inventory_transfer_cancel'), findsNothing);
    });

    testWidgets('insufficient_stock names the destination from the error\'s '
        'warehouse_id', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodInsufficientStock,
        'inventory_document.insufficient_stock',
        {
          'product_id': 7,
          'warehouse_id': 4,
          'requested': '8',
          'available': '2',
        },
      );
      when(
        () => h.transfers.cancel(412),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpTransfer(tester, receivedTransfer);

      await tapAndSubmit(
        tester,
        'inventory_transfer_cancel',
        'inventory_transfer_cancel_submit',
      );

      expect(find.text(localized(refusal)), findsOneWidget);
      expect(find.text('Producto: A-100 · Almacén: Almacén 4'), findsOneWidget);
    });

    testWidgets('already_cancelled shows "El traspaso ya está cancelado." and '
        're-fetches', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
        'inventory_document.already_cancelled',
        {'resource': 'inventory_transfer'},
      );
      when(
        () => h.transfers.cancel(412),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpTransfer(tester, aTransfer());
      h.stubTransfer(aTransfer(status: InventoryTransferStatus.cancelled));

      await tapAndSubmit(
        tester,
        'inventory_transfer_cancel',
        'inventory_transfer_cancel_submit',
      );

      expect(find.text('El traspaso ya está cancelado.'), findsOneWidget);
      verify(() => h.transfers.get(412)).called(2);
      expect(key('inventory_transfer_cancel'), findsNothing);
    });

    testWidgets('facility.other_facility shows in Spanish', (tester) async {
      final refusal = aRefusal(
        api.ErrorCode.facilityPeriodOtherFacility,
        'facility.other_facility',
        {'resource': 'inventory_transfer'},
      );
      when(
        () => h.transfers.cancel(412),
      ).thenAnswer((_) async => throw refusal);
      await h.pumpTransfer(tester, aTransfer());

      await tapAndSubmit(
        tester,
        'inventory_transfer_cancel',
        'inventory_transfer_cancel_submit',
      );

      expect(find.text(localized(refusal)), findsOneWidget);
    });
  });
}
