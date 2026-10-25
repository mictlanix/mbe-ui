//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_agent_rate_response.g.dart';

/// CommissionAgentRateResponse
///
/// Properties:
/// * [commissionSalespersonId]
/// * [salesperson]
/// * [commission]
/// * [commissionParticipation]
/// * [participationRate]
@BuiltValue()
abstract class CommissionAgentRateResponse
    implements
        Built<CommissionAgentRateResponse, CommissionAgentRateResponseBuilder> {
  @BuiltValueField(wireName: r'commission_salesperson_id')
  int get commissionSalespersonId;

  @BuiltValueField(wireName: r'salesperson')
  int get salesperson;

  @BuiltValueField(wireName: r'commission')
  int get commission;

  @BuiltValueField(wireName: r'commission_participation')
  int get commissionParticipation;

  @BuiltValueField(wireName: r'participation_rate')
  String get participationRate;

  CommissionAgentRateResponse._();

  factory CommissionAgentRateResponse([
    void updates(CommissionAgentRateResponseBuilder b),
  ]) = _$CommissionAgentRateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionAgentRateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionAgentRateResponse> get serializer =>
      _$CommissionAgentRateResponseSerializer();
}

class _$CommissionAgentRateResponseSerializer
    implements PrimitiveSerializer<CommissionAgentRateResponse> {
  @override
  final Iterable<Type> types = const [
    CommissionAgentRateResponse,
    _$CommissionAgentRateResponse,
  ];

  @override
  final String wireName = r'CommissionAgentRateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionAgentRateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'commission_salesperson_id';
    yield serializers.serialize(
      object.commissionSalespersonId,
      specifiedType: const FullType(int),
    );
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
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionAgentRateResponse object, {
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
    required CommissionAgentRateResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'commission_salesperson_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.commissionSalespersonId = valueDes;
          break;
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.participationRate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionAgentRateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionAgentRateResponseBuilder();
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
