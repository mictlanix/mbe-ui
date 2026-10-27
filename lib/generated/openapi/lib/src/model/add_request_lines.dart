//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_request_lines.g.dart';

/// AddRequestLines
///
/// Properties:
/// * [purchaseRequest]
@BuiltValue()
abstract class AddRequestLines
    implements Built<AddRequestLines, AddRequestLinesBuilder> {
  @BuiltValueField(wireName: r'purchase_request')
  int get purchaseRequest;

  AddRequestLines._();

  factory AddRequestLines([void updates(AddRequestLinesBuilder b)]) =
      _$AddRequestLines;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddRequestLinesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddRequestLines> get serializer =>
      _$AddRequestLinesSerializer();
}

class _$AddRequestLinesSerializer
    implements PrimitiveSerializer<AddRequestLines> {
  @override
  final Iterable<Type> types = const [AddRequestLines, _$AddRequestLines];

  @override
  final String wireName = r'AddRequestLines';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddRequestLines object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_request';
    yield serializers.serialize(
      object.purchaseRequest,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AddRequestLines object, {
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
    required AddRequestLinesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_request':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseRequest = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AddRequestLines deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddRequestLinesBuilder();
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
