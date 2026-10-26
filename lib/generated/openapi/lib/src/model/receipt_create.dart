//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'receipt_create.g.dart';

/// ReceiptCreate
///
/// Properties:
/// * [warehouse]
/// * [comment]
@BuiltValue()
abstract class ReceiptCreate
    implements Built<ReceiptCreate, ReceiptCreateBuilder> {
  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ReceiptCreate._();

  factory ReceiptCreate([void updates(ReceiptCreateBuilder b)]) =
      _$ReceiptCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReceiptCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReceiptCreate> get serializer =>
      _$ReceiptCreateSerializer();
}

class _$ReceiptCreateSerializer implements PrimitiveSerializer<ReceiptCreate> {
  @override
  final Iterable<Type> types = const [ReceiptCreate, _$ReceiptCreate];

  @override
  final String wireName = r'ReceiptCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReceiptCreate object, {
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
    ReceiptCreate object, {
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
    required ReceiptCreateBuilder result,
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
  ReceiptCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReceiptCreateBuilder();
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
