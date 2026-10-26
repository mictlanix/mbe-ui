//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/commission_scheme.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_agent_create.g.dart';

/// CommissionAgentCreate
///
/// Properties:
/// * [employee]
/// * [scheme]
@BuiltValue()
abstract class CommissionAgentCreate
    implements Built<CommissionAgentCreate, CommissionAgentCreateBuilder> {
  @BuiltValueField(wireName: r'employee')
  int get employee;

  @BuiltValueField(wireName: r'scheme')
  CommissionScheme? get scheme;
  // enum schemeEnum {  1,  2,  };

  CommissionAgentCreate._();

  factory CommissionAgentCreate([
    void updates(CommissionAgentCreateBuilder b),
  ]) = _$CommissionAgentCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionAgentCreateBuilder b) =>
      b..scheme = CommissionScheme.number1;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionAgentCreate> get serializer =>
      _$CommissionAgentCreateSerializer();
}

class _$CommissionAgentCreateSerializer
    implements PrimitiveSerializer<CommissionAgentCreate> {
  @override
  final Iterable<Type> types = const [
    CommissionAgentCreate,
    _$CommissionAgentCreate,
  ];

  @override
  final String wireName = r'CommissionAgentCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionAgentCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'employee';
    yield serializers.serialize(
      object.employee,
      specifiedType: const FullType(int),
    );
    if (object.scheme != null) {
      yield r'scheme';
      yield serializers.serialize(
        object.scheme,
        specifiedType: const FullType(CommissionScheme),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionAgentCreate object, {
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
    required CommissionAgentCreateBuilder result,
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
        case r'scheme':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(CommissionScheme),
                  )
                  as CommissionScheme?;
          if (valueDes == null) continue;
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
  CommissionAgentCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionAgentCreateBuilder();
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
