//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_balance_payment.g.dart';

/// SupplierBalancePayment
///
/// Properties:
/// * [supplierPaymentId]
/// * [facility]
/// * [serial]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [amount]
/// * [credit]
@BuiltValue()
abstract class SupplierBalancePayment
    implements Built<SupplierBalancePayment, SupplierBalancePaymentBuilder> {
  @BuiltValueField(wireName: r'supplier_payment_id')
  int get supplierPaymentId;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'serial')
  int get serial;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'credit')
  String get credit;

  SupplierBalancePayment._();

  factory SupplierBalancePayment([
    void updates(SupplierBalancePaymentBuilder b),
  ]) = _$SupplierBalancePayment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierBalancePaymentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierBalancePayment> get serializer =>
      _$SupplierBalancePaymentSerializer();
}

class _$SupplierBalancePaymentSerializer
    implements PrimitiveSerializer<SupplierBalancePayment> {
  @override
  final Iterable<Type> types = const [
    SupplierBalancePayment,
    _$SupplierBalancePayment,
  ];

  @override
  final String wireName = r'SupplierBalancePayment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierBalancePayment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier_payment_id';
    yield serializers.serialize(
      object.supplierPaymentId,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    yield r'serial';
    yield serializers.serialize(
      object.serial,
      specifiedType: const FullType(int),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'credit';
    yield serializers.serialize(
      object.credit,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierBalancePayment object, {
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
    required SupplierBalancePaymentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier_payment_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.supplierPaymentId = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'serial':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.serial = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.amount = valueDes;
          break;
        case r'credit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.credit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierBalancePayment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierBalancePaymentBuilder();
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
