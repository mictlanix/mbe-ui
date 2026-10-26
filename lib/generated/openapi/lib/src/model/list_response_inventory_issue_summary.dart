//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/inventory_issue_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_inventory_issue_summary.g.dart';

/// ListResponseInventoryIssueSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseInventoryIssueSummary
    implements
        Built<
          ListResponseInventoryIssueSummary,
          ListResponseInventoryIssueSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<InventoryIssueSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseInventoryIssueSummary._();

  factory ListResponseInventoryIssueSummary([
    void updates(ListResponseInventoryIssueSummaryBuilder b),
  ]) = _$ListResponseInventoryIssueSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseInventoryIssueSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseInventoryIssueSummary> get serializer =>
      _$ListResponseInventoryIssueSummarySerializer();
}

class _$ListResponseInventoryIssueSummarySerializer
    implements PrimitiveSerializer<ListResponseInventoryIssueSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseInventoryIssueSummary,
    _$ListResponseInventoryIssueSummary,
  ];

  @override
  final String wireName = r'ListResponseInventoryIssueSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseInventoryIssueSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(InventoryIssueSummary),
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
    ListResponseInventoryIssueSummary object, {
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
    required ListResponseInventoryIssueSummaryBuilder result,
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
                      FullType(InventoryIssueSummary),
                    ]),
                  )
                  as BuiltList<InventoryIssueSummary>;
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
  ListResponseInventoryIssueSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseInventoryIssueSummaryBuilder();
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
