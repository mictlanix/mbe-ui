//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_approve.g.dart';

/// BulkApprove
///
/// Properties:
/// * [ids]
@BuiltValue()
abstract class BulkApprove implements Built<BulkApprove, BulkApproveBuilder> {
  @BuiltValueField(wireName: r'ids')
  BuiltList<int> get ids;

  BulkApprove._();

  factory BulkApprove([void updates(BulkApproveBuilder b)]) = _$BulkApprove;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkApproveBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkApprove> get serializer => _$BulkApproveSerializer();
}

class _$BulkApproveSerializer implements PrimitiveSerializer<BulkApprove> {
  @override
  final Iterable<Type> types = const [BulkApprove, _$BulkApprove];

  @override
  final String wireName = r'BulkApprove';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkApprove object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ids';
    yield serializers.serialize(
      object.ids,
      specifiedType: const FullType(BuiltList, [FullType(int)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkApprove object, {
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
    required BulkApproveBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ids':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [FullType(int)]),
                  )
                  as BuiltList<int>;
          result.ids.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BulkApprove deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkApproveBuilder();
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
