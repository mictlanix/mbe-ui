//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/count_line_set.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'count_lines_set.g.dart';

/// A batch: each product's quantity is replaced, never added to (research R3).
///
/// Properties:
/// * [lines]
@BuiltValue()
abstract class CountLinesSet
    implements Built<CountLinesSet, CountLinesSetBuilder> {
  @BuiltValueField(wireName: r'lines')
  BuiltList<CountLineSet> get lines;

  CountLinesSet._();

  factory CountLinesSet([void updates(CountLinesSetBuilder b)]) =
      _$CountLinesSet;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CountLinesSetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CountLinesSet> get serializer =>
      _$CountLinesSetSerializer();
}

class _$CountLinesSetSerializer implements PrimitiveSerializer<CountLinesSet> {
  @override
  final Iterable<Type> types = const [CountLinesSet, _$CountLinesSet];

  @override
  final String wireName = r'CountLinesSet';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CountLinesSet object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(CountLineSet)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CountLinesSet object, {
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
    required CountLinesSetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(CountLineSet),
                    ]),
                  )
                  as BuiltList<CountLineSet>;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CountLinesSet deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CountLinesSetBuilder();
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
