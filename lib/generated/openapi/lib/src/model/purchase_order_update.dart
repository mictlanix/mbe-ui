//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_order_update.g.dart';

/// PurchaseOrderUpdate
///
/// Properties:
/// * [supplier]
/// * [estimatedReceiptDate]
/// * [comment]
@BuiltValue()
abstract class PurchaseOrderUpdate
    implements Built<PurchaseOrderUpdate, PurchaseOrderUpdateBuilder> {
  @BuiltValueField(wireName: r'supplier')
  int? get supplier;

  @BuiltValueField(wireName: r'estimated_receipt_date')
  Date? get estimatedReceiptDate;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  PurchaseOrderUpdate._();

  factory PurchaseOrderUpdate([void updates(PurchaseOrderUpdateBuilder b)]) =
      _$PurchaseOrderUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseOrderUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseOrderUpdate> get serializer =>
      _$PurchaseOrderUpdateSerializer();
}

class _$PurchaseOrderUpdateSerializer
    implements PrimitiveSerializer<PurchaseOrderUpdate> {
  @override
  final Iterable<Type> types = const [
    PurchaseOrderUpdate,
    _$PurchaseOrderUpdate,
  ];

  @override
  final String wireName = r'PurchaseOrderUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseOrderUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.supplier != null) {
      yield r'supplier';
      yield serializers.serialize(
        object.supplier,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.estimatedReceiptDate != null) {
      yield r'estimated_receipt_date';
      yield serializers.serialize(
        object.estimatedReceiptDate,
        specifiedType: const FullType.nullable(Date),
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
    PurchaseOrderUpdate object, {
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
    required PurchaseOrderUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.supplier = valueDes;
          break;
        case r'estimated_receipt_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
          result.estimatedReceiptDate = valueDes;
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
  PurchaseOrderUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseOrderUpdateBuilder();
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
