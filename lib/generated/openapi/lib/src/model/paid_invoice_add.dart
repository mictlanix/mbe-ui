//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/amount3.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'paid_invoice_add.g.dart';

/// PaidInvoiceAdd
///
/// Properties:
/// * [invoice]
/// * [amount]
@BuiltValue()
abstract class PaidInvoiceAdd
    implements Built<PaidInvoiceAdd, PaidInvoiceAddBuilder> {
  @BuiltValueField(wireName: r'invoice')
  int get invoice;

  @BuiltValueField(wireName: r'amount')
  Amount3? get amount;

  PaidInvoiceAdd._();

  factory PaidInvoiceAdd([void updates(PaidInvoiceAddBuilder b)]) =
      _$PaidInvoiceAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaidInvoiceAddBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaidInvoiceAdd> get serializer =>
      _$PaidInvoiceAddSerializer();
}

class _$PaidInvoiceAddSerializer
    implements PrimitiveSerializer<PaidInvoiceAdd> {
  @override
  final Iterable<Type> types = const [PaidInvoiceAdd, _$PaidInvoiceAdd];

  @override
  final String wireName = r'PaidInvoiceAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaidInvoiceAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'invoice';
    yield serializers.serialize(
      object.invoice,
      specifiedType: const FullType(int),
    );
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType.nullable(Amount3),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaidInvoiceAdd object, {
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
    required PaidInvoiceAddBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'invoice':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.invoice = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Amount3),
                  )
                  as Amount3?;
          if (valueDes == null) continue;
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
  PaidInvoiceAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaidInvoiceAddBuilder();
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
