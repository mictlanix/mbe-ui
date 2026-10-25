//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/participation_rate.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_agent_rate_create.g.dart';

/// CommissionAgentRateCreate
///
/// Properties:
/// * [salesperson]
/// * [commission]
/// * [commissionParticipation]
/// * [participationRate]
@BuiltValue()
abstract class CommissionAgentRateCreate
    implements
        Built<CommissionAgentRateCreate, CommissionAgentRateCreateBuilder> {
  @BuiltValueField(wireName: r'salesperson')
  int get salesperson;

  @BuiltValueField(wireName: r'commission')
  int get commission;

  @BuiltValueField(wireName: r'commission_participation')
  int get commissionParticipation;

  @BuiltValueField(wireName: r'participation_rate')
  ParticipationRate get participationRate;

  CommissionAgentRateCreate._();

  factory CommissionAgentRateCreate([
    void updates(CommissionAgentRateCreateBuilder b),
  ]) = _$CommissionAgentRateCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionAgentRateCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionAgentRateCreate> get serializer =>
      _$CommissionAgentRateCreateSerializer();
}

class _$CommissionAgentRateCreateSerializer
    implements PrimitiveSerializer<CommissionAgentRateCreate> {
  @override
  final Iterable<Type> types = const [
    CommissionAgentRateCreate,
    _$CommissionAgentRateCreate,
  ];

  @override
  final String wireName = r'CommissionAgentRateCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionAgentRateCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'salesperson';
    yield serializers.serialize(
      object.salesperson,
      specifiedType: const FullType(int),
    );
    yield r'commission';
    yield serializers.serialize(
      object.commission,
      specifiedType: const FullType(int),
    );
    yield r'commission_participation';
    yield serializers.serialize(
      object.commissionParticipation,
      specifiedType: const FullType(int),
    );
    yield r'participation_rate';
    yield serializers.serialize(
      object.participationRate,
      specifiedType: const FullType(ParticipationRate),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionAgentRateCreate object, {
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
    required CommissionAgentRateCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'salesperson':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesperson = valueDes;
          break;
        case r'commission':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.commission = valueDes;
          break;
        case r'commission_participation':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.commissionParticipation = valueDes;
          break;
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
  CommissionAgentRateCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionAgentRateCreateBuilder();
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
