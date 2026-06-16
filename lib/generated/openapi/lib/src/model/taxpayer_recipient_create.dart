//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxpayer_recipient_create.g.dart';

/// TaxpayerRecipientCreate
///
/// Properties:
/// * [taxpayerRecipientId] 
/// * [name] 
/// * [email] 
/// * [postalCode] 
/// * [regime] 
@BuiltValue()
abstract class TaxpayerRecipientCreate implements Built<TaxpayerRecipientCreate, TaxpayerRecipientCreateBuilder> {
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

  TaxpayerRecipientCreate._();

  factory TaxpayerRecipientCreate([void updates(TaxpayerRecipientCreateBuilder b)]) = _$TaxpayerRecipientCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxpayerRecipientCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxpayerRecipientCreate> get serializer => _$TaxpayerRecipientCreateSerializer();
}

class _$TaxpayerRecipientCreateSerializer implements PrimitiveSerializer<TaxpayerRecipientCreate> {
  @override
  final Iterable<Type> types = const [TaxpayerRecipientCreate, _$TaxpayerRecipientCreate];

  @override
  final String wireName = r'TaxpayerRecipientCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxpayerRecipientCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxpayer_recipient_id';
    yield serializers.serialize(
      object.taxpayerRecipientId,
      specifiedType: const FullType(String),
    );
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    if (object.postalCode != null) {
      yield r'postal_code';
      yield serializers.serialize(
        object.postalCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.regime != null) {
      yield r'regime';
      yield serializers.serialize(
        object.regime,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxpayerRecipientCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TaxpayerRecipientCreateBuilder result,
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
  TaxpayerRecipientCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxpayerRecipientCreateBuilder();
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

