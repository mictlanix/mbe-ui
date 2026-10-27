//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/purchase_order_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_purchase_order_summary.g.dart';

/// ListResponsePurchaseOrderSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponsePurchaseOrderSummary
    implements
        Built<
          ListResponsePurchaseOrderSummary,
          ListResponsePurchaseOrderSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<PurchaseOrderSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponsePurchaseOrderSummary._();

  factory ListResponsePurchaseOrderSummary([
    void updates(ListResponsePurchaseOrderSummaryBuilder b),
  ]) = _$ListResponsePurchaseOrderSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponsePurchaseOrderSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponsePurchaseOrderSummary> get serializer =>
      _$ListResponsePurchaseOrderSummarySerializer();
}

class _$ListResponsePurchaseOrderSummarySerializer
    implements PrimitiveSerializer<ListResponsePurchaseOrderSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponsePurchaseOrderSummary,
    _$ListResponsePurchaseOrderSummary,
  ];

  @override
  final String wireName = r'ListResponsePurchaseOrderSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponsePurchaseOrderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(PurchaseOrderSummary),
      ]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListResponsePurchaseOrderSummary object, {
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
    required ListResponsePurchaseOrderSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(PurchaseOrderSummary),
                    ]),
                  )
                  as BuiltList<PurchaseOrderSummary>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListResponsePurchaseOrderSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponsePurchaseOrderSummaryBuilder();
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
