import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'customer_discount.freezed.dart';

/// A negotiated discount on one product for one customer (data-model.md),
/// mapped from `CustomerDiscountResponse`. [discount] is the wire's decimal
/// **fraction** string (`"0.12500000"` is 12.5 %); turning it into a
/// percentage is the presentation layer's job.
@freezed
abstract class CustomerDiscount with _$CustomerDiscount {
  const factory CustomerDiscount({
    required int customerDiscountId,
    required int customerId,
    required int productId,
    required String productCode,
    required String productName,
    required String discount,
  }) = _CustomerDiscount;

  factory CustomerDiscount.fromResponse(CustomerDiscountResponse r) =>
      CustomerDiscount(
        customerDiscountId: r.customerDiscountId,
        customerId: r.customer,
        productId: r.product.productId,
        productCode: r.product.code,
        productName: r.product.name,
        discount: r.discount,
      );
}
