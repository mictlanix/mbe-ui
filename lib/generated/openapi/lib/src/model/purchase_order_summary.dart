//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_order_summary.g.dart';

/// PurchaseOrderSummary
///
/// Properties:
/// * [purchaseOrderId]
/// * [status]
/// * [supplier]
/// * [supplierName]
/// * [estimatedReceiptDate] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [comment]
/// * [creator]
/// * [updater]
/// * [creationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [modificationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [lineCount]
/// * [subtotal]
/// * [tax]
/// * [total]
@BuiltValue()
abstract class PurchaseOrderSummary
    implements Built<PurchaseOrderSummary, PurchaseOrderSummaryBuilder> {
  @BuiltValueField(wireName: r'purchase_order_id')
  int get purchaseOrderId;

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'supplier')
  int? get supplier;

  @BuiltValueField(wireName: r'supplier_name')
  String? get supplierName;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'estimated_receipt_date')
  DateTime? get estimatedReceiptDate;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'creator')
  int get creator;

  @BuiltValueField(wireName: r'updater')
  int get updater;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'creation_time')
  DateTime get creationTime;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'modification_time')
  DateTime get modificationTime;

  @BuiltValueField(wireName: r'line_count')
  int get lineCount;

  @BuiltValueField(wireName: r'subtotal')
  String get subtotal;

  @BuiltValueField(wireName: r'tax')
  String get tax;

  @BuiltValueField(wireName: r'total')
  String get total;

  PurchaseOrderSummary._();

  factory PurchaseOrderSummary([void updates(PurchaseOrderSummaryBuilder b)]) =
      _$PurchaseOrderSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseOrderSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseOrderSummary> get serializer =>
      _$PurchaseOrderSummarySerializer();
}

class _$PurchaseOrderSummarySerializer
    implements PrimitiveSerializer<PurchaseOrderSummary> {
  @override
  final Iterable<Type> types = const [
    PurchaseOrderSummary,
    _$PurchaseOrderSummary,
  ];

  @override
  final String wireName = r'PurchaseOrderSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseOrderSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_order_id';
    yield serializers.serialize(
      object.purchaseOrderId,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DocumentStatus),
    );
    yield r'supplier';
    yield object.supplier == null
        ? null
        : serializers.serialize(
            object.supplier,
            specifiedType: const FullType.nullable(int),
          );
    yield r'supplier_name';
    yield object.supplierName == null
        ? null
        : serializers.serialize(
            object.supplierName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'estimated_receipt_date';
    yield object.estimatedReceiptDate == null
        ? null
        : serializers.serialize(
            object.estimatedReceiptDate,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    yield r'creator';
    yield serializers.serialize(
      object.creator,
      specifiedType: const FullType(int),
    );
    yield r'updater';
    yield serializers.serialize(
      object.updater,
      specifiedType: const FullType(int),
    );
    yield r'creation_time';
    yield serializers.serialize(
      object.creationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'modification_time';
    yield serializers.serialize(
      object.modificationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'line_count';
    yield serializers.serialize(
      object.lineCount,
      specifiedType: const FullType(int),
    );
    yield r'subtotal';
    yield serializers.serialize(
      object.subtotal,
      specifiedType: const FullType(String),
    );
    yield r'tax';
    yield serializers.serialize(
      object.tax,
      specifiedType: const FullType(String),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseOrderSummary object, {
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
    required PurchaseOrderSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_order_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseOrderId = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DocumentStatus),
                  )
                  as DocumentStatus;
          result.status = valueDes;
          break;
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
        case r'supplier_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.supplierName = valueDes;
          break;
        case r'estimated_receipt_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
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
        case r'creator':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creator = valueDes;
          break;
        case r'updater':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.updater = valueDes;
          break;
        case r'creation_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.creationTime = valueDes;
          break;
        case r'modification_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.modificationTime = valueDes;
          break;
        case r'line_count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lineCount = valueDes;
          break;
        case r'subtotal':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.subtotal = valueDes;
          break;
        case r'tax':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.tax = valueDes;
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurchaseOrderSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseOrderSummaryBuilder();
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
