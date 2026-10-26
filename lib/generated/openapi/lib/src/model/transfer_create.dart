//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transfer_create.g.dart';

/// TransferCreate
///
/// Properties:
/// * [warehouse]
/// * [warehouseTo]
/// * [comment]
@BuiltValue()
abstract class TransferCreate
    implements Built<TransferCreate, TransferCreateBuilder> {
  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'warehouse_to')
  int get warehouseTo;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  TransferCreate._();

  factory TransferCreate([void updates(TransferCreateBuilder b)]) =
      _$TransferCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransferCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TransferCreate> get serializer =>
      _$TransferCreateSerializer();
}

class _$TransferCreateSerializer
    implements PrimitiveSerializer<TransferCreate> {
  @override
  final Iterable<Type> types = const [TransferCreate, _$TransferCreate];

  @override
  final String wireName = r'TransferCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TransferCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'warehouse_to';
    yield serializers.serialize(
      object.warehouseTo,
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
    TransferCreate object, {
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
    required TransferCreateBuilder result,
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
        case r'warehouse_to':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouseTo = valueDes;
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
  TransferCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransferCreateBuilder();
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
