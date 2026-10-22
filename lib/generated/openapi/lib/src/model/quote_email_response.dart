//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quote_email_response.g.dart';

/// QuoteEmailResponse
///
/// Properties:
/// * [recipients]
/// * [sentAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
@BuiltValue()
abstract class QuoteEmailResponse
    implements Built<QuoteEmailResponse, QuoteEmailResponseBuilder> {
  @BuiltValueField(wireName: r'recipients')
  BuiltList<String> get recipients;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'sent_at')
  DateTime get sentAt;

  QuoteEmailResponse._();

  factory QuoteEmailResponse([void updates(QuoteEmailResponseBuilder b)]) =
      _$QuoteEmailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QuoteEmailResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<QuoteEmailResponse> get serializer =>
      _$QuoteEmailResponseSerializer();
}

class _$QuoteEmailResponseSerializer
    implements PrimitiveSerializer<QuoteEmailResponse> {
  @override
  final Iterable<Type> types = const [QuoteEmailResponse, _$QuoteEmailResponse];

  @override
  final String wireName = r'QuoteEmailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    QuoteEmailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recipients';
    yield serializers.serialize(
      object.recipients,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'sent_at';
    yield serializers.serialize(
      object.sentAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    QuoteEmailResponse object, {
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
    required QuoteEmailResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recipients':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.recipients.replace(valueDes);
          break;
        case r'sent_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.sentAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  QuoteEmailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QuoteEmailResponseBuilder();
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
