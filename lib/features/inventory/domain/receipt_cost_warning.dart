/// Why a confirm or cancel left a product's cost alone (mbe-api#322).
enum ReceiptCostWarningKind {
  /// `purchase_cost.zero_price`: priced at 0 on the order, cost unchanged.
  zeroPrice,

  /// `purchase_cost.not_restored`: on cancel, a later receipt changed the
  /// cost since, so it was not restored.
  notRestored,

  /// A cost warning code this client doesn't know yet.
  other,
}

/// One cost warning from a confirm or cancel response. [productCode] falls
/// back to the product id as text; [receipt] is the later receipt's label,
/// set only for [ReceiptCostWarningKind.notRestored].
typedef ReceiptCostWarning = ({
  ReceiptCostWarningKind kind,
  String productCode,
  String? receipt,
});
