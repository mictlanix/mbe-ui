//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_order_create.g.dart';

/// PurchaseOrderCreate
///
/// Properties:
/// * [supplier]
/// * [estimatedReceiptDate]
/// * [comment]
@BuiltValue()
abstract class PurchaseOrderCreate
    implements Built<PurchaseOrderCreate, PurchaseOrderCreateBuilder> {
  @BuiltValueField(wireName: r'supplier')
  int get supplier;

  @BuiltValueField(wireName: r'estimated_receipt_date')
  Date? get estimatedReceiptDate;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  PurchaseOrderCreate._();

  factory PurchaseOrderCreate([void updates(PurchaseOrderCreateBuilder b)]) =
      _$PurchaseOrderCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseOrderCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseOrderCreate> get serializer =>
      _$PurchaseOrderCreateSerializer();
}

class _$PurchaseOrderCreateSerializer
    implements PrimitiveSerializer<PurchaseOrderCreate> {
  @override
  final Iterable<Type> types = const [
    PurchaseOrderCreate,
    _$PurchaseOrderCreate,
  ];

  @override
  final String wireName = r'PurchaseOrderCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseOrderCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier';
    yield serializers.serialize(
      object.supplier,
      specifiedType: const FullType(int),
    );
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
    PurchaseOrderCreate object, {
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
    required PurchaseOrderCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
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
  PurchaseOrderCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseOrderCreateBuilder();
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
