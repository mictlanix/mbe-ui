import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:one_of/any_of.dart';

/// `quantity`/`price`/`discount_rate`/`tax_rate`/`price_adjustment` are all
/// `anyOf: [string, num]` in mbe-api's schema; this project always sends the
/// String arm via `AnyOf2<String, num>(values: {0: value})` (String first,
/// key `0` — mirrors the proven `_setCommission`/`_setOpeningAmount`
/// precedents in sibling repositories, verified there against a live
/// serialization round-trip). Each generated wrapper type is distinct
/// (`Quantity`/`Price1`/`DiscountRate`/`DiscountRate1`/`TaxRate1`/
/// `PriceAdjustment`/`PriceAdjustment1`), so each gets its own tiny setter
/// rather than one generic function.
///
/// Promoted out of `sales_order_repository_impl.dart` (spec 040, contracts/
/// sales-quote-repository.md §3) — `Quantity`, `Price1`, `DiscountRate` and
/// `DiscountRate1` are the **same generated types** the quote line bodies
/// use, so the four order setters are reusable verbatim; only
/// `setPriceAdjustment`/`setPriceAdjustment1` are new, for the quote-only
/// absolute per-line markup (spec A3 — round-tripped, not written by any
/// shared widget in v1).
void setQuantity(api.QuantityBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void setPrice1(api.Price1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void setDiscountRate(api.DiscountRateBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void setDiscountRate1(api.DiscountRate1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void setTaxRate1(api.TaxRate1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void setPriceAdjustment(api.PriceAdjustmentBuilder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}

void setPriceAdjustment1(api.PriceAdjustment1Builder builder, String value) {
  builder.anyOf = AnyOf2<String, num>(values: {0: value});
}
