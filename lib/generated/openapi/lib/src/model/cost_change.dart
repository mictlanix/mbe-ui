//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cost_change.g.dart';

/// CostChange
///
/// Properties:
/// * [productCostChangeId]
/// * [product]
/// * [receipt]
/// * [purchaseOrderDetail]
/// * [previousCost]
/// * [newCost]
/// * [quantityOnHand]
/// * [quantityReceived]
/// * [unitCost]
/// * [revertedChange]
/// * [creationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [creator]
@BuiltValue()
abstract class CostChange implements Built<CostChange, CostChangeBuilder> {
  @BuiltValueField(wireName: r'product_cost_change_id')
  int get productCostChangeId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'receipt')
  int get receipt;

  @BuiltValueField(wireName: r'purchase_order_detail')
  int? get purchaseOrderDetail;

  @BuiltValueField(wireName: r'previous_cost')
  String get previousCost;

  @BuiltValueField(wireName: r'new_cost')
  String get newCost;

  @BuiltValueField(wireName: r'quantity_on_hand')
  String? get quantityOnHand;

  @BuiltValueField(wireName: r'quantity_received')
  String? get quantityReceived;

  @BuiltValueField(wireName: r'unit_cost')
  String? get unitCost;

  @BuiltValueField(wireName: r'reverted_change')
  int? get revertedChange;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'creation_time')
  DateTime get creationTime;

  @BuiltValueField(wireName: r'creator')
  int get creator;

  CostChange._();

  factory CostChange([void updates(CostChangeBuilder b)]) = _$CostChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CostChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CostChange> get serializer => _$CostChangeSerializer();
}

class _$CostChangeSerializer implements PrimitiveSerializer<CostChange> {
  @override
  final Iterable<Type> types = const [CostChange, _$CostChange];

  @override
  final String wireName = r'CostChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CostChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product_cost_change_id';
    yield serializers.serialize(
      object.productCostChangeId,
      specifiedType: const FullType(int),
    );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'receipt';
    yield serializers.serialize(
      object.receipt,
      specifiedType: const FullType(int),
    );
    yield r'purchase_order_detail';
    yield object.purchaseOrderDetail == null
        ? null
        : serializers.serialize(
            object.purchaseOrderDetail,
            specifiedType: const FullType.nullable(int),
          );
    yield r'previous_cost';
    yield serializers.serialize(
      object.previousCost,
      specifiedType: const FullType(String),
    );
    yield r'new_cost';
    yield serializers.serialize(
      object.newCost,
      specifiedType: const FullType(String),
    );
    yield r'quantity_on_hand';
    yield object.quantityOnHand == null
        ? null
        : serializers.serialize(
            object.quantityOnHand,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity_received';
    yield object.quantityReceived == null
        ? null
        : serializers.serialize(
            object.quantityReceived,
            specifiedType: const FullType.nullable(String),
          );
    yield r'unit_cost';
    yield object.unitCost == null
        ? null
        : serializers.serialize(
            object.unitCost,
            specifiedType: const FullType.nullable(String),
          );
    yield r'reverted_change';
    yield object.revertedChange == null
        ? null
        : serializers.serialize(
            object.revertedChange,
            specifiedType: const FullType.nullable(int),
          );
    yield r'creation_time';
    yield serializers.serialize(
      object.creationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'creator';
    yield serializers.serialize(
      object.creator,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CostChange object, {
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
    required CostChangeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product_cost_change_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.productCostChangeId = valueDes;
          break;
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'receipt':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.receipt = valueDes;
          break;
        case r'purchase_order_detail':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.purchaseOrderDetail = valueDes;
          break;
        case r'previous_cost':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.previousCost = valueDes;
          break;
        case r'new_cost':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.newCost = valueDes;
          break;
        case r'quantity_on_hand':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.quantityOnHand = valueDes;
          break;
        case r'quantity_received':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.quantityReceived = valueDes;
          break;
        case r'unit_cost':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.unitCost = valueDes;
          break;
        case r'reverted_change':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.revertedChange = valueDes;
          break;
        case r'creation_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.creationTime = valueDes;
          break;
        case r'creator':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creator = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CostChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CostChangeBuilder();
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
