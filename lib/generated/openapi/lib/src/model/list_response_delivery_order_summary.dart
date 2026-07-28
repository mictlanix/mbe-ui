//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/delivery_order_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_delivery_order_summary.g.dart';

/// ListResponseDeliveryOrderSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseDeliveryOrderSummary
    implements
        Built<
          ListResponseDeliveryOrderSummary,
          ListResponseDeliveryOrderSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<DeliveryOrderSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseDeliveryOrderSummary._();

  factory ListResponseDeliveryOrderSummary([
    void updates(ListResponseDeliveryOrderSummaryBuilder b),
  ]) = _$ListResponseDeliveryOrderSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseDeliveryOrderSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseDeliveryOrderSummary> get serializer =>
      _$ListResponseDeliveryOrderSummarySerializer();
}

class _$ListResponseDeliveryOrderSummarySerializer
    implements PrimitiveSerializer<ListResponseDeliveryOrderSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseDeliveryOrderSummary,
    _$ListResponseDeliveryOrderSummary,
  ];

  @override
  final String wireName = r'ListResponseDeliveryOrderSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseDeliveryOrderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(DeliveryOrderSummary),
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
    ListResponseDeliveryOrderSummary object, {
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
    required ListResponseDeliveryOrderSummaryBuilder result,
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
                      FullType(DeliveryOrderSummary),
                    ]),
                  )
                  as BuiltList<DeliveryOrderSummary>;
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
  ListResponseDeliveryOrderSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseDeliveryOrderSummaryBuilder();
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
