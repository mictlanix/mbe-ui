//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/itinerary_status.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/itinerary_stop_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'itinerary_response.g.dart';

/// ItineraryResponse
///
/// Properties:
/// * [deliveriesItineraryId]
/// * [date]
/// * [vehicle]
/// * [vehicleOperator]
/// * [warehouse]
/// * [status]
/// * [departureTime]
/// * [returnTime]
/// * [comment]
/// * [stops]
/// * [warnings]
@BuiltValue()
abstract class ItineraryResponse
    implements Built<ItineraryResponse, ItineraryResponseBuilder> {
  @BuiltValueField(wireName: r'deliveries_itinerary_id')
  int get deliveriesItineraryId;

  @BuiltValueField(wireName: r'date')
  Date get date;

  @BuiltValueField(wireName: r'vehicle')
  int? get vehicle;

  @BuiltValueField(wireName: r'vehicle_operator')
  int? get vehicleOperator;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'status')
  ItineraryStatus get status;
  // enum statusEnum {  0,  1,  2,  3,  };

  @BuiltValueField(wireName: r'departure_time')
  DateTime? get departureTime;

  @BuiltValueField(wireName: r'return_time')
  DateTime? get returnTime;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'stops')
  BuiltList<ItineraryStopResponse>? get stops;

  @BuiltValueField(wireName: r'warnings')
  BuiltList<String>? get warnings;

  ItineraryResponse._();

  factory ItineraryResponse([void updates(ItineraryResponseBuilder b)]) =
      _$ItineraryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItineraryResponseBuilder b) => b
    ..stops = ListBuilder()
    ..warnings = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<ItineraryResponse> get serializer =>
      _$ItineraryResponseSerializer();
}

class _$ItineraryResponseSerializer
    implements PrimitiveSerializer<ItineraryResponse> {
  @override
  final Iterable<Type> types = const [ItineraryResponse, _$ItineraryResponse];

  @override
  final String wireName = r'ItineraryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItineraryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'deliveries_itinerary_id';
    yield serializers.serialize(
      object.deliveriesItineraryId,
      specifiedType: const FullType(int),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(Date),
    );
    yield r'vehicle';
    yield object.vehicle == null
        ? null
        : serializers.serialize(
            object.vehicle,
            specifiedType: const FullType.nullable(int),
          );
    yield r'vehicle_operator';
    yield object.vehicleOperator == null
        ? null
        : serializers.serialize(
            object.vehicleOperator,
            specifiedType: const FullType.nullable(int),
          );
    yield r'warehouse';
    yield object.warehouse == null
        ? null
        : serializers.serialize(
            object.warehouse,
            specifiedType: const FullType.nullable(int),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ItineraryStatus),
    );
    yield r'departure_time';
    yield object.departureTime == null
        ? null
        : serializers.serialize(
            object.departureTime,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'return_time';
    yield object.returnTime == null
        ? null
        : serializers.serialize(
            object.returnTime,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    if (object.stops != null) {
      yield r'stops';
      yield serializers.serialize(
        object.stops,
        specifiedType: const FullType(BuiltList, [
          FullType(ItineraryStopResponse),
        ]),
      );
    }
    if (object.warnings != null) {
      yield r'warnings';
      yield serializers.serialize(
        object.warnings,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ItineraryResponse object, {
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
    required ItineraryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'deliveries_itinerary_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveriesItineraryId = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.date = valueDes;
          break;
        case r'vehicle':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.vehicle = valueDes;
          break;
        case r'vehicle_operator':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.vehicleOperator = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.warehouse = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ItineraryStatus),
                  )
                  as ItineraryStatus;
          result.status = valueDes;
          break;
        case r'departure_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.departureTime = valueDes;
          break;
        case r'return_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.returnTime = valueDes;
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        case r'stops':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(ItineraryStopResponse),
                    ]),
                  )
                  as BuiltList<ItineraryStopResponse>;
          result.stops.replace(valueDes);
          break;
        case r'warnings':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.warnings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItineraryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItineraryResponseBuilder();
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
