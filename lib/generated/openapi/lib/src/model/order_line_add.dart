//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price.dart';
import 'package:mbe_api_client/src/model/quantity5.dart';
import 'package:mbe_api_client/src/model/tax_rate1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_line_add.g.dart';

/// OrderLineAdd
///
/// Properties:
/// * [product]
/// * [quantity]
/// * [warehouse]
/// * [price]
/// * [taxRate]
@BuiltValue()
abstract class OrderLineAdd
    implements Built<OrderLineAdd, OrderLineAddBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'quantity')
  Quantity5 get quantity;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'price')
  Price? get price;

  @BuiltValueField(wireName: r'tax_rate')
  TaxRate1? get taxRate;

  OrderLineAdd._();

  factory OrderLineAdd([void updates(OrderLineAddBuilder b)]) = _$OrderLineAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderLineAddBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderLineAdd> get serializer => _$OrderLineAddSerializer();
}

class _$OrderLineAddSerializer implements PrimitiveSerializer<OrderLineAdd> {
  @override
  final Iterable<Type> types = const [OrderLineAdd, _$OrderLineAdd];

  @override
  final String wireName = r'OrderLineAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderLineAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(Quantity5),
    );
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.price != null) {
      yield r'price';
      yield serializers.serialize(
        object.price,
        specifiedType: const FullType.nullable(Price),
      );
    }
    if (object.taxRate != null) {
      yield r'tax_rate';
      yield serializers.serialize(
        object.taxRate,
        specifiedType: const FullType.nullable(TaxRate1),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderLineAdd object, {
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
    required OrderLineAddBuilder result,
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
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Quantity5),
                  )
                  as Quantity5;
          result.quantity.replace(valueDes);
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.warehouse = valueDes;
          break;
        case r'price':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Price),
                  )
                  as Price?;
          if (valueDes == null) continue;
          result.price.replace(valueDes);
          break;
        case r'tax_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(TaxRate1),
                  )
                  as TaxRate1?;
          if (valueDes == null) continue;
          result.taxRate.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OrderLineAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderLineAddBuilder();
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
