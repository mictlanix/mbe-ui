//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pac_simulation_response.g.dart';

/// The simulated SAT's view of a document (spec 040): `sat_status` is `not_found` and `cancellation_status` `none` until the document has a UUID. The library cannot read back a queued outcome, so the response does not carry one.
///
/// Properties:
/// * [uuid]
/// * [satStatus]
/// * [cancellationStatus]
@BuiltValue()
abstract class PacSimulationResponse
    implements Built<PacSimulationResponse, PacSimulationResponseBuilder> {
  @BuiltValueField(wireName: r'uuid')
  String? get uuid;

  @BuiltValueField(wireName: r'sat_status')
  String get satStatus;

  @BuiltValueField(wireName: r'cancellation_status')
  String get cancellationStatus;

  PacSimulationResponse._();

  factory PacSimulationResponse([
    void updates(PacSimulationResponseBuilder b),
  ]) = _$PacSimulationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PacSimulationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PacSimulationResponse> get serializer =>
      _$PacSimulationResponseSerializer();
}

class _$PacSimulationResponseSerializer
    implements PrimitiveSerializer<PacSimulationResponse> {
  @override
  final Iterable<Type> types = const [
    PacSimulationResponse,
    _$PacSimulationResponse,
  ];

  @override
  final String wireName = r'PacSimulationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PacSimulationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'uuid';
    yield object.uuid == null
        ? null
        : serializers.serialize(
            object.uuid,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sat_status';
    yield serializers.serialize(
      object.satStatus,
      specifiedType: const FullType(String),
    );
    yield r'cancellation_status';
    yield serializers.serialize(
      object.cancellationStatus,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PacSimulationResponse object, {
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
    required PacSimulationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'uuid':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.uuid = valueDes;
          break;
        case r'sat_status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.satStatus = valueDes;
          break;
        case r'cancellation_status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.cancellationStatus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PacSimulationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PacSimulationResponseBuilder();
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
