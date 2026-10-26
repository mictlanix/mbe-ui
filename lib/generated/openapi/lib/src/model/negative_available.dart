//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'negative_available.g.dart';

/// NegativeAvailable
///
/// Properties:
/// * [product]
/// * [productCode]
/// * [counted]
/// * [reserved]
/// * [available]
@BuiltValue()
abstract class NegativeAvailable
    implements Built<NegativeAvailable, NegativeAvailableBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'counted')
  String get counted;

  @BuiltValueField(wireName: r'reserved')
  String get reserved;

  @BuiltValueField(wireName: r'available')
  String get available;

  NegativeAvailable._();

  factory NegativeAvailable([void updates(NegativeAvailableBuilder b)]) =
      _$NegativeAvailable;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NegativeAvailableBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NegativeAvailable> get serializer =>
      _$NegativeAvailableSerializer();
}

class _$NegativeAvailableSerializer
    implements PrimitiveSerializer<NegativeAvailable> {
  @override
  final Iterable<Type> types = const [NegativeAvailable, _$NegativeAvailable];

  @override
  final String wireName = r'NegativeAvailable';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NegativeAvailable object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_code';
    yield object.productCode == null
        ? null
        : serializers.serialize(
            object.productCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'counted';
    yield serializers.serialize(
      object.counted,
      specifiedType: const FullType(String),
    );
    yield r'reserved';
    yield serializers.serialize(
      object.reserved,
      specifiedType: const FullType(String),
    );
    yield r'available';
    yield serializers.serialize(
      object.available,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NegativeAvailable object, {
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
    required NegativeAvailableBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'product_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productCode = valueDes;
          break;
        case r'counted':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.counted = valueDes;
          break;
        case r'reserved':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.reserved = valueDes;
          break;
        case r'available':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.available = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NegativeAvailable deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NegativeAvailableBuilder();
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
