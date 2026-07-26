//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/sales_quote_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_sales_quote_summary.g.dart';

/// ListResponseSalesQuoteSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseSalesQuoteSummary
    implements
        Built<
          ListResponseSalesQuoteSummary,
          ListResponseSalesQuoteSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<SalesQuoteSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseSalesQuoteSummary._();

  factory ListResponseSalesQuoteSummary([
    void updates(ListResponseSalesQuoteSummaryBuilder b),
  ]) = _$ListResponseSalesQuoteSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseSalesQuoteSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseSalesQuoteSummary> get serializer =>
      _$ListResponseSalesQuoteSummarySerializer();
}

class _$ListResponseSalesQuoteSummarySerializer
    implements PrimitiveSerializer<ListResponseSalesQuoteSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseSalesQuoteSummary,
    _$ListResponseSalesQuoteSummary,
  ];

  @override
  final String wireName = r'ListResponseSalesQuoteSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseSalesQuoteSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(SalesQuoteSummary)]),
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
    ListResponseSalesQuoteSummary object, {
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
    required ListResponseSalesQuoteSummaryBuilder result,
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
                      FullType(SalesQuoteSummary),
                    ]),
                  )
                  as BuiltList<SalesQuoteSummary>;
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
  ListResponseSalesQuoteSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseSalesQuoteSummaryBuilder();
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
