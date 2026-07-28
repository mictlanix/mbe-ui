//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commit_line_update.g.dart';

/// CommitLineUpdate
///
/// Properties:
/// * [quantity]
@BuiltValue()
abstract class CommitLineUpdate
    implements Built<CommitLineUpdate, CommitLineUpdateBuilder> {
  @BuiltValueField(wireName: r'quantity')
  Quantity1 get quantity;

  CommitLineUpdate._();

  factory CommitLineUpdate([void updates(CommitLineUpdateBuilder b)]) =
      _$CommitLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommitLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommitLineUpdate> get serializer =>
      _$CommitLineUpdateSerializer();
}

class _$CommitLineUpdateSerializer
    implements PrimitiveSerializer<CommitLineUpdate> {
  @override
  final Iterable<Type> types = const [CommitLineUpdate, _$CommitLineUpdate];

  @override
  final String wireName = r'CommitLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommitLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(Quantity1),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommitLineUpdate object, {
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
    required CommitLineUpdateBuilder result,
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
                    specifiedType: const FullType(Quantity1),
                  )
                  as Quantity1;
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
  CommitLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommitLineUpdateBuilder();
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
