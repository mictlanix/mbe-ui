//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inventory_transfer_line_response.g.dart';

/// InventoryTransferLineResponse
///
/// Properties:
/// * [transferDetailId]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantity]
/// * [quantityReceived]
/// * [quantityOutstanding]
@BuiltValue()
abstract class InventoryTransferLineResponse
    implements
        Built<
          InventoryTransferLineResponse,
          InventoryTransferLineResponseBuilder
        > {
  @BuiltValueField(wireName: r'transfer_detail_id')
  int get transferDetailId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'quantity_received')
  String get quantityReceived;

  @BuiltValueField(wireName: r'quantity_outstanding')
  String get quantityOutstanding;

  InventoryTransferLineResponse._();

  factory InventoryTransferLineResponse([
    void updates(InventoryTransferLineResponseBuilder b),
  ]) = _$InventoryTransferLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InventoryTransferLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InventoryTransferLineResponse> get serializer =>
      _$InventoryTransferLineResponseSerializer();
}

class _$InventoryTransferLineResponseSerializer
    implements PrimitiveSerializer<InventoryTransferLineResponse> {
  @override
  final Iterable<Type> types = const [
    InventoryTransferLineResponse,
    _$InventoryTransferLineResponse,
  ];

  @override
  final String wireName = r'InventoryTransferLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InventoryTransferLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'quantity_received';
    yield serializers.serialize(
      object.quantityReceived,
      specifiedType: const FullType(String),
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
    InventoryTransferLineResponse object, {
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
    required InventoryTransferLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantity = valueDes;
          break;
        case r'quantity_received':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantityReceived = valueDes;
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
  InventoryTransferLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InventoryTransferLineResponseBuilder();
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
