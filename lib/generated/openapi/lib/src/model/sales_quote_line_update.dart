//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price1.dart';
import 'package:mbe_api_client/src/model/quantity1.dart';
import 'package:mbe_api_client/src/model/price_adjustment1.dart';
import 'package:mbe_api_client/src/model/discount_rate1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sales_quote_line_update.g.dart';

/// SalesQuoteLineUpdate
///
/// Properties:
/// * [quantity]
/// * [price]
/// * [priceAdjustment]
/// * [discountRate]
/// * [comment]
@BuiltValue()
abstract class SalesQuoteLineUpdate
    implements Built<SalesQuoteLineUpdate, SalesQuoteLineUpdateBuilder> {
  @BuiltValueField(wireName: r'quantity')
  Quantity1? get quantity;

  @BuiltValueField(wireName: r'price')
  Price1? get price;

  @BuiltValueField(wireName: r'price_adjustment')
  PriceAdjustment1? get priceAdjustment;

  @BuiltValueField(wireName: r'discount_rate')
  DiscountRate1? get discountRate;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SalesQuoteLineUpdate._();

  factory SalesQuoteLineUpdate([void updates(SalesQuoteLineUpdateBuilder b)]) =
      _$SalesQuoteLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SalesQuoteLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SalesQuoteLineUpdate> get serializer =>
      _$SalesQuoteLineUpdateSerializer();
}

class _$SalesQuoteLineUpdateSerializer
    implements PrimitiveSerializer<SalesQuoteLineUpdate> {
  @override
  final Iterable<Type> types = const [
    SalesQuoteLineUpdate,
    _$SalesQuoteLineUpdate,
  ];

  @override
  final String wireName = r'SalesQuoteLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SalesQuoteLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.priceAdjustment != null) {
      yield r'price_adjustment';
      yield serializers.serialize(
        object.priceAdjustment,
        specifiedType: const FullType.nullable(PriceAdjustment1),
      );
    }
    if (object.discountRate != null) {
      yield r'discount_rate';
      yield serializers.serialize(
        object.discountRate,
        specifiedType: const FullType.nullable(DiscountRate1),
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
    SalesQuoteLineUpdate object, {
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
    required SalesQuoteLineUpdateBuilder result,
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
        case r'price_adjustment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(PriceAdjustment1),
                  )
                  as PriceAdjustment1?;
          if (valueDes == null) continue;
          result.priceAdjustment.replace(valueDes);
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
  SalesQuoteLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SalesQuoteLineUpdateBuilder();
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
