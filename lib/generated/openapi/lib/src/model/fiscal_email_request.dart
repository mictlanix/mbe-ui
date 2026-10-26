//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_email_request.g.dart';

/// 1–10 addresses, validated and deduplicated as spec 024's quote email does.
///
/// Properties:
/// * [to]
@BuiltValue()
abstract class FiscalEmailRequest
    implements Built<FiscalEmailRequest, FiscalEmailRequestBuilder> {
  @BuiltValueField(wireName: r'to')
  BuiltList<String> get to;

  FiscalEmailRequest._();

  factory FiscalEmailRequest([void updates(FiscalEmailRequestBuilder b)]) =
      _$FiscalEmailRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FiscalEmailRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FiscalEmailRequest> get serializer =>
      _$FiscalEmailRequestSerializer();
}

class _$FiscalEmailRequestSerializer
    implements PrimitiveSerializer<FiscalEmailRequest> {
  @override
  final Iterable<Type> types = const [FiscalEmailRequest, _$FiscalEmailRequest];

  @override
  final String wireName = r'FiscalEmailRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FiscalEmailRequest object, {
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
    FiscalEmailRequest object, {
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
    required FiscalEmailRequestBuilder result,
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
  FiscalEmailRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FiscalEmailRequestBuilder();
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
