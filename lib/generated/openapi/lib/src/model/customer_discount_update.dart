//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/discount.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_discount_update.g.dart';

/// CustomerDiscountUpdate
///
/// Properties:
/// * [discount]
@BuiltValue()
abstract class CustomerDiscountUpdate
    implements Built<CustomerDiscountUpdate, CustomerDiscountUpdateBuilder> {
  @BuiltValueField(wireName: r'discount')
  Discount get discount;

  CustomerDiscountUpdate._();

  factory CustomerDiscountUpdate([
    void updates(CustomerDiscountUpdateBuilder b),
  ]) = _$CustomerDiscountUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerDiscountUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerDiscountUpdate> get serializer =>
      _$CustomerDiscountUpdateSerializer();
}

class _$CustomerDiscountUpdateSerializer
    implements PrimitiveSerializer<CustomerDiscountUpdate> {
  @override
  final Iterable<Type> types = const [
    CustomerDiscountUpdate,
    _$CustomerDiscountUpdate,
  ];

  @override
  final String wireName = r'CustomerDiscountUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerDiscountUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'discount';
    yield serializers.serialize(
      object.discount,
      specifiedType: const FullType(Discount),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerDiscountUpdate object, {
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
    required CustomerDiscountUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  CustomerDiscountUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerDiscountUpdateBuilder();
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
