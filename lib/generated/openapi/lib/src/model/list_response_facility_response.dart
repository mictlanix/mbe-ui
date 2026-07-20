//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/facility_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_facility_response.g.dart';

/// ListResponseFacilityResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseFacilityResponse
    implements
        Built<
          ListResponseFacilityResponse,
          ListResponseFacilityResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<FacilityResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseFacilityResponse._();

  factory ListResponseFacilityResponse([
    void updates(ListResponseFacilityResponseBuilder b),
  ]) = _$ListResponseFacilityResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseFacilityResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseFacilityResponse> get serializer =>
      _$ListResponseFacilityResponseSerializer();
}

class _$ListResponseFacilityResponseSerializer
    implements PrimitiveSerializer<ListResponseFacilityResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseFacilityResponse,
    _$ListResponseFacilityResponse,
  ];

  @override
  final String wireName = r'ListResponseFacilityResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseFacilityResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(FacilityResponse)]),
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
    ListResponseFacilityResponse object, {
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
    required ListResponseFacilityResponseBuilder result,
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
                      FullType(FacilityResponse),
                    ]),
                  )
                  as BuiltList<FacilityResponse>;
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
  ListResponseFacilityResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseFacilityResponseBuilder();
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
