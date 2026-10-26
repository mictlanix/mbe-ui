//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice_sales_order_add.g.dart';

/// InvoiceSalesOrderAdd
///
/// Properties:
/// * [salesOrder]
@BuiltValue()
abstract class InvoiceSalesOrderAdd
    implements Built<InvoiceSalesOrderAdd, InvoiceSalesOrderAddBuilder> {
  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  InvoiceSalesOrderAdd._();

  factory InvoiceSalesOrderAdd([void updates(InvoiceSalesOrderAddBuilder b)]) =
      _$InvoiceSalesOrderAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceSalesOrderAddBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvoiceSalesOrderAdd> get serializer =>
      _$InvoiceSalesOrderAddSerializer();
}

class _$InvoiceSalesOrderAddSerializer
    implements PrimitiveSerializer<InvoiceSalesOrderAdd> {
  @override
  final Iterable<Type> types = const [
    InvoiceSalesOrderAdd,
    _$InvoiceSalesOrderAdd,
  ];

  @override
  final String wireName = r'InvoiceSalesOrderAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvoiceSalesOrderAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InvoiceSalesOrderAdd object, {
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
    required InvoiceSalesOrderAddBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvoiceSalesOrderAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceSalesOrderAddBuilder();
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
