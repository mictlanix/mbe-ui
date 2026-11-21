import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/widgets/inline_error_text.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_itinerary.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/close_stop_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_itineraries/itinerary_dialogs.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/sales/delivery_itinerary_fixtures.dart';
import 'delivery_itinerary_harness.dart';

/// Spec 075 FR-015 to FR-018, research R8: "Cerrar parada".
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  final trip = fakeItinerary(status: ItineraryStatus.departed);
  final stop = fakeItineraryStop(
    id: 502,
    sequence: 2,
    orderId: 1540,
    customer: 'Materiales Herrera',
    lines: [
      fakeItineraryLine(
        id: 7001,
        code: 'CEM-50',
        name: 'Cemento gris 50 kg',
        unit: 'bulto',
        committed: '6',
        sent: '6',
      ),
      fakeItineraryLine(
        id: 7002,
        orderLineId: 901,
        code: 'ARE-01',
        name: 'Arena m³',
        unit: 'm³',
        committed: '2',
        sent: '2',
      ),
    ],
  );

  final png = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
  ]);

  Future<List<ItineraryActionResult?>> open(
    WidgetTester tester,
    FakeItineraryActions actions, {
    Future<PickedProof?> Function()? pickImage,
    Size surface = const Size(1400, 1400),
  }) async {
    final results = <ItineraryActionResult?>[];
    await pumpDialogHost(
      tester,
      open: (context) async => results.add(
        await showCloseStopDialog(
          context,
          trip: trip,
          stop: stop,
          pickImage:
              pickImage ?? () async => (bytes: png, name: 'nota-1540.jpg'),
        ),
      ),
      actions: actions,
      access: itineraryAccess(rights: itineraryWriter),
      surface: surface,
    );
    return results;
  }

  Finder key(String k) => find.byKey(Key(k));

  bool canClose(WidgetTester tester) =>
      tester.widget<FilledButton>(key('itinerary_close_submit')).onPressed !=
      null;

  Future<void> fillReceiver(WidgetTester tester) async {
    await tester.enterText(key('itinerary_close_name'), 'Ana Domínguez');
    await tester.enterText(key('itinerary_close_id'), 'INE 0123456789');
    await tester.pump();
  }

  Future<void> chooseImage(WidgetTester tester) async {
    await tester.tap(key('itinerary_close_choose_image'));
    await tester.pumpAndSettle();
  }

  testWidgets('titles the stop with its order and customer, and every line '
      'starts at what was sent', (tester) async {
    await open(tester, FakeItineraryActions());

    expect(
      find.text(
        l10n.itineraryCloseSubtitle(
          l10n.itineraryCloseTitle(2),
          '1540',
          'Materiales Herrera',
        ),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(key('itinerary_close_delivered_7001'))
          .controller!
          .text,
      '6',
    );
    expect(
      tester
          .widget<TextField>(key('itinerary_close_delivered_7002'))
          .controller!
          .text,
      '2',
    );
    // Nothing short yet, so no reason is asked.
    expect(key('itinerary_close_reason_7001'), findsNothing);
    expect(key('itinerary_close_reason_7002'), findsNothing);
  });

  testWidgets('a reason appears only for a shortfall', (tester) async {
    await open(tester, FakeItineraryActions());

    await tester.enterText(key('itinerary_close_delivered_7001'), '4');
    await tester.pump();

    expect(key('itinerary_close_reason_7001'), findsOneWidget);
    expect(key('itinerary_close_reason_7002'), findsNothing);

    await tester.enterText(key('itinerary_close_delivered_7001'), '6');
    await tester.pump();
    expect(key('itinerary_close_reason_7001'), findsNothing);
  });

  testWidgets('a quantity below zero or above what was sent is refused', (
    tester,
  ) async {
    await open(tester, FakeItineraryActions());
    await fillReceiver(tester);
    await chooseImage(tester);
    expect(canClose(tester), isTrue);

    await tester.enterText(key('itinerary_close_delivered_7001'), '7');
    await tester.pump();
    expect(find.text(l10n.itineraryQuantityInvalid), findsOneWidget);
    expect(canClose(tester), isFalse);

    await tester.enterText(key('itinerary_close_delivered_7001'), '-1');
    await tester.pump();
    expect(canClose(tester), isFalse);
  });

  testWidgets('"Todo entregado" and "Nada entregado" set every row', (
    tester,
  ) async {
    await open(tester, FakeItineraryActions());

    await tester.tap(key('itinerary_close_none'));
    await tester.pump();
    for (final id in [7001, 7002]) {
      expect(
        tester
            .widget<TextField>(key('itinerary_close_delivered_$id'))
            .controller!
            .text,
        '0',
      );
      expect(key('itinerary_close_reason_$id'), findsOneWidget);
    }

    await tester.tap(key('itinerary_close_all'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(key('itinerary_close_delivered_7001'))
          .controller!
          .text,
      '6',
    );
    expect(key('itinerary_close_reason_7001'), findsNothing);
  });

  testWidgets('confirm stays disabled and the list names each gap', (
    tester,
  ) async {
    await open(tester, FakeItineraryActions());

    expect(canClose(tester), isFalse);
    final missing = tester.widget<Text>(key('itinerary_close_missing')).data!;
    expect(missing, contains(l10n.itineraryCloseMissingReceiver));
    expect(missing, contains(l10n.itineraryCloseMissingId));
    expect(missing, contains(l10n.itineraryCloseMissingProof));

    await tester.enterText(key('itinerary_close_delivered_7001'), '4');
    await tester.pump();
    expect(
      tester.widget<Text>(key('itinerary_close_missing')).data,
      contains(l10n.itineraryCloseMissingReason('CEM-50')),
    );
  });

  testWidgets('a blank receiver (spaces only) is still missing', (
    tester,
  ) async {
    await open(tester, FakeItineraryActions());
    await tester.enterText(key('itinerary_close_name'), '   ');
    await tester.enterText(key('itinerary_close_id'), 'INE 1');
    await chooseImage(tester);

    expect(canClose(tester), isFalse);
    expect(
      tester.widget<Text>(key('itinerary_close_missing')).data,
      contains(l10n.itineraryCloseMissingReceiver),
    );
  });

  testWidgets('the image proof sends exactly one image: the chosen file', (
    tester,
  ) async {
    final actions = FakeItineraryActions();
    final results = await open(tester, actions);
    await fillReceiver(tester);
    await chooseImage(tester);
    expect(find.text('nota-1540.jpg'), findsOneWidget);
    expect(canClose(tester), isTrue);

    await tester.tap(key('itinerary_close_submit'));
    await tester.pumpAndSettle();

    expect(actions.calls.single, 'closeStop 502');
    final closure = actions.lastClosure!;
    expect(closure.receiverName, 'Ana Domínguez');
    expect(closure.receiverIdShown, 'INE 0123456789');
    expect(closure.proof.filename, 'nota-1540.jpg');
    expect(closure.proof.bytes, png);
    expect(
      closure.lines.map((l) => (l.lineId, l.delivered.toString(), l.reason)),
      [(7001, '6', null), (7002, '2', null)],
    );
    expect(results.single?.error, isNull);
  });

  testWidgets('a shortfall is sent with its reason; a full line with none', (
    tester,
  ) async {
    final actions = FakeItineraryActions();
    await open(tester, actions);
    await fillReceiver(tester);
    await chooseImage(tester);
    await tester.enterText(key('itinerary_close_delivered_7001'), '4');
    await tester.pump();

    await tester.tap(key('itinerary_close_reason_7001'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.itineraryReasonDamagedGoods).last);
    await tester.pumpAndSettle();
    expect(canClose(tester), isTrue);

    await tester.tap(key('itinerary_close_submit'));
    await tester.pumpAndSettle();

    final lines = actions.lastClosure!.lines;
    expect(lines[0].delivered.toString(), '4');
    expect(lines[0].reason, ShortfallReason.damagedGoods);
    expect(lines[1].reason, isNull);
  });

  testWidgets('the signature proof sends firma.png, a PNG drawn on screen', (
    tester,
  ) async {
    final actions = FakeItineraryActions();
    await open(tester, actions);
    await fillReceiver(tester);
    await tester.tap(find.text(l10n.itineraryCloseProofSignature));
    await tester.pumpAndSettle();
    expect(canClose(tester), isFalse, reason: 'an empty pad is no proof');
    expect(
      tester.widget<Text>(key('itinerary_close_missing')).data,
      contains(l10n.itineraryCloseMissingProof),
    );

    final pad = key('signature_pad');
    final gesture = await tester.startGesture(
      tester.getTopLeft(pad) + const Offset(30, 30),
    );
    await gesture.moveBy(const Offset(80, 20));
    await gesture.up();
    await tester.pump();
    expect(canClose(tester), isTrue);

    await tester.runAsync(() async {
      await tester.tap(key('itinerary_close_submit'));
      // Rendering the PNG needs the real event loop.
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    final proof = actions.lastClosure!.proof;
    expect(proof.filename, 'firma.png');
    expect(proof.bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });

  testWidgets('switching proof kind keeps each side\'s input, and only the '
      'selected one is sent', (tester) async {
    final actions = FakeItineraryActions();
    await open(tester, actions);
    await fillReceiver(tester);
    await chooseImage(tester);

    await tester.tap(find.text(l10n.itineraryCloseProofSignature));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.itineraryCloseProofImage));
    await tester.pumpAndSettle();

    expect(find.text('nota-1540.jpg'), findsOneWidget);
    expect(canClose(tester), isTrue);
    await tester.tap(key('itinerary_close_submit'));
    await tester.pumpAndSettle();
    expect(actions.lastClosure!.proof.filename, 'nota-1540.jpg');
  });

  testWidgets('an oversized or non-image file is refused before sending', (
    tester,
  ) async {
    final actions = FakeItineraryActions();
    var next = (bytes: Uint8List(3 * 1024 * 1024), name: 'grande.jpg');
    await open(tester, actions, pickImage: () async => next);
    await fillReceiver(tester);

    await chooseImage(tester);
    expect(
      tester.widget<InlineErrorText>(key('itinerary_close_image_problem')).text,
      l10n.itineraryCloseImageTooLarge,
    );
    expect(canClose(tester), isFalse);

    next = (bytes: png, name: 'nota.pdf');
    await chooseImage(tester);
    expect(
      tester.widget<InlineErrorText>(key('itinerary_close_image_problem')).text,
      l10n.itineraryCloseImageFormat,
    );
    expect(canClose(tester), isFalse);
    expect(actions.calls, isEmpty);
  });

  testWidgets('removing the chosen image makes the proof missing again', (
    tester,
  ) async {
    await open(tester, FakeItineraryActions());
    await fillReceiver(tester);
    await chooseImage(tester);
    expect(canClose(tester), isTrue);

    await tester.tap(key('itinerary_close_remove_image'));
    await tester.pump();

    expect(canClose(tester), isFalse);
  });

  testWidgets('a server refusal shows in the dialog, which stays open with '
      'what was typed', (tester) async {
    final actions = FakeItineraryActions(
      error: const AppError.server(
        statusCode: 409,
        problem: ApiProblem(
          codeName: 'itinerary.stop_already_resolved',
          code: api.ErrorCode.itineraryPeriodStopAlreadyResolved,
        ),
      ),
    );
    await open(tester, actions);
    await fillReceiver(tester);
    await chooseImage(tester);

    await tester.tap(key('itinerary_close_submit'));
    await tester.pumpAndSettle();

    expect(key('itinerary_close_dialog'), findsOneWidget);
    expect(
      find.text(l10n.apiErrorItineraryStopAlreadyResolved),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(key('itinerary_close_name')).controller!.text,
      'Ana Domínguez',
    );
  });

  testWidgets('a compact screen lays each line out on two rows, no overflow', (
    tester,
  ) async {
    await open(tester, FakeItineraryActions(), surface: const Size(420, 1100));

    // Two rows (a Column), not the wide layout's single Row.
    expect(tester.widget(key('itinerary_close_line_7001')), isA<Column>());
    expect(tester.takeException(), isNull);
  });
}
