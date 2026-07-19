//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/vehicle_operator_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_vehicle_operator_response.g.dart';

/// ListResponseVehicleOperatorResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseVehicleOperatorResponse
    implements
        Built<
          ListResponseVehicleOperatorResponse,
          ListResponseVehicleOperatorResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<VehicleOperatorResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseVehicleOperatorResponse._();

  factory ListResponseVehicleOperatorResponse([
    void updates(ListResponseVehicleOperatorResponseBuilder b),
  ]) = _$ListResponseVehicleOperatorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseVehicleOperatorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseVehicleOperatorResponse> get serializer =>
      _$ListResponseVehicleOperatorResponseSerializer();
}

class _$ListResponseVehicleOperatorResponseSerializer
    implements PrimitiveSerializer<ListResponseVehicleOperatorResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseVehicleOperatorResponse,
    _$ListResponseVehicleOperatorResponse,
  ];

  @override
  final String wireName = r'ListResponseVehicleOperatorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseVehicleOperatorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(VehicleOperatorResponse),
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
    ListResponseVehicleOperatorResponse object, {
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
    required ListResponseVehicleOperatorResponseBuilder result,
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
                      FullType(VehicleOperatorResponse),
                    ]),
                  )
                  as BuiltList<VehicleOperatorResponse>;
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
  ListResponseVehicleOperatorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseVehicleOperatorResponseBuilder();
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
