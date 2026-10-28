//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'statement_email_response.g.dart';

/// StatementEmailResponse
///
/// Properties:
/// * [sentAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [to]
@BuiltValue()
abstract class StatementEmailResponse
    implements Built<StatementEmailResponse, StatementEmailResponseBuilder> {
  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'sent_at')
  DateTime get sentAt;

  @BuiltValueField(wireName: r'to')
  BuiltList<String> get to;

  StatementEmailResponse._();

  factory StatementEmailResponse([
    void updates(StatementEmailResponseBuilder b),
  ]) = _$StatementEmailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StatementEmailResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StatementEmailResponse> get serializer =>
      _$StatementEmailResponseSerializer();
}

class _$StatementEmailResponseSerializer
    implements PrimitiveSerializer<StatementEmailResponse> {
  @override
  final Iterable<Type> types = const [
    StatementEmailResponse,
    _$StatementEmailResponse,
  ];

  @override
  final String wireName = r'StatementEmailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StatementEmailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sent_at';
    yield serializers.serialize(
      object.sentAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StatementEmailResponse object, {
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
    required StatementEmailResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sent_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.sentAt = valueDes;
          break;
        case r'to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.to.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StatementEmailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StatementEmailResponseBuilder();
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
