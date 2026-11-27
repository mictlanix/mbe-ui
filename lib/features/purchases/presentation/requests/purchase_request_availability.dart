import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

/// What the user may do with one request (spec 079 data-model "Action
/// availability", research R12). Pure: it needs only the request's [status]
/// and [facilityId], which both `PurchaseRequestSummary` and
/// `PurchaseRequest` carry, so the detail and the queue rows share the rules.
///
/// A missing right means the control is absent, never disabled (§IV, FR-025).
/// System objects: PurchaseRequest = 86, PurchaseRequestApproval = 96,
/// PurchasesOrders = 20, Warehouses = 4.
class PurchaseRequestAvailability {
  const PurchaseRequestAvailability({
    required this.status,
    required this.facilityId,
    required this.access,
    required this.userFacilityId,
  });

  final PurchaseRequestStatus status;

  /// The request's facility; null when the server has none.
  final int? facilityId;
  final AccessControlService access;

  /// The user's facility (`UserSettings.facilityId`).
  final int? userFacilityId;

  bool get _isDraft => status == PurchaseRequestStatus.draft;
  bool get _isSubmitted => status == PurchaseRequestStatus.submitted;

  /// An administrator, a request with no facility, or the user's own
  /// facility. Header, line, submit and cancel actions need it; approve,
  /// reject and line marking do not, because the server doesn't limit them by
  /// facility.
  bool get own =>
      access.isAdministrator ||
      facilityId == null ||
      facilityId == userFacilityId;

  bool _can(SystemObject object, AccessRight right) =>
      access.can(object, right);

  /// Editar encabezado: update on 86 and read on warehouses (its picker).
  bool get canEditHeader =>
      _isDraft &&
      own &&
      _can(SystemObject.purchaseRequest, AccessRight.update) &&
      _can(SystemObject.warehouses, AccessRight.read);

  /// Agregar producto: update on 86 and read on products (its picker).
  bool get canAddLine =>
      _isDraft &&
      own &&
      _can(SystemObject.purchaseRequest, AccessRight.update) &&
      _can(SystemObject.products, AccessRight.read);

  /// Line edit and remove icons.
  bool get canEditLines =>
      _isDraft && own && _can(SystemObject.purchaseRequest, AccessRight.update);

  bool get canSubmit => canEditLines;

  /// Cancelar: any state but cancelled, with delete on 86.
  bool get canCancel =>
      status != PurchaseRequestStatus.cancelled &&
      own &&
      _can(SystemObject.purchaseRequest, AccessRight.delete);

  /// Mark or unmark a line: update on PurchasesOrders, on a submitted or
  /// approved request, in any facility.
  bool get canMarkLines =>
      (_isSubmitted || status == PurchaseRequestStatus.approved) &&
      _can(SystemObject.purchasesOrders, AccessRight.update);

  /// Aprobar on the detail: update on 96, plus read on 86 to be there.
  bool get canApprove =>
      _isSubmitted &&
      _can(SystemObject.purchaseRequestApproval, AccessRight.update) &&
      _can(SystemObject.purchaseRequest, AccessRight.read);

  bool get canReject => canApprove;

  /// Whether a queue row opens the detail.
  bool get canOpenFromQueue =>
      _can(SystemObject.purchaseRequest, AccessRight.read);

  /// The queue's row ✓ and its checkbox.
  bool get canApproveFromQueue =>
      _isSubmitted &&
      _can(SystemObject.purchaseRequestApproval, AccessRight.update);
}
