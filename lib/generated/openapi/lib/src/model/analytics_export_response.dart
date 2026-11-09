//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/export_format.dart';
import 'package:mbe_api_client/src/model/export_source.dart';
import 'package:mbe_api_client/src/model/export_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_export_response.g.dart';

/// AnalyticsExportResponse
///
/// Properties:
/// * [analyticsExportId]
/// * [source_]
/// * [format]
/// * [status]
/// * [rowCount]
/// * [creationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [completionTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [expiryTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [downloadUrl]
@BuiltValue()
abstract class AnalyticsExportResponse
    implements Built<AnalyticsExportResponse, AnalyticsExportResponseBuilder> {
  @BuiltValueField(wireName: r'analytics_export_id')
  int get analyticsExportId;

  @BuiltValueField(wireName: r'source')
  ExportSource get source_;
  // enum source_Enum {  query,  dashboard,  detail,  };

  @BuiltValueField(wireName: r'format')
  ExportFormat get format;
  // enum formatEnum {  xlsx,  pdf,  csv,  };

  @BuiltValueField(wireName: r'status')
  ExportStatus get status;
  // enum statusEnum {  pending,  running,  ready,  failed,  };

  @BuiltValueField(wireName: r'row_count')
  int? get rowCount;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'creation_time')
  DateTime get creationTime;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'completion_time')
  DateTime? get completionTime;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'expiry_time')
  DateTime? get expiryTime;

  @BuiltValueField(wireName: r'download_url')
  String? get downloadUrl;

  AnalyticsExportResponse._();

  factory AnalyticsExportResponse([
    void updates(AnalyticsExportResponseBuilder b),
  ]) = _$AnalyticsExportResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsExportResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsExportResponse> get serializer =>
      _$AnalyticsExportResponseSerializer();
}

class _$AnalyticsExportResponseSerializer
    implements PrimitiveSerializer<AnalyticsExportResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsExportResponse,
    _$AnalyticsExportResponse,
  ];

  @override
  final String wireName = r'AnalyticsExportResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsExportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'analytics_export_id';
    yield serializers.serialize(
      object.analyticsExportId,
      specifiedType: const FullType(int),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(ExportSource),
    );
    yield r'format';
    yield serializers.serialize(
      object.format,
      specifiedType: const FullType(ExportFormat),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ExportStatus),
    );
    yield r'row_count';
    yield object.rowCount == null
        ? null
        : serializers.serialize(
            object.rowCount,
            specifiedType: const FullType.nullable(int),
          );
    yield r'creation_time';
    yield serializers.serialize(
      object.creationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'completion_time';
    yield object.completionTime == null
        ? null
        : serializers.serialize(
            object.completionTime,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'expiry_time';
    yield object.expiryTime == null
        ? null
        : serializers.serialize(
            object.expiryTime,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'download_url';
    yield object.downloadUrl == null
        ? null
        : serializers.serialize(
            object.downloadUrl,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsExportResponse object, {
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
    required AnalyticsExportResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'analytics_export_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.analyticsExportId = valueDes;
          break;
        case r'source':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ExportSource),
                  )
                  as ExportSource;
          result.source_ = valueDes;
          break;
        case r'format':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ExportFormat),
                  )
                  as ExportFormat;
          result.format = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ExportStatus),
                  )
                  as ExportStatus;
          result.status = valueDes;
          break;
        case r'row_count':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.rowCount = valueDes;
          break;
        case r'creation_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.creationTime = valueDes;
          break;
        case r'completion_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.completionTime = valueDes;
          break;
        case r'expiry_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.expiryTime = valueDes;
          break;
        case r'download_url':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.downloadUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsExportResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsExportResponseBuilder();
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
