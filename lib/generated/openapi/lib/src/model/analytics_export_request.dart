//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_dashboard_request.dart';
import 'package:mbe_api_client/src/model/analytics_detail_request.dart';
import 'package:mbe_api_client/src/model/export_format.dart';
import 'package:mbe_api_client/src/model/analytics_query_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_export_request.g.dart';

/// Exactly one source; a dashboard exports only to PDF (`analytics.export_source_invalid`).
///
/// Properties:
/// * [format]
/// * [query]
/// * [dashboard]
/// * [detail]
@BuiltValue()
abstract class AnalyticsExportRequest
    implements Built<AnalyticsExportRequest, AnalyticsExportRequestBuilder> {
  @BuiltValueField(wireName: r'format')
  ExportFormat get format;
  // enum formatEnum {  xlsx,  pdf,  csv,  };

  @BuiltValueField(wireName: r'query')
  AnalyticsQueryRequest? get query;

  @BuiltValueField(wireName: r'dashboard')
  AnalyticsDashboardRequest? get dashboard;

  @BuiltValueField(wireName: r'detail')
  AnalyticsDetailRequest? get detail;

  AnalyticsExportRequest._();

  factory AnalyticsExportRequest([
    void updates(AnalyticsExportRequestBuilder b),
  ]) = _$AnalyticsExportRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsExportRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsExportRequest> get serializer =>
      _$AnalyticsExportRequestSerializer();
}

class _$AnalyticsExportRequestSerializer
    implements PrimitiveSerializer<AnalyticsExportRequest> {
  @override
  final Iterable<Type> types = const [
    AnalyticsExportRequest,
    _$AnalyticsExportRequest,
  ];

  @override
  final String wireName = r'AnalyticsExportRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsExportRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'format';
    yield serializers.serialize(
      object.format,
      specifiedType: const FullType(ExportFormat),
    );
    if (object.query != null) {
      yield r'query';
      yield serializers.serialize(
        object.query,
        specifiedType: const FullType.nullable(AnalyticsQueryRequest),
      );
    }
    if (object.dashboard != null) {
      yield r'dashboard';
      yield serializers.serialize(
        object.dashboard,
        specifiedType: const FullType.nullable(AnalyticsDashboardRequest),
      );
    }
    if (object.detail != null) {
      yield r'detail';
      yield serializers.serialize(
        object.detail,
        specifiedType: const FullType.nullable(AnalyticsDetailRequest),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsExportRequest object, {
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
    required AnalyticsExportRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'format':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ExportFormat),
                  )
                  as ExportFormat;
          result.format = valueDes;
          break;
        case r'query':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      AnalyticsQueryRequest,
                    ),
                  )
                  as AnalyticsQueryRequest?;
          if (valueDes == null) continue;
          result.query.replace(valueDes);
          break;
        case r'dashboard':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      AnalyticsDashboardRequest,
                    ),
                  )
                  as AnalyticsDashboardRequest?;
          if (valueDes == null) continue;
          result.dashboard.replace(valueDes);
          break;
        case r'detail':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      AnalyticsDetailRequest,
                    ),
                  )
                  as AnalyticsDetailRequest?;
          if (valueDes == null) continue;
          result.detail.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsExportRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsExportRequestBuilder();
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
