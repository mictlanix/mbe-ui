import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_availability.dart';

const _own = 2;
const _foreign = 9;

const _read = 2;
const _create = 1;
const _update = 4;
const _delete = 8;

AccessControlService _access(
  Map<SystemObject, int> grants, {
  bool administrator = false,
}) => AccessControlService(
  AuthState.authenticated(
    token: 't',
    user: User(
      userId: 'u',
      email: 'u@example.com',
      administrator: administrator,
      status: EntityStatus.active,
      sessionVersion: 1,
      privileges: [
        for (final e in grants.entries)
          Privilege(systemObject: e.key, rawValue: e.value),
      ],
    ),
  ),
);

PurchaseRequestAvailability _of(
  PurchaseRequestStatus status,
  AccessControlService access, {
  int? facility = _own,
}) => PurchaseRequestAvailability(
  status: status,
  facilityId: facility,
  access: access,
  userFacilityId: _own,
);

/// The full set of rights a requester holds, with every optional right.
const _requester = {
  SystemObject.purchaseRequest: _read | _create | _update | _delete,
  SystemObject.warehouses: _read,
  SystemObject.products: _read,
};

/// Spec 079 data-model "Action availability", research R12 (T011).
void main() {
  group('a requester on their own facility', () {
    final access = _access(_requester);

    test('draft: every edit action, no decision, no marks', () {
      final a = _of(PurchaseRequestStatus.draft, access);
      expect(a.canEditHeader, isTrue);
      expect(a.canAddLine, isTrue);
      expect(a.canEditLines, isTrue);
      expect(a.canSubmit, isTrue);
      expect(a.canCancel, isTrue);
      expect(a.canMarkLines, isFalse);
      expect(a.canApprove, isFalse);
      expect(a.canReject, isFalse);
      expect(a.canApproveFromQueue, isFalse);
      expect(a.canOpenFromQueue, isTrue);
    });

    for (final status in [
      PurchaseRequestStatus.submitted,
      PurchaseRequestStatus.approved,
    ]) {
      test('${status.name}: read-only apart from cancel', () {
        final a = _of(status, access);
        expect(a.canEditHeader, isFalse);
        expect(a.canAddLine, isFalse);
        expect(a.canEditLines, isFalse);
        expect(a.canSubmit, isFalse);
        expect(a.canCancel, isTrue);
        expect(a.canMarkLines, isFalse, reason: 'no update on 20');
        expect(a.canApprove, isFalse, reason: 'no update on 96');
      });
    }

    test('cancelled: nothing at all', () {
      final a = _of(PurchaseRequestStatus.cancelled, access);
      expect(a.canEditHeader, isFalse);
      expect(a.canAddLine, isFalse);
      expect(a.canEditLines, isFalse);
      expect(a.canSubmit, isFalse);
      expect(a.canCancel, isFalse);
      expect(a.canMarkLines, isFalse);
      expect(a.canApprove, isFalse);
      expect(a.canReject, isFalse);
      expect(a.canApproveFromQueue, isFalse);
    });
  });

  group('a requester on another facility', () {
    final access = _access(_requester);

    test('has no edit, submit or cancel action', () {
      for (final status in [
        PurchaseRequestStatus.draft,
        PurchaseRequestStatus.submitted,
        PurchaseRequestStatus.approved,
      ]) {
        final a = _of(status, access, facility: _foreign);
        expect(a.own, isFalse);
        expect(a.canEditHeader, isFalse, reason: status.name);
        expect(a.canAddLine, isFalse, reason: status.name);
        expect(a.canEditLines, isFalse, reason: status.name);
        expect(a.canSubmit, isFalse, reason: status.name);
        expect(a.canCancel, isFalse, reason: status.name);
      }
    });

    test('a request with no facility counts as their own', () {
      final a = _of(PurchaseRequestStatus.draft, access, facility: null);
      expect(a.own, isTrue);
      expect(a.canSubmit, isTrue);
    });
  });

  group('an administrator', () {
    test('has every action on a foreign facility', () {
      final access = _access(const {}, administrator: true);
      final draft = _of(
        PurchaseRequestStatus.draft,
        access,
        facility: _foreign,
      );
      expect(draft.own, isTrue);
      expect(draft.canEditHeader, isTrue);
      expect(draft.canAddLine, isTrue);
      expect(draft.canSubmit, isTrue);
      expect(draft.canCancel, isTrue);
      final submitted = _of(
        PurchaseRequestStatus.submitted,
        access,
        facility: _foreign,
      );
      expect(submitted.canApprove, isTrue);
      expect(submitted.canReject, isTrue);
      expect(submitted.canMarkLines, isTrue);
      expect(submitted.canApproveFromQueue, isTrue);
    });
  });

  group('approve, reject and marks ignore the facility', () {
    final access = _access(const {
      SystemObject.purchaseRequest: _read,
      SystemObject.purchaseRequestApproval: _update,
      SystemObject.purchasesOrders: _update,
    });

    test('a foreign submitted request can be decided and marked', () {
      final a = _of(
        PurchaseRequestStatus.submitted,
        access,
        facility: _foreign,
      );
      expect(a.canApprove, isTrue);
      expect(a.canReject, isTrue);
      expect(a.canMarkLines, isTrue);
      expect(a.canApproveFromQueue, isTrue);
      expect(a.canCancel, isFalse);
      expect(a.canSubmit, isFalse);
    });

    test('a foreign approved request can be marked but not decided', () {
      final a = _of(PurchaseRequestStatus.approved, access, facility: _foreign);
      expect(a.canMarkLines, isTrue);
      expect(a.canApprove, isFalse);
      expect(a.canReject, isFalse);
    });

    test('a draft or cancelled request is neither decided nor marked', () {
      for (final status in [
        PurchaseRequestStatus.draft,
        PurchaseRequestStatus.cancelled,
      ]) {
        final a = _of(status, access);
        expect(a.canApprove, isFalse, reason: status.name);
        expect(a.canMarkLines, isFalse, reason: status.name);
        expect(a.canApproveFromQueue, isFalse, reason: status.name);
      }
    });
  });

  group('each right is needed', () {
    PurchaseRequestAvailability draft(Map<SystemObject, int> grants) =>
        _of(PurchaseRequestStatus.draft, _access(grants));

    test('update on 86 edits lines and submits; without it nothing', () {
      final a = draft(const {SystemObject.purchaseRequest: _read | _delete});
      expect(a.canEditLines, isFalse);
      expect(a.canSubmit, isFalse);
      expect(a.canEditHeader, isFalse);
      expect(a.canAddLine, isFalse);
      expect(a.canCancel, isTrue);
    });

    test('the header also needs read on warehouses', () {
      final a = draft(const {SystemObject.purchaseRequest: _update});
      expect(a.canEditLines, isTrue);
      expect(a.canEditHeader, isFalse);
    });

    test('adding a product also needs read on products', () {
      final a = draft(const {
        SystemObject.purchaseRequest: _update,
        SystemObject.warehouses: _read,
      });
      expect(a.canEditHeader, isTrue);
      expect(a.canAddLine, isFalse);
    });

    test('cancel needs delete on 86', () {
      final a = draft(const {SystemObject.purchaseRequest: _read | _update});
      expect(a.canCancel, isFalse);
    });

    test('approve needs update on 96 and read on 86', () {
      final submitted = PurchaseRequestStatus.submitted;
      expect(
        _of(
          submitted,
          _access(const {SystemObject.purchaseRequestApproval: _update}),
        ).canApprove,
        isFalse,
        reason: 'no read on 86',
      );
      expect(
        _of(
          submitted,
          _access(const {SystemObject.purchaseRequestApproval: _update}),
        ).canApproveFromQueue,
        isTrue,
        reason: 'the queue row needs only update on 96',
      );
      expect(
        _of(
          submitted,
          _access(const {
            SystemObject.purchaseRequestApproval: _read,
            SystemObject.purchaseRequest: _read,
          }),
        ).canApprove,
        isFalse,
        reason: 'read on 96 is not update',
      );
    });

    test('a queue row opens the detail only with read on 86', () {
      final submitted = PurchaseRequestStatus.submitted;
      expect(
        _of(
          submitted,
          _access(const {SystemObject.purchaseRequestApproval: _update}),
        ).canOpenFromQueue,
        isFalse,
      );
      expect(
        _of(
          submitted,
          _access(const {SystemObject.purchaseRequest: _read}),
        ).canOpenFromQueue,
        isTrue,
      );
    });

    test('marking needs update on 20', () {
      final submitted = PurchaseRequestStatus.submitted;
      expect(
        _of(
          submitted,
          _access(const {SystemObject.purchasesOrders: _read}),
        ).canMarkLines,
        isFalse,
      );
    });
  });
}
