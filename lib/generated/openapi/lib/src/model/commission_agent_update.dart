//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/commission_scheme.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_agent_update.g.dart';

/// CommissionAgentUpdate
///
/// Properties:
/// * [scheme]
@BuiltValue()
abstract class CommissionAgentUpdate
    implements Built<CommissionAgentUpdate, CommissionAgentUpdateBuilder> {
  @BuiltValueField(wireName: r'scheme')
  CommissionScheme get scheme;
  // enum schemeEnum {  1,  2,  };

  CommissionAgentUpdate._();

  factory CommissionAgentUpdate([
    void updates(CommissionAgentUpdateBuilder b),
  ]) = _$CommissionAgentUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionAgentUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionAgentUpdate> get serializer =>
      _$CommissionAgentUpdateSerializer();
}

class _$CommissionAgentUpdateSerializer
    implements PrimitiveSerializer<CommissionAgentUpdate> {
  @override
  final Iterable<Type> types = const [
    CommissionAgentUpdate,
    _$CommissionAgentUpdate,
  ];

  @override
  final String wireName = r'CommissionAgentUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionAgentUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'scheme';
    yield serializers.serialize(
      object.scheme,
      specifiedType: const FullType(CommissionScheme),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionAgentUpdate object, {
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
    required CommissionAgentUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'scheme':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(CommissionScheme),
                  )
                  as CommissionScheme;
          result.scheme = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionAgentUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionAgentUpdateBuilder();
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
