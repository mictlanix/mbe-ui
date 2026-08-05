//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price1.dart';
import 'package:mbe_api_client/src/model/tax_rate1.dart';
import 'package:mbe_api_client/src/model/quantity.dart';
import 'package:mbe_api_client/src/model/discount_rate1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sales_order_line_update.g.dart';

/// SalesOrderLineUpdate
///
/// Properties:
/// * [quantity]
/// * [price]
/// * [discountRate]
/// * [taxRate]
/// * [warehouse]
/// * [comment]
@BuiltValue()
abstract class SalesOrderLineUpdate
    implements Built<SalesOrderLineUpdate, SalesOrderLineUpdateBuilder> {
  @BuiltValueField(wireName: r'quantity')
  Quantity? get quantity;

  @BuiltValueField(wireName: r'price')
  Price1? get price;

  @BuiltValueField(wireName: r'discount_rate')
  DiscountRate1? get discountRate;

  @BuiltValueField(wireName: r'tax_rate')
  TaxRate1? get taxRate;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SalesOrderLineUpdate._();

  factory SalesOrderLineUpdate([void updates(SalesOrderLineUpdateBuilder b)]) =
      _$SalesOrderLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SalesOrderLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SalesOrderLineUpdate> get serializer =>
      _$SalesOrderLineUpdateSerializer();
}

class _$SalesOrderLineUpdateSerializer
    implements PrimitiveSerializer<SalesOrderLineUpdate> {
  @override
  final Iterable<Type> types = const [
    SalesOrderLineUpdate,
    _$SalesOrderLineUpdate,
  ];

  @override
  final String wireName = r'SalesOrderLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SalesOrderLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(Quantity),
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
        specifiedType: const FullType.nullable(DiscountRate1),
      );
    }
    if (object.taxRate != null) {
      yield r'tax_rate';
      yield serializers.serialize(
        object.taxRate,
        specifiedType: const FullType.nullable(TaxRate1),
      );
    }
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
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
    SalesOrderLineUpdate object, {
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
    required SalesOrderLineUpdateBuilder result,
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
                    specifiedType: const FullType.nullable(Quantity),
                  )
                  as Quantity?;
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
                    specifiedType: const FullType.nullable(DiscountRate1),
                  )
                  as DiscountRate1?;
          if (valueDes == null) continue;
          result.discountRate.replace(valueDes);
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
  SalesOrderLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SalesOrderLineUpdateBuilder();
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
