//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_participation_response.g.dart';

/// CommissionParticipationResponse
///
/// Properties:
/// * [commissionParticipationId]
/// * [name]
@BuiltValue()
abstract class CommissionParticipationResponse
    implements
        Built<
          CommissionParticipationResponse,
          CommissionParticipationResponseBuilder
        > {
  @BuiltValueField(wireName: r'commission_participation_id')
  int get commissionParticipationId;

  @BuiltValueField(wireName: r'name')
  String get name;

  CommissionParticipationResponse._();

  factory CommissionParticipationResponse([
    void updates(CommissionParticipationResponseBuilder b),
  ]) = _$CommissionParticipationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionParticipationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionParticipationResponse> get serializer =>
      _$CommissionParticipationResponseSerializer();
}

class _$CommissionParticipationResponseSerializer
    implements PrimitiveSerializer<CommissionParticipationResponse> {
  @override
  final Iterable<Type> types = const [
    CommissionParticipationResponse,
    _$CommissionParticipationResponse,
  ];

  @override
  final String wireName = r'CommissionParticipationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionParticipationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'commission_participation_id';
    yield serializers.serialize(
      object.commissionParticipationId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionParticipationResponse object, {
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
    required CommissionParticipationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'commission_participation_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.commissionParticipationId = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionParticipationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionParticipationResponseBuilder();
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
