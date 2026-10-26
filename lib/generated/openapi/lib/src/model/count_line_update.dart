//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity2.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'count_line_update.g.dart';

/// CountLineUpdate
///
/// Properties:
/// * [quantity]
@BuiltValue()
abstract class CountLineUpdate
    implements Built<CountLineUpdate, CountLineUpdateBuilder> {
  @BuiltValueField(wireName: r'quantity')
  Quantity2 get quantity;

  CountLineUpdate._();

  factory CountLineUpdate([void updates(CountLineUpdateBuilder b)]) =
      _$CountLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CountLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CountLineUpdate> get serializer =>
      _$CountLineUpdateSerializer();
}

class _$CountLineUpdateSerializer
    implements PrimitiveSerializer<CountLineUpdate> {
  @override
  final Iterable<Type> types = const [CountLineUpdate, _$CountLineUpdate];

  @override
  final String wireName = r'CountLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CountLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(Quantity2),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CountLineUpdate object, {
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
    required CountLineUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Quantity2),
                  )
                  as Quantity2;
          result.quantity.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CountLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CountLineUpdateBuilder();
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
