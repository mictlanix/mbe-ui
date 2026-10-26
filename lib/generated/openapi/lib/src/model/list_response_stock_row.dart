//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/stock_row.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_stock_row.g.dart';

/// ListResponseStockRow
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseStockRow
    implements Built<ListResponseStockRow, ListResponseStockRowBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<StockRow> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseStockRow._();

  factory ListResponseStockRow([void updates(ListResponseStockRowBuilder b)]) =
      _$ListResponseStockRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseStockRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseStockRow> get serializer =>
      _$ListResponseStockRowSerializer();
}

class _$ListResponseStockRowSerializer
    implements PrimitiveSerializer<ListResponseStockRow> {
  @override
  final Iterable<Type> types = const [
    ListResponseStockRow,
    _$ListResponseStockRow,
  ];

  @override
  final String wireName = r'ListResponseStockRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseStockRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(StockRow)]),
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
    ListResponseStockRow object, {
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
    required ListResponseStockRowBuilder result,
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
                      FullType(StockRow),
                    ]),
                  )
                  as BuiltList<StockRow>;
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
  ListResponseStockRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseStockRowBuilder();
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
