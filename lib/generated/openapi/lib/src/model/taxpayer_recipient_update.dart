//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxpayer_recipient_update.g.dart';

/// TaxpayerRecipientUpdate
///
/// Properties:
/// * [name]
/// * [email]
/// * [postalCode]
/// * [regime]
@BuiltValue()
abstract class TaxpayerRecipientUpdate
    implements Built<TaxpayerRecipientUpdate, TaxpayerRecipientUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'postal_code')
  String? get postalCode;

  @BuiltValueField(wireName: r'regime')
  String? get regime;

  TaxpayerRecipientUpdate._();

  factory TaxpayerRecipientUpdate([
    void updates(TaxpayerRecipientUpdateBuilder b),
  ]) = _$TaxpayerRecipientUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxpayerRecipientUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxpayerRecipientUpdate> get serializer =>
      _$TaxpayerRecipientUpdateSerializer();
}

class _$TaxpayerRecipientUpdateSerializer
    implements PrimitiveSerializer<TaxpayerRecipientUpdate> {
  @override
  final Iterable<Type> types = const [
    TaxpayerRecipientUpdate,
    _$TaxpayerRecipientUpdate,
  ];

  @override
  final String wireName = r'TaxpayerRecipientUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxpayerRecipientUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    TaxpayerRecipientUpdate object, {
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
    required TaxpayerRecipientUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'email':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'postal_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.postalCode = valueDes;
          break;
        case r'regime':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
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
  TaxpayerRecipientUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxpayerRecipientUpdateBuilder();
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
