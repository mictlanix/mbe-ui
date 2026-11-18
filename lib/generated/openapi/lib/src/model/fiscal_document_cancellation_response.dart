//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_document_cancellation_response.g.dart';

/// One cancellation request (spec 039), newest first in the detail.
///
/// Properties:
/// * [fiscalDocumentCancellationId]
/// * [reason]
/// * [substitution]
/// * [status]
/// * [pacCode]
/// * [pacMessage]
/// * [requestedBy]
/// * [requestedAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [answeredAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [resolvedAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [lastCheckedAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
@BuiltValue()
abstract class FiscalDocumentCancellationResponse
    implements
        Built<
          FiscalDocumentCancellationResponse,
          FiscalDocumentCancellationResponseBuilder
        > {
  @BuiltValueField(wireName: r'fiscal_document_cancellation_id')
  int get fiscalDocumentCancellationId;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'substitution')
  String? get substitution;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'pac_code')
  String? get pacCode;

  @BuiltValueField(wireName: r'pac_message')
  String? get pacMessage;

  @BuiltValueField(wireName: r'requested_by')
  int get requestedBy;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'requested_at')
  DateTime get requestedAt;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'answered_at')
  DateTime? get answeredAt;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'last_checked_at')
  DateTime? get lastCheckedAt;

  FiscalDocumentCancellationResponse._();

  factory FiscalDocumentCancellationResponse([
    void updates(FiscalDocumentCancellationResponseBuilder b),
  ]) = _$FiscalDocumentCancellationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FiscalDocumentCancellationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FiscalDocumentCancellationResponse> get serializer =>
      _$FiscalDocumentCancellationResponseSerializer();
}

class _$FiscalDocumentCancellationResponseSerializer
    implements PrimitiveSerializer<FiscalDocumentCancellationResponse> {
  @override
  final Iterable<Type> types = const [
    FiscalDocumentCancellationResponse,
    _$FiscalDocumentCancellationResponse,
  ];

  @override
  final String wireName = r'FiscalDocumentCancellationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FiscalDocumentCancellationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fiscal_document_cancellation_id';
    yield serializers.serialize(
      object.fiscalDocumentCancellationId,
      specifiedType: const FullType(int),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'substitution';
    yield object.substitution == null
        ? null
        : serializers.serialize(
            object.substitution,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'pac_code';
    yield object.pacCode == null
        ? null
        : serializers.serialize(
            object.pacCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'pac_message';
    yield object.pacMessage == null
        ? null
        : serializers.serialize(
            object.pacMessage,
            specifiedType: const FullType.nullable(String),
          );
    yield r'requested_by';
    yield serializers.serialize(
      object.requestedBy,
      specifiedType: const FullType(int),
    );
    yield r'requested_at';
    yield serializers.serialize(
      object.requestedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'answered_at';
    yield object.answeredAt == null
        ? null
        : serializers.serialize(
            object.answeredAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'resolved_at';
    yield object.resolvedAt == null
        ? null
        : serializers.serialize(
            object.resolvedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'last_checked_at';
    yield object.lastCheckedAt == null
        ? null
        : serializers.serialize(
            object.lastCheckedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    FiscalDocumentCancellationResponse object, {
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
    required FiscalDocumentCancellationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fiscal_document_cancellation_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.fiscalDocumentCancellationId = valueDes;
          break;
        case r'reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.reason = valueDes;
          break;
        case r'substitution':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.substitution = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.status = valueDes;
          break;
        case r'pac_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.pacCode = valueDes;
          break;
        case r'pac_message':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.pacMessage = valueDes;
          break;
        case r'requested_by':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.requestedBy = valueDes;
          break;
        case r'requested_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.requestedAt = valueDes;
          break;
        case r'answered_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.answeredAt = valueDes;
          break;
        case r'resolved_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        case r'last_checked_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.lastCheckedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FiscalDocumentCancellationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FiscalDocumentCancellationResponseBuilder();
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
