import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';

/// Address lookup and creation — deliberately **not** full CRUD
/// (data-model.md "AddressListItem", contracts/mbe-api-catalogs.md
/// §Addresses). [list] backs the facility form's address
/// `CatalogEntityPicker`; [create] backs its inline-create dialog
/// (FR-031/032). Addresses have no screens of their own in this feature —
/// get/update/delete are intentionally not exposed here.
abstract class AddressRepository {
  Future<AddressListResult> list({String? search, int skip = 0, int limit = 20});

  Future<AddressListItem> create(AddressCreatePayload payload);
}

class AddressListResult {
  const AddressListResult({required this.items, required this.total});
  final List<AddressListItem> items;
  final int total;
}
