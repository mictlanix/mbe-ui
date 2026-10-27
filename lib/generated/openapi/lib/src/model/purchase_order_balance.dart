//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:mbe_api_client/src/model/purchase_order_application.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_order_balance.g.dart';

/// PurchaseOrderBalance
///
/// Properties:
/// * [purchaseOrderId]
/// * [supplier]
/// * [status]
/// * [counts]
/// * [total]
/// * [applied]
/// * [balance]
/// * [applications]
@BuiltValue()
abstract class PurchaseOrderBalance
    implements Built<PurchaseOrderBalance, PurchaseOrderBalanceBuilder> {
  @BuiltValueField(wireName: r'purchase_order_id')
  int get purchaseOrderId;

  @BuiltValueField(wireName: r'supplier')
  int? get supplier;

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'counts')
  bool get counts;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'applied')
  String get applied;

  @BuiltValueField(wireName: r'balance')
  String? get balance;

  @BuiltValueField(wireName: r'applications')
  BuiltList<PurchaseOrderApplication>? get applications;

  PurchaseOrderBalance._();

  factory PurchaseOrderBalance([void updates(PurchaseOrderBalanceBuilder b)]) =
      _$PurchaseOrderBalance;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseOrderBalanceBuilder b) =>
      b..applications = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseOrderBalance> get serializer =>
      _$PurchaseOrderBalanceSerializer();
}

class _$PurchaseOrderBalanceSerializer
    implements PrimitiveSerializer<PurchaseOrderBalance> {
  @override
  final Iterable<Type> types = const [
    PurchaseOrderBalance,
    _$PurchaseOrderBalance,
  ];

  @override
  final String wireName = r'PurchaseOrderBalance';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseOrderBalance object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_order_id';
    yield serializers.serialize(
      object.purchaseOrderId,
      specifiedType: const FullType(int),
    );
    yield r'supplier';
    yield object.supplier == null
        ? null
        : serializers.serialize(
            object.supplier,
            specifiedType: const FullType.nullable(int),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DocumentStatus),
    );
    yield r'counts';
    yield serializers.serialize(
      object.counts,
      specifiedType: const FullType(bool),
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
    yield object.balance == null
        ? null
        : serializers.serialize(
            object.balance,
            specifiedType: const FullType.nullable(String),
          );
    if (object.applications != null) {
      yield r'applications';
      yield serializers.serialize(
        object.applications,
        specifiedType: const FullType(BuiltList, [
          FullType(PurchaseOrderApplication),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseOrderBalance object, {
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
    required PurchaseOrderBalanceBuilder result,
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
        case r'supplier':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.supplier = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DocumentStatus),
                  )
                  as DocumentStatus;
          result.status = valueDes;
          break;
        case r'counts':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.counts = valueDes;
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
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.balance = valueDes;
          break;
        case r'applications':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(PurchaseOrderApplication),
                    ]),
                  )
                  as BuiltList<PurchaseOrderApplication>?;
          if (valueDes == null) continue;
          result.applications.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurchaseOrderBalance deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseOrderBalanceBuilder();
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
