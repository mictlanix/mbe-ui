//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/error_code.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_approve_result.g.dart';

/// BulkApproveResult
///
/// Properties:
/// * [purchaseRequestId]
/// * [approved]
/// * [reason]
/// * [code]
/// * [params]
@BuiltValue()
abstract class BulkApproveResult
    implements Built<BulkApproveResult, BulkApproveResultBuilder> {
  @BuiltValueField(wireName: r'purchase_request_id')
  int get purchaseRequestId;

  @BuiltValueField(wireName: r'approved')
  bool get approved;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'code')
  ErrorCode? get code;
  // enum codeEnum {  auth.administrator_required,  auth.forbidden,  auth.incorrect_current_password,  auth.invalid_credentials,  auth.not_authenticated,  auth.password_change_required,  auth.recovery_token_invalid,  cash_session.already_closed,  cash_session.closed,  cash_session.drawer_busy,  cash_session.not_closed,  cash_session.not_open,  cash_session.user_busy,  commission_agent.salesperson_not_agent,  commission_period.already_closed,  commission_period.already_paid,  commission_period.later_closed,  commission_period.not_closed,  commission_period.not_ended,  commission_period.paid_cannot_reopen,  commission_period.previous_not_closed,  csd.certificate_not_rsa,  csd.certificate_unreadable,  csd.key_mismatch,  csd.key_not_encrypted,  csd.key_not_rsa,  csd.key_unreadable,  customer.credit_hold,  customer.credit_limit_exceeded,  customer.credit_limit_reached,  customer.default_not_deletable,  customer.no_credit_limit,  customer.walk_in_no_credit,  customer_discount.product_not_found,  delivery_order.insufficient_notice,  delivery_order.line_already_present,  delivery_order.line_not_deliverable,  delivery_order.line_repeated,  delivery_order.mixed_not_allowed,  delivery_order.no_lines,  delivery_order.no_lines_from_warehouse,  delivery_order.not_approved,  delivery_order.not_editable,  delivery_order.not_failed,  delivery_order.not_in_preparation,  delivery_order.not_pending_approval,  delivery_order.pickup_not_loadable,  delivery_order.proof_incomplete,  delivery_order.quantity_exceeds_remaining,  delivery_order.reason_required,  delivery_order.sales_order_fully_delivered,  delivery_order.sales_order_not_deliverable,  delivery_order.sales_order_unpaid,  delivery_order.unknown_warehouse,  delivery_order_line.nothing_to_load,  delivery_order_line.quantity_unavailable,  document.not_editable,  email.contact_no_address,  email.contact_not_of_party,  email.no_recipients,  email.not_configured,  email.send_failed,  email.too_many_recipients,  expense_voucher.not_cashier,  expense_voucher.not_confirmed,  expense_voucher.total_not_positive,  expense_voucher.unknown_category,  facility.no_dispatch_warehouse,  facility.no_in_transit_location,  facility.other_facility,  facility.required,  fiscal_document.already_related,  fiscal_document.amount_exceeds_balance,  fiscal_document.amounts_exceed_payment,  fiscal_document.amounts_not_equal_payment,  fiscal_document.certificate_cannot_sign,  fiscal_document.credit_exceeds_invoice,  fiscal_document.credit_quantity_exceeds_line,  fiscal_document.field_not_for_type,  fiscal_document.invoice_already_on_receipt,  fiscal_document.invoice_not_creditable,  fiscal_document.invoice_not_payable,  fiscal_document.issue_date_out_of_range,  fiscal_document.issuer_has_no_series,  fiscal_document.line_missing_sat_key,  fiscal_document.line_quantity_not_positive,  fiscal_document.no_invoiceable_lines,  fiscal_document.no_lines,  fiscal_document.no_valid_certificate,  fiscal_document.not_draft,  fiscal_document.not_emailable,  fiscal_document.not_issued,  fiscal_document.not_sealed,  fiscal_document.not_stamped,  fiscal_document.order_not_invoiceable,  fiscal_document.payment_already_receipted,  fiscal_document.payment_date_out_of_range,  fiscal_document.payment_form_required,  fiscal_document.payment_other_customer,  fiscal_document.product_unpriced,  fiscal_document.quantity_exceeds_invoiceable,  fiscal_document.receipt_needs_payment_data,  fiscal_document.receipt_pays_no_invoice,  fiscal_document.recipient_incomplete,  fiscal_document.recipient_not_linked,  fiscal_document.relation_not_allowed,  fiscal_document.relation_types_mixed,  fiscal_document.series_locked,  fiscal_document.series_missing,  fiscal_document.series_not_of_type,  fiscal_document.type_not_supported,  fiscal_document.unknown_facility,  fiscal_document.unknown_usage,  fiscal_document.version_not_printable,  fiscal_document.xml_unavailable,  image.too_large,  image.unsupported_format,  incidence.reason_required,  inventory_count.batch_invalid,  inventory_count.confirmed_cannot_cancel,  inventory_count_line.not_stockable,  inventory_count_line.product_reference,  inventory_count_line.product_unknown,  inventory_count_line.repeated,  inventory_document.already_cancelled,  inventory_document.insufficient_stock,  inventory_document.line_without_quantity,  inventory_document.no_lines,  inventory_receipt.warehouse_fixed,  inventory_receipt.complementary_unavailable,  inventory_transfer.line_repeated,  inventory_transfer.not_in_transit,  inventory_transfer.over_received,  inventory_transfer.same_warehouse,  itinerary.cancelled,  itinerary.lines_overcommitted,  itinerary.not_departed,  itinerary.not_open,  itinerary.nothing_committed,  itinerary.stop_already_resolved,  itinerary.stop_delivered_exceeds_sent,  itinerary.stop_lines_incomplete,  itinerary.stop_lines_malformed,  itinerary.stop_shortfall_needs_reason,  kardex.range_reversed,  kardex.range_too_long,  lock.busy,  payment.already_verified,  payment.application_reversed,  payment.currency_mismatch,  payment.customer_mismatch,  payment.exceeds_order_balance,  payment.exceeds_unapplied,  payment.no_ticket,  payment.order_cancelled,  payment.order_not_completed,  payment.order_settled,  point_of_sale.warehouse_facility_mismatch,  price_list.cost_not_assignable,  price_list.cost_not_deletable,  price_list.cost_read_only,  price_list.replace_with_itself,  product.lookup_criteria_required,  product.lookup_too_many,  product.merge_with_itself,  product.not_purchasable,  product.not_stockable,  product_price.duplicate_entry,  product_price.references_not_found,  purchase_order.already_cancelled,  purchase_order.confirmed_cannot_cancel,  purchase_order.line_without_quantity,  purchase_order.no_lines,  purchase_order.no_supplier,  purchase_order.not_confirmed,  purchase_order.nothing_pending,  purchase_order.nothing_to_add,  purchase_order.request_not_approved,  purchase_request.already_cancelled,  purchase_request.facility_locked,  purchase_request.line_on_live_order,  purchase_request.line_without_quantity,  purchase_request.lines_not_markable,  purchase_request.lines_on_live_order,  purchase_request.no_lines,  purchase_request.not_draft,  purchase_request.not_submitted,  purchase_request.warehouse_facility_changed,  quote.already_cancelled,  quote.cancelled,  quote.expired,  quote.not_confirmed,  refund.already_cancelled,  refund.completed_cannot_cancel,  refund.line_invoiced,  refund.no_returnable_lines,  refund.not_confirmed,  refund.nothing_refundable,  refund.order_not_completed,  refund.order_not_paid,  refund.quantity_exceeds_refundable,  refund.warehouse_other_facility,  request.malformed,  request.method_not_allowed,  request.route_not_found,  resource.already_exists,  resource.conflict,  resource.not_found,  resource.still_referenced,  sales_order.already_cancelled,  sales_order.below_min_quantity,  sales_order.has_payment_applications,  sales_order.insufficient_stock,  sales_order.missing_delivery_details,  sales_order.no_lines,  sales_order.not_confirmed,  sales_order.paid_cannot_cancel,  sales_order.zero_priced_lines,  server.error,  state.transition_invalid,  status_filter.unsupported,  supplier_agreement.end_before_start,  supplier_payment.already_cancelled,  supplier_payment.amount_exceeds_balance,  supplier_payment.amounts_exceed_credit,  supplier_payment.application_already_reversed,  supplier_payment.cancelled,  supplier_payment.cutoff_not_set,  supplier_payment.facility_not_nameable,  supplier_payment.legacy_not_applicable,  supplier_payment.order_before_cutoff,  supplier_payment.order_other_supplier,  taxpayer_batch.in_use,  taxpayer_certificate.holder_mismatch,  taxpayer_issuer.unknown,  user.no_cash_drawer,  user.no_facility,  user.no_point_of_sale,  user_profile.not_active,  vehicle.open_itinerary_exists,  warehouse.in_transit_location,  warehouse.in_transit_managed,  warehouse.required,  };

  @BuiltValueField(wireName: r'params')
  BuiltMap<String, JsonObject?>? get params;

  BulkApproveResult._();

  factory BulkApproveResult([void updates(BulkApproveResultBuilder b)]) =
      _$BulkApproveResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkApproveResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkApproveResult> get serializer =>
      _$BulkApproveResultSerializer();
}

class _$BulkApproveResultSerializer
    implements PrimitiveSerializer<BulkApproveResult> {
  @override
  final Iterable<Type> types = const [BulkApproveResult, _$BulkApproveResult];

  @override
  final String wireName = r'BulkApproveResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkApproveResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_request_id';
    yield serializers.serialize(
      object.purchaseRequestId,
      specifiedType: const FullType(int),
    );
    yield r'approved';
    yield serializers.serialize(
      object.approved,
      specifiedType: const FullType(bool),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType.nullable(ErrorCode),
      );
    }
    if (object.params != null) {
      yield r'params';
      yield serializers.serialize(
        object.params,
        specifiedType: const FullType.nullable(BuiltMap, [
          FullType(String),
          FullType.nullable(JsonObject),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkApproveResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(
      serializers,
      object,
      specifiedType: specifiedType,
    ).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BulkApproveResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_request_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseRequestId = valueDes;
          break;
        case r'approved':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.approved = valueDes;
          break;
        case r'reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(ErrorCode),
                  )
                  as ErrorCode?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'params':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltMap, [
                      FullType(String),
                      FullType.nullable(JsonObject),
                    ]),
                  )
                  as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.params.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BulkApproveResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkApproveResultBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
