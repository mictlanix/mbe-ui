//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/vehicle_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_vehicle_response.g.dart';

/// ListResponseVehicleResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseVehicleResponse
    implements
        Built<ListResponseVehicleResponse, ListResponseVehicleResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<VehicleResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseVehicleResponse._();

  factory ListResponseVehicleResponse([
    void updates(ListResponseVehicleResponseBuilder b),
  ]) = _$ListResponseVehicleResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseVehicleResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseVehicleResponse> get serializer =>
      _$ListResponseVehicleResponseSerializer();
}

class _$ListResponseVehicleResponseSerializer
    implements PrimitiveSerializer<ListResponseVehicleResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseVehicleResponse,
    _$ListResponseVehicleResponse,
  ];

  @override
  final String wireName = r'ListResponseVehicleResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseVehicleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(VehicleResponse)]),
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
    ListResponseVehicleResponse object, {
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
    required ListResponseVehicleResponseBuilder result,
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
                      FullType(VehicleResponse),
                    ]),
                  )
                  as BuiltList<VehicleResponse>;
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
  ListResponseVehicleResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseVehicleResponseBuilder();
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
