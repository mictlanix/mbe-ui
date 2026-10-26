//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transfer_update.g.dart';

/// TransferUpdate
///
/// Properties:
/// * [warehouse]
/// * [warehouseTo]
/// * [comment]
@BuiltValue()
abstract class TransferUpdate
    implements Built<TransferUpdate, TransferUpdateBuilder> {
  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'warehouse_to')
  int? get warehouseTo;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  TransferUpdate._();

  factory TransferUpdate([void updates(TransferUpdateBuilder b)]) =
      _$TransferUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransferUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TransferUpdate> get serializer =>
      _$TransferUpdateSerializer();
}

class _$TransferUpdateSerializer
    implements PrimitiveSerializer<TransferUpdate> {
  @override
  final Iterable<Type> types = const [TransferUpdate, _$TransferUpdate];

  @override
  final String wireName = r'TransferUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TransferUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.warehouseTo != null) {
      yield r'warehouse_to';
      yield serializers.serialize(
        object.warehouseTo,
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
    TransferUpdate object, {
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
    required TransferUpdateBuilder result,
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
        case r'warehouse_to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
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
  TransferUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransferUpdateBuilder();
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
