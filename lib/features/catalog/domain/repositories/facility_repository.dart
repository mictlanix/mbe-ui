import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';

/// Facility lookup and full CRUD management (data-model.md, US4,
/// contracts/mbe-api-catalogs.md §Facilities). [list] backs both the
/// Facilities catalog's own list screen and the facility
/// `CatalogEntityPicker`/filter facet the other three operational catalogs
/// consume — foundational to every story in this feature (FR-023).
abstract class FacilityRepository {
  Future<FacilityListResult> list({
    String? search,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  });

  Future<Facility> get({required int facilityId});

  Future<Facility> create({
    required String code,
    required String name,
    FacilityType? type,
    required String location,
    required int address,
    required String taxpayer,
    String? logo,
    String? receiptMessage,
    String? defaultBatch,
    EntityStatus? status,
  });

  Future<Facility> update({
    required int facilityId,
    String? code,
    String? name,
    FacilityType? type,
    String? location,
    int? address,
    String? taxpayer,
    String? logo,
    String? receiptMessage,
    String? defaultBatch,
    EntityStatus? status,
  });

  Future<void> delete({required int facilityId});
}

class FacilityListResult {
  const FacilityListResult({required this.items, required this.total});
  final List<FacilityListItem> items;
  final int total;
}
