//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'deliverable_line_response.g.dart';

/// A sales line with something left to deliver, and how much (#313).
///
/// Properties:
/// * [salesOrder]
/// * [salesOrderDetail]
/// * [facility]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [warehouse]
/// * [quantity]
/// * [covered]
/// * [remaining]
@BuiltValue()
abstract class DeliverableLineResponse
    implements Built<DeliverableLineResponse, DeliverableLineResponseBuilder> {
  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  @BuiltValueField(wireName: r'sales_order_detail')
  int get salesOrderDetail;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String get productCode;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'covered')
  String get covered;

  @BuiltValueField(wireName: r'remaining')
  String get remaining;

  DeliverableLineResponse._();

  factory DeliverableLineResponse([
    void updates(DeliverableLineResponseBuilder b),
  ]) = _$DeliverableLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliverableLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliverableLineResponse> get serializer =>
      _$DeliverableLineResponseSerializer();
}

class _$DeliverableLineResponseSerializer
    implements PrimitiveSerializer<DeliverableLineResponse> {
  @override
  final Iterable<Type> types = const [
    DeliverableLineResponse,
    _$DeliverableLineResponse,
  ];

  @override
  final String wireName = r'DeliverableLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliverableLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
    yield r'sales_order_detail';
    yield serializers.serialize(
      object.salesOrderDetail,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
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
    yield serializers.serialize(
      object.productName,
      specifiedType: const FullType(String),
    );
    yield r'warehouse';
    yield object.warehouse == null
        ? null
        : serializers.serialize(
            object.warehouse,
            specifiedType: const FullType.nullable(int),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'covered';
    yield serializers.serialize(
      object.covered,
      specifiedType: const FullType(String),
    );
    yield r'remaining';
    yield serializers.serialize(
      object.remaining,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeliverableLineResponse object, {
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
    required DeliverableLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
          break;
        case r'sales_order_detail':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrderDetail = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productName = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.warehouse = valueDes;
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
        case r'covered':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.covered = valueDes;
          break;
        case r'remaining':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.remaining = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeliverableLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliverableLineResponseBuilder();
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
