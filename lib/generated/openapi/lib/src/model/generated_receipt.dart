//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'generated_receipt.g.dart';

/// GeneratedReceipt
///
/// Properties:
/// * [inventoryReceiptId]
/// * [warehouse]
/// * [facility]
/// * [lineCount]
@BuiltValue()
abstract class GeneratedReceipt
    implements Built<GeneratedReceipt, GeneratedReceiptBuilder> {
  @BuiltValueField(wireName: r'inventory_receipt_id')
  int get inventoryReceiptId;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'line_count')
  int get lineCount;

  GeneratedReceipt._();

  factory GeneratedReceipt([void updates(GeneratedReceiptBuilder b)]) =
      _$GeneratedReceipt;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeneratedReceiptBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeneratedReceipt> get serializer =>
      _$GeneratedReceiptSerializer();
}

class _$GeneratedReceiptSerializer
    implements PrimitiveSerializer<GeneratedReceipt> {
  @override
  final Iterable<Type> types = const [GeneratedReceipt, _$GeneratedReceipt];

  @override
  final String wireName = r'GeneratedReceipt';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeneratedReceipt object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'inventory_receipt_id';
    yield serializers.serialize(
      object.inventoryReceiptId,
      specifiedType: const FullType(int),
    );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    yield r'line_count';
    yield serializers.serialize(
      object.lineCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GeneratedReceipt object, {
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
    required GeneratedReceiptBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'inventory_receipt_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.inventoryReceiptId = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'line_count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lineCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GeneratedReceipt deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeneratedReceiptBuilder();
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
