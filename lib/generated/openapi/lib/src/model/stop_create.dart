//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stop_create.g.dart';

/// StopCreate
///
/// Properties:
/// * [deliveryOrder]
/// * [comment]
@BuiltValue()
abstract class StopCreate implements Built<StopCreate, StopCreateBuilder> {
  @BuiltValueField(wireName: r'delivery_order')
  int get deliveryOrder;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  StopCreate._();

  factory StopCreate([void updates(StopCreateBuilder b)]) = _$StopCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StopCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StopCreate> get serializer => _$StopCreateSerializer();
}

class _$StopCreateSerializer implements PrimitiveSerializer<StopCreate> {
  @override
  final Iterable<Type> types = const [StopCreate, _$StopCreate];

  @override
  final String wireName = r'StopCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StopCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'delivery_order';
    yield serializers.serialize(
      object.deliveryOrder,
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
    StopCreate object, {
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
    required StopCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'delivery_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.deliveryOrder = valueDes;
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
  StopCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StopCreateBuilder();
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
