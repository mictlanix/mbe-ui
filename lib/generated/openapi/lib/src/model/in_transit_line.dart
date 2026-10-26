//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'in_transit_line.g.dart';

/// InTransitLine
///
/// Properties:
/// * [inventoryTransferId]
/// * [serial]
/// * [warehouse]
/// * [warehouseTo]
/// * [transferDetailId]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantityOutstanding]
@BuiltValue()
abstract class InTransitLine
    implements Built<InTransitLine, InTransitLineBuilder> {
  @BuiltValueField(wireName: r'inventory_transfer_id')
  int get inventoryTransferId;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'warehouse_to')
  int get warehouseTo;

  @BuiltValueField(wireName: r'transfer_detail_id')
  int get transferDetailId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'quantity_outstanding')
  String get quantityOutstanding;

  InTransitLine._();

  factory InTransitLine([void updates(InTransitLineBuilder b)]) =
      _$InTransitLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InTransitLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InTransitLine> get serializer =>
      _$InTransitLineSerializer();
}

class _$InTransitLineSerializer implements PrimitiveSerializer<InTransitLine> {
  @override
  final Iterable<Type> types = const [InTransitLine, _$InTransitLine];

  @override
  final String wireName = r'InTransitLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InTransitLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'inventory_transfer_id';
    yield serializers.serialize(
      object.inventoryTransferId,
      specifiedType: const FullType(int),
    );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'warehouse_to';
    yield serializers.serialize(
      object.warehouseTo,
      specifiedType: const FullType(int),
    );
    yield r'transfer_detail_id';
    yield serializers.serialize(
      object.transferDetailId,
      specifiedType: const FullType(int),
    );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_code';
    yield object.productCode == null
        ? null
        : serializers.serialize(
            object.productCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'product_name';
    yield object.productName == null
        ? null
        : serializers.serialize(
            object.productName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity_outstanding';
    yield serializers.serialize(
      object.quantityOutstanding,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InTransitLine object, {
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
    required InTransitLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'inventory_transfer_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.inventoryTransferId = valueDes;
          break;
        case r'serial':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.serial = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
        case r'warehouse_to':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouseTo = valueDes;
          break;
        case r'transfer_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.transferDetailId = valueDes;
          break;
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'product_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productCode = valueDes;
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productName = valueDes;
          break;
        case r'quantity_outstanding':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantityOutstanding = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InTransitLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InTransitLineBuilder();
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
