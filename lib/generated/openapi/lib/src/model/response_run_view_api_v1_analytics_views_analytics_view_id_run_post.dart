//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_dashboard_request.dart';
import 'package:mbe_api_client/src/model/analytics_series.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/analytics_customer_response.dart';
import 'package:mbe_api_client/src/model/analytics_query_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_detail_item.dart';
import 'package:mbe_api_client/src/model/analytics_alert.dart';
import 'package:mbe_api_client/src/model/analytics_detail_response.dart';
import 'package:mbe_api_client/src/model/analytics_dashboard_response.dart';
import 'package:mbe_api_client/src/model/analytics_kpi.dart';
import 'package:mbe_api_client/src/model/analytics_row.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'response_run_view_api_v1_analytics_views_analytics_view_id_run_post.g.dart';

/// ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost
///
/// Properties:
/// * [asOf] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [definition]
/// * [rows]
/// * [others]
/// * [totals]
/// * [overlapping] - True when one document can count in several rows (grouped by label, or orders by a line dimension), so rows can add up to more than the totals.
/// * [comparisonStart]
/// * [comparisonEnd]
/// * [kpis]
/// * [series]
/// * [alerts]
/// * [items]
/// * [total]
/// * [sums] - amount, quantity, discount, and cost and margin for holders of the cost privilege, over every page: they equal the aggregate.
/// * [customer]
/// * [customerName]
/// * [start]
/// * [end]
/// * [sales] - Net sales, refunds, collected (payments family) and margin (cost) for the period, with the previous period. Null without the sales family.
/// * [receivable] - Receivable, current and overdue now, by aging bucket. Null without the receivables family.
/// * [topProducts] - The ten products with the most net sales in the period. Null without the sales family.
/// * [lastPurchase] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [ordersPerMonth] - Orders in the 12 months up to end ÷ 12, two decimals. Sales family.
/// * [creditLimit] - Spec 033's. Receivables family.
/// * [creditUtilization] - Spec 033's: owed across every facility ÷ the limit; null without a limit. Receivables family.
@BuiltValue()
abstract class ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost
    implements
        Built<
          ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost,
          ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPostBuilder
        > {
  /// Any Of [AnalyticsCustomerResponse], [AnalyticsDashboardResponse], [AnalyticsDetailResponse], [AnalyticsQueryResponse]
  AnyOf get anyOf;

  ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost._();

  factory ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost([
    void updates(
      ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPostBuilder b,
    ),
  ]) = _$ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
    ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPostBuilder b,
  ) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost>
  get serializer =>
      _$ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPostSerializer();
}

class _$ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPostSerializer
    implements
        PrimitiveSerializer<
          ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost
        > {
  @override
  final Iterable<Type> types = const [
    ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost,
    _$ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost,
  ];

  @override
  final String wireName =
      r'ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(
      anyOf,
      specifiedType: FullType(
        AnyOf,
        anyOf.types.map((type) => FullType(type)).toList(),
      ),
    )!;
  }

  @override
  ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPost deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        ResponseRunViewApiV1AnalyticsViewsAnalyticsViewIdRunPostBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(AnalyticsQueryResponse),
      FullType(AnalyticsDashboardResponse),
      FullType(AnalyticsDetailResponse),
      FullType(AnalyticsCustomerResponse),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf =
        serializers.deserialize(anyOfDataSrc, specifiedType: targetType)
            as AnyOf;
    return result.build();
  }
}
