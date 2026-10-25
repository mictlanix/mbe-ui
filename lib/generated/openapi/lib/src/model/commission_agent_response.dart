//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_agent_response.g.dart';

/// CommissionAgentResponse
///
/// Properties:
/// * [employee]
/// * [name]
/// * [scheme]
@BuiltValue()
abstract class CommissionAgentResponse
    implements Built<CommissionAgentResponse, CommissionAgentResponseBuilder> {
  @BuiltValueField(wireName: r'employee')
  int get employee;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'scheme')
  int get scheme;

  CommissionAgentResponse._();

  factory CommissionAgentResponse([
    void updates(CommissionAgentResponseBuilder b),
  ]) = _$CommissionAgentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionAgentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionAgentResponse> get serializer =>
      _$CommissionAgentResponseSerializer();
}

class _$CommissionAgentResponseSerializer
    implements PrimitiveSerializer<CommissionAgentResponse> {
  @override
  final Iterable<Type> types = const [
    CommissionAgentResponse,
    _$CommissionAgentResponse,
  ];

  @override
  final String wireName = r'CommissionAgentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionAgentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'employee';
    yield serializers.serialize(
      object.employee,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'scheme';
    yield serializers.serialize(
      object.scheme,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionAgentResponse object, {
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
    required CommissionAgentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'employee':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.employee = valueDes;
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
        case r'scheme':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
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
  CommissionAgentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionAgentResponseBuilder();
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
