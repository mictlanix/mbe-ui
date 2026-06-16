//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxpayer_recipient_response.g.dart';

/// TaxpayerRecipientResponse
///
/// Properties:
/// * [taxpayerRecipientId] 
/// * [name] 
/// * [email] 
/// * [postalCode] 
/// * [regime] 
@BuiltValue()
abstract class TaxpayerRecipientResponse implements Built<TaxpayerRecipientResponse, TaxpayerRecipientResponseBuilder> {
  @BuiltValueField(wireName: r'taxpayer_recipient_id')
  String get taxpayerRecipientId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'postal_code')
  String? get postalCode;

  @BuiltValueField(wireName: r'regime')
  String? get regime;

  TaxpayerRecipientResponse._();

  factory TaxpayerRecipientResponse([void updates(TaxpayerRecipientResponseBuilder b)]) = _$TaxpayerRecipientResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxpayerRecipientResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxpayerRecipientResponse> get serializer => _$TaxpayerRecipientResponseSerializer();
}

class _$TaxpayerRecipientResponseSerializer implements PrimitiveSerializer<TaxpayerRecipientResponse> {
  @override
  final Iterable<Type> types = const [TaxpayerRecipientResponse, _$TaxpayerRecipientResponse];

  @override
  final String wireName = r'TaxpayerRecipientResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxpayerRecipientResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxpayer_recipient_id';
    yield serializers.serialize(
      object.taxpayerRecipientId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null ? null : serializers.serialize(
      object.name,
      specifiedType: const FullType.nullable(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'postal_code';
    yield object.postalCode == null ? null : serializers.serialize(
      object.postalCode,
      specifiedType: const FullType.nullable(String),
    );
    yield r'regime';
    yield object.regime == null ? null : serializers.serialize(
      object.regime,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxpayerRecipientResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TaxpayerRecipientResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taxpayer_recipient_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.taxpayerRecipientId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'postal_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.postalCode = valueDes;
          break;
        case r'regime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.regime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxpayerRecipientResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxpayerRecipientResponseBuilder();
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

