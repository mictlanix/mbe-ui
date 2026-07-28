//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_line_update.g.dart';

/// DeliveryOrderLineUpdate
///
/// Properties:
/// * [quantity]
@BuiltValue()
abstract class DeliveryOrderLineUpdate
    implements Built<DeliveryOrderLineUpdate, DeliveryOrderLineUpdateBuilder> {
  @BuiltValueField(wireName: r'quantity')
  Quantity1 get quantity;

  DeliveryOrderLineUpdate._();

  factory DeliveryOrderLineUpdate([
    void updates(DeliveryOrderLineUpdateBuilder b),
  ]) = _$DeliveryOrderLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliveryOrderLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliveryOrderLineUpdate> get serializer =>
      _$DeliveryOrderLineUpdateSerializer();
}

class _$DeliveryOrderLineUpdateSerializer
    implements PrimitiveSerializer<DeliveryOrderLineUpdate> {
  @override
  final Iterable<Type> types = const [
    DeliveryOrderLineUpdate,
    _$DeliveryOrderLineUpdate,
  ];

  @override
  final String wireName = r'DeliveryOrderLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliveryOrderLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(Quantity1),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeliveryOrderLineUpdate object, {
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
    required DeliveryOrderLineUpdateBuilder result,
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
                    specifiedType: const FullType(Quantity1),
                  )
                  as Quantity1;
          result.quantity.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeliveryOrderLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliveryOrderLineUpdateBuilder();
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
