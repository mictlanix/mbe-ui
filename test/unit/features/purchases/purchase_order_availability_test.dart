import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_availability.dart';

const _read = 2;
const _create = 1;
const _update = 4;
const _delete = 8;

AccessControlService _access(Map<SystemObject, int> grants) =>
    AccessControlService(
      AuthState.authenticated(
        token: 't',
        user: User(
          userId: 'u',
          email: 'u@example.com',
          administrator: false,
          status: EntityStatus.active,
          sessionVersion: 1,
          privileges: [
            for (final e in grants.entries)
              Privilege(systemObject: e.key, rawValue: e.value),
          ],
        ),
      ),
    );

/// Every right a buyer may hold.
const _all = {
  SystemObject.purchasesOrders: _read | _create | _update | _delete,
  SystemObject.inventoryReceipts: _read,
  SystemObject.suppliers: _read,
  SystemObject.products: _read,
  SystemObject.warehouses: _read,
  SystemObject.purchaseRequest: _read,
};

/// [_all] with [object]'s right [bit] taken away.
Map<SystemObject, int> _without(SystemObject object, int bit) => {
  ..._all,
  object: _all[object]! & ~bit,
};

PurchaseOrderAvailability _of(
  InventoryDocumentStatus? status,
  Map<SystemObject, int> grants, {
  int lineCount = 1,
}) => PurchaseOrderAvailability(
  status: status,
  access: _access(grants),
  lineCount: lineCount,
);

typedef _Getter = bool Function(PurchaseOrderAvailability a);

/// Spec 080 data-model "Action availability" (T009).
void main() {
  const draft = InventoryDocumentStatus.draft;
  const confirmed = InventoryDocumentStatus.completed;
  const cancelled = InventoryDocumentStatus.cancelled;

  /// Each action: the states it is offered in with every right, and the
  /// rights that each, missing, take it away.
  final actions =
      <
        String,
        ({
          _Getter get,
          Set<InventoryDocumentStatus> states,
          List<(SystemObject, int)> needs,
        })
      >{
        'canEditHeader': (
          get: (a) => a.canEditHeader,
          states: {draft},
          needs: [
            (SystemObject.purchasesOrders, _update),
            (SystemObject.suppliers, _read),
          ],
        ),
        'canAddLine': (
          get: (a) => a.canAddLine,
          states: {draft},
          needs: [
            (SystemObject.purchasesOrders, _update),
            (SystemObject.products, _read),
          ],
        ),
        'canAddRequestLines': (
          get: (a) => a.canAddRequestLines,
          states: {draft},
          needs: [
            (SystemObject.purchasesOrders, _update),
            (SystemObject.purchaseRequest, _read),
          ],
        ),
        'canEditLines': (
          get: (a) => a.canEditLines,
          states: {draft},
          needs: [
            (SystemObject.purchasesOrders, _update),
            (SystemObject.warehouses, _read),
          ],
        ),
        'canRemoveLines': (
          get: (a) => a.canRemoveLines,
          states: {draft},
          needs: [(SystemObject.purchasesOrders, _update)],
        ),
        'canConfirm': (
          get: (a) => a.canConfirm,
          states: {draft},
          needs: [(SystemObject.purchasesOrders, _update)],
        ),
        'canCancel': (
          get: (a) => a.canCancel,
          states: {draft},
          needs: [(SystemObject.purchasesOrders, _delete)],
        ),
        'canPrint': (
          get: (a) => a.canPrint,
          states: {confirmed},
          needs: [(SystemObject.purchasesOrders, _read)],
        ),
        'canEmail': (
          get: (a) => a.canEmail,
          states: {confirmed},
          needs: [(SystemObject.purchasesOrders, _update)],
        ),
        'canOpenReceipt': (
          get: (a) => a.canOpenReceipt,
          states: {confirmed},
          needs: [(SystemObject.inventoryReceipts, _read)],
        ),
      };

  for (final MapEntry(key: name, value: action) in actions.entries) {
    group(name, () {
      for (final status in [draft, confirmed, cancelled]) {
        final offered = action.states.contains(status);
        test('with every right on a ${status.name} order: $offered', () {
          expect(action.get(_of(status, _all)), offered);
        });
      }
      for (final (object, bit) in action.needs) {
        test('absent without right $bit on ${object.name}', () {
          final state = action.states.first;
          expect(action.get(_of(state, _without(object, bit))), isFalse);
        });
      }
    });
  }

  group('canCreate', () {
    test('create on 20 and read on suppliers, in any state', () {
      for (final status in [null, draft, confirmed, cancelled]) {
        expect(_of(status, _all).canCreate, isTrue);
      }
    });

    test('absent without create on 20', () {
      expect(
        _of(null, _without(SystemObject.purchasesOrders, _create)).canCreate,
        isFalse,
      );
    });

    test('absent without read on suppliers', () {
      expect(
        _of(null, _without(SystemObject.suppliers, _read)).canCreate,
        isFalse,
      );
    });
  });

  group('canCreateFromGroup', () {
    test('create on 20 alone', () {
      expect(
        _of(null, {SystemObject.purchasesOrders: _create}).canCreateFromGroup,
        isTrue,
      );
    });

    test('absent without create on 20', () {
      expect(
        _of(
          null,
          _without(SystemObject.purchasesOrders, _create),
        ).canCreateFromGroup,
        isFalse,
      );
    });
  });

  group('confirmNeedsLines', () {
    test('a draft with no lines', () {
      expect(_of(draft, _all, lineCount: 0).confirmNeedsLines, isTrue);
      expect(_of(draft, _all, lineCount: 0).canConfirm, isTrue);
    });

    test('not with lines', () {
      expect(_of(draft, _all).confirmNeedsLines, isFalse);
    });

    test('not without the right to confirm at all', () {
      expect(
        _of(
          draft,
          _without(SystemObject.purchasesOrders, _update),
          lineCount: 0,
        ).confirmNeedsLines,
        isFalse,
      );
    });
  });

  test('with no rights at all nothing is offered', () {
    final a = _of(draft, const {});
    expect([
      a.canCreate,
      a.canCreateFromGroup,
      a.canEditHeader,
      a.canAddLine,
      a.canAddRequestLines,
      a.canEditLines,
      a.canRemoveLines,
      a.canConfirm,
      a.canCancel,
    ], everyElement(isFalse));
  });
}
