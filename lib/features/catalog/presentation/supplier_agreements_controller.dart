import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/supplier_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_agreement.dart';

part 'supplier_agreements_controller.g.dart';

/// Loads the open supplier's agreements for the Agreements section
/// (spec 050, FR-016) — a family provider keyed by supplier id. The server
/// returns them unordered, so they are sorted here, newest start first. No
/// search/pagination: a per-supplier collection is small and bounded.
/// Refreshed (via `ref.invalidate`) after an agreement is saved or removed.
@riverpod
class SupplierAgreementsController extends _$SupplierAgreementsController {
  @override
  Future<List<SupplierAgreement>> build(int supplierId) async {
    final agreements = await ref
        .read(supplierRepositoryProvider)
        .listAgreements(supplierId: supplierId);
    return [...agreements]..sort((a, b) => b.start.compareTo(a.start));
  }
}
