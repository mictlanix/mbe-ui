import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/pickup_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Records each pickup and answers [error].
class _FakeActions extends DeliveryOrderActions {
  _FakeActions({this.error});

  AppError? error;
  final calls = <String>[];

  @override
  Future<AppError?> confirmPickup(
    int id, {
    required String receiverName,
    required String receiverIdShown,
    required Uint8List bytes,
    required String filename,
  }) async {
    calls.add('$receiverName|$receiverIdShown|$filename|${bytes.length}');
    return error;
  }
}

final _order = DeliveryOrder(
  id: 9,
  facilityId: 1,
  serial: 1529,
  customerId: 7,
  date: DateTime(2026, 11, 15),
  priority: 0,
  status: DeliveryOrderStatus.readyForPickup,
  type: FulfillmentType.counterPickup,
  createdAt: DateTime(2026, 11, 14),
  modifiedAt: DateTime(2026, 11, 14),
);

final PickedPhoto _photo = (
  bytes: Uint8List.fromList([1, 2, 3]),
  name: 'recibo.jpg',
);

AppError _refusal(
  String codeName,
  api.ErrorCode code, [
  Map<String, Object?>? params,
]) => AppError.server(
  statusCode: 422,
  problem: ApiProblem(
    codeName: codeName,
    code: code,
    params: params ?? const {},
  ),
);

/// Spec 061 T038, contracts C9: the "Entregar al cliente" dialog.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  /// Opens the dialog; the picker answers [photo]. Its answer lands in the
  /// returned list.
  Future<List<bool>> pumpDialog(
    WidgetTester tester, {
    required _FakeActions actions,
    PickedPhoto? photo,
  }) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final results = <bool>[];
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          deliveryOrderActionsProvider.overrideWith(() => actions),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => results.add(
                  await showPickupDialog(
                    context,
                    _order,
                    pickPhoto: () async => photo ?? _photo,
                  ),
                ),
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

  bool enabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(key('delivery_order_pickup_submit'))
          .onPressed !=
      null;

  Future<void> fill(
    WidgetTester tester, {
    String name = 'Juan Pérez',
    String id = 'INE 0123456789',
    bool file = true,
  }) async {
    await tester.enterText(key('delivery_order_pickup_name'), name);
    await tester.enterText(key('delivery_order_pickup_id'), id);
    if (file) {
      await tester.tap(key('delivery_order_pickup_choose_file'));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('is titled with the folio', (tester) async {
    await pumpDialog(tester, actions: _FakeActions());

    expect(find.text(l10n.deliveryOrderPickupTitle('1529')), findsOneWidget);
    expect(enabled(tester), isFalse);
  });

  group('"Entregar" stays disabled until all three are given', () {
    testWidgets('no name', (tester) async {
      await pumpDialog(tester, actions: _FakeActions());
      await fill(tester, name: '');
      expect(enabled(tester), isFalse);
    });

    testWidgets('a whitespace-only name', (tester) async {
      await pumpDialog(tester, actions: _FakeActions());
      await fill(tester, name: '   ');
      expect(enabled(tester), isFalse);
    });

    testWidgets('no identification', (tester) async {
      await pumpDialog(tester, actions: _FakeActions());
      await fill(tester, id: '');
      expect(enabled(tester), isFalse);
    });

    testWidgets('a whitespace-only identification', (tester) async {
      await pumpDialog(tester, actions: _FakeActions());
      await fill(tester, id: '  ');
      expect(enabled(tester), isFalse);
    });

    testWidgets('no file', (tester) async {
      await pumpDialog(tester, actions: _FakeActions());
      await fill(tester, file: false);
      expect(enabled(tester), isFalse);
    });

    testWidgets('a cleared file', (tester) async {
      await pumpDialog(tester, actions: _FakeActions());
      await fill(tester);
      expect(enabled(tester), isTrue);
      expect(find.text('recibo.jpg'), findsOneWidget);

      await tester.tap(key('delivery_order_pickup_clear_file'));
      await tester.pump();

      expect(find.text('recibo.jpg'), findsNothing);
      expect(enabled(tester), isFalse);
    });
  });

  testWidgets('sends the trimmed texts and the photo, then closes', (
    tester,
  ) async {
    final actions = _FakeActions();
    final results = await pumpDialog(tester, actions: actions);
    await fill(tester, name: ' Juan Pérez ', id: ' INE 0123456789 ');

    await tester.tap(key('delivery_order_pickup_submit'));
    await tester.pumpAndSettle();

    expect(actions.calls, ['Juan Pérez|INE 0123456789|recibo.jpg|3']);
    expect(key('delivery_order_pickup_dialog'), findsNothing);
    expect(results, [true]);
  });

  for (final (label, error, message) in [
    (
      'proof_incomplete',
      _refusal(
        'delivery_order.proof_incomplete',
        api.ErrorCode.deliveryOrderPeriodProofIncomplete,
      ),
      (AppLocalizations l10n) =>
          find.text(l10n.apiErrorDeliveryOrderProofIncomplete),
    ),
    (
      'image.too_large (a file over 2 MB)',
      _refusal('image.too_large', api.ErrorCode.imagePeriodTooLarge, {
        'max_bytes': 2097152,
      }),
      // The size itself is formatted; match the sentence around it.
      (AppLocalizations l10n) => find.textContaining(
        l10n.apiErrorImageTooLarge('\u0000').split('\u0000').first,
      ),
    ),
    (
      'image.unsupported_format',
      _refusal(
        'image.unsupported_format',
        api.ErrorCode.imagePeriodUnsupportedFormat,
      ),
      (AppLocalizations l10n) => find.text(l10n.apiErrorImageUnsupportedFormat),
    ),
  ]) {
    testWidgets('$label keeps the dialog, the fields and the photo', (
      tester,
    ) async {
      final actions = _FakeActions(error: error);
      final results = await pumpDialog(
        tester,
        actions: actions,
        photo: (bytes: Uint8List(2 * 1024 * 1024 + 1), name: 'grande.png'),
      );
      await fill(tester);

      await tester.tap(key('delivery_order_pickup_submit'));
      await tester.pumpAndSettle();

      expect(actions.calls, hasLength(1));
      expect(key('delivery_order_pickup_dialog'), findsOneWidget);
      expect(key('delivery_order_refusal'), findsOneWidget);
      expect(message(l10n), findsOneWidget);
      expect(find.text('grande.png'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(enabled(tester), isTrue);
      expect(results, isEmpty);
    });
  }
}
