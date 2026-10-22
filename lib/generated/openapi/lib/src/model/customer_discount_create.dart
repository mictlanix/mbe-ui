//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/discount.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_discount_create.g.dart';

/// CustomerDiscountCreate
///
/// Properties:
/// * [product]
/// * [discount]
@BuiltValue()
abstract class CustomerDiscountCreate
    implements Built<CustomerDiscountCreate, CustomerDiscountCreateBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'discount')
  Discount get discount;

  CustomerDiscountCreate._();

  factory CustomerDiscountCreate([
    void updates(CustomerDiscountCreateBuilder b),
  ]) = _$CustomerDiscountCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerDiscountCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerDiscountCreate> get serializer =>
      _$CustomerDiscountCreateSerializer();
}

class _$CustomerDiscountCreateSerializer
    implements PrimitiveSerializer<CustomerDiscountCreate> {
  @override
  final Iterable<Type> types = const [
    CustomerDiscountCreate,
    _$CustomerDiscountCreate,
  ];

  @override
  final String wireName = r'CustomerDiscountCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerDiscountCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'discount';
    yield serializers.serialize(
      object.discount,
      specifiedType: const FullType(Discount),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerDiscountCreate object, {
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
    required CustomerDiscountCreateBuilder result,
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
        case r'discount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Discount),
                  )
                  as Discount;
          result.discount.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerDiscountCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerDiscountCreateBuilder();
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
