import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// The codes [localizeProblem] renders (spec 058, contracts/message-catalog.md).
///
/// A later spec that builds screens for a new area adds that area's codes
/// here, to the switch in [localizeProblem] and to both ARB files together.
/// `test/unit/core/errors/catalog_coverage_test.dart` checks that every member
/// renders in both languages.
const Set<api.ErrorCode> localizedErrorCodes = {
  api.ErrorCode.authPeriodAdministratorRequired,
  api.ErrorCode.authPeriodForbidden,
  api.ErrorCode.authPeriodIncorrectCurrentPassword,
  api.ErrorCode.authPeriodInvalidCredentials,
  api.ErrorCode.authPeriodNotAuthenticated,
  api.ErrorCode.authPeriodPasswordChangeRequired,
  api.ErrorCode.authPeriodRecoveryTokenInvalid,
  api.ErrorCode.cashSessionPeriodAlreadyClosed,
  api.ErrorCode.cashSessionPeriodClosed,
  api.ErrorCode.cashSessionPeriodDrawerBusy,
  api.ErrorCode.cashSessionPeriodNotClosed,
  api.ErrorCode.cashSessionPeriodNotOpen,
  api.ErrorCode.cashSessionPeriodUserBusy,
  api.ErrorCode.csdPeriodCertificateNotRsa,
  api.ErrorCode.csdPeriodCertificateUnreadable,
  api.ErrorCode.csdPeriodKeyMismatch,
  api.ErrorCode.csdPeriodKeyNotEncrypted,
  api.ErrorCode.csdPeriodKeyNotRsa,
  api.ErrorCode.csdPeriodKeyUnreadable,
  api.ErrorCode.customerPeriodCreditHold,
  api.ErrorCode.customerPeriodCreditLimitExceeded,
  api.ErrorCode.customerPeriodCreditLimitReached,
  api.ErrorCode.customerPeriodDefaultNotDeletable,
  api.ErrorCode.customerPeriodNoCreditLimit,
  api.ErrorCode.customerPeriodWalkInNoCredit,
  api.ErrorCode.customerDiscountPeriodProductNotFound,
  api.ErrorCode.deliveryOrderPeriodLineAlreadyPresent,
  api.ErrorCode.deliveryOrderPeriodLineNotDeliverable,
  api.ErrorCode.deliveryOrderPeriodLineRepeated,
  api.ErrorCode.deliveryOrderPeriodMixedNotAllowed,
  api.ErrorCode.deliveryOrderPeriodNotEditable,
  api.ErrorCode.deliveryOrderPeriodQuantityExceedsRemaining,
  api.ErrorCode.deliveryOrderPeriodReasonRequired,
  api.ErrorCode.deliveryOrderPeriodSalesOrderFullyDelivered,
  api.ErrorCode.deliveryOrderPeriodSalesOrderNotDeliverable,
  api.ErrorCode.deliveryOrderPeriodSalesOrderUnpaid,
  api.ErrorCode.documentPeriodNotEditable,
  api.ErrorCode.emailPeriodNotConfigured,
  api.ErrorCode.emailPeriodSendFailed,
  api.ErrorCode.facilityPeriodNoDispatchWarehouse,
  api.ErrorCode.facilityPeriodOtherFacility,
  api.ErrorCode.facilityPeriodRequired,
  api.ErrorCode.imagePeriodTooLarge,
  api.ErrorCode.imagePeriodUnsupportedFormat,
  api.ErrorCode.incidencePeriodReasonRequired,
  api.ErrorCode.lockPeriodBusy,
  api.ErrorCode.paymentPeriodNoTicket,
  api.ErrorCode.pointOfSalePeriodWarehouseFacilityMismatch,
  api.ErrorCode.priceListPeriodCostNotAssignable,
  api.ErrorCode.priceListPeriodCostNotDeletable,
  api.ErrorCode.priceListPeriodCostReadOnly,
  api.ErrorCode.priceListPeriodReplaceWithItself,
  api.ErrorCode.productPeriodLookupCriteriaRequired,
  api.ErrorCode.productPeriodLookupTooMany,
  api.ErrorCode.productPeriodMergeWithItself,
  api.ErrorCode.productPricePeriodDuplicateEntry,
  api.ErrorCode.productPricePeriodReferencesNotFound,
  api.ErrorCode.quotePeriodAlreadyCancelled,
  api.ErrorCode.quotePeriodCancelled,
  api.ErrorCode.quotePeriodExpired,
  api.ErrorCode.quotePeriodNotConfirmed,
  api.ErrorCode.refundPeriodAlreadyCancelled,
  api.ErrorCode.refundPeriodCompletedCannotCancel,
  api.ErrorCode.refundPeriodLineInvoiced,
  api.ErrorCode.refundPeriodNoReturnableLines,
  api.ErrorCode.refundPeriodNotConfirmed,
  api.ErrorCode.refundPeriodNothingRefundable,
  api.ErrorCode.refundPeriodOrderNotCompleted,
  api.ErrorCode.refundPeriodOrderNotPaid,
  api.ErrorCode.requestPeriodMalformed,
  api.ErrorCode.requestPeriodMethodNotAllowed,
  api.ErrorCode.requestPeriodRouteNotFound,
  api.ErrorCode.resourcePeriodAlreadyExists,
  api.ErrorCode.resourcePeriodConflict,
  api.ErrorCode.resourcePeriodNotFound,
  api.ErrorCode.resourcePeriodStillReferenced,
  api.ErrorCode.salesOrderPeriodAlreadyCancelled,
  api.ErrorCode.salesOrderPeriodBelowMinQuantity,
  api.ErrorCode.salesOrderPeriodHasPaymentApplications,
  api.ErrorCode.salesOrderPeriodInsufficientStock,
  api.ErrorCode.salesOrderPeriodMissingDeliveryDetails,
  api.ErrorCode.salesOrderPeriodNoLines,
  api.ErrorCode.salesOrderPeriodPaidCannotCancel,
  api.ErrorCode.salesOrderPeriodZeroPricedLines,
  api.ErrorCode.serverPeriodError,
  api.ErrorCode.statePeriodTransitionInvalid,
  api.ErrorCode.supplierAgreementPeriodEndBeforeStart,
  api.ErrorCode.taxpayerCertificatePeriodHolderMismatch,
  api.ErrorCode.taxpayerIssuerPeriodUnknown,
  api.ErrorCode.userPeriodNoCashDrawer,
  api.ErrorCode.userPeriodNoFacility,
  api.ErrorCode.userPeriodNoPointOfSale,
  api.ErrorCode.userProfilePeriodNotActive,
  api.ErrorCode.warehousePeriodInTransitLocation,
  api.ErrorCode.warehousePeriodInTransitManaged,
  api.ErrorCode.warehousePeriodRequired,
};

/// The validation `type`s [localizeValidationType] renders.
const Set<String> localizedValidationTypes = {
  'contact_name_blank',
  'email_address_invalid',
  'product_barcode_invalid',
  'product_code_has_whitespace',
  'profile_duplicate_system_object',
  'profile_unknown_system_object',
  'supplier_agreement_end_before_start',
  'user_id_not_alphanumeric',
};

/// The message for [problem] in the user's language, with amounts, quantities
/// and dates formatted by [fmt] (spec 028), or `null` when there is none:
/// a code this client does not know, or a param the message needs that is
/// missing or of the wrong type (FR-004). A `null` makes the caller fall back
/// to today's display.
String? localizeProblem(
  ApiProblem problem,
  AppLocalizations l10n,
  AppFormatters fmt,
) {
  final code = problem.code;
  if (code == null) return null;
  return switch (code) {
    api.ErrorCode.authPeriodAdministratorRequired =>
      l10n.apiErrorAuthAdministratorRequired,
    api.ErrorCode.authPeriodForbidden => l10n.apiErrorAuthForbidden,
    api.ErrorCode.authPeriodIncorrectCurrentPassword =>
      l10n.apiErrorAuthIncorrectCurrentPassword,
    api.ErrorCode.authPeriodInvalidCredentials =>
      l10n.apiErrorAuthInvalidCredentials,
    api.ErrorCode.authPeriodNotAuthenticated =>
      l10n.apiErrorAuthNotAuthenticated,
    api.ErrorCode.authPeriodPasswordChangeRequired =>
      l10n.apiErrorAuthPasswordChangeRequired,
    api.ErrorCode.authPeriodRecoveryTokenInvalid =>
      l10n.apiErrorAuthRecoveryTokenInvalid,
    api.ErrorCode.requestPeriodMalformed => l10n.apiErrorRequestMalformed,
    api.ErrorCode.requestPeriodMethodNotAllowed =>
      l10n.apiErrorRequestMethodNotAllowed,
    api.ErrorCode.requestPeriodRouteNotFound =>
      l10n.apiErrorRequestRouteNotFound,
    api.ErrorCode.resourcePeriodConflict => l10n.apiErrorResourceConflict,
    api.ErrorCode.serverPeriodError => l10n.apiErrorServerError,
    api.ErrorCode.statePeriodTransitionInvalid =>
      l10n.apiErrorStateTransitionInvalid,
    api.ErrorCode.resourcePeriodNotFound => _ap1(
      problem.stringParam('resource'),
      (r) => l10n.apiErrorResourceNotFound(
        resourceGender(r, l10n),
        resourceNoun(r, l10n),
      ),
    ),
    api.ErrorCode.resourcePeriodAlreadyExists => _ap1(
      problem.stringParam('resource'),
      (r) => l10n.apiErrorResourceAlreadyExists(
        resourceGender(r, l10n),
        resourceNoun(r, l10n),
      ),
    ),
    api.ErrorCode.resourcePeriodStillReferenced => _stillReferenced(
      problem,
      l10n,
      fmt,
    ),
    api.ErrorCode.cashSessionPeriodAlreadyClosed =>
      l10n.apiErrorCashSessionAlreadyClosed,
    api.ErrorCode.cashSessionPeriodClosed => l10n.apiErrorCashSessionClosed,
    api.ErrorCode.cashSessionPeriodDrawerBusy =>
      l10n.apiErrorCashSessionDrawerBusy,
    api.ErrorCode.cashSessionPeriodNotClosed =>
      l10n.apiErrorCashSessionNotClosed,
    api.ErrorCode.cashSessionPeriodNotOpen => l10n.apiErrorCashSessionNotOpen,
    api.ErrorCode.cashSessionPeriodUserBusy => l10n.apiErrorCashSessionUserBusy,
    api.ErrorCode.csdPeriodCertificateNotRsa =>
      l10n.apiErrorCsdCertificateNotRsa,
    api.ErrorCode.csdPeriodCertificateUnreadable =>
      l10n.apiErrorCsdCertificateUnreadable,
    api.ErrorCode.csdPeriodKeyMismatch => l10n.apiErrorCsdKeyMismatch,
    api.ErrorCode.csdPeriodKeyNotEncrypted => l10n.apiErrorCsdKeyNotEncrypted,
    api.ErrorCode.csdPeriodKeyNotRsa => l10n.apiErrorCsdKeyNotRsa,
    api.ErrorCode.csdPeriodKeyUnreadable => l10n.apiErrorCsdKeyUnreadable,
    api.ErrorCode.customerPeriodCreditHold => _ap1(
      problem.intParam('overdue_count'),
      l10n.apiErrorCustomerCreditHold,
    ),
    api.ErrorCode.customerPeriodCreditLimitExceeded => _ap2(
      _money(problem, 'outstanding', fmt),
      _money(problem, 'limit', fmt),
      l10n.apiErrorCustomerCreditLimitExceeded,
    ),
    api.ErrorCode.customerPeriodCreditLimitReached => _ap2(
      _money(problem, 'outstanding', fmt),
      _money(problem, 'limit', fmt),
      l10n.apiErrorCustomerCreditLimitReached,
    ),
    api.ErrorCode.customerPeriodDefaultNotDeletable =>
      l10n.apiErrorCustomerDefaultNotDeletable,
    api.ErrorCode.customerPeriodNoCreditLimit =>
      l10n.apiErrorCustomerNoCreditLimit,
    api.ErrorCode.customerPeriodWalkInNoCredit =>
      l10n.apiErrorCustomerWalkInNoCredit,
    api.ErrorCode.customerDiscountPeriodProductNotFound =>
      l10n.apiErrorCustomerDiscountProductNotFound,
    api.ErrorCode.deliveryOrderPeriodLineAlreadyPresent =>
      l10n.apiErrorDeliveryOrderLineAlreadyPresent,
    api.ErrorCode.deliveryOrderPeriodLineNotDeliverable =>
      l10n.apiErrorDeliveryOrderLineNotDeliverable,
    api.ErrorCode.deliveryOrderPeriodLineRepeated =>
      l10n.apiErrorDeliveryOrderLineRepeated,
    api.ErrorCode.deliveryOrderPeriodMixedNotAllowed =>
      l10n.apiErrorDeliveryOrderMixedNotAllowed,
    api.ErrorCode.deliveryOrderPeriodNotEditable =>
      l10n.apiErrorDeliveryOrderNotEditable,
    api.ErrorCode.deliveryOrderPeriodQuantityExceedsRemaining => _ap2(
      _quantity(problem, 'requested', fmt),
      _quantity(problem, 'remaining', fmt),
      l10n.apiErrorDeliveryOrderQuantityExceedsRemaining,
    ),
    api.ErrorCode.deliveryOrderPeriodReasonRequired =>
      l10n.apiErrorDeliveryOrderReasonRequired,
    api.ErrorCode.deliveryOrderPeriodSalesOrderFullyDelivered =>
      l10n.apiErrorDeliveryOrderSalesOrderFullyDelivered,
    api.ErrorCode.deliveryOrderPeriodSalesOrderNotDeliverable =>
      l10n.apiErrorDeliveryOrderSalesOrderNotDeliverable,
    api.ErrorCode.deliveryOrderPeriodSalesOrderUnpaid =>
      l10n.apiErrorDeliveryOrderSalesOrderUnpaid,
    api.ErrorCode.documentPeriodNotEditable => l10n.apiErrorDocumentNotEditable,
    api.ErrorCode.emailPeriodNotConfigured => l10n.apiErrorEmailNotConfigured,
    api.ErrorCode.emailPeriodSendFailed => l10n.apiErrorEmailSendFailed,
    api.ErrorCode.facilityPeriodNoDispatchWarehouse =>
      l10n.apiErrorFacilityNoDispatchWarehouse,
    api.ErrorCode.facilityPeriodOtherFacility => _ap1(
      problem.stringParam('resource'),
      (r) => l10n.apiErrorFacilityOtherFacility(
        resourceGender(r, l10n),
        resourceNoun(r, l10n),
      ),
    ),
    api.ErrorCode.facilityPeriodRequired => l10n.apiErrorFacilityRequired,
    api.ErrorCode.imagePeriodTooLarge => _ap1(
      _size(problem, 'max_bytes', fmt),
      l10n.apiErrorImageTooLarge,
    ),
    api.ErrorCode.imagePeriodUnsupportedFormat =>
      l10n.apiErrorImageUnsupportedFormat,
    api.ErrorCode.incidencePeriodReasonRequired =>
      l10n.apiErrorIncidenceReasonRequired,
    api.ErrorCode.lockPeriodBusy => l10n.apiErrorLockBusy,
    api.ErrorCode.paymentPeriodNoTicket => l10n.apiErrorPaymentNoTicket,
    api.ErrorCode.pointOfSalePeriodWarehouseFacilityMismatch =>
      l10n.apiErrorPointOfSaleWarehouseFacilityMismatch,
    api.ErrorCode.priceListPeriodCostNotAssignable =>
      l10n.apiErrorPriceListCostNotAssignable,
    api.ErrorCode.priceListPeriodCostNotDeletable =>
      l10n.apiErrorPriceListCostNotDeletable,
    api.ErrorCode.priceListPeriodCostReadOnly =>
      l10n.apiErrorPriceListCostReadOnly,
    api.ErrorCode.priceListPeriodReplaceWithItself =>
      l10n.apiErrorPriceListReplaceWithItself,
    api.ErrorCode.productPeriodLookupCriteriaRequired =>
      l10n.apiErrorProductLookupCriteriaRequired,
    api.ErrorCode.productPeriodLookupTooMany => _ap1(
      _count(problem, 'max', fmt),
      l10n.apiErrorProductLookupTooMany,
    ),
    api.ErrorCode.productPeriodMergeWithItself =>
      l10n.apiErrorProductMergeWithItself,
    api.ErrorCode.productPricePeriodDuplicateEntry =>
      l10n.apiErrorProductPriceDuplicateEntry,
    api.ErrorCode.productPricePeriodReferencesNotFound => _ap1(
      problem.stringParam('resource'),
      (r) => l10n.apiErrorProductPriceReferencesNotFound(
        resourceGender(r, l10n),
        resourceNoun(r, l10n, count: 2),
      ),
    ),
    api.ErrorCode.quotePeriodAlreadyCancelled =>
      l10n.apiErrorQuoteAlreadyCancelled,
    api.ErrorCode.quotePeriodCancelled => l10n.apiErrorQuoteCancelled,
    api.ErrorCode.quotePeriodExpired => l10n.apiErrorQuoteExpired,
    api.ErrorCode.quotePeriodNotConfirmed => l10n.apiErrorQuoteNotConfirmed,
    api.ErrorCode.refundPeriodAlreadyCancelled =>
      l10n.apiErrorRefundAlreadyCancelled,
    api.ErrorCode.refundPeriodCompletedCannotCancel =>
      l10n.apiErrorRefundCompletedCannotCancel,
    api.ErrorCode.refundPeriodLineInvoiced => _ap1(
      problem.stringParam('product_code'),
      (product) {
        final invoice = problem.stringParam('invoice');
        return invoice == null
            ? l10n.apiErrorRefundLineInvoicedNoFolio(product)
            : l10n.apiErrorRefundLineInvoiced(product, invoice);
      },
    ),
    api.ErrorCode.refundPeriodNoReturnableLines =>
      l10n.apiErrorRefundNoReturnableLines,
    api.ErrorCode.refundPeriodNotConfirmed => l10n.apiErrorRefundNotConfirmed,
    api.ErrorCode.refundPeriodNothingRefundable =>
      l10n.apiErrorRefundNothingRefundable,
    api.ErrorCode.refundPeriodOrderNotCompleted =>
      l10n.apiErrorRefundOrderNotCompleted,
    api.ErrorCode.refundPeriodOrderNotPaid => l10n.apiErrorRefundOrderNotPaid,
    api.ErrorCode.salesOrderPeriodAlreadyCancelled =>
      l10n.apiErrorSalesOrderAlreadyCancelled,
    api.ErrorCode.salesOrderPeriodBelowMinQuantity => _ap1(
      _count(problem, 'min_order_qty', fmt),
      l10n.apiErrorSalesOrderBelowMinQuantity,
    ),
    api.ErrorCode.salesOrderPeriodHasPaymentApplications =>
      l10n.apiErrorSalesOrderHasPaymentApplications,
    api.ErrorCode.salesOrderPeriodInsufficientStock => _withItems(
      problem,
      l10n,
      fmt,
      l10n.apiErrorSalesOrderInsufficientStock,
    ),
    api.ErrorCode.salesOrderPeriodMissingDeliveryDetails => _withItems(
      problem,
      l10n,
      fmt,
      l10n.apiErrorSalesOrderMissingDeliveryDetails,
    ),
    api.ErrorCode.salesOrderPeriodNoLines => l10n.apiErrorSalesOrderNoLines,
    api.ErrorCode.salesOrderPeriodPaidCannotCancel =>
      l10n.apiErrorSalesOrderPaidCannotCancel,
    api.ErrorCode.salesOrderPeriodZeroPricedLines => _withItems(
      problem,
      l10n,
      fmt,
      l10n.apiErrorSalesOrderZeroPricedLines,
    ),
    api.ErrorCode.supplierAgreementPeriodEndBeforeStart => _ap2(
      _date(problem, 'end', fmt),
      _date(problem, 'start', fmt),
      l10n.apiErrorSupplierAgreementEndBeforeStart,
    ),
    api.ErrorCode.taxpayerCertificatePeriodHolderMismatch => _ap2(
      problem.stringParam('certificate_taxpayer'),
      problem.stringParam('taxpayer'),
      l10n.apiErrorTaxpayerCertificateHolderMismatch,
    ),
    api.ErrorCode.taxpayerIssuerPeriodUnknown => _ap1(
      problem.stringParam('taxpayer'),
      l10n.apiErrorTaxpayerIssuerUnknown,
    ),
    api.ErrorCode.userPeriodNoCashDrawer => l10n.apiErrorUserNoCashDrawer,
    api.ErrorCode.userPeriodNoFacility => l10n.apiErrorUserNoFacility,
    api.ErrorCode.userPeriodNoPointOfSale => l10n.apiErrorUserNoPointOfSale,
    api.ErrorCode.userProfilePeriodNotActive =>
      l10n.apiErrorUserProfileNotActive,
    api.ErrorCode.warehousePeriodInTransitLocation =>
      l10n.apiErrorWarehouseInTransitLocation,
    api.ErrorCode.warehousePeriodInTransitManaged =>
      l10n.apiErrorWarehouseInTransitManaged,
    api.ErrorCode.warehousePeriodRequired => l10n.apiErrorWarehouseRequired,
    _ => null,
  };
}

/// The message for a request-validation `type` (the `type` of an entry in
/// FastAPI's 422 list), or `null` for an unknown type and for
/// `password_policy`, whose per-rule messages stay in `localizePasswordRule`.
///
/// The messages carry no values from the refusal's `ctx`: the field already
/// shows the value (research R7).
String? localizeValidationType(String type, AppLocalizations l10n) {
  return switch (type) {
    'contact_name_blank' => l10n.apiValidationContactNameBlank,
    'email_address_invalid' => l10n.apiValidationEmailAddressInvalid,
    'product_barcode_invalid' => l10n.apiValidationProductBarcodeInvalid,
    'product_code_has_whitespace' => l10n.apiValidationProductCodeHasWhitespace,
    'profile_duplicate_system_object' =>
      l10n.apiValidationProfileDuplicateSystemObject,
    'profile_unknown_system_object' =>
      l10n.apiValidationProfileUnknownSystemObject,
    'supplier_agreement_end_before_start' =>
      l10n.apiValidationSupplierAgreementEndBeforeStart,
    'user_id_not_alphanumeric' => l10n.apiValidationUserIdNotAlphanumeric,
    _ => null,
  };
}

/// What a form stores for a server field error: the entry's `type` when
/// [localizeValidationType] knows it, so the screen can resolve it to text at
/// render time in the current language, else its English `msg` (as before).
String serverFieldValue(FieldError error) =>
    localizedValidationTypes.contains(error.type) ? error.type : error.msg;

/// The localized noun for a record kind the server names in `params`
/// (`resource: "customer"`), in the singular or, for [count] != 1, the plural.
/// A kind the app has no noun for gets a generic noun ("record") rather than
/// the server's internal name.
String resourceNoun(String? resource, AppLocalizations l10n, {int count = 1}) =>
    switch (resource) {
      'cash_drawer' => l10n.apiResourceCashDrawer(count),
      'cash_session' => l10n.apiResourceCashSession(count),
      'credit_note' => l10n.apiResourceCreditNote(count),
      'customer' => l10n.apiResourceCustomer(count),
      'customer_discount' => l10n.apiResourceCustomerDiscount(count),
      'customer_payment' => l10n.apiResourceCustomerPayment(count),
      'customer_refund' => l10n.apiResourceCustomerRefund(count),
      'delivery_itinerary' => l10n.apiResourceDeliveryItinerary(count),
      'delivery_order' => l10n.apiResourceDeliveryOrder(count),
      'delivery_order_line' => l10n.apiResourceDeliveryOrderLine(count),
      'employee' => l10n.apiResourceEmployee(count),
      'exchange_rate' => l10n.apiResourceExchangeRate(count),
      'expense' => l10n.apiResourceExpense(count),
      'expense_voucher' => l10n.apiResourceExpenseVoucher(count),
      'facility' => l10n.apiResourceFacility(count),
      'fiscal_document' => l10n.apiResourceFiscalDocument(count),
      'inventory_issue' => l10n.apiResourceInventoryIssue(count),
      'inventory_receipt' => l10n.apiResourceInventoryReceipt(count),
      'inventory_transfer' => l10n.apiResourceInventoryTransfer(count),
      'label' => l10n.apiResourceLabel(count),
      'payment_method_option' => l10n.apiResourcePaymentMethodOption(count),
      'point_of_sale' => l10n.apiResourcePointOfSale(count),
      'price_list' => l10n.apiResourcePriceList(count),
      'product' => l10n.apiResourceProduct(count),
      'product_price' => l10n.apiResourceProductPrice(count),
      'purchase_order' => l10n.apiResourcePurchaseOrder(count),
      'sales_order' => l10n.apiResourceSalesOrder(count),
      'sales_order_line' => l10n.apiResourceSalesOrderLine(count),
      'sales_order_payment' => l10n.apiResourceSalesOrderPayment(count),
      'sales_quote' => l10n.apiResourceSalesQuote(count),
      'sales_quote_line' => l10n.apiResourceSalesQuoteLine(count),
      'stock_movement' => l10n.apiResourceStockMovement(count),
      'supplier' => l10n.apiResourceSupplier(count),
      'supplier_payment' => l10n.apiResourceSupplierPayment(count),
      'taxpayer_certificate' => l10n.apiResourceTaxpayerCertificate(count),
      'taxpayer_issuer' => l10n.apiResourceTaxpayerIssuer(count),
      'taxpayer_recipient' => l10n.apiResourceTaxpayerRecipient(count),
      'user' => l10n.apiResourceUser(count),
      'user_profile' => l10n.apiResourceUserProfile(count),
      'vehicle' => l10n.apiResourceVehicle(count),
      'vehicle_operator' => l10n.apiResourceVehicleOperator(count),
      'warehouse' => l10n.apiResourceWarehouse(count),
      _ => l10n.apiResourceGeneric(count),
    };

/// `masculine` or `feminine`: the grammatical gender of [resourceNoun] in
/// Spanish, which the messages that put a noun in a sentence select on.
String resourceGender(String? resource, AppLocalizations l10n) =>
    switch (resource) {
      'cash_drawer' => l10n.apiResourceGenderCashDrawer,
      'cash_session' => l10n.apiResourceGenderCashSession,
      'credit_note' => l10n.apiResourceGenderCreditNote,
      'customer' => l10n.apiResourceGenderCustomer,
      'customer_discount' => l10n.apiResourceGenderCustomerDiscount,
      'customer_payment' => l10n.apiResourceGenderCustomerPayment,
      'customer_refund' => l10n.apiResourceGenderCustomerRefund,
      'delivery_itinerary' => l10n.apiResourceGenderDeliveryItinerary,
      'delivery_order' => l10n.apiResourceGenderDeliveryOrder,
      'delivery_order_line' => l10n.apiResourceGenderDeliveryOrderLine,
      'employee' => l10n.apiResourceGenderEmployee,
      'exchange_rate' => l10n.apiResourceGenderExchangeRate,
      'expense' => l10n.apiResourceGenderExpense,
      'expense_voucher' => l10n.apiResourceGenderExpenseVoucher,
      'facility' => l10n.apiResourceGenderFacility,
      'fiscal_document' => l10n.apiResourceGenderFiscalDocument,
      'inventory_issue' => l10n.apiResourceGenderInventoryIssue,
      'inventory_receipt' => l10n.apiResourceGenderInventoryReceipt,
      'inventory_transfer' => l10n.apiResourceGenderInventoryTransfer,
      'label' => l10n.apiResourceGenderLabel,
      'payment_method_option' => l10n.apiResourceGenderPaymentMethodOption,
      'point_of_sale' => l10n.apiResourceGenderPointOfSale,
      'price_list' => l10n.apiResourceGenderPriceList,
      'product' => l10n.apiResourceGenderProduct,
      'product_price' => l10n.apiResourceGenderProductPrice,
      'purchase_order' => l10n.apiResourceGenderPurchaseOrder,
      'sales_order' => l10n.apiResourceGenderSalesOrder,
      'sales_order_line' => l10n.apiResourceGenderSalesOrderLine,
      'sales_order_payment' => l10n.apiResourceGenderSalesOrderPayment,
      'sales_quote' => l10n.apiResourceGenderSalesQuote,
      'sales_quote_line' => l10n.apiResourceGenderSalesQuoteLine,
      'stock_movement' => l10n.apiResourceGenderStockMovement,
      'supplier' => l10n.apiResourceGenderSupplier,
      'supplier_payment' => l10n.apiResourceGenderSupplierPayment,
      'taxpayer_certificate' => l10n.apiResourceGenderTaxpayerCertificate,
      'taxpayer_issuer' => l10n.apiResourceGenderTaxpayerIssuer,
      'taxpayer_recipient' => l10n.apiResourceGenderTaxpayerRecipient,
      'user' => l10n.apiResourceGenderUser,
      'user_profile' => l10n.apiResourceGenderUserProfile,
      'vehicle' => l10n.apiResourceGenderVehicle,
      'vehicle_operator' => l10n.apiResourceGenderVehicleOperator,
      'warehouse' => l10n.apiResourceGenderWarehouse,
      _ => l10n.apiResourceGenderGeneric,
    };

extension AppErrorText on AppError {
  /// This error in the user's language, or `null` when none can be built.
  ///
  /// 1. The coded problem, through [localizeProblem].
  /// 2. A field-level validation refusal whose every entry has a localized
  ///    `type`.
  ///
  /// [fmt] formats the amounts and dates of a coded problem, so it may be
  /// `null` only for an error that has none.
  String? localizedMessage(AppLocalizations l10n, AppFormatters? fmt) {
    final coded = problem;
    if (coded != null && fmt != null) {
      final text = localizeProblem(coded, l10n, fmt);
      if (text != null) return text;
    }
    final self = this;
    if (self is ValidationError && self.errors.isNotEmpty) {
      final lines = <String>[];
      for (final entry in self.errors) {
        final text = localizeValidationType(entry.type, l10n);
        if (text == null) return null;
        lines.add(text);
      }
      return lines.join('\n');
    }
    return null;
  }

  /// The text to show for this error: the localized message, else the server's
  /// English detail (not for an auth or network error), else, for a
  /// field-level validation refusal, each entry's localized text or English
  /// `msg`. `null` when there is nothing to show.
  ///
  /// The only way server text reaches a screen (FR-014): single-line displays
  /// such as tooltips and snackbars use this, and the shared error panel
  /// applies the same order.
  String? userMessage(AppLocalizations l10n, AppFormatters? fmt) {
    final localized = localizedMessage(l10n, fmt);
    if (localized != null) return localized;
    // Never an auth detail (FR-008: a failed sign-in must not reveal which
    // credential was wrong) nor a network error's raw exception text (SC-008):
    // the shared error panel has always excluded both.
    final server = switch (this) {
      AuthError() || NetworkError() => null,
      _ => serverMessage,
    };
    if (server != null && server.isNotEmpty) return server;
    final self = this;
    if (self is ValidationError) {
      final lines = [
        for (final entry in self.errors)
          if ((localizeValidationType(entry.type, l10n) ?? entry.msg)
              case final line when line.isNotEmpty)
            line,
      ];
      if (lines.isNotEmpty) return lines.join('\n');
    }
    return null;
  }
}

String _stillReferenced(
  ApiProblem problem,
  AppLocalizations l10n,
  AppFormatters fmt,
) {
  final references = problem.mapListParam('references');
  if (references == null || references.isEmpty) {
    return l10n.apiErrorResourceStillReferencedGeneric;
  }
  final items = <String>[];
  for (final reference in references) {
    final count = reference['count'];
    final resource = reference['resource'];
    if (count is! int || resource is! String) {
      return l10n.apiErrorResourceStillReferencedGeneric;
    }
    items.add(
      '${fmt.display.count(count)} ${resourceNoun(resource, l10n, count: count)}',
    );
  }
  final more = problem.intParam('more') ?? 0;
  final list = more > 0
      ? '${items.join(', ')} ${l10n.apiReferenceMore(more)}'
      : items.join(', ');
  return l10n.apiErrorResourceStillReferenced(list);
}

/// Applies [f] when [a] is present, else `null`: a case whose param is
/// missing or of the wrong type has no message (FR-004).
String? _ap1<A>(A? a, String Function(A) f) => a == null ? null : f(a);

String? _ap2<A, B>(A? a, B? b, String Function(A, B) f) =>
    a == null || b == null ? null : f(a, b);

/// A money param, through the formatter the rest of the app uses.
String? _money(ApiProblem problem, String key, AppFormatters fmt) {
  final value = problem.decimalParam(key);
  return value == null ? null : fmt.display.currency(value);
}

/// A quantity param.
String? _quantity(ApiProblem problem, String key, AppFormatters fmt) {
  final value = problem.decimalParam(key);
  return value == null ? null : fmt.display.quantity(value);
}

/// A date param.
String? _date(ApiProblem problem, String key, AppFormatters fmt) {
  final value = problem.dateParam(key);
  return value == null ? null : fmt.display.date(value);
}

/// An integer count param, with the locale's digit grouping.
String? _count(ApiProblem problem, String key, AppFormatters fmt) {
  final value = problem.intParam(key);
  return value == null ? null : fmt.display.count(value);
}

/// A byte count as whole megabytes when it is one, else kilobytes (rounded
/// up). The unit symbols are not translated.
String? _size(ApiProblem problem, String key, AppFormatters fmt) {
  final bytes = problem.intParam(key);
  if (bytes == null) return null;
  const megabyte = 1024 * 1024;
  if (bytes >= megabyte && bytes % megabyte == 0) {
    return '${fmt.display.count(bytes ~/ megabyte)} MB';
  }
  return '${fmt.display.count((bytes / 1024).ceil())} KB';
}

/// The headline of a refusal that lists the lines at fault, followed by one
/// line each. A part with a code this client knows is localized; one it does
/// not know shows its product code when it has one (research R9). Today's
/// dict details carry only the server's English prose per line, shown as sent
/// until mbe-api's phase 3 moves them to parts.
String _withItems(
  ApiProblem problem,
  AppLocalizations l10n,
  AppFormatters fmt,
  String headline,
) {
  final lines = <String>[];
  if (problem.parts.isNotEmpty) {
    for (final part in problem.parts) {
      final text = part.code == null
          ? null
          : localizeProblem(
              ApiProblem(
                codeName: part.codeName,
                code: part.code,
                params: part.params,
              ),
              l10n,
              fmt,
            );
      final line = text ?? part.stringParam('product_code');
      if (line != null) lines.add(line);
    }
  } else {
    lines.addAll(problem.detailItems);
  }
  return lines.isEmpty ? headline : '$headline:\n${lines.join('\n')}';
}
