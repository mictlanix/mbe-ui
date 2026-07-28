//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/itinerary_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_itinerary_summary.g.dart';

/// ListResponseItinerarySummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseItinerarySummary
    implements
        Built<
          ListResponseItinerarySummary,
          ListResponseItinerarySummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<ItinerarySummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseItinerarySummary._();

  factory ListResponseItinerarySummary([
    void updates(ListResponseItinerarySummaryBuilder b),
  ]) = _$ListResponseItinerarySummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseItinerarySummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseItinerarySummary> get serializer =>
      _$ListResponseItinerarySummarySerializer();
}

class _$ListResponseItinerarySummarySerializer
    implements PrimitiveSerializer<ListResponseItinerarySummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseItinerarySummary,
    _$ListResponseItinerarySummary,
  ];

  @override
  final String wireName = r'ListResponseItinerarySummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseItinerarySummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ItinerarySummary)]),
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
    ListResponseItinerarySummary object, {
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
    required ListResponseItinerarySummaryBuilder result,
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
                      FullType(ItinerarySummary),
                    ]),
                  )
                  as BuiltList<ItinerarySummary>;
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
  ListResponseItinerarySummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseItinerarySummaryBuilder();
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
