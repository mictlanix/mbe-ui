//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'method_total.g.dart';

/// MethodTotal
///
/// Properties:
/// * [method]
/// * [total]
@BuiltValue()
abstract class MethodTotal implements Built<MethodTotal, MethodTotalBuilder> {
  @BuiltValueField(wireName: r'method')
  int get method;

  @BuiltValueField(wireName: r'total')
  String get total;

  MethodTotal._();

  factory MethodTotal([void updates(MethodTotalBuilder b)]) = _$MethodTotal;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MethodTotalBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MethodTotal> get serializer => _$MethodTotalSerializer();
}

class _$MethodTotalSerializer implements PrimitiveSerializer<MethodTotal> {
  @override
  final Iterable<Type> types = const [MethodTotal, _$MethodTotal];

  @override
  final String wireName = r'MethodTotal';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MethodTotal object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(int),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MethodTotal object, {
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
    required MethodTotalBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'method':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.method = valueDes;
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MethodTotal deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MethodTotalBuilder();
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
