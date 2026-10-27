//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_balance_order.g.dart';

/// SupplierBalanceOrder
///
/// Properties:
/// * [purchaseOrderId]
/// * [confirmed] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [total]
/// * [applied]
/// * [balance]
@BuiltValue()
abstract class SupplierBalanceOrder
    implements Built<SupplierBalanceOrder, SupplierBalanceOrderBuilder> {
  @BuiltValueField(wireName: r'purchase_order_id')
  int get purchaseOrderId;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'confirmed')
  DateTime get confirmed;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'applied')
  String get applied;

  @BuiltValueField(wireName: r'balance')
  String get balance;

  SupplierBalanceOrder._();

  factory SupplierBalanceOrder([void updates(SupplierBalanceOrderBuilder b)]) =
      _$SupplierBalanceOrder;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierBalanceOrderBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierBalanceOrder> get serializer =>
      _$SupplierBalanceOrderSerializer();
}

class _$SupplierBalanceOrderSerializer
    implements PrimitiveSerializer<SupplierBalanceOrder> {
  @override
  final Iterable<Type> types = const [
    SupplierBalanceOrder,
    _$SupplierBalanceOrder,
  ];

  @override
  final String wireName = r'SupplierBalanceOrder';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierBalanceOrder object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_order_id';
    yield serializers.serialize(
      object.purchaseOrderId,
      specifiedType: const FullType(int),
    );
    yield r'confirmed';
    yield serializers.serialize(
      object.confirmed,
      specifiedType: const FullType(DateTime),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'applied';
    yield serializers.serialize(
      object.applied,
      specifiedType: const FullType(String),
    );
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierBalanceOrder object, {
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
    required SupplierBalanceOrderBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_order_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseOrderId = valueDes;
          break;
        case r'confirmed':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.confirmed = valueDes;
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.total = valueDes;
          break;
        case r'applied':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.applied = valueDes;
          break;
        case r'balance':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.balance = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierBalanceOrder deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierBalanceOrderBuilder();
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
