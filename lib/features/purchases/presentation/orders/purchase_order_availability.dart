import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

/// What the user may do with one order (spec 080 data-model "Action
/// availability"). Pure: it needs only the order's [status] and line count
/// and the user's rights. Orders are not facility-scoped (FR-003), so there
/// is no facility rule.
///
/// A missing right means the control is absent, never disabled (§IV). The
/// one state-based exception is [confirmNeedsLines], which the screen turns
/// into a disabled Confirmar with a tooltip.
///
/// System objects: PurchasesOrders = 20, InventoryReceipts = 15,
/// PurchaseRequest = 86, Suppliers = 3, Products = 0, Warehouses = 4.
class PurchaseOrderAvailability {
  const PurchaseOrderAvailability({
    required this.status,
    required this.access,
    this.lineCount = 0,
  });

  /// The order's status; null where there is no order yet (the list bar,
  /// Por comprar), where only [canCreate] and [canCreateFromGroup] apply.
  final InventoryDocumentStatus? status;
  final AccessControlService access;
  final int lineCount;

  bool get _isDraft => status == InventoryDocumentStatus.draft;
  bool get _isConfirmed => status == InventoryDocumentStatus.completed;

  bool _can(SystemObject object, AccessRight right) =>
      access.can(object, right);

  bool get _update => _can(SystemObject.purchasesOrders, AccessRight.update);

  /// Nueva orden: create on 20 and read on suppliers (its picker).
  bool get canCreate =>
      _can(SystemObject.purchasesOrders, AccessRight.create) &&
      _can(SystemObject.suppliers, AccessRight.read);

  /// Por comprar's Crear orden: create on 20. Disabled, not absent, while no
  /// group is selected (state, not rights).
  bool get canCreateFromGroup =>
      _can(SystemObject.purchasesOrders, AccessRight.create);

  /// Editar encabezado: update on 20 and read on suppliers (its picker).
  bool get canEditHeader =>
      _isDraft && _update && _can(SystemObject.suppliers, AccessRight.read);

  /// Agregar producto: update on 20 and read on products (its picker).
  bool get canAddLine =>
      _isDraft && _update && _can(SystemObject.products, AccessRight.read);

  /// Agregar solicitud: update on 20 and read on 86 (its picker).
  bool get canAddRequestLines =>
      _isDraft &&
      _update &&
      _can(SystemObject.purchaseRequest, AccessRight.read);

  /// A line's ✎: update on 20 and read on warehouses (its picker).
  bool get canEditLines =>
      _isDraft && _update && _can(SystemObject.warehouses, AccessRight.read);

  /// A line's 🗑: update on 20.
  bool get canRemoveLines => _isDraft && _update;

  /// Confirmar: update on 20 on a draft.
  bool get canConfirm => _isDraft && _update;

  /// Confirmar is shown but disabled, with a tooltip, while the draft has no
  /// lines.
  bool get confirmNeedsLines => canConfirm && lineCount == 0;

  /// Cancelar orden: delete on 20, only on a draft (FR-024).
  bool get canCancel =>
      _isDraft && _can(SystemObject.purchasesOrders, AccessRight.delete);

  /// Imprimir: read on 20, on a confirmed order (FR-026).
  bool get canPrint =>
      _isConfirmed && _can(SystemObject.purchasesOrders, AccessRight.read);

  /// Enviar por correo: update on 20, on a confirmed order (FR-027).
  bool get canEmail => _isConfirmed && _update;

  /// A receipt's "Abrir": read on 15.
  bool get canOpenReceipt =>
      _isConfirmed && _can(SystemObject.inventoryReceipts, AccessRight.read);
}
