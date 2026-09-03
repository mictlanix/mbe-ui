//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/itinerary_line_response.dart';
import 'package:mbe_api_client/src/model/stop_outcome.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'itinerary_stop_response.g.dart';

/// ItineraryStopResponse
///
/// Properties:
/// * [deliveriesItineraryStopId]
/// * [sequence]
/// * [arrivalTime]
/// * [outcome]
/// * [proofOfDelivery]
/// * [comment]
/// * [lines]
@BuiltValue()
abstract class ItineraryStopResponse
    implements Built<ItineraryStopResponse, ItineraryStopResponseBuilder> {
  @BuiltValueField(wireName: r'deliveries_itinerary_stop_id')
  int get deliveriesItineraryStopId;

  @BuiltValueField(wireName: r'sequence')
  int get sequence;

  @BuiltValueField(wireName: r'arrival_time')
  DateTime? get arrivalTime;

  @BuiltValueField(wireName: r'outcome')
  StopOutcome get outcome;
  // enum outcomeEnum {  0,  1,  2,  3,  };

  @BuiltValueField(wireName: r'proof_of_delivery')
  int? get proofOfDelivery;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'lines')
  BuiltList<ItineraryLineResponse>? get lines;

  ItineraryStopResponse._();

  factory ItineraryStopResponse([
    void updates(ItineraryStopResponseBuilder b),
  ]) = _$ItineraryStopResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItineraryStopResponseBuilder b) =>
      b..lines = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<ItineraryStopResponse> get serializer =>
      _$ItineraryStopResponseSerializer();
}

class _$ItineraryStopResponseSerializer
    implements PrimitiveSerializer<ItineraryStopResponse> {
  @override
  final Iterable<Type> types = const [
    ItineraryStopResponse,
    _$ItineraryStopResponse,
  ];

  @override
  final String wireName = r'ItineraryStopResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItineraryStopResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'deliveries_itinerary_stop_id';
    yield serializers.serialize(
      object.deliveriesItineraryStopId,
      specifiedType: const FullType(int),
    );
    yield r'sequence';
    yield serializers.serialize(
      object.sequence,
      specifiedType: const FullType(int),
    );
    yield r'arrival_time';
    yield object.arrivalTime == null
        ? null
        : serializers.serialize(
            object.arrivalTime,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'outcome';
    yield serializers.serialize(
      object.outcome,
      specifiedType: const FullType(StopOutcome),
    );
    yield r'proof_of_delivery';
    yield object.proofOfDelivery == null
        ? null
        : serializers.serialize(
            object.proofOfDelivery,
            specifiedType: const FullType.nullable(int),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [
          FullType(ItineraryLineResponse),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ItineraryStopResponse object, {
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
    required ItineraryStopResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'deliveries_itinerary_stop_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveriesItineraryStopId = valueDes;
          break;
        case r'sequence':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.sequence = valueDes;
          break;
        case r'arrival_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.arrivalTime = valueDes;
          break;
        case r'outcome':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(StopOutcome),
                  )
                  as StopOutcome;
          result.outcome = valueDes;
          break;
        case r'proof_of_delivery':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.proofOfDelivery = valueDes;
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
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(ItineraryLineResponse),
                    ]),
                  )
                  as BuiltList<ItineraryLineResponse>?;
          if (valueDes == null) continue;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ItineraryStopResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItineraryStopResponseBuilder();
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
