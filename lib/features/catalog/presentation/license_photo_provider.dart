import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';

part 'license_photo_provider.g.dart';

/// A vehicle operator's stored license photo, as PNG bytes.
///
/// An autodispose family keyed by operator id, and deliberately not kept
/// alive: the photo is personal data, so the bytes go when the form closes
/// (051 R3, constitution §VII — no caching layer). It is a provider of its
/// own, not a field on the form state, so a slow or failed photo read never
/// reads as an edit to the dirty check and never stops the fields from
/// rendering (FR-014).
@riverpod
Future<Uint8List> licensePhoto(Ref ref, int vehicleOperatorId) {
  return ref
      .watch(vehicleOperatorRepositoryProvider)
      .getLicensePhoto(vehicleOperatorId: vehicleOperatorId);
}
