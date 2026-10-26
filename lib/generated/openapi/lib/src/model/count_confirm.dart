//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'count_confirm.g.dart';

/// CountConfirm
///
/// Properties:
/// * [includeUncounted]
@BuiltValue()
abstract class CountConfirm
    implements Built<CountConfirm, CountConfirmBuilder> {
  @BuiltValueField(wireName: r'include_uncounted')
  bool? get includeUncounted;

  CountConfirm._();

  factory CountConfirm([void updates(CountConfirmBuilder b)]) = _$CountConfirm;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CountConfirmBuilder b) => b..includeUncounted = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<CountConfirm> get serializer => _$CountConfirmSerializer();
}

class _$CountConfirmSerializer implements PrimitiveSerializer<CountConfirm> {
  @override
  final Iterable<Type> types = const [CountConfirm, _$CountConfirm];

  @override
  final String wireName = r'CountConfirm';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CountConfirm object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.includeUncounted != null) {
      yield r'include_uncounted';
      yield serializers.serialize(
        object.includeUncounted,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CountConfirm object, {
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
    required CountConfirmBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'include_uncounted':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
          if (valueDes == null) continue;
          result.includeUncounted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CountConfirm deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CountConfirmBuilder();
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
