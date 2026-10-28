//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'buckets.g.dart';

/// Aging by days past due. Each document lands in exactly one, so they add up to owed.
///
/// Properties:
/// * [current]
/// * [n130]
/// * [n3160]
/// * [n6190]
/// * [n90plus]
@BuiltValue()
abstract class Buckets implements Built<Buckets, BucketsBuilder> {
  @BuiltValueField(wireName: r'current')
  String get current;

  @BuiltValueField(wireName: r'1-30')
  String get n130;

  @BuiltValueField(wireName: r'31-60')
  String get n3160;

  @BuiltValueField(wireName: r'61-90')
  String get n6190;

  @BuiltValueField(wireName: r'90+')
  String get n90plus;

  Buckets._();

  factory Buckets([void updates(BucketsBuilder b)]) = _$Buckets;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BucketsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Buckets> get serializer => _$BucketsSerializer();
}

class _$BucketsSerializer implements PrimitiveSerializer<Buckets> {
  @override
  final Iterable<Type> types = const [Buckets, _$Buckets];

  @override
  final String wireName = r'Buckets';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Buckets object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current';
    yield serializers.serialize(
      object.current,
      specifiedType: const FullType(String),
    );
    yield r'1-30';
    yield serializers.serialize(
      object.n130,
      specifiedType: const FullType(String),
    );
    yield r'31-60';
    yield serializers.serialize(
      object.n3160,
      specifiedType: const FullType(String),
    );
    yield r'61-90';
    yield serializers.serialize(
      object.n6190,
      specifiedType: const FullType(String),
    );
    yield r'90+';
    yield serializers.serialize(
      object.n90plus,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Buckets object, {
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
    required BucketsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.current = valueDes;
          break;
        case r'1-30':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.n130 = valueDes;
          break;
        case r'31-60':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.n3160 = valueDes;
          break;
        case r'61-90':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.n6190 = valueDes;
          break;
        case r'90+':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.n90plus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Buckets deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BucketsBuilder();
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
