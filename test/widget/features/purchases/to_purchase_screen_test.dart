import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_order_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 080 US1 (T014): Por comprar.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = PurchasesHarness());

  /// PurchasesOrders (20) read and create; Facilities read by default.
  User buyer({int orderRights = 3, bool facilitiesRead = true}) =>
      PurchasesHarness.user(
        requestRights: 0,
        orderRights: orderRights,
        facilitiesRead: facilitiesRead,
      );

  /// Answers [groups] from `toPurchase`, recording each facility sent.
  final facilities = <int?>[];
  void serve(List<ToPurchaseGroup> groups) {
    facilities.clear();
    when(
      () => h.orders.toPurchase(facilityId: any(named: 'facilityId')),
    ).thenAnswer((i) async {
      facilities.add(i.namedArguments[#facilityId] as int?);
      return groups;
    });
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    User? who,
    String location = toPurchasePath,
    Size surface = const Size(1400, 1000),
  }) async {
    await h.pump(
      tester,
      who: who ?? buyer(),
      location: location,
      surface: surface,
    );
  }

  final norte = aToPurchaseGroup(
    lines: [
      aToPurchaseLine(),
      aToPurchaseLine(requestLineId: 901, serial: 566, cost: '0'),
    ],
  );
  final centro = aToPurchaseGroup(
    supplierId: 13,
    supplierName: 'Tornillería del Centro',
    lines: [aToPurchaseLine(requestLineId: 902)],
  );
  final none = aToPurchaseGroup(
    supplierId: null,
    supplierName: null,
    lines: [aToPurchaseLine(requestLineId: 903)],
  );

  Finder createButton() => key('to_purchase_create_order');
  bool createEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(createButton()).onPressed != null;

  testWidgets('shows each group with its facility, line count and total', (
    tester,
  ) async {
    serve([norte, centro, none]);
    await pumpScreen(tester);

    expect(facilities, [null]);
    expect(find.text('Ferretera del Norte'), findsOneWidget);
    expect(find.text('Tornillería del Centro'), findsOneWidget);
    expect(find.text(l10n.toPurchaseNoSupplier), findsOneWidget);
    expect(find.text('Sucursal 2'), findsNWidgets(3));
    expect(find.text(l10n.toPurchaseLineCount(2)), findsOneWidget);
    expect(
      tester.widget<Text>(key('to_purchase_group_total_12_2')).data,
      l10n.toPurchaseEstimate(r'$1,000.00'),
    );
    // Collapsed by default when the page has more than one group.
    expect(key('to_purchase_group_lines_12_2'), findsNothing);
  });

  testWidgets('an expanded group lists its lines; no cost reads "sin costo"', (
    tester,
  ) async {
    serve([norte, centro]);
    await pumpScreen(tester);

    await tester.tap(key('to_purchase_group_toggle_12_2'));
    await tester.pumpAndSettle();

    expect(key('to_purchase_group_lines_12_2'), findsOneWidget);
    expect(find.text('571'), findsOneWidget);
    expect(find.text('566'), findsOneWidget);
    expect(find.text('Almacén 3'), findsNWidgets(2));
    expect(
      tester.widget<Text>(key('to_purchase_line_cost_901')).data,
      l10n.toPurchaseNoCost,
    );
    expect(
      tester.widget<Text>(key('to_purchase_line_cost_900')).data,
      r'$125.00',
    );
  });

  testWidgets('a "Sin proveedor" group has no radio and a hint', (
    tester,
  ) async {
    serve([norte, none]);
    await pumpScreen(tester);

    expect(key('to_purchase_group_radio_12_2'), findsOneWidget);
    expect(key('to_purchase_group_radio_none_2'), findsNothing);
    expect(find.text(l10n.toPurchaseNoSupplierHint), findsOneWidget);
  });

  group('Crear orden', () {
    testWidgets('absent without create on 20', (tester) async {
      serve([norte, centro]);
      await pumpScreen(tester, who: buyer(orderRights: 2));

      expect(createButton(), findsNothing);
      expect(key('to_purchase_refresh'), findsOneWidget);
    });

    testWidgets('disabled until a group is selected, by its radio', (
      tester,
    ) async {
      serve([norte, centro]);
      await pumpScreen(tester);

      expect(createButton(), findsOneWidget);
      expect(createEnabled(tester), isFalse);

      await tester.tap(key('to_purchase_group_radio_13_2'));
      await tester.pumpAndSettle();

      expect(createEnabled(tester), isTrue);
    });

    testWidgets('a tap on a group header selects it', (tester) async {
      serve([norte, centro, none]);
      await pumpScreen(tester);

      await tester.tap(find.text('Tornillería del Centro'));
      await tester.pumpAndSettle();

      expect(createEnabled(tester), isTrue);

      // A "Sin proveedor" header can't be selected: the choice stays.
      await tester.tap(find.text(l10n.toPurchaseNoSupplier));
      await tester.pumpAndSettle();
      expect(createEnabled(tester), isTrue);
    });

    testWidgets('one group on the page starts expanded and selected', (
      tester,
    ) async {
      serve([norte]);
      await pumpScreen(tester);

      expect(key('to_purchase_group_lines_12_2'), findsOneWidget);
      expect(createEnabled(tester), isTrue);
    });

    testWidgets('a lone "Sin proveedor" group is expanded, not selectable', (
      tester,
    ) async {
      serve([none]);
      await pumpScreen(tester);

      expect(key('to_purchase_group_lines_none_2'), findsOneWidget);
      expect(createEnabled(tester), isFalse);
    });

    testWidgets('creates the order, opens it and says how many lines, '
        "counted on the server's answer", (tester) async {
      serve([norte]);
      // The group showed 2 lines; a third was approved meanwhile and the
      // server took it too.
      when(
        () => h.orders.createFromGroup(supplierId: 12, facilityId: 2),
      ).thenAnswer(
        (_) async => anOrder(
          id: 402,
          lines: [anOrderLine(), anOrderLine(id: 901), anOrderLine(id: 902)],
        ),
      );
      h.stubOrder(anOrder(id: 402));
      final router = await h.pump(
        tester,
        who: buyer(),
        location: toPurchasePath,
      );

      await tester.tap(createButton());
      await tester.pumpAndSettle();

      verify(
        () => h.orders.createFromGroup(supplierId: 12, facilityId: 2),
      ).called(1);
      expect(router.state.uri.path, '/purchases/orders/402');
      expect(find.text(l10n.toPurchaseCreatedSnack('402', 3)), findsOneWidget);
    });

    testWidgets('says how many lines were left out', (tester) async {
      serve([norte]);
      when(
        () => h.orders.createFromGroup(supplierId: 12, facilityId: 2),
      ).thenAnswer((_) async => anOrder(id: 402, skippedCount: 1));
      h.stubOrder(anOrder(id: 402));
      await pumpScreen(tester);

      await tester.tap(createButton());
      await tester.pumpAndSettle();

      expect(
        find.text(
          '${l10n.toPurchaseCreatedSnack('402', 1)}'
          '${l10n.purchaseOrderLeftOutSnack(1)}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a refusal shows in a banner from its code', (tester) async {
      serve([norte]);
      when(
        () => h.orders.createFromGroup(supplierId: 12, facilityId: 2),
      ).thenAnswer(
        (_) async => throw aRefusal(
          api.ErrorCode.purchaseOrderPeriodNothingPending,
          'purchase_order.nothing_pending',
        ),
      );
      final router = await h.pump(
        tester,
        who: buyer(),
        location: toPurchasePath,
      );

      await tester.tap(createButton());
      await tester.pumpAndSettle();

      expect(key('to_purchase_refusal'), findsOneWidget);
      expect(find.textContaining('SERVER TEXT'), findsNothing);
      expect(router.state.uri.path, toPurchasePath);
      // The group shown was stale: Por comprar reloads.
      expect(facilities, [null, null]);
    });

    group('the refusal banner clears', () {
      void refuseCreates() =>
          when(
            () => h.orders.createFromGroup(
              supplierId: any(named: 'supplierId'),
              facilityId: any(named: 'facilityId'),
            ),
          ).thenAnswer(
            (_) async => throw aRefusal(
              api.ErrorCode.purchaseOrderPeriodNoSupplier,
              'purchase_order.no_supplier',
            ),
          );

      Future<void> refuse(WidgetTester tester, String groupText) async {
        await tester.tap(find.text(groupText));
        await tester.pumpAndSettle();
        await tester.tap(createButton());
        await tester.pumpAndSettle();
        expect(key('to_purchase_refusal'), findsOneWidget);
      }

      testWidgets('on Actualizar', (tester) async {
        serve([norte, centro]);
        refuseCreates();
        await pumpScreen(tester);
        await refuse(tester, 'Ferretera del Norte');

        await tester.tap(key('to_purchase_refresh'));
        await tester.pumpAndSettle();

        expect(key('to_purchase_refusal'), findsNothing);
      });

      testWidgets('when another group is selected', (tester) async {
        serve([norte, centro]);
        refuseCreates();
        await pumpScreen(tester);
        await refuse(tester, 'Ferretera del Norte');

        await tester.tap(key('to_purchase_group_radio_13_2'));
        await tester.pumpAndSettle();

        expect(key('to_purchase_refusal'), findsNothing);
      });

      testWidgets('on a filter change', (tester) async {
        serve([norte, centro]);
        refuseCreates();
        final router = await h.pump(
          tester,
          who: buyer(),
          location: toPurchasePath,
        );
        await refuse(tester, 'Ferretera del Norte');

        router.go('$toPurchasePath?facility=2');
        await tester.pumpAndSettle();

        expect(key('to_purchase_refusal'), findsNothing);
      });

      testWidgets('on a page change', (tester) async {
        serve([
          for (var i = 1; i <= 21; i++)
            aToPurchaseGroup(supplierId: i, supplierName: 'Proveedor $i'),
        ]);
        refuseCreates();
        await pumpScreen(tester, surface: const Size(1400, 3000));
        await refuse(tester, 'Proveedor 2');

        await tester.tap(key('to_purchase_next_page'));
        await tester.pumpAndSettle();

        expect(key('to_purchase_refusal'), findsNothing);
      });
    });
  });

  group('pagination', () {
    // Tall enough to build all 20 cards of a page.
    const tall = Size(1400, 3000);
    final many = [
      for (var i = 1; i <= 21; i++)
        aToPurchaseGroup(supplierId: i, supplierName: 'Proveedor $i'),
    ];

    testWidgets('20 groups per page, the 21st on page 2', (tester) async {
      serve(many);
      await pumpScreen(tester, surface: tall);

      expect(find.text('Proveedor 20'), findsOneWidget);
      expect(find.text('Proveedor 21'), findsNothing);
      expect(
        tester.widget<Text>(key('to_purchase_pagination_summary')).data,
        l10n.toPurchasePaginationSummary('1', '20', '21'),
      );

      await tester.tap(key('to_purchase_next_page'));
      await tester.pumpAndSettle();

      expect(find.text('Proveedor 21'), findsOneWidget);
      expect(find.text('Proveedor 1'), findsNothing);
      // One fetch: the pages slice the loaded response.
      expect(facilities, [null]);
    });

    testWidgets('a page change clears the selection', (tester) async {
      serve(many);
      await pumpScreen(tester, surface: tall);
      await tester.tap(find.text('Proveedor 2'));
      await tester.pumpAndSettle();
      expect(createEnabled(tester), isTrue);

      await tester.tap(key('to_purchase_next_page'));
      await tester.pumpAndSettle();
      await tester.tap(key('to_purchase_previous_page'));
      await tester.pumpAndSettle();

      expect(createEnabled(tester), isFalse);
    });

    testWidgets('a page past the last clamps to the last', (tester) async {
      serve(many);
      await pumpScreen(
        tester,
        location: '$toPurchasePath?page=9',
        surface: tall,
      );

      expect(find.text('Proveedor 21'), findsOneWidget);
    });
  });

  group('the facility facet', () {
    testWidgets('lives in the filter sheet', (tester) async {
      serve([norte, centro]);
      await pumpScreen(tester);

      expect(key('to_purchase_filter_facility'), findsNothing);
      await tester.tap(key('to_purchase_filter_button'));
      await tester.pumpAndSettle();
      expect(key('to_purchase_filter_facility'), findsOneWidget);
    });

    testWidgets('a chosen facility reaches the server', (tester) async {
      serve([norte, centro]);
      await pumpScreen(tester, location: '$toPurchasePath?facility=4');

      expect(facilities, [4]);
    });

    testWidgets('without Facilities read there is no filters button', (
      tester,
    ) async {
      serve([norte, centro]);
      await pumpScreen(tester, who: buyer(facilitiesRead: false));

      expect(key('to_purchase_filter_button'), findsNothing);
      expect(find.text('Ferretera del Norte'), findsOneWidget);
    });
  });

  testWidgets('Actualizar reloads the groups', (tester) async {
    serve([norte, centro]);
    await pumpScreen(tester);

    await tester.tap(key('to_purchase_refresh'));
    await tester.pumpAndSettle();

    expect(facilities, [null, null]);
  });

  testWidgets('empty: no pending lines', (tester) async {
    serve(const []);
    await pumpScreen(tester);

    expect(find.text(l10n.toPurchaseEmpty), findsOneWidget);
  });

  testWidgets('filtered empty offers "Limpiar filtros"', (tester) async {
    serve(const []);
    await pumpScreen(tester, location: '$toPurchasePath?facility=4');

    expect(find.text(l10n.clearFiltersButton), findsOneWidget);
  });

  testWidgets('an error offers a retry', (tester) async {
    when(
      () => h.orders.toPurchase(facilityId: any(named: 'facilityId')),
    ).thenAnswer((_) async => throw const AppError.network());
    await pumpScreen(tester);

    expect(find.text(l10n.retryButton), findsOneWidget);
  });
}
