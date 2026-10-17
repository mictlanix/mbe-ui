//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/fiscal_document_line.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_document_response.g.dart';

/// FiscalDocumentResponse
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
/// * [issuerRegime]
/// * [issuerRegimeName]
/// * [taxpayerRegime]
/// * [taxpayerPostalCode]
/// * [usage]
/// * [paymentMethod]
/// * [paymentTerms]
/// * [currency]
/// * [exchangeRate]
/// * [issuedLocation]
/// * [reference]
/// * [comment]
/// * [stamped] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [cancellationDate] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [cancellationReason]
/// * [lines]
@BuiltValue()
abstract class FiscalDocumentResponse
    implements Built<FiscalDocumentResponse, FiscalDocumentResponseBuilder> {
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
  FiscalDocumentResponseStatusEnum get status;
  // enum statusEnum {  draft,  issued,  cancelled,  };

  @BuiltValueField(wireName: r'total')
  String? get total;

  @BuiltValueField(wireName: r'issuer_regime')
  String? get issuerRegime;

  @BuiltValueField(wireName: r'issuer_regime_name')
  String? get issuerRegimeName;

  @BuiltValueField(wireName: r'taxpayer_regime')
  String? get taxpayerRegime;

  @BuiltValueField(wireName: r'taxpayer_postal_code')
  String? get taxpayerPostalCode;

  @BuiltValueField(wireName: r'usage')
  String? get usage;

  @BuiltValueField(wireName: r'payment_method')
  int get paymentMethod;

  @BuiltValueField(wireName: r'payment_terms')
  int get paymentTerms;

  @BuiltValueField(wireName: r'currency')
  int get currency;

  @BuiltValueField(wireName: r'exchange_rate')
  String get exchangeRate;

  @BuiltValueField(wireName: r'issued_location')
  String get issuedLocation;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'stamped')
  DateTime? get stamped;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'cancellation_date')
  DateTime? get cancellationDate;

  @BuiltValueField(wireName: r'cancellation_reason')
  String? get cancellationReason;

  @BuiltValueField(wireName: r'lines')
  BuiltList<FiscalDocumentLine> get lines;

  FiscalDocumentResponse._();

  factory FiscalDocumentResponse([
    void updates(FiscalDocumentResponseBuilder b),
  ]) = _$FiscalDocumentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FiscalDocumentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FiscalDocumentResponse> get serializer =>
      _$FiscalDocumentResponseSerializer();
}

class _$FiscalDocumentResponseSerializer
    implements PrimitiveSerializer<FiscalDocumentResponse> {
  @override
  final Iterable<Type> types = const [
    FiscalDocumentResponse,
    _$FiscalDocumentResponse,
  ];

  @override
  final String wireName = r'FiscalDocumentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FiscalDocumentResponse object, {
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
      specifiedType: const FullType(FiscalDocumentResponseStatusEnum),
    );
    yield r'total';
    yield object.total == null
        ? null
        : serializers.serialize(
            object.total,
            specifiedType: const FullType.nullable(String),
          );
    yield r'issuer_regime';
    yield object.issuerRegime == null
        ? null
        : serializers.serialize(
            object.issuerRegime,
            specifiedType: const FullType.nullable(String),
          );
    yield r'issuer_regime_name';
    yield object.issuerRegimeName == null
        ? null
        : serializers.serialize(
            object.issuerRegimeName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'taxpayer_regime';
    yield object.taxpayerRegime == null
        ? null
        : serializers.serialize(
            object.taxpayerRegime,
            specifiedType: const FullType.nullable(String),
          );
    yield r'taxpayer_postal_code';
    yield object.taxpayerPostalCode == null
        ? null
        : serializers.serialize(
            object.taxpayerPostalCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'usage';
    yield object.usage == null
        ? null
        : serializers.serialize(
            object.usage,
            specifiedType: const FullType.nullable(String),
          );
    yield r'payment_method';
    yield serializers.serialize(
      object.paymentMethod,
      specifiedType: const FullType(int),
    );
    yield r'payment_terms';
    yield serializers.serialize(
      object.paymentTerms,
      specifiedType: const FullType(int),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(int),
    );
    yield r'exchange_rate';
    yield serializers.serialize(
      object.exchangeRate,
      specifiedType: const FullType(String),
    );
    yield r'issued_location';
    yield serializers.serialize(
      object.issuedLocation,
      specifiedType: const FullType(String),
    );
    yield r'reference';
    yield object.reference == null
        ? null
        : serializers.serialize(
            object.reference,
            specifiedType: const FullType.nullable(String),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    yield r'stamped';
    yield object.stamped == null
        ? null
        : serializers.serialize(
            object.stamped,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'cancellation_date';
    yield object.cancellationDate == null
        ? null
        : serializers.serialize(
            object.cancellationDate,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'cancellation_reason';
    yield object.cancellationReason == null
        ? null
        : serializers.serialize(
            object.cancellationReason,
            specifiedType: const FullType.nullable(String),
          );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(FiscalDocumentLine)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FiscalDocumentResponse object, {
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
    required FiscalDocumentResponseBuilder result,
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
                      FiscalDocumentResponseStatusEnum,
                    ),
                  )
                  as FiscalDocumentResponseStatusEnum;
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
        case r'issuer_regime':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.issuerRegime = valueDes;
          break;
        case r'issuer_regime_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.issuerRegimeName = valueDes;
          break;
        case r'taxpayer_regime':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.taxpayerRegime = valueDes;
          break;
        case r'taxpayer_postal_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.taxpayerPostalCode = valueDes;
          break;
        case r'usage':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.usage = valueDes;
          break;
        case r'payment_method':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.paymentMethod = valueDes;
          break;
        case r'payment_terms':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.paymentTerms = valueDes;
          break;
        case r'currency':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.currency = valueDes;
          break;
        case r'exchange_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.exchangeRate = valueDes;
          break;
        case r'issued_location':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.issuedLocation = valueDes;
          break;
        case r'reference':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.reference = valueDes;
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
        case r'stamped':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.stamped = valueDes;
          break;
        case r'cancellation_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.cancellationDate = valueDes;
          break;
        case r'cancellation_reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.cancellationReason = valueDes;
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(FiscalDocumentLine),
                    ]),
                  )
                  as BuiltList<FiscalDocumentLine>;
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
  FiscalDocumentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FiscalDocumentResponseBuilder();
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

class FiscalDocumentResponseStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const FiscalDocumentResponseStatusEnum draft =
      _$fiscalDocumentResponseStatusEnum_draft;
  @BuiltValueEnumConst(wireName: r'issued')
  static const FiscalDocumentResponseStatusEnum issued =
      _$fiscalDocumentResponseStatusEnum_issued;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const FiscalDocumentResponseStatusEnum cancelled =
      _$fiscalDocumentResponseStatusEnum_cancelled;

  static Serializer<FiscalDocumentResponseStatusEnum> get serializer =>
      _$fiscalDocumentResponseStatusEnumSerializer;

  const FiscalDocumentResponseStatusEnum._(String name) : super(name);

  static BuiltSet<FiscalDocumentResponseStatusEnum> get values =>
      _$fiscalDocumentResponseStatusEnumValues;
  static FiscalDocumentResponseStatusEnum valueOf(String name) =>
      _$fiscalDocumentResponseStatusEnumValueOf(name);
}
