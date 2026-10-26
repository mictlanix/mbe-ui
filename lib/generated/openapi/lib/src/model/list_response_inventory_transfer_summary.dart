//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/inventory_transfer_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_inventory_transfer_summary.g.dart';

/// ListResponseInventoryTransferSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseInventoryTransferSummary
    implements
        Built<
          ListResponseInventoryTransferSummary,
          ListResponseInventoryTransferSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<InventoryTransferSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseInventoryTransferSummary._();

  factory ListResponseInventoryTransferSummary([
    void updates(ListResponseInventoryTransferSummaryBuilder b),
  ]) = _$ListResponseInventoryTransferSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseInventoryTransferSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseInventoryTransferSummary> get serializer =>
      _$ListResponseInventoryTransferSummarySerializer();
}

class _$ListResponseInventoryTransferSummarySerializer
    implements PrimitiveSerializer<ListResponseInventoryTransferSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseInventoryTransferSummary,
    _$ListResponseInventoryTransferSummary,
  ];

  @override
  final String wireName = r'ListResponseInventoryTransferSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseInventoryTransferSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(InventoryTransferSummary),
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
    ListResponseInventoryTransferSummary object, {
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
    required ListResponseInventoryTransferSummaryBuilder result,
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
                      FullType(InventoryTransferSummary),
                    ]),
                  )
                  as BuiltList<InventoryTransferSummary>;
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
  ListResponseInventoryTransferSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseInventoryTransferSummaryBuilder();
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
