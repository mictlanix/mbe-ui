//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/sales_order_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_sales_order_summary.g.dart';

/// ListResponseSalesOrderSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseSalesOrderSummary
    implements
        Built<
          ListResponseSalesOrderSummary,
          ListResponseSalesOrderSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<SalesOrderSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseSalesOrderSummary._();

  factory ListResponseSalesOrderSummary([
    void updates(ListResponseSalesOrderSummaryBuilder b),
  ]) = _$ListResponseSalesOrderSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseSalesOrderSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseSalesOrderSummary> get serializer =>
      _$ListResponseSalesOrderSummarySerializer();
}

class _$ListResponseSalesOrderSummarySerializer
    implements PrimitiveSerializer<ListResponseSalesOrderSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseSalesOrderSummary,
    _$ListResponseSalesOrderSummary,
  ];

  @override
  final String wireName = r'ListResponseSalesOrderSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseSalesOrderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(SalesOrderSummary)]),
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
    ListResponseSalesOrderSummary object, {
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
    required ListResponseSalesOrderSummaryBuilder result,
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
                      FullType(SalesOrderSummary),
                    ]),
                  )
                  as BuiltList<SalesOrderSummary>;
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
  ListResponseSalesOrderSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseSalesOrderSummaryBuilder();
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
