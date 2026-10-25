//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/participation_rate.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_agent_rate_update.g.dart';

/// CommissionAgentRateUpdate
///
/// Properties:
/// * [participationRate]
@BuiltValue()
abstract class CommissionAgentRateUpdate
    implements
        Built<CommissionAgentRateUpdate, CommissionAgentRateUpdateBuilder> {
  @BuiltValueField(wireName: r'participation_rate')
  ParticipationRate get participationRate;

  CommissionAgentRateUpdate._();

  factory CommissionAgentRateUpdate([
    void updates(CommissionAgentRateUpdateBuilder b),
  ]) = _$CommissionAgentRateUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionAgentRateUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionAgentRateUpdate> get serializer =>
      _$CommissionAgentRateUpdateSerializer();
}

class _$CommissionAgentRateUpdateSerializer
    implements PrimitiveSerializer<CommissionAgentRateUpdate> {
  @override
  final Iterable<Type> types = const [
    CommissionAgentRateUpdate,
    _$CommissionAgentRateUpdate,
  ];

  @override
  final String wireName = r'CommissionAgentRateUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionAgentRateUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'participation_rate';
    yield serializers.serialize(
      object.participationRate,
      specifiedType: const FullType(ParticipationRate),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionAgentRateUpdate object, {
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
    required CommissionAgentRateUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'participation_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(ParticipationRate),
                  )
                  as ParticipationRate;
          result.participationRate.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionAgentRateUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionAgentRateUpdateBuilder();
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
