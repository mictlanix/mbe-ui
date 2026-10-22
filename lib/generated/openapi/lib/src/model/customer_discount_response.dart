//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/product_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_discount_response.g.dart';

/// CustomerDiscountResponse
///
/// Properties:
/// * [customerDiscountId]
/// * [customer]
/// * [product]
/// * [discount]
@BuiltValue()
abstract class CustomerDiscountResponse
    implements
        Built<CustomerDiscountResponse, CustomerDiscountResponseBuilder> {
  @BuiltValueField(wireName: r'customer_discount_id')
  int get customerDiscountId;

  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'product')
  ProductSummary get product;

  @BuiltValueField(wireName: r'discount')
  String get discount;

  CustomerDiscountResponse._();

  factory CustomerDiscountResponse([
    void updates(CustomerDiscountResponseBuilder b),
  ]) = _$CustomerDiscountResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerDiscountResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerDiscountResponse> get serializer =>
      _$CustomerDiscountResponseSerializer();
}

class _$CustomerDiscountResponseSerializer
    implements PrimitiveSerializer<CustomerDiscountResponse> {
  @override
  final Iterable<Type> types = const [
    CustomerDiscountResponse,
    _$CustomerDiscountResponse,
  ];

  @override
  final String wireName = r'CustomerDiscountResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerDiscountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer_discount_id';
    yield serializers.serialize(
      object.customerDiscountId,
      specifiedType: const FullType(int),
    );
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(ProductSummary),
    );
    yield r'discount';
    yield serializers.serialize(
      object.discount,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerDiscountResponse object, {
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
    required CustomerDiscountResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customer_discount_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customerDiscountId = valueDes;
          break;
        case r'customer':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customer = valueDes;
          break;
        case r'product':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ProductSummary),
                  )
                  as ProductSummary;
          result.product.replace(valueDes);
          break;
        case r'discount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.discount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerDiscountResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerDiscountResponseBuilder();
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
