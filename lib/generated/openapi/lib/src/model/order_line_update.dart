//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price.dart';
import 'package:mbe_api_client/src/model/quantity4.dart';
import 'package:mbe_api_client/src/model/tax_rate1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_line_update.g.dart';

/// OrderLineUpdate
///
/// Properties:
/// * [quantity]
/// * [warehouse]
/// * [price]
/// * [taxRate]
@BuiltValue()
abstract class OrderLineUpdate
    implements Built<OrderLineUpdate, OrderLineUpdateBuilder> {
  @BuiltValueField(wireName: r'quantity')
  Quantity4? get quantity;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'price')
  Price? get price;

  @BuiltValueField(wireName: r'tax_rate')
  TaxRate1? get taxRate;

  OrderLineUpdate._();

  factory OrderLineUpdate([void updates(OrderLineUpdateBuilder b)]) =
      _$OrderLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderLineUpdate> get serializer =>
      _$OrderLineUpdateSerializer();
}

class _$OrderLineUpdateSerializer
    implements PrimitiveSerializer<OrderLineUpdate> {
  @override
  final Iterable<Type> types = const [OrderLineUpdate, _$OrderLineUpdate];

  @override
  final String wireName = r'OrderLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(Quantity4),
      );
    }
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
    OrderLineUpdate object, {
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
    required OrderLineUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Quantity4),
                  )
                  as Quantity4?;
          if (valueDes == null) continue;
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
  OrderLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderLineUpdateBuilder();
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
