//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/customer_refund_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_customer_refund_summary.g.dart';

/// ListResponseCustomerRefundSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseCustomerRefundSummary
    implements
        Built<
          ListResponseCustomerRefundSummary,
          ListResponseCustomerRefundSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<CustomerRefundSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseCustomerRefundSummary._();

  factory ListResponseCustomerRefundSummary([
    void updates(ListResponseCustomerRefundSummaryBuilder b),
  ]) = _$ListResponseCustomerRefundSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseCustomerRefundSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseCustomerRefundSummary> get serializer =>
      _$ListResponseCustomerRefundSummarySerializer();
}

class _$ListResponseCustomerRefundSummarySerializer
    implements PrimitiveSerializer<ListResponseCustomerRefundSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseCustomerRefundSummary,
    _$ListResponseCustomerRefundSummary,
  ];

  @override
  final String wireName = r'ListResponseCustomerRefundSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseCustomerRefundSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(CustomerRefundSummary),
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
    ListResponseCustomerRefundSummary object, {
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
    required ListResponseCustomerRefundSummaryBuilder result,
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
                      FullType(CustomerRefundSummary),
                    ]),
                  )
                  as BuiltList<CustomerRefundSummary>;
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
  ListResponseCustomerRefundSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseCustomerRefundSummaryBuilder();
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
