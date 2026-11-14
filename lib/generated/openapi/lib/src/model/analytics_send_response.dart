//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/send_outcome.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_send_response.g.dart';

/// AnalyticsSendResponse
///
/// Properties:
/// * [analyticsSendId]
/// * [occurrence] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [startedAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [finishedAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [outcome] - A row left running over 10 minutes reads as failed.
/// * [code] - The spec 036 code of a failure or skip.
/// * [sentTo]
/// * [dropped] - Recipients who no longer qualified at send time.
/// * [size] - Attachment bytes.
/// * [rowCount]
@BuiltValue()
abstract class AnalyticsSendResponse
    implements Built<AnalyticsSendResponse, AnalyticsSendResponseBuilder> {
  @BuiltValueField(wireName: r'analytics_send_id')
  int get analyticsSendId;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'occurrence')
  DateTime get occurrence;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'finished_at')
  DateTime? get finishedAt;

  /// A row left running over 10 minutes reads as failed.
  @BuiltValueField(wireName: r'outcome')
  SendOutcome get outcome;
  // enum outcomeEnum {  running,  sent,  failed,  skipped,  };

  /// The spec 036 code of a failure or skip.
  @BuiltValueField(wireName: r'code')
  String? get code;

  @BuiltValueField(wireName: r'sent_to')
  BuiltList<String> get sentTo;

  /// Recipients who no longer qualified at send time.
  @BuiltValueField(wireName: r'dropped')
  BuiltList<String> get dropped;

  /// Attachment bytes.
  @BuiltValueField(wireName: r'size')
  int? get size;

  @BuiltValueField(wireName: r'row_count')
  int? get rowCount;

  AnalyticsSendResponse._();

  factory AnalyticsSendResponse([
    void updates(AnalyticsSendResponseBuilder b),
  ]) = _$AnalyticsSendResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsSendResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsSendResponse> get serializer =>
      _$AnalyticsSendResponseSerializer();
}

class _$AnalyticsSendResponseSerializer
    implements PrimitiveSerializer<AnalyticsSendResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsSendResponse,
    _$AnalyticsSendResponse,
  ];

  @override
  final String wireName = r'AnalyticsSendResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsSendResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'analytics_send_id';
    yield serializers.serialize(
      object.analyticsSendId,
      specifiedType: const FullType(int),
    );
    yield r'occurrence';
    yield serializers.serialize(
      object.occurrence,
      specifiedType: const FullType(DateTime),
    );
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'finished_at';
    yield object.finishedAt == null
        ? null
        : serializers.serialize(
            object.finishedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(SendOutcome),
    );
    yield r'code';
    yield object.code == null
        ? null
        : serializers.serialize(
            object.code,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sent_to';
    yield serializers.serialize(
      object.sentTo,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'dropped';
    yield serializers.serialize(
      object.dropped,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'size';
    yield object.size == null
        ? null
        : serializers.serialize(
            object.size,
            specifiedType: const FullType.nullable(int),
          );
    yield r'row_count';
    yield object.rowCount == null
        ? null
        : serializers.serialize(
            object.rowCount,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsSendResponse object, {
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
    required AnalyticsSendResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'analytics_send_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.analyticsSendId = valueDes;
          break;
        case r'occurrence':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.occurrence = valueDes;
          break;
        case r'started_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.startedAt = valueDes;
          break;
        case r'finished_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.finishedAt = valueDes;
          break;
        case r'outcome':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(SendOutcome),
                  )
                  as SendOutcome;
          result.outcome = valueDes;
          break;
        case r'code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'sent_to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.sentTo.replace(valueDes);
          break;
        case r'dropped':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.dropped.replace(valueDes);
          break;
        case r'size':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.size = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsSendResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsSendResponseBuilder();
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
