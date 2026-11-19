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
  api.ErrorCode.customerDiscountPeriodProductNotFound,
  api.ErrorCode.customerPeriodCreditHold,
  api.ErrorCode.customerPeriodCreditLimitExceeded,
  api.ErrorCode.customerPeriodCreditLimitReached,
  api.ErrorCode.customerPeriodDefaultNotDeletable,
  api.ErrorCode.customerPeriodNoCreditLimit,
  api.ErrorCode.customerPeriodWalkInNoCredit,
  api.ErrorCode.deliveryOrderPeriodInsufficientNotice,
  api.ErrorCode.deliveryOrderPeriodLineAlreadyPresent,
  api.ErrorCode.deliveryOrderPeriodLineNotDeliverable,
  api.ErrorCode.deliveryOrderPeriodLineRepeated,
  api.ErrorCode.deliveryOrderPeriodMixedNotAllowed,
  api.ErrorCode.deliveryOrderPeriodNoLines,
  api.ErrorCode.deliveryOrderPeriodNoLinesFromWarehouse,
  api.ErrorCode.deliveryOrderPeriodNotApproved,
  api.ErrorCode.deliveryOrderPeriodNotEditable,
  api.ErrorCode.deliveryOrderPeriodNotFailed,
  api.ErrorCode.deliveryOrderPeriodNotPendingApproval,
  api.ErrorCode.deliveryOrderPeriodOnItinerary,
  api.ErrorCode.deliveryOrderPeriodProofIncomplete,
  api.ErrorCode.deliveryOrderPeriodQuantityExceedsRemaining,
  api.ErrorCode.deliveryOrderPeriodReasonRequired,
  api.ErrorCode.deliveryOrderPeriodSalesOrderFullyDelivered,
  api.ErrorCode.deliveryOrderPeriodSalesOrderNotDeliverable,
  api.ErrorCode.deliveryOrderPeriodSalesOrderUnpaid,
  api.ErrorCode.deliveryOrderPeriodUnknownWarehouse,
  api.ErrorCode.documentPeriodNotEditable,
  api.ErrorCode.emailPeriodNotConfigured,
  api.ErrorCode.emailPeriodSendFailed,
  api.ErrorCode.facilityPeriodNoDispatchWarehouse,
  api.ErrorCode.facilityPeriodNoInTransitLocation,
  api.ErrorCode.facilityPeriodOtherFacility,
  api.ErrorCode.facilityPeriodRequired,
  api.ErrorCode.fiscalDocumentPeriodAlreadyRelated,
  api.ErrorCode.fiscalDocumentPeriodAmountExceedsBalance,
  api.ErrorCode.fiscalDocumentPeriodAmountsExceedPayment,
  api.ErrorCode.fiscalDocumentPeriodAmountsNotEqualPayment,
  api.ErrorCode.fiscalDocumentPeriodInvoiceAlreadyOnReceipt,
  api.ErrorCode.fiscalDocumentPeriodInvoiceNotPayable,
  api.ErrorCode.fiscalDocumentPeriodPaymentAlreadyReceipted,
  api.ErrorCode.fiscalDocumentPeriodPaymentDateOutOfRange,
  api.ErrorCode.fiscalDocumentPeriodPaymentOtherCustomer,
  api.ErrorCode.fiscalDocumentPeriodReceiptNeedsPaymentData,
  api.ErrorCode.fiscalDocumentPeriodReceiptPaysNoInvoice,
  api.ErrorCode.fiscalDocumentPeriodCertificateCannotSign,
  api.ErrorCode.fiscalDocumentPeriodCreditExceedsInvoice,
  api.ErrorCode.fiscalDocumentPeriodCreditQuantityExceedsLine,
  api.ErrorCode.fiscalDocumentPeriodFieldNotForType,
  api.ErrorCode.fiscalDocumentPeriodInvoiceNotCreditable,
  api.ErrorCode.fiscalDocumentPeriodIssueDateOutOfRange,
  api.ErrorCode.fiscalDocumentPeriodIssuerHasNoSeries,
  api.ErrorCode.fiscalDocumentPeriodLineMissingSatKey,
  api.ErrorCode.fiscalDocumentPeriodLineQuantityNotPositive,
  api.ErrorCode.fiscalDocumentPeriodNoInvoiceableLines,
  api.ErrorCode.fiscalDocumentPeriodNoLines,
  api.ErrorCode.fiscalDocumentPeriodNoValidCertificate,
  api.ErrorCode.fiscalDocumentPeriodNotDraft,
  api.ErrorCode.fiscalDocumentPeriodNotIssued,
  api.ErrorCode.fiscalDocumentPeriodNotSealed,
  api.ErrorCode.fiscalDocumentPeriodNotStamped,
  api.ErrorCode.fiscalDocumentPeriodOrderNotInvoiceable,
  api.ErrorCode.fiscalDocumentPeriodPaymentFormRequired,
  api.ErrorCode.fiscalDocumentPeriodProductUnpriced,
  api.ErrorCode.fiscalDocumentPeriodQuantityExceedsInvoiceable,
  api.ErrorCode.fiscalDocumentPeriodRecipientIncomplete,
  api.ErrorCode.fiscalDocumentPeriodRecipientNotLinked,
  api.ErrorCode.fiscalDocumentPeriodRelationNotAllowed,
  api.ErrorCode.fiscalDocumentPeriodRelationTypesMixed,
  api.ErrorCode.fiscalDocumentPeriodSeriesLocked,
  api.ErrorCode.fiscalDocumentPeriodSeriesMissing,
  api.ErrorCode.fiscalDocumentPeriodSeriesNotOfType,
  api.ErrorCode.fiscalDocumentPeriodTypeNotSupported,
  api.ErrorCode.fiscalDocumentPeriodUnknownFacility,
  api.ErrorCode.fiscalDocumentPeriodUnknownUsage,
  api.ErrorCode.fiscalDocumentPeriodVersionNotPrintable,
  api.ErrorCode.fiscalDocumentPeriodXmlUnavailable,
  api.ErrorCode.fiscalDocumentPeriodCancellationOpen,
  api.ErrorCode.fiscalDocumentPeriodHasLiveDocuments,
  api.ErrorCode.fiscalDocumentPeriodNotCancellable,
  api.ErrorCode.fiscalDocumentPeriodNothingToRefresh,
  api.ErrorCode.fiscalDocumentPeriodStamping,
  api.ErrorCode.fiscalDocumentPeriodSubstitutionInvalid,
  api.ErrorCode.fiscalDocumentPeriodSubstitutionRequired,
  api.ErrorCode.fiscalDocumentPeriodUnknownCancellationReason,
  api.ErrorCode.pacPeriodNotConfigured,
  api.ErrorCode.pacPeriodRejected,
  api.ErrorCode.pacPeriodTimeout,
  api.ErrorCode.pacPeriodUnavailable,
  api.ErrorCode.imagePeriodTooLarge,
  api.ErrorCode.imagePeriodUnsupportedFormat,
  api.ErrorCode.incidencePeriodReasonRequired,
  api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled,
  api.ErrorCode.inventoryDocumentPeriodInsufficientStock,
  api.ErrorCode.inventoryDocumentPeriodLineWithoutQuantity,
  api.ErrorCode.inventoryDocumentPeriodNoLines,
  api.ErrorCode.inventoryReceiptPeriodComplementaryUnavailable,
  api.ErrorCode.inventoryReceiptPeriodWarehouseFixed,
  api.ErrorCode.inventoryTransferPeriodLineRepeated,
  api.ErrorCode.inventoryTransferPeriodNotInTransit,
  api.ErrorCode.inventoryTransferPeriodOverReceived,
  api.ErrorCode.inventoryTransferPeriodSameWarehouse,
  api.ErrorCode.lockPeriodBusy,
  api.ErrorCode.inventoryCountPeriodBatchInvalid,
  api.ErrorCode.inventoryCountPeriodConfirmedCannotCancel,
  api.ErrorCode.inventoryCountLinePeriodProductUnknown,
  api.ErrorCode.inventoryCountLinePeriodNotStockable,
  api.ErrorCode.inventoryCountLinePeriodRepeated,
  api.ErrorCode.inventoryCountLinePeriodProductReference,
  api.ErrorCode.kardexPeriodRangeReversed,
  api.ErrorCode.kardexPeriodRangeTooLong,
  api.ErrorCode.paymentPeriodAlreadyApplied,
  api.ErrorCode.paymentPeriodAlreadyVerified,
  api.ErrorCode.paymentPeriodApplicationReversed,
  api.ErrorCode.paymentPeriodCurrencyMismatch,
  api.ErrorCode.paymentPeriodCustomerMismatch,
  api.ErrorCode.paymentPeriodExceedsOrderBalance,
  api.ErrorCode.paymentPeriodExceedsUnapplied,
  api.ErrorCode.paymentPeriodNoTicket,
  api.ErrorCode.paymentPeriodOrderCancelled,
  api.ErrorCode.paymentPeriodOrderNotCompleted,
  api.ErrorCode.paymentPeriodOrderSettled,
  api.ErrorCode.pointOfSalePeriodWarehouseFacilityMismatch,
  api.ErrorCode.priceListPeriodCostNotAssignable,
  api.ErrorCode.priceListPeriodCostNotDeletable,
  api.ErrorCode.priceListPeriodCostReadOnly,
  api.ErrorCode.priceListPeriodReplaceWithItself,
  api.ErrorCode.productPeriodLookupCriteriaRequired,
  api.ErrorCode.productPeriodLookupTooMany,
  api.ErrorCode.productPeriodMergeWithItself,
  api.ErrorCode.productPeriodNotStockable,
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
  api.ErrorCode.salesOrderPeriodNotConfirmed,
  api.ErrorCode.salesOrderPeriodPaidCannotCancel,
  api.ErrorCode.salesOrderPeriodZeroPricedLines,
  api.ErrorCode.serverPeriodError,
  api.ErrorCode.statePeriodTransitionInvalid,
  api.ErrorCode.statusFilterPeriodUnsupported,
  api.ErrorCode.supplierAgreementPeriodEndBeforeStart,
  api.ErrorCode.taxpayerBatchPeriodInUse,
  api.ErrorCode.taxpayerCertificatePeriodHolderMismatch,
  api.ErrorCode.taxpayerIssuerPeriodUnknown,
  api.ErrorCode.userPeriodNoCashDrawer,
  api.ErrorCode.userPeriodNoFacility,
  api.ErrorCode.userPeriodNoPointOfSale,
  api.ErrorCode.userProfilePeriodNotActive,
  api.ErrorCode.warehousePeriodInTransitLocation,
  api.ErrorCode.warehousePeriodInTransitManaged,
  api.ErrorCode.warehousePeriodRequired,
  api.ErrorCode.deliveryOrderPeriodNotInPreparation,
  api.ErrorCode.deliveryOrderPeriodPickupNotLoadable,
  api.ErrorCode.deliveryOrderLinePeriodNothingToLoad,
  api.ErrorCode.deliveryOrderLinePeriodQuantityUnavailable,
  api.ErrorCode.itineraryPeriodCancelled,
  api.ErrorCode.itineraryPeriodLinesOvercommitted,
  api.ErrorCode.itineraryPeriodNotDeparted,
  api.ErrorCode.itineraryPeriodNotOpen,
  api.ErrorCode.itineraryPeriodNothingCommitted,
  api.ErrorCode.itineraryPeriodStopAlreadyResolved,
  api.ErrorCode.itineraryPeriodStopDeliveredExceedsSent,
  api.ErrorCode.itineraryPeriodStopLinesIncomplete,
  api.ErrorCode.itineraryPeriodStopLinesMalformed,
  api.ErrorCode.itineraryPeriodStopShortfallNeedsReason,
  api.ErrorCode.vehiclePeriodOpenItineraryExists,
};

/// The validation `type`s [localizeValidationType] renders.
const Set<String> localizedValidationTypes = {
  'contact_name_blank',
  'email_address_invalid',
  'fiscal_document_payment_form_unknown',
  'fiscal_document_tax_rate_invalid',
  'inventory_transfer_duplicate_line',
  'product_barcode_invalid',
  'product_code_has_whitespace',
  'profile_duplicate_system_object',
  'profile_unknown_system_object',
  'supplier_agreement_end_before_start',
  'taxpayer_batch_series_blank',
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
    api.ErrorCode.statusFilterPeriodUnsupported =>
      l10n.apiErrorStatusFilterUnsupported,
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
    api.ErrorCode.deliveryOrderPeriodInsufficientNotice => _ap2(
      _count(problem, 'min_hours', fmt),
      _dateTime(problem, 'earliest', fmt),
      l10n.apiErrorDeliveryOrderInsufficientNotice,
    ),
    api.ErrorCode.deliveryOrderPeriodLineAlreadyPresent =>
      l10n.apiErrorDeliveryOrderLineAlreadyPresent,
    api.ErrorCode.deliveryOrderPeriodLineNotDeliverable =>
      l10n.apiErrorDeliveryOrderLineNotDeliverable,
    api.ErrorCode.deliveryOrderPeriodLineRepeated =>
      l10n.apiErrorDeliveryOrderLineRepeated,
    api.ErrorCode.deliveryOrderPeriodMixedNotAllowed =>
      l10n.apiErrorDeliveryOrderMixedNotAllowed,
    api.ErrorCode.deliveryOrderPeriodNoLines =>
      l10n.apiErrorDeliveryOrderNoLines,
    api.ErrorCode.deliveryOrderPeriodNoLinesFromWarehouse =>
      l10n.apiErrorDeliveryOrderNoLinesFromWarehouse,
    api.ErrorCode.deliveryOrderPeriodNotApproved =>
      l10n.apiErrorDeliveryOrderNotApproved,
    api.ErrorCode.deliveryOrderPeriodNotEditable =>
      l10n.apiErrorDeliveryOrderNotEditable,
    api.ErrorCode.deliveryOrderPeriodNotFailed =>
      l10n.apiErrorDeliveryOrderNotFailed,
    api.ErrorCode.deliveryOrderPeriodNotPendingApproval =>
      l10n.apiErrorDeliveryOrderNotPendingApproval,
    api.ErrorCode.deliveryOrderPeriodOnItinerary =>
      l10n.apiErrorDeliveryOrderOnItinerary,
    api.ErrorCode.deliveryOrderPeriodProofIncomplete =>
      l10n.apiErrorDeliveryOrderProofIncomplete,
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
    api.ErrorCode.deliveryOrderPeriodUnknownWarehouse =>
      l10n.apiErrorDeliveryOrderUnknownWarehouse,
    api.ErrorCode.deliveryOrderPeriodNotInPreparation =>
      l10n.apiErrorDeliveryOrderNotInPreparation,
    api.ErrorCode.deliveryOrderPeriodPickupNotLoadable =>
      l10n.apiErrorDeliveryOrderPickupNotLoadable,
    api.ErrorCode.deliveryOrderLinePeriodNothingToLoad =>
      l10n.apiErrorDeliveryOrderLineNothingToLoad,
    api.ErrorCode.deliveryOrderLinePeriodQuantityUnavailable => _ap2(
      _quantity(problem, 'requested', fmt),
      _quantity(problem, 'available', fmt),
      l10n.apiErrorDeliveryOrderLineQuantityUnavailable,
    ),
    api.ErrorCode.itineraryPeriodCancelled => l10n.apiErrorItineraryCancelled,
    // The refusal lists delivery-order line ids, not product names, so they
    // show as the numbers the server sent (spec 075 contracts/error-messages).
    api.ErrorCode.itineraryPeriodLinesOvercommitted => _withItems(
      problem,
      l10n,
      fmt,
      l10n.apiErrorItineraryLinesOvercommitted,
    ),
    api.ErrorCode.itineraryPeriodNotDeparted =>
      l10n.apiErrorItineraryNotDeparted,
    api.ErrorCode.itineraryPeriodNotOpen => l10n.apiErrorItineraryNotOpen,
    api.ErrorCode.itineraryPeriodNothingCommitted =>
      l10n.apiErrorItineraryNothingCommitted,
    api.ErrorCode.itineraryPeriodStopAlreadyResolved =>
      l10n.apiErrorItineraryStopAlreadyResolved,
    // simplified: the stop's lines are named by number ("Partida 7"), not by
    // product; resolving the name needs a lookup `localizeProblem` doesn't
    // take. The close dialog validates both cases first, so a server refusal
    // here is rare. Add a lookup parameter if it turns out to matter.
    api.ErrorCode.itineraryPeriodStopDeliveredExceedsSent => _ap3(
      problem.intParam('line_id'),
      _quantity(problem, 'sent', fmt),
      _quantity(problem, 'delivered', fmt),
      (line, sent, delivered) => l10n.apiErrorItineraryStopDeliveredExceedsSent(
        '$line',
        sent,
        delivered,
      ),
    ),
    api.ErrorCode.itineraryPeriodStopLinesIncomplete =>
      l10n.apiErrorItineraryStopLinesIncomplete,
    api.ErrorCode.itineraryPeriodStopLinesMalformed =>
      l10n.apiErrorItineraryStopLinesMalformed,
    api.ErrorCode.itineraryPeriodStopShortfallNeedsReason => _ap1(
      problem.intParam('line_id'),
      (line) => l10n.apiErrorItineraryStopShortfallNeedsReason('$line'),
    ),
    api.ErrorCode.vehiclePeriodOpenItineraryExists => _ap1(
      problem.intParam('itinerary_id'),
      (id) => l10n.apiErrorVehicleOpenItineraryExists('$id'),
    ),
    api.ErrorCode.documentPeriodNotEditable => l10n.apiErrorDocumentNotEditable,
    api.ErrorCode.emailPeriodNotConfigured => l10n.apiErrorEmailNotConfigured,
    api.ErrorCode.emailPeriodSendFailed => l10n.apiErrorEmailSendFailed,
    api.ErrorCode.facilityPeriodNoDispatchWarehouse =>
      l10n.apiErrorFacilityNoDispatchWarehouse,
    api.ErrorCode.facilityPeriodNoInTransitLocation =>
      l10n.apiErrorFacilityNoInTransitLocation,
    api.ErrorCode.facilityPeriodOtherFacility => _ap1(
      problem.stringParam('resource'),
      (r) => l10n.apiErrorFacilityOtherFacility(
        resourceGender(r, l10n),
        resourceNoun(r, l10n),
      ),
    ),
    api.ErrorCode.facilityPeriodRequired => l10n.apiErrorFacilityRequired,
    api.ErrorCode.fiscalDocumentPeriodAlreadyRelated =>
      l10n.apiErrorFiscalDocumentAlreadyRelated,
    api.ErrorCode.fiscalDocumentPeriodAmountExceedsBalance => _ap1(
      _money(problem, 'balance', fmt),
      l10n.apiErrorFiscalDocumentAmountExceedsBalance,
    ),
    api.ErrorCode.fiscalDocumentPeriodAmountsExceedPayment =>
      l10n.apiErrorFiscalDocumentAmountsExceedPayment,
    api.ErrorCode.fiscalDocumentPeriodAmountsNotEqualPayment =>
      l10n.apiErrorFiscalDocumentAmountsNotEqualPayment,
    api.ErrorCode.fiscalDocumentPeriodInvoiceAlreadyOnReceipt =>
      l10n.apiErrorFiscalDocumentInvoiceAlreadyOnReceipt,
    api.ErrorCode.fiscalDocumentPeriodInvoiceNotPayable =>
      l10n.apiErrorFiscalDocumentInvoiceNotPayable,
    api.ErrorCode.fiscalDocumentPeriodPaymentAlreadyReceipted =>
      l10n.apiErrorFiscalDocumentPaymentAlreadyReceipted,
    api.ErrorCode.fiscalDocumentPeriodPaymentDateOutOfRange =>
      l10n.apiErrorFiscalDocumentPaymentDateOutOfRange,
    api.ErrorCode.fiscalDocumentPeriodPaymentOtherCustomer =>
      l10n.apiErrorFiscalDocumentPaymentOtherCustomer,
    api.ErrorCode.fiscalDocumentPeriodReceiptNeedsPaymentData =>
      l10n.apiErrorFiscalDocumentReceiptNeedsPaymentData,
    api.ErrorCode.fiscalDocumentPeriodReceiptPaysNoInvoice =>
      l10n.apiErrorFiscalDocumentReceiptPaysNoInvoice,
    api.ErrorCode.fiscalDocumentPeriodCertificateCannotSign =>
      l10n.apiErrorFiscalDocumentCertificateCannotSign,
    api.ErrorCode.fiscalDocumentPeriodCreditExceedsInvoice => _ap1(
      _money(problem, 'remaining', fmt),
      l10n.apiErrorFiscalDocumentCreditExceedsInvoice,
    ),
    api.ErrorCode.fiscalDocumentPeriodCreditQuantityExceedsLine => _ap1(
      _quantity(problem, 'max', fmt),
      l10n.apiErrorFiscalDocumentCreditQuantityExceedsLine,
    ),
    api.ErrorCode.fiscalDocumentPeriodFieldNotForType =>
      l10n.apiErrorFiscalDocumentFieldNotForType,
    api.ErrorCode.fiscalDocumentPeriodInvoiceNotCreditable =>
      l10n.apiErrorFiscalDocumentInvoiceNotCreditable,
    api.ErrorCode.fiscalDocumentPeriodIssueDateOutOfRange =>
      l10n.apiErrorFiscalDocumentIssueDateOutOfRange,
    api.ErrorCode.fiscalDocumentPeriodIssuerHasNoSeries =>
      l10n.apiErrorFiscalDocumentIssuerHasNoSeries,
    api.ErrorCode.fiscalDocumentPeriodLineMissingSatKey => _ap1(
      _count(problem, 'line', fmt),
      l10n.apiErrorFiscalDocumentLineMissingSatKey,
    ),
    api.ErrorCode.fiscalDocumentPeriodLineQuantityNotPositive => _ap1(
      _count(problem, 'line', fmt),
      l10n.apiErrorFiscalDocumentLineQuantityNotPositive,
    ),
    api.ErrorCode.fiscalDocumentPeriodNoInvoiceableLines =>
      l10n.apiErrorFiscalDocumentNoInvoiceableLines,
    api.ErrorCode.fiscalDocumentPeriodNoLines =>
      l10n.apiErrorFiscalDocumentNoLines,
    api.ErrorCode.fiscalDocumentPeriodNoValidCertificate =>
      l10n.apiErrorFiscalDocumentNoValidCertificate,
    api.ErrorCode.fiscalDocumentPeriodNotDraft =>
      l10n.apiErrorFiscalDocumentNotDraft,
    api.ErrorCode.fiscalDocumentPeriodNotIssued =>
      l10n.apiErrorFiscalDocumentNotIssued,
    api.ErrorCode.fiscalDocumentPeriodNotSealed =>
      l10n.apiErrorFiscalDocumentNotSealed,
    api.ErrorCode.fiscalDocumentPeriodNotStamped =>
      l10n.apiErrorFiscalDocumentNotStamped,
    api.ErrorCode.fiscalDocumentPeriodOrderNotInvoiceable =>
      l10n.apiErrorFiscalDocumentOrderNotInvoiceable,
    api.ErrorCode.fiscalDocumentPeriodPaymentFormRequired =>
      l10n.apiErrorFiscalDocumentPaymentFormRequired,
    api.ErrorCode.fiscalDocumentPeriodProductUnpriced =>
      l10n.apiErrorFiscalDocumentProductUnpriced,
    api.ErrorCode.fiscalDocumentPeriodQuantityExceedsInvoiceable =>
      problem.intParam('line') == null
          ? _ap1(
              _quantity(problem, 'remaining', fmt),
              l10n.apiErrorFiscalDocumentQuantityExceedsInvoiceable,
            )
          : _ap2(
              _count(problem, 'line', fmt),
              _quantity(problem, 'remaining', fmt),
              l10n.apiErrorFiscalDocumentQuantityExceedsInvoiceableLine,
            ),
    api.ErrorCode.fiscalDocumentPeriodRecipientIncomplete =>
      l10n.apiErrorFiscalDocumentRecipientIncomplete,
    api.ErrorCode.fiscalDocumentPeriodRecipientNotLinked =>
      l10n.apiErrorFiscalDocumentRecipientNotLinked,
    api.ErrorCode.fiscalDocumentPeriodRelationNotAllowed =>
      l10n.apiErrorFiscalDocumentRelationNotAllowed,
    api.ErrorCode.fiscalDocumentPeriodRelationTypesMixed =>
      l10n.apiErrorFiscalDocumentRelationTypesMixed,
    api.ErrorCode.fiscalDocumentPeriodSeriesLocked =>
      l10n.apiErrorFiscalDocumentSeriesLocked,
    api.ErrorCode.fiscalDocumentPeriodSeriesMissing => _ap1(
      problem.stringParam('batch'),
      l10n.apiErrorFiscalDocumentSeriesMissing,
    ),
    api.ErrorCode.fiscalDocumentPeriodSeriesNotOfType => _ap1(
      problem.stringParam('batch'),
      l10n.apiErrorFiscalDocumentSeriesNotOfType,
    ),
    api.ErrorCode.fiscalDocumentPeriodTypeNotSupported =>
      l10n.apiErrorFiscalDocumentTypeNotSupported,
    api.ErrorCode.fiscalDocumentPeriodUnknownFacility =>
      l10n.apiErrorFiscalDocumentUnknownFacility,
    api.ErrorCode.fiscalDocumentPeriodUnknownUsage => _ap1(
      problem.stringParam('usage'),
      l10n.apiErrorFiscalDocumentUnknownUsage,
    ),
    api.ErrorCode.fiscalDocumentPeriodVersionNotPrintable => _ap1(
      problem.stringParam('version'),
      l10n.apiErrorFiscalDocumentVersionNotPrintable,
    ),
    api.ErrorCode.fiscalDocumentPeriodXmlUnavailable =>
      l10n.apiErrorFiscalDocumentXmlUnavailable,
    // Stamping, cancellation and refresh (spec 072).
    api.ErrorCode.fiscalDocumentPeriodCancellationOpen =>
      l10n.apiErrorFiscalDocumentCancellationOpen,
    api.ErrorCode.fiscalDocumentPeriodHasLiveDocuments => _ap1(
      _stringList(problem.listParam('documents')),
      (documents) =>
          l10n.apiErrorFiscalDocumentHasLiveDocuments(documents.join(', ')),
    ),
    api.ErrorCode.fiscalDocumentPeriodNotCancellable =>
      l10n.apiErrorFiscalDocumentNotCancellable,
    api.ErrorCode.fiscalDocumentPeriodNothingToRefresh =>
      l10n.apiErrorFiscalDocumentNothingToRefresh,
    api.ErrorCode.fiscalDocumentPeriodStamping =>
      l10n.apiErrorFiscalDocumentStamping,
    api.ErrorCode.fiscalDocumentPeriodSubstitutionInvalid =>
      l10n.apiErrorFiscalDocumentSubstitutionInvalid,
    api.ErrorCode.fiscalDocumentPeriodSubstitutionRequired =>
      l10n.apiErrorFiscalDocumentSubstitutionRequired,
    api.ErrorCode.fiscalDocumentPeriodUnknownCancellationReason => _ap1(
      problem.stringParam('reason'),
      l10n.apiErrorFiscalDocumentUnknownCancellationReason,
    ),
    api.ErrorCode.pacPeriodNotConfigured => l10n.apiErrorPacNotConfigured,
    // The PAC's own words: the params carry SAT's code and message, which the
    // clerk needs as written, so they are shown inside our sentence.
    api.ErrorCode.pacPeriodRejected => _ap2(
      problem.stringParam('pac_code'),
      problem.stringParam('pac_message'),
      l10n.apiErrorPacRejected,
    ),
    api.ErrorCode.pacPeriodTimeout => l10n.apiErrorPacTimeout,
    api.ErrorCode.pacPeriodUnavailable => l10n.apiErrorPacUnavailable,
    api.ErrorCode.imagePeriodTooLarge => _ap1(
      _size(problem, 'max_bytes', fmt),
      l10n.apiErrorImageTooLarge,
    ),
    api.ErrorCode.imagePeriodUnsupportedFormat =>
      l10n.apiErrorImageUnsupportedFormat,
    api.ErrorCode.incidencePeriodReasonRequired =>
      l10n.apiErrorIncidenceReasonRequired,
    api.ErrorCode.inventoryDocumentPeriodAlreadyCancelled => _ap1(
      problem.stringParam('resource'),
      (r) => l10n.apiErrorInventoryDocumentAlreadyCancelled(
        resourceGender(r, l10n),
        resourceNoun(r, l10n),
      ),
    ),
    api.ErrorCode.inventoryDocumentPeriodInsufficientStock => _ap2(
      _quantity(problem, 'requested', fmt),
      _quantity(problem, 'available', fmt),
      l10n.apiErrorInventoryDocumentInsufficientStock,
    ),
    api.ErrorCode.inventoryDocumentPeriodLineWithoutQuantity => _ap1(
      problem.stringParam('product_code'),
      l10n.apiErrorInventoryDocumentLineWithoutQuantity,
    ),
    api.ErrorCode.inventoryDocumentPeriodNoLines => _ap1(
      problem.stringParam('resource'),
      (r) => l10n.apiErrorInventoryDocumentNoLines(
        resourceGender(r, l10n),
        resourceNoun(r, l10n),
      ),
    ),
    // The reason picks the sentence; a missing or unknown one reads as the
    // generic sentence, so a message always shows (spec 067).
    api.ErrorCode.inventoryReceiptPeriodComplementaryUnavailable =>
      switch (problem.stringParam('reason')) {
        'no_purchase_order' =>
          l10n.apiErrorInventoryReceiptComplementaryNoPurchaseOrder,
        'purchase_order_cancelled' =>
          l10n.apiErrorInventoryReceiptComplementaryPurchaseOrderCancelled,
        'purchase_order_not_completed' =>
          l10n.apiErrorInventoryReceiptComplementaryPurchaseOrderNotCompleted,
        'purchase_order_fully_received' =>
          l10n.apiErrorInventoryReceiptComplementaryPurchaseOrderFullyReceived,
        _ => l10n.apiErrorInventoryReceiptComplementaryUnavailable,
      },
    api.ErrorCode.inventoryReceiptPeriodWarehouseFixed =>
      l10n.apiErrorInventoryReceiptWarehouseFixed,
    api.ErrorCode.inventoryTransferPeriodLineRepeated =>
      l10n.apiErrorInventoryTransferLineRepeated,
    api.ErrorCode.inventoryTransferPeriodNotInTransit =>
      l10n.apiErrorInventoryTransferNotInTransit,
    api.ErrorCode.inventoryTransferPeriodOverReceived => _overReceived(
      problem,
      fmt,
      l10n,
    ),
    api.ErrorCode.inventoryTransferPeriodSameWarehouse =>
      l10n.apiErrorInventoryTransferSameWarehouse,
    api.ErrorCode.lockPeriodBusy => l10n.apiErrorLockBusy,
    api.ErrorCode.inventoryCountPeriodBatchInvalid =>
      l10n.apiErrorInventoryCountBatchInvalid,
    api.ErrorCode.inventoryCountPeriodConfirmedCannotCancel =>
      l10n.apiErrorInventoryCountConfirmedCannotCancel,
    api.ErrorCode.inventoryCountLinePeriodProductUnknown =>
      l10n.apiErrorInventoryCountLineProductUnknown,
    api.ErrorCode.inventoryCountLinePeriodNotStockable =>
      l10n.apiErrorInventoryCountLineNotStockable,
    api.ErrorCode.inventoryCountLinePeriodRepeated =>
      l10n.apiErrorInventoryCountLineRepeated,
    api.ErrorCode.inventoryCountLinePeriodProductReference =>
      l10n.apiErrorInventoryCountLineProductReference,
    api.ErrorCode.kardexPeriodRangeReversed => l10n.apiErrorKardexRangeReversed,
    api.ErrorCode.kardexPeriodRangeTooLong => _ap1(
      _count(problem, 'max_days', fmt),
      l10n.apiErrorKardexRangeTooLong,
    ),
    api.ErrorCode.paymentPeriodAlreadyApplied =>
      l10n.apiErrorPaymentAlreadyApplied,
    api.ErrorCode.paymentPeriodAlreadyVerified =>
      l10n.apiErrorPaymentAlreadyVerified,
    api.ErrorCode.paymentPeriodApplicationReversed =>
      l10n.apiErrorPaymentApplicationReversed,
    api.ErrorCode.paymentPeriodCurrencyMismatch => _ap2(
      problem.stringParam('payment_currency'),
      problem.stringParam('order_currency'),
      l10n.apiErrorPaymentCurrencyMismatch,
    ),
    api.ErrorCode.paymentPeriodCustomerMismatch =>
      l10n.apiErrorPaymentCustomerMismatch,
    api.ErrorCode.paymentPeriodExceedsOrderBalance => _ap2(
      _money(problem, 'amount', fmt),
      _money(problem, 'balance', fmt),
      l10n.apiErrorPaymentExceedsOrderBalance,
    ),
    api.ErrorCode.paymentPeriodExceedsUnapplied => _ap2(
      _money(problem, 'amount', fmt),
      _money(problem, 'unapplied', fmt),
      l10n.apiErrorPaymentExceedsUnapplied,
    ),
    api.ErrorCode.paymentPeriodNoTicket => l10n.apiErrorPaymentNoTicket,
    api.ErrorCode.paymentPeriodOrderCancelled =>
      l10n.apiErrorPaymentOrderCancelled,
    api.ErrorCode.paymentPeriodOrderNotCompleted =>
      l10n.apiErrorPaymentOrderNotCompleted,
    api.ErrorCode.paymentPeriodOrderSettled => l10n.apiErrorPaymentOrderSettled,
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
    api.ErrorCode.productPeriodNotStockable => _ap1(
      problem.stringParam('product_code'),
      l10n.apiErrorProductNotStockable,
    ),
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
    api.ErrorCode.salesOrderPeriodNotConfirmed =>
      l10n.apiErrorSalesOrderNotConfirmed,
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
    // The refused action picks the sentence; a missing or unexpected `action`
    // reads as the update one, so a message always shows (spec 065 R9).
    api.ErrorCode.taxpayerBatchPeriodInUse =>
      problem.stringParam('action') == 'delete'
          ? l10n.apiErrorTaxpayerBatchInUseDelete
          : l10n.apiErrorTaxpayerBatchInUseUpdate,
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
    'fiscal_document_payment_form_unknown' =>
      l10n.apiValidationFiscalDocumentPaymentFormUnknown,
    'fiscal_document_tax_rate_invalid' =>
      l10n.apiValidationFiscalDocumentTaxRateInvalid,
    'inventory_transfer_duplicate_line' =>
      l10n.apiValidationInventoryTransferDuplicateLine,
    'product_barcode_invalid' => l10n.apiValidationProductBarcodeInvalid,
    'product_code_has_whitespace' => l10n.apiValidationProductCodeHasWhitespace,
    'profile_duplicate_system_object' =>
      l10n.apiValidationProfileDuplicateSystemObject,
    'profile_unknown_system_object' =>
      l10n.apiValidationProfileUnknownSystemObject,
    'supplier_agreement_end_before_start' =>
      l10n.apiValidationSupplierAgreementEndBeforeStart,
    'taxpayer_batch_series_blank' => l10n.apiValidationTaxpayerBatchSeriesBlank,
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
      'delivery_itinerary_line' => l10n.apiResourceDeliveryItineraryLine(count),
      'delivery_itinerary_stop' => l10n.apiResourceDeliveryItineraryStop(count),
      'delivery_order' => l10n.apiResourceDeliveryOrder(count),
      'delivery_order_line' => l10n.apiResourceDeliveryOrderLine(count),
      'employee' => l10n.apiResourceEmployee(count),
      'exchange_rate' => l10n.apiResourceExchangeRate(count),
      'expense' => l10n.apiResourceExpense(count),
      'expense_voucher' => l10n.apiResourceExpenseVoucher(count),
      'facility' => l10n.apiResourceFacility(count),
      'fiscal_document' => l10n.apiResourceFiscalDocument(count),
      'fiscal_document_line' => l10n.apiResourceFiscalDocumentLine(count),
      'fiscal_document_relation' => l10n.apiResourceFiscalDocumentRelation(
        count,
      ),
      'inventory_issue' => l10n.apiResourceInventoryIssue(count),
      'inventory_count' => l10n.apiResourceInventoryCount(count),
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
      'taxpayer_batch' => l10n.apiResourceTaxpayerBatch(count),
      'taxpayer_certificate' => l10n.apiResourceTaxpayerCertificate(count),
      'taxpayer_issuer' => l10n.apiResourceTaxpayerIssuer(count),
      'taxpayer_recipient' => l10n.apiResourceTaxpayerRecipient(count),
      'user' => l10n.apiResourceUser(count),
      'user_profile' => l10n.apiResourceUserProfile(count),
      'vehicle' => l10n.apiResourceVehicle(count),
      'vehicle_operator' => l10n.apiResourceVehicleOperator(count),
      'warehouse' => l10n.apiResourceWarehouse(count),
      'customer_address' => l10n.apiResourceCustomerAddress(count),
      'customer_contact' => l10n.apiResourceCustomerContact(count),
      'customer_taxpayer' => l10n.apiResourceCustomerTaxpayer(count),
      'supplier_address' => l10n.apiResourceSupplierAddress(count),
      'supplier_agreement' => l10n.apiResourceSupplierAgreement(count),
      'supplier_bank_account' => l10n.apiResourceSupplierBankAccount(count),
      'supplier_contact' => l10n.apiResourceSupplierContact(count),
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
      'delivery_itinerary_line' => l10n.apiResourceGenderDeliveryItineraryLine,
      'delivery_itinerary_stop' => l10n.apiResourceGenderDeliveryItineraryStop,
      'delivery_order' => l10n.apiResourceGenderDeliveryOrder,
      'delivery_order_line' => l10n.apiResourceGenderDeliveryOrderLine,
      'employee' => l10n.apiResourceGenderEmployee,
      'exchange_rate' => l10n.apiResourceGenderExchangeRate,
      'expense' => l10n.apiResourceGenderExpense,
      'expense_voucher' => l10n.apiResourceGenderExpenseVoucher,
      'facility' => l10n.apiResourceGenderFacility,
      'fiscal_document' => l10n.apiResourceGenderFiscalDocument,
      'fiscal_document_line' => l10n.apiResourceGenderFiscalDocumentLine,
      'fiscal_document_relation' =>
        l10n.apiResourceGenderFiscalDocumentRelation,
      'inventory_issue' => l10n.apiResourceGenderInventoryIssue,
      'inventory_count' => l10n.apiResourceGenderInventoryCount,
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
      'taxpayer_batch' => l10n.apiResourceGenderTaxpayerBatch,
      'taxpayer_certificate' => l10n.apiResourceGenderTaxpayerCertificate,
      'taxpayer_issuer' => l10n.apiResourceGenderTaxpayerIssuer,
      'taxpayer_recipient' => l10n.apiResourceGenderTaxpayerRecipient,
      'user' => l10n.apiResourceGenderUser,
      'user_profile' => l10n.apiResourceGenderUserProfile,
      'vehicle' => l10n.apiResourceGenderVehicle,
      'vehicle_operator' => l10n.apiResourceGenderVehicleOperator,
      'warehouse' => l10n.apiResourceGenderWarehouse,
      'customer_address' => l10n.apiResourceGenderCustomerAddress,
      'customer_contact' => l10n.apiResourceGenderCustomerContact,
      'customer_taxpayer' => l10n.apiResourceGenderCustomerTaxpayer,
      'supplier_address' => l10n.apiResourceGenderSupplierAddress,
      'supplier_agreement' => l10n.apiResourceGenderSupplierAgreement,
      'supplier_bank_account' => l10n.apiResourceGenderSupplierBankAccount,
      'supplier_contact' => l10n.apiResourceGenderSupplierContact,
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
/// A non-empty list whose every element is a string, or `null`.
List<String>? _stringList(List<Object?>? list) =>
    list == null || list.isEmpty || !list.every((e) => e is String)
    ? null
    : list.cast<String>();

String? _ap1<A>(A? a, String Function(A) f) => a == null ? null : f(a);

String? _ap2<A, B>(A? a, B? b, String Function(A, B) f) =>
    a == null || b == null ? null : f(a, b);

String? _ap3<A, B, C>(A? a, B? b, C? c, String Function(A, B, C) f) =>
    a == null || b == null || c == null ? null : f(a, b, c);

/// `inventory_transfer.over_received`: the product and the two quantities.
String? _overReceived(
  ApiProblem problem,
  AppFormatters fmt,
  AppLocalizations l10n,
) {
  final code = problem.stringParam('product_code');
  final received = _quantity(problem, 'received', fmt);
  final outstanding = _quantity(problem, 'outstanding', fmt);
  if (code == null || received == null || outstanding == null) return null;
  return l10n.apiErrorInventoryTransferOverReceived(
    code,
    received,
    outstanding,
  );
}

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

/// A date-and-time param.
String? _dateTime(ApiProblem problem, String key, AppFormatters fmt) {
  final value = problem.dateParam(key);
  return value == null ? null : fmt.display.dateTime(value);
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
