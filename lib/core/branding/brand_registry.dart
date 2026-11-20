import 'package:mbe_ui/core/branding/brand_definition.dart';
import 'package:mbe_ui/core/branding/brands/casa_maestra_brand.dart';
import 'package:mbe_ui/core/branding/brands/xbe_brand.dart';

/// Every brand a build can select with `BRAND_ID` (spec 077 FR-001). Kept apart
/// from `brand_definition.dart` so the brand files can import the types
/// without a cycle.
const Map<String, BrandDefinition> kBrandRegistry = {
  'xbe': xbeBrand,
  'xbe.cm': casaMaestraBrand,
};

/// The brand for [brandId]. An empty, `mbe`, `xbe` or unknown ID resolves to
/// the default XBE brand (FR-003): a malformed build flag must not brick
/// startup.
BrandDefinition brandDefinitionById(String brandId) =>
    kBrandRegistry[brandId] ?? xbeBrand;

/// `true` when [brandId] names a registered brand other than the default.
bool isRegisteredBrand(String brandId) => kBrandRegistry.containsKey(brandId);
