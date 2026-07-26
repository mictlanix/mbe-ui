//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price1.dart';
import 'package:mbe_api_client/src/model/quantity1.dart';
import 'package:mbe_api_client/src/model/discount_rate.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sales_order_line_create.g.dart';

/// SalesOrderLineCreate
///
/// Properties:
/// * [product]
/// * [quantity]
/// * [price]
/// * [discountRate]
/// * [warehouse]
/// * [delivery]
/// * [comment]
@BuiltValue()
abstract class SalesOrderLineCreate
    implements Built<SalesOrderLineCreate, SalesOrderLineCreateBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'quantity')
  Quantity1? get quantity;

  @BuiltValueField(wireName: r'price')
  Price1? get price;

  @BuiltValueField(wireName: r'discount_rate')
  DiscountRate? get discountRate;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'delivery')
  bool? get delivery;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SalesOrderLineCreate._();

  factory SalesOrderLineCreate([void updates(SalesOrderLineCreateBuilder b)]) =
      _$SalesOrderLineCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SalesOrderLineCreateBuilder b) => b..delivery = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<SalesOrderLineCreate> get serializer =>
      _$SalesOrderLineCreateSerializer();
}

class _$SalesOrderLineCreateSerializer
    implements PrimitiveSerializer<SalesOrderLineCreate> {
  @override
  final Iterable<Type> types = const [
    SalesOrderLineCreate,
    _$SalesOrderLineCreate,
  ];

  @override
  final String wireName = r'SalesOrderLineCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SalesOrderLineCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(Quantity1),
      );
    }
    if (object.price != null) {
      yield r'price';
      yield serializers.serialize(
        object.price,
        specifiedType: const FullType.nullable(Price1),
      );
    }
    if (object.discountRate != null) {
      yield r'discount_rate';
      yield serializers.serialize(
        object.discountRate,
        specifiedType: const FullType(DiscountRate),
      );
    }
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.delivery != null) {
      yield r'delivery';
      yield serializers.serialize(
        object.delivery,
        specifiedType: const FullType(bool),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SalesOrderLineCreate object, {
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
    required SalesOrderLineCreateBuilder result,
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
                    specifiedType: const FullType.nullable(Quantity1),
                  )
                  as Quantity1?;
          if (valueDes == null) continue;
          result.quantity.replace(valueDes);
          break;
        case r'price':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Price1),
                  )
                  as Price1?;
          if (valueDes == null) continue;
          result.price.replace(valueDes);
          break;
        case r'discount_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DiscountRate),
                  )
                  as DiscountRate;
          result.discountRate.replace(valueDes);
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
        case r'delivery':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.delivery = valueDes;
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SalesOrderLineCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SalesOrderLineCreateBuilder();
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
