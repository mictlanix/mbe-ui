//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_refund_create.g.dart';

/// CustomerRefundCreate
///
/// Properties:
/// * [salesOrder]
@BuiltValue()
abstract class CustomerRefundCreate
    implements Built<CustomerRefundCreate, CustomerRefundCreateBuilder> {
  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  CustomerRefundCreate._();

  factory CustomerRefundCreate([void updates(CustomerRefundCreateBuilder b)]) =
      _$CustomerRefundCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerRefundCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerRefundCreate> get serializer =>
      _$CustomerRefundCreateSerializer();
}

class _$CustomerRefundCreateSerializer
    implements PrimitiveSerializer<CustomerRefundCreate> {
  @override
  final Iterable<Type> types = const [
    CustomerRefundCreate,
    _$CustomerRefundCreate,
  ];

  @override
  final String wireName = r'CustomerRefundCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerRefundCreate object, {
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
    CustomerRefundCreate object, {
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
    required CustomerRefundCreateBuilder result,
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
  CustomerRefundCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerRefundCreateBuilder();
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
