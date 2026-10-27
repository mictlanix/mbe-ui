//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/supplier_balance_order.dart';
import 'package:mbe_api_client/src/model/supplier_balance_payment.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_balance.g.dart';

/// SupplierBalance
///
/// Properties:
/// * [supplier]
/// * [supplierName]
/// * [cutoff] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [owed]
/// * [credit]
/// * [net]
/// * [orders]
/// * [payments]
@BuiltValue()
abstract class SupplierBalance
    implements Built<SupplierBalance, SupplierBalanceBuilder> {
  @BuiltValueField(wireName: r'supplier')
  int get supplier;

  @BuiltValueField(wireName: r'supplier_name')
  String get supplierName;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'cutoff')
  DateTime? get cutoff;

  @BuiltValueField(wireName: r'owed')
  String get owed;

  @BuiltValueField(wireName: r'credit')
  String get credit;

  @BuiltValueField(wireName: r'net')
  String get net;

  @BuiltValueField(wireName: r'orders')
  BuiltList<SupplierBalanceOrder>? get orders;

  @BuiltValueField(wireName: r'payments')
  BuiltList<SupplierBalancePayment>? get payments;

  SupplierBalance._();

  factory SupplierBalance([void updates(SupplierBalanceBuilder b)]) =
      _$SupplierBalance;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierBalanceBuilder b) => b
    ..orders = ListBuilder()
    ..payments = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierBalance> get serializer =>
      _$SupplierBalanceSerializer();
}

class _$SupplierBalanceSerializer
    implements PrimitiveSerializer<SupplierBalance> {
  @override
  final Iterable<Type> types = const [SupplierBalance, _$SupplierBalance];

  @override
  final String wireName = r'SupplierBalance';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierBalance object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier';
    yield serializers.serialize(
      object.supplier,
      specifiedType: const FullType(int),
    );
    yield r'supplier_name';
    yield serializers.serialize(
      object.supplierName,
      specifiedType: const FullType(String),
    );
    yield r'cutoff';
    yield object.cutoff == null
        ? null
        : serializers.serialize(
            object.cutoff,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'owed';
    yield serializers.serialize(
      object.owed,
      specifiedType: const FullType(String),
    );
    yield r'credit';
    yield serializers.serialize(
      object.credit,
      specifiedType: const FullType(String),
    );
    yield r'net';
    yield serializers.serialize(
      object.net,
      specifiedType: const FullType(String),
    );
    if (object.orders != null) {
      yield r'orders';
      yield serializers.serialize(
        object.orders,
        specifiedType: const FullType(BuiltList, [
          FullType(SupplierBalanceOrder),
        ]),
      );
    }
    if (object.payments != null) {
      yield r'payments';
      yield serializers.serialize(
        object.payments,
        specifiedType: const FullType(BuiltList, [
          FullType(SupplierBalancePayment),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierBalance object, {
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
    required SupplierBalanceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.supplier = valueDes;
          break;
        case r'supplier_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.supplierName = valueDes;
          break;
        case r'cutoff':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.cutoff = valueDes;
          break;
        case r'owed':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.owed = valueDes;
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
        case r'net':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.net = valueDes;
          break;
        case r'orders':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(SupplierBalanceOrder),
                    ]),
                  )
                  as BuiltList<SupplierBalanceOrder>?;
          if (valueDes == null) continue;
          result.orders.replace(valueDes);
          break;
        case r'payments':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(SupplierBalancePayment),
                    ]),
                  )
                  as BuiltList<SupplierBalancePayment>?;
          if (valueDes == null) continue;
          result.payments.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierBalance deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierBalanceBuilder();
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
