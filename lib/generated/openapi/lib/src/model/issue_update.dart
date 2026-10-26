//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'issue_update.g.dart';

/// IssueUpdate
///
/// Properties:
/// * [warehouse]
/// * [comment]
@BuiltValue()
abstract class IssueUpdate implements Built<IssueUpdate, IssueUpdateBuilder> {
  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  IssueUpdate._();

  factory IssueUpdate([void updates(IssueUpdateBuilder b)]) = _$IssueUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IssueUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IssueUpdate> get serializer => _$IssueUpdateSerializer();
}

class _$IssueUpdateSerializer implements PrimitiveSerializer<IssueUpdate> {
  @override
  final Iterable<Type> types = const [IssueUpdate, _$IssueUpdate];

  @override
  final String wireName = r'IssueUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IssueUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
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
    IssueUpdate object, {
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
    required IssueUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'warehouse':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
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
  IssueUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IssueUpdateBuilder();
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
