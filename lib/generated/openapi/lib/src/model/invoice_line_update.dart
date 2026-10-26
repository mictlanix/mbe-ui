//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/price.dart';
import 'package:mbe_api_client/src/model/quantity4.dart';
import 'package:mbe_api_client/src/model/tax_rate.dart';
import 'package:mbe_api_client/src/model/discount1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice_line_update.g.dart';

/// Only the fields sent change (`model_fields_set`).
///
/// Properties:
/// * [quantity]
/// * [price]
/// * [discount]
/// * [taxRate]
/// * [productCode]
/// * [productName]
/// * [comment]
@BuiltValue()
abstract class InvoiceLineUpdate
    implements Built<InvoiceLineUpdate, InvoiceLineUpdateBuilder> {
  @BuiltValueField(wireName: r'quantity')
  Quantity4? get quantity;

  @BuiltValueField(wireName: r'price')
  Price? get price;

  @BuiltValueField(wireName: r'discount')
  Discount1? get discount;

  @BuiltValueField(wireName: r'tax_rate')
  TaxRate? get taxRate;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  InvoiceLineUpdate._();

  factory InvoiceLineUpdate([void updates(InvoiceLineUpdateBuilder b)]) =
      _$InvoiceLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvoiceLineUpdate> get serializer =>
      _$InvoiceLineUpdateSerializer();
}

class _$InvoiceLineUpdateSerializer
    implements PrimitiveSerializer<InvoiceLineUpdate> {
  @override
  final Iterable<Type> types = const [InvoiceLineUpdate, _$InvoiceLineUpdate];

  @override
  final String wireName = r'InvoiceLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvoiceLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(Quantity4),
      );
    }
    if (object.price != null) {
      yield r'price';
      yield serializers.serialize(
        object.price,
        specifiedType: const FullType.nullable(Price),
      );
    }
    if (object.discount != null) {
      yield r'discount';
      yield serializers.serialize(
        object.discount,
        specifiedType: const FullType.nullable(Discount1),
      );
    }
    if (object.taxRate != null) {
      yield r'tax_rate';
      yield serializers.serialize(
        object.taxRate,
        specifiedType: const FullType.nullable(TaxRate),
      );
    }
    if (object.productCode != null) {
      yield r'product_code';
      yield serializers.serialize(
        object.productCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.productName != null) {
      yield r'product_name';
      yield serializers.serialize(
        object.productName,
        specifiedType: const FullType.nullable(String),
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
    InvoiceLineUpdate object, {
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
    required InvoiceLineUpdateBuilder result,
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
        case r'discount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Discount1),
                  )
                  as Discount1?;
          if (valueDes == null) continue;
          result.discount.replace(valueDes);
          break;
        case r'tax_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(TaxRate),
                  )
                  as TaxRate?;
          if (valueDes == null) continue;
          result.taxRate.replace(valueDes);
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
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productName = valueDes;
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
  InvoiceLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceLineUpdateBuilder();
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
