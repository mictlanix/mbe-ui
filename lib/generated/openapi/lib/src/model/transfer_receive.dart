//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/transfer_receive_line.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transfer_receive.g.dart';

/// TransferReceive
///
/// Properties:
/// * [lines]
@BuiltValue()
abstract class TransferReceive
    implements Built<TransferReceive, TransferReceiveBuilder> {
  @BuiltValueField(wireName: r'lines')
  BuiltList<TransferReceiveLine>? get lines;

  TransferReceive._();

  factory TransferReceive([void updates(TransferReceiveBuilder b)]) =
      _$TransferReceive;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransferReceiveBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TransferReceive> get serializer =>
      _$TransferReceiveSerializer();
}

class _$TransferReceiveSerializer
    implements PrimitiveSerializer<TransferReceive> {
  @override
  final Iterable<Type> types = const [TransferReceive, _$TransferReceive];

  @override
  final String wireName = r'TransferReceive';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TransferReceive object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType.nullable(BuiltList, [
          FullType(TransferReceiveLine),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TransferReceive object, {
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
    required TransferReceiveBuilder result,
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
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(TransferReceiveLine),
                    ]),
                  )
                  as BuiltList<TransferReceiveLine>?;
          if (valueDes == null) continue;
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
  TransferReceive deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransferReceiveBuilder();
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
