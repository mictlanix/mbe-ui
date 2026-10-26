//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_document_summary.g.dart';

/// One row of the list. `total` is the stamped XML's, `None` when there is no XML.
///
/// Properties:
/// * [fiscalDocumentId]
/// * [type]
/// * [version]
/// * [batch]
/// * [serial]
/// * [issuer]
/// * [issuerName]
/// * [recipient]
/// * [recipientName]
/// * [issued] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [stampUuid]
/// * [status]
/// * [total]
@BuiltValue()
abstract class FiscalDocumentSummary
    implements Built<FiscalDocumentSummary, FiscalDocumentSummaryBuilder> {
  @BuiltValueField(wireName: r'fiscal_document_id')
  int get fiscalDocumentId;

  @BuiltValueField(wireName: r'type')
  int get type;

  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'batch')
  String? get batch;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'issuer')
  String get issuer;

  @BuiltValueField(wireName: r'issuer_name')
  String? get issuerName;

  @BuiltValueField(wireName: r'recipient')
  String? get recipient;

  @BuiltValueField(wireName: r'recipient_name')
  String? get recipientName;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'issued')
  DateTime? get issued;

  @BuiltValueField(wireName: r'stamp_uuid')
  String? get stampUuid;

  @BuiltValueField(wireName: r'status')
  FiscalDocumentSummaryStatusEnum get status;
  // enum statusEnum {  draft,  sealed,  issued,  cancelled,  };

  @BuiltValueField(wireName: r'total')
  String? get total;

  FiscalDocumentSummary._();

  factory FiscalDocumentSummary([
    void updates(FiscalDocumentSummaryBuilder b),
  ]) = _$FiscalDocumentSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FiscalDocumentSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FiscalDocumentSummary> get serializer =>
      _$FiscalDocumentSummarySerializer();
}

class _$FiscalDocumentSummarySerializer
    implements PrimitiveSerializer<FiscalDocumentSummary> {
  @override
  final Iterable<Type> types = const [
    FiscalDocumentSummary,
    _$FiscalDocumentSummary,
  ];

  @override
  final String wireName = r'FiscalDocumentSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FiscalDocumentSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fiscal_document_id';
    yield serializers.serialize(
      object.fiscalDocumentId,
      specifiedType: const FullType(int),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(int),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'batch';
    yield object.batch == null
        ? null
        : serializers.serialize(
            object.batch,
            specifiedType: const FullType.nullable(String),
          );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'issuer';
    yield serializers.serialize(
      object.issuer,
      specifiedType: const FullType(String),
    );
    yield r'issuer_name';
    yield object.issuerName == null
        ? null
        : serializers.serialize(
            object.issuerName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'recipient';
    yield object.recipient == null
        ? null
        : serializers.serialize(
            object.recipient,
            specifiedType: const FullType.nullable(String),
          );
    yield r'recipient_name';
    yield object.recipientName == null
        ? null
        : serializers.serialize(
            object.recipientName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'issued';
    yield object.issued == null
        ? null
        : serializers.serialize(
            object.issued,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'stamp_uuid';
    yield object.stampUuid == null
        ? null
        : serializers.serialize(
            object.stampUuid,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(FiscalDocumentSummaryStatusEnum),
    );
    yield r'total';
    yield object.total == null
        ? null
        : serializers.serialize(
            object.total,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    FiscalDocumentSummary object, {
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
    required FiscalDocumentSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fiscal_document_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.fiscalDocumentId = valueDes;
          break;
        case r'type':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.type = valueDes;
          break;
        case r'version':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.version = valueDes;
          break;
        case r'batch':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.batch = valueDes;
          break;
        case r'serial':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.serial = valueDes;
          break;
        case r'issuer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.issuer = valueDes;
          break;
        case r'issuer_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.issuerName = valueDes;
          break;
        case r'recipient':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.recipient = valueDes;
          break;
        case r'recipient_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.recipientName = valueDes;
          break;
        case r'issued':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.issued = valueDes;
          break;
        case r'stamp_uuid':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.stampUuid = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(
                      FiscalDocumentSummaryStatusEnum,
                    ),
                  )
                  as FiscalDocumentSummaryStatusEnum;
          result.status = valueDes;
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
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
  FiscalDocumentSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FiscalDocumentSummaryBuilder();
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

class FiscalDocumentSummaryStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const FiscalDocumentSummaryStatusEnum draft =
      _$fiscalDocumentSummaryStatusEnum_draft;
  @BuiltValueEnumConst(wireName: r'sealed')
  static const FiscalDocumentSummaryStatusEnum sealed_ =
      _$fiscalDocumentSummaryStatusEnum_sealed_;
  @BuiltValueEnumConst(wireName: r'issued')
  static const FiscalDocumentSummaryStatusEnum issued =
      _$fiscalDocumentSummaryStatusEnum_issued;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const FiscalDocumentSummaryStatusEnum cancelled =
      _$fiscalDocumentSummaryStatusEnum_cancelled;

  static Serializer<FiscalDocumentSummaryStatusEnum> get serializer =>
      _$fiscalDocumentSummaryStatusEnumSerializer;

  const FiscalDocumentSummaryStatusEnum._(String name) : super(name);

  static BuiltSet<FiscalDocumentSummaryStatusEnum> get values =>
      _$fiscalDocumentSummaryStatusEnumValues;
  static FiscalDocumentSummaryStatusEnum valueOf(String name) =>
      _$fiscalDocumentSummaryStatusEnumValueOf(name);
}
