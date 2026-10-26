//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'paid_invoice_response.g.dart';

/// One invoice a payment receipt pays. Live values on a draft, stored once sealed.
///
/// Properties:
/// * [fiscalDocumentRelationId]
/// * [invoice]
/// * [batch]
/// * [serial]
/// * [stampUuid]
/// * [installment]
/// * [previousBalance]
/// * [amount]
/// * [remaining]
@BuiltValue()
abstract class PaidInvoiceResponse
    implements Built<PaidInvoiceResponse, PaidInvoiceResponseBuilder> {
  @BuiltValueField(wireName: r'fiscal_document_relation_id')
  int get fiscalDocumentRelationId;

  @BuiltValueField(wireName: r'invoice')
  int get invoice;

  @BuiltValueField(wireName: r'batch')
  String? get batch;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'stamp_uuid')
  String? get stampUuid;

  @BuiltValueField(wireName: r'installment')
  int get installment;

  @BuiltValueField(wireName: r'previous_balance')
  String get previousBalance;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'remaining')
  String get remaining;

  PaidInvoiceResponse._();

  factory PaidInvoiceResponse([void updates(PaidInvoiceResponseBuilder b)]) =
      _$PaidInvoiceResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaidInvoiceResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaidInvoiceResponse> get serializer =>
      _$PaidInvoiceResponseSerializer();
}

class _$PaidInvoiceResponseSerializer
    implements PrimitiveSerializer<PaidInvoiceResponse> {
  @override
  final Iterable<Type> types = const [
    PaidInvoiceResponse,
    _$PaidInvoiceResponse,
  ];

  @override
  final String wireName = r'PaidInvoiceResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaidInvoiceResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fiscal_document_relation_id';
    yield serializers.serialize(
      object.fiscalDocumentRelationId,
      specifiedType: const FullType(int),
    );
    yield r'invoice';
    yield serializers.serialize(
      object.invoice,
      specifiedType: const FullType(int),
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
    yield r'stamp_uuid';
    yield object.stampUuid == null
        ? null
        : serializers.serialize(
            object.stampUuid,
            specifiedType: const FullType.nullable(String),
          );
    yield r'installment';
    yield serializers.serialize(
      object.installment,
      specifiedType: const FullType(int),
    );
    yield r'previous_balance';
    yield serializers.serialize(
      object.previousBalance,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'remaining';
    yield serializers.serialize(
      object.remaining,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaidInvoiceResponse object, {
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
    required PaidInvoiceResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fiscal_document_relation_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.fiscalDocumentRelationId = valueDes;
          break;
        case r'invoice':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.invoice = valueDes;
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
        case r'installment':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.installment = valueDes;
          break;
        case r'previous_balance':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.previousBalance = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.amount = valueDes;
          break;
        case r'remaining':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.remaining = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaidInvoiceResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaidInvoiceResponseBuilder();
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
