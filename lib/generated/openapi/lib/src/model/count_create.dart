//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'count_create.g.dart';

/// CountCreate
///
/// Properties:
/// * [warehouse]
/// * [comment]
@BuiltValue()
abstract class CountCreate implements Built<CountCreate, CountCreateBuilder> {
  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  CountCreate._();

  factory CountCreate([void updates(CountCreateBuilder b)]) = _$CountCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CountCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CountCreate> get serializer => _$CountCreateSerializer();
}

class _$CountCreateSerializer implements PrimitiveSerializer<CountCreate> {
  @override
  final Iterable<Type> types = const [CountCreate, _$CountCreate];

  @override
  final String wireName = r'CountCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CountCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CountCreate object, {
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
    required CountCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CountCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CountCreateBuilder();
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
