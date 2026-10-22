//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'quote_email_request.g.dart';

/// QuoteEmailRequest
///
/// Properties:
/// * [to]
@BuiltValue()
abstract class QuoteEmailRequest
    implements Built<QuoteEmailRequest, QuoteEmailRequestBuilder> {
  @BuiltValueField(wireName: r'to')
  BuiltList<String> get to;

  QuoteEmailRequest._();

  factory QuoteEmailRequest([void updates(QuoteEmailRequestBuilder b)]) =
      _$QuoteEmailRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(QuoteEmailRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<QuoteEmailRequest> get serializer =>
      _$QuoteEmailRequestSerializer();
}

class _$QuoteEmailRequestSerializer
    implements PrimitiveSerializer<QuoteEmailRequest> {
  @override
  final Iterable<Type> types = const [QuoteEmailRequest, _$QuoteEmailRequest];

  @override
  final String wireName = r'QuoteEmailRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    QuoteEmailRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    QuoteEmailRequest object, {
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
    required QuoteEmailRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  QuoteEmailRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = QuoteEmailRequestBuilder();
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
