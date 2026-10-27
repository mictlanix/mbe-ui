//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/amount4.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'paid_invoice_update.g.dart';

/// PaidInvoiceUpdate
///
/// Properties:
/// * [amount]
@BuiltValue()
abstract class PaidInvoiceUpdate
    implements Built<PaidInvoiceUpdate, PaidInvoiceUpdateBuilder> {
  @BuiltValueField(wireName: r'amount')
  Amount4 get amount;

  PaidInvoiceUpdate._();

  factory PaidInvoiceUpdate([void updates(PaidInvoiceUpdateBuilder b)]) =
      _$PaidInvoiceUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaidInvoiceUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaidInvoiceUpdate> get serializer =>
      _$PaidInvoiceUpdateSerializer();
}

class _$PaidInvoiceUpdateSerializer
    implements PrimitiveSerializer<PaidInvoiceUpdate> {
  @override
  final Iterable<Type> types = const [PaidInvoiceUpdate, _$PaidInvoiceUpdate];

  @override
  final String wireName = r'PaidInvoiceUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaidInvoiceUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Amount4),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaidInvoiceUpdate object, {
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
    required PaidInvoiceUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Amount4),
                  )
                  as Amount4;
          result.amount.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaidInvoiceUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaidInvoiceUpdateBuilder();
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
