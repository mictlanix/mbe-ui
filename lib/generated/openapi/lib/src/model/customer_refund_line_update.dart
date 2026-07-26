//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_refund_line_update.g.dart';

/// CustomerRefundLineUpdate
///
/// Properties:
/// * [quantity]
/// * [warehouse]
@BuiltValue()
abstract class CustomerRefundLineUpdate
    implements
        Built<CustomerRefundLineUpdate, CustomerRefundLineUpdateBuilder> {
  @BuiltValueField(wireName: r'quantity')
  Quantity? get quantity;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  CustomerRefundLineUpdate._();

  factory CustomerRefundLineUpdate([
    void updates(CustomerRefundLineUpdateBuilder b),
  ]) = _$CustomerRefundLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerRefundLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerRefundLineUpdate> get serializer =>
      _$CustomerRefundLineUpdateSerializer();
}

class _$CustomerRefundLineUpdateSerializer
    implements PrimitiveSerializer<CustomerRefundLineUpdate> {
  @override
  final Iterable<Type> types = const [
    CustomerRefundLineUpdate,
    _$CustomerRefundLineUpdate,
  ];

  @override
  final String wireName = r'CustomerRefundLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerRefundLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(Quantity),
      );
    }
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerRefundLineUpdate object, {
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
    required CustomerRefundLineUpdateBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerRefundLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerRefundLineUpdateBuilder();
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
