//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/inventory_count_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_inventory_count_summary.g.dart';

/// ListResponseInventoryCountSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseInventoryCountSummary
    implements
        Built<
          ListResponseInventoryCountSummary,
          ListResponseInventoryCountSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<InventoryCountSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseInventoryCountSummary._();

  factory ListResponseInventoryCountSummary([
    void updates(ListResponseInventoryCountSummaryBuilder b),
  ]) = _$ListResponseInventoryCountSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseInventoryCountSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseInventoryCountSummary> get serializer =>
      _$ListResponseInventoryCountSummarySerializer();
}

class _$ListResponseInventoryCountSummarySerializer
    implements PrimitiveSerializer<ListResponseInventoryCountSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseInventoryCountSummary,
    _$ListResponseInventoryCountSummary,
  ];

  @override
  final String wireName = r'ListResponseInventoryCountSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseInventoryCountSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(InventoryCountSummary),
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
    ListResponseInventoryCountSummary object, {
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
    required ListResponseInventoryCountSummaryBuilder result,
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
                      FullType(InventoryCountSummary),
                    ]),
                  )
                  as BuiltList<InventoryCountSummary>;
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
  ListResponseInventoryCountSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseInventoryCountSummaryBuilder();
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
