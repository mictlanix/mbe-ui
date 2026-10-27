//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'to_purchase_line.g.dart';

/// ToPurchaseLine
///
/// Properties:
/// * [purchaseRequestDetailId]
/// * [purchaseRequest]
/// * [serial]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantity]
/// * [warehouse]
/// * [cost]
@BuiltValue()
abstract class ToPurchaseLine
    implements Built<ToPurchaseLine, ToPurchaseLineBuilder> {
  @BuiltValueField(wireName: r'purchase_request_detail_id')
  int get purchaseRequestDetailId;

  @BuiltValueField(wireName: r'purchase_request')
  int get purchaseRequest;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'cost')
  String get cost;

  ToPurchaseLine._();

  factory ToPurchaseLine([void updates(ToPurchaseLineBuilder b)]) =
      _$ToPurchaseLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ToPurchaseLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ToPurchaseLine> get serializer =>
      _$ToPurchaseLineSerializer();
}

class _$ToPurchaseLineSerializer
    implements PrimitiveSerializer<ToPurchaseLine> {
  @override
  final Iterable<Type> types = const [ToPurchaseLine, _$ToPurchaseLine];

  @override
  final String wireName = r'ToPurchaseLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ToPurchaseLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_request_detail_id';
    yield serializers.serialize(
      object.purchaseRequestDetailId,
      specifiedType: const FullType(int),
    );
    yield r'purchase_request';
    yield serializers.serialize(
      object.purchaseRequest,
      specifiedType: const FullType(int),
    );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_code';
    yield serializers.serialize(
      object.productCode,
      specifiedType: const FullType(String),
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
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'cost';
    yield serializers.serialize(
      object.cost,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ToPurchaseLine object, {
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
    required ToPurchaseLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_request_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseRequestDetailId = valueDes;
          break;
        case r'purchase_request':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseRequest = valueDes;
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
                    specifiedType: const FullType(String),
                  )
                  as String;
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
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
        case r'cost':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.cost = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ToPurchaseLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ToPurchaseLineBuilder();
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
