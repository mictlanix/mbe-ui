//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sales_order_items_add.g.dart';

/// SalesOrderItemsAdd
///
/// Properties:
/// * [salesOrder]
@BuiltValue()
abstract class SalesOrderItemsAdd
    implements Built<SalesOrderItemsAdd, SalesOrderItemsAddBuilder> {
  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  SalesOrderItemsAdd._();

  factory SalesOrderItemsAdd([void updates(SalesOrderItemsAddBuilder b)]) =
      _$SalesOrderItemsAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SalesOrderItemsAddBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SalesOrderItemsAdd> get serializer =>
      _$SalesOrderItemsAddSerializer();
}

class _$SalesOrderItemsAddSerializer
    implements PrimitiveSerializer<SalesOrderItemsAdd> {
  @override
  final Iterable<Type> types = const [SalesOrderItemsAdd, _$SalesOrderItemsAdd];

  @override
  final String wireName = r'SalesOrderItemsAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SalesOrderItemsAdd object, {
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
    SalesOrderItemsAdd object, {
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
    required SalesOrderItemsAddBuilder result,
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
  SalesOrderItemsAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SalesOrderItemsAddBuilder();
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
