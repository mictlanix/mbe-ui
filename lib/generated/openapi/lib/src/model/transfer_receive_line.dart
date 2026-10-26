//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity5.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transfer_receive_line.g.dart';

/// TransferReceiveLine
///
/// Properties:
/// * [lineId]
/// * [quantity]
@BuiltValue()
abstract class TransferReceiveLine
    implements Built<TransferReceiveLine, TransferReceiveLineBuilder> {
  @BuiltValueField(wireName: r'line_id')
  int get lineId;

  @BuiltValueField(wireName: r'quantity')
  Quantity5 get quantity;

  TransferReceiveLine._();

  factory TransferReceiveLine([void updates(TransferReceiveLineBuilder b)]) =
      _$TransferReceiveLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransferReceiveLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TransferReceiveLine> get serializer =>
      _$TransferReceiveLineSerializer();
}

class _$TransferReceiveLineSerializer
    implements PrimitiveSerializer<TransferReceiveLine> {
  @override
  final Iterable<Type> types = const [
    TransferReceiveLine,
    _$TransferReceiveLine,
  ];

  @override
  final String wireName = r'TransferReceiveLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TransferReceiveLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'line_id';
    yield serializers.serialize(
      object.lineId,
      specifiedType: const FullType(int),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(Quantity5),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TransferReceiveLine object, {
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
    required TransferReceiveLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'line_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lineId = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Quantity5),
                  )
                  as Quantity5;
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
  TransferReceiveLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransferReceiveLineBuilder();
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
