//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/refund_payout.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_refund_confirm.g.dart';

/// CustomerRefundConfirm
///
/// Properties:
/// * [payout]
@BuiltValue()
abstract class CustomerRefundConfirm
    implements Built<CustomerRefundConfirm, CustomerRefundConfirmBuilder> {
  @BuiltValueField(wireName: r'payout')
  RefundPayout get payout;
  // enum payoutEnum {  cash,  credit_note,  };

  CustomerRefundConfirm._();

  factory CustomerRefundConfirm([
    void updates(CustomerRefundConfirmBuilder b),
  ]) = _$CustomerRefundConfirm;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerRefundConfirmBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerRefundConfirm> get serializer =>
      _$CustomerRefundConfirmSerializer();
}

class _$CustomerRefundConfirmSerializer
    implements PrimitiveSerializer<CustomerRefundConfirm> {
  @override
  final Iterable<Type> types = const [
    CustomerRefundConfirm,
    _$CustomerRefundConfirm,
  ];

  @override
  final String wireName = r'CustomerRefundConfirm';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerRefundConfirm object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'payout';
    yield serializers.serialize(
      object.payout,
      specifiedType: const FullType(RefundPayout),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerRefundConfirm object, {
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
    required CustomerRefundConfirmBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'payout':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(RefundPayout),
                  )
                  as RefundPayout;
          result.payout = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerRefundConfirm deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerRefundConfirmBuilder();
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
