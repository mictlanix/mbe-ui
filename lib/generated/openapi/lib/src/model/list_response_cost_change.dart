//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/cost_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_cost_change.g.dart';

/// ListResponseCostChange
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseCostChange
    implements Built<ListResponseCostChange, ListResponseCostChangeBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<CostChange> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseCostChange._();

  factory ListResponseCostChange([
    void updates(ListResponseCostChangeBuilder b),
  ]) = _$ListResponseCostChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseCostChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseCostChange> get serializer =>
      _$ListResponseCostChangeSerializer();
}

class _$ListResponseCostChangeSerializer
    implements PrimitiveSerializer<ListResponseCostChange> {
  @override
  final Iterable<Type> types = const [
    ListResponseCostChange,
    _$ListResponseCostChange,
  ];

  @override
  final String wireName = r'ListResponseCostChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseCostChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(CostChange)]),
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
    ListResponseCostChange object, {
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
    required ListResponseCostChangeBuilder result,
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
                      FullType(CostChange),
                    ]),
                  )
                  as BuiltList<CostChange>;
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
  ListResponseCostChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseCostChangeBuilder();
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
