import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/purchases/purchase_request_fixtures.dart';
import 'purchases_harness.dart';

/// Spec 079 US4 (T029, T030), FR-007 and FR-008: "Editar encabezado" on a
/// draft's detail.
void main() {
  late PurchasesHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    h = PurchasesHarness();
    h.serveWarehouses([aWarehouse(3), aWarehouse(4)]);
  });

  final draft = aRequest(comment: 'Para diciembre');

  Future<void> open(
    WidgetTester tester,
    PurchaseRequest request, {
    bool administrator = false,
  }) async {
    await h.pumpRequest(
      tester,
      request,
      who: PurchasesHarness.user(administrator: administrator),
    );
    await tester.tap(key('purchase_request_edit_header'));
    await tester.pumpAndSettle();
  }

  Finder warehouseField() => find.descendant(
    of: key('purchase_request_header_warehouse'),
    matching: find.byType(TextField),
  );

  FilledButton save(WidgetTester tester) =>
      tester.widget<FilledButton>(key('purchase_request_header_submit'));

  void answerUpdate(PurchaseRequest reply) => when(
    () => h.requests.updateHeader(
      any(),
      warehouseId: any(named: 'warehouseId'),
      comment: any(named: 'comment'),
      clearComment: any(named: 'clearComment'),
    ),
  ).thenAnswer((_) async => reply);

  group('the button', () {
    testWidgets('is on an own draft with update on 86 and read on 4', (
      tester,
    ) async {
      await h.pumpRequest(tester, draft);
      expect(key('purchase_request_edit_header'), findsOneWidget);
    });

    testWidgets('is absent without Warehouses (4) read', (tester) async {
      await h.pumpRequest(
        tester,
        draft,
        who: PurchasesHarness.user(warehousesRead: false),
      );
      expect(key('purchase_request_edit_header'), findsNothing);
    });

    testWidgets('is absent on a submitted request', (tester) async {
      await h.pumpRequest(
        tester,
        aRequest(serial: 571, status: PurchaseRequestStatus.submitted),
      );
      expect(key('purchase_request_edit_header'), findsNothing);
    });
  });

  testWidgets("a non-administrator is offered their own facility's "
      'warehouses', (tester) async {
    await open(tester, draft);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();

    verify(
      () => h.warehouses.list(
        search: 'Alm',
        facilityId: 2,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('an administrator is offered every warehouse', (tester) async {
    await open(tester, draft, administrator: true);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();

    verify(
      () => h.warehouses.list(
        search: 'Alm',
        facilityId: null,
        status: EntityStatus.active,
        limit: 10,
      ),
    ).called(greaterThan(0));
  });

  testWidgets('a numbered request says it keeps its facility', (tester) async {
    await open(tester, aRequest(serial: 569));

    expect(
      find.text(l10n.purchaseRequestWarehouseFacilityHelper('Sucursal 2')),
      findsOneWidget,
    );
  });

  testWidgets('a never-submitted draft has no facility helper', (tester) async {
    await open(tester, draft);

    expect(key('purchase_request_header_facility_helper'), findsNothing);
  });

  testWidgets('nothing changed: Guardar is disabled', (tester) async {
    await open(tester, draft);
    expect(save(tester).onPressed, isNull);
  });

  testWidgets('changing only the notes sends only the notes', (tester) async {
    answerUpdate(aRequest(comment: 'Para enero'));
    await open(tester, draft);

    await tester.enterText(
      key('purchase_request_header_comment'),
      'Para enero',
    );
    await tester.pumpAndSettle();
    await tester.tap(key('purchase_request_header_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.requests.updateHeader(
        212,
        warehouseId: null,
        comment: 'Para enero',
        clearComment: false,
      ),
    ).called(1);
    expect(key('purchase_request_header_dialog'), findsNothing);
    expect(find.text('Para enero'), findsOneWidget);
  });

  testWidgets('changing only the warehouse sends only the warehouse', (
    tester,
  ) async {
    answerUpdate(aRequest(warehouseId: 4, comment: 'Para diciembre'));
    await open(tester, draft);

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 4').last);
    await tester.pumpAndSettle();
    await tester.tap(key('purchase_request_header_submit'));
    await tester.pumpAndSettle();

    verify(
      () => h.requests.updateHeader(
        212,
        warehouseId: 4,
        comment: null,
        clearComment: false,
      ),
    ).called(1);
  });

  testWidgets('clearing the notes asks for them to be cleared', (tester) async {
    answerUpdate(aRequest());
    await open(tester, draft);

    await tester.enterText(key('purchase_request_header_comment'), '  ');
    await tester.pumpAndSettle();
    await tester.tap(key('purchase_request_header_submit'));
    await tester.pumpAndSettle();

    // The repository sends `clearComment` as "" (research R8, T005).
    verify(
      () => h.requests.updateHeader(
        212,
        warehouseId: null,
        comment: null,
        clearComment: true,
      ),
    ).called(1);
  });

  testWidgets("notes over 500 characters can't be saved", (tester) async {
    await open(tester, draft);

    await tester.enterText(key('purchase_request_header_comment'), 'x' * 501);
    await tester.pumpAndSettle();
    expect(save(tester).onPressed, isNull);

    await tester.enterText(key('purchase_request_header_comment'), 'x' * 500);
    await tester.pumpAndSettle();
    expect(save(tester).onPressed, isNotNull);
  });

  testWidgets('facility_locked stays in the dialog, in Spanish', (
    tester,
  ) async {
    when(
      () => h.requests.updateHeader(
        any(),
        warehouseId: any(named: 'warehouseId'),
        comment: any(named: 'comment'),
        clearComment: any(named: 'clearComment'),
      ),
    ).thenAnswer(
      (_) async => throw aRefusal(
        api.ErrorCode.purchaseRequestPeriodFacilityLocked,
        'purchase_request.facility_locked',
      ),
    );
    await open(tester, aRequest(serial: 569));

    await tester.enterText(warehouseField(), 'Alm');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Almacén 4').last);
    await tester.pumpAndSettle();
    await tester.tap(key('purchase_request_header_submit'));
    await tester.pumpAndSettle();

    expect(key('purchase_request_header_dialog'), findsOneWidget);
    expect(key('purchase_request_header_refusal'), findsOneWidget);
    expect(
      find.textContaining(l10n.apiErrorPurchaseRequestFacilityLocked),
      findsOneWidget,
    );
    expect(find.text('SERVER TEXT'), findsNothing);
  });
}
