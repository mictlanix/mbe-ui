//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/payment_amount.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/payment_terms.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice_update.g.dart';

/// Only the fields sent change (`model_fields_set`).
///
/// Properties:
/// * [recipient]
/// * [batch]
/// * [usage]
/// * [paymentTerms]
/// * [paymentMethod]
/// * [issued] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [facility]
/// * [reference]
/// * [comment]
/// * [paymentDate]
/// * [paymentAmount]
/// * [paymentReference]
/// * [orderingBank]
@BuiltValue()
abstract class InvoiceUpdate
    implements Built<InvoiceUpdate, InvoiceUpdateBuilder> {
  @BuiltValueField(wireName: r'recipient')
  String? get recipient;

  @BuiltValueField(wireName: r'batch')
  String? get batch;

  @BuiltValueField(wireName: r'usage')
  String? get usage;

  @BuiltValueField(wireName: r'payment_terms')
  PaymentTerms? get paymentTerms;
  // enum paymentTermsEnum {  0,  1,  };

  @BuiltValueField(wireName: r'payment_method')
  int? get paymentMethod;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'issued')
  DateTime? get issued;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'payment_date')
  Date? get paymentDate;

  @BuiltValueField(wireName: r'payment_amount')
  PaymentAmount? get paymentAmount;

  @BuiltValueField(wireName: r'payment_reference')
  String? get paymentReference;

  @BuiltValueField(wireName: r'ordering_bank')
  String? get orderingBank;

  InvoiceUpdate._();

  factory InvoiceUpdate([void updates(InvoiceUpdateBuilder b)]) =
      _$InvoiceUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvoiceUpdate> get serializer =>
      _$InvoiceUpdateSerializer();
}

class _$InvoiceUpdateSerializer implements PrimitiveSerializer<InvoiceUpdate> {
  @override
  final Iterable<Type> types = const [InvoiceUpdate, _$InvoiceUpdate];

  @override
  final String wireName = r'InvoiceUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvoiceUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.recipient != null) {
      yield r'recipient';
      yield serializers.serialize(
        object.recipient,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.batch != null) {
      yield r'batch';
      yield serializers.serialize(
        object.batch,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.usage != null) {
      yield r'usage';
      yield serializers.serialize(
        object.usage,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.paymentTerms != null) {
      yield r'payment_terms';
      yield serializers.serialize(
        object.paymentTerms,
        specifiedType: const FullType.nullable(PaymentTerms),
      );
    }
    if (object.paymentMethod != null) {
      yield r'payment_method';
      yield serializers.serialize(
        object.paymentMethod,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.issued != null) {
      yield r'issued';
      yield serializers.serialize(
        object.issued,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.reference != null) {
      yield r'reference';
      yield serializers.serialize(
        object.reference,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.paymentDate != null) {
      yield r'payment_date';
      yield serializers.serialize(
        object.paymentDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.paymentAmount != null) {
      yield r'payment_amount';
      yield serializers.serialize(
        object.paymentAmount,
        specifiedType: const FullType.nullable(PaymentAmount),
      );
    }
    if (object.paymentReference != null) {
      yield r'payment_reference';
      yield serializers.serialize(
        object.paymentReference,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.orderingBank != null) {
      yield r'ordering_bank';
      yield serializers.serialize(
        object.orderingBank,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InvoiceUpdate object, {
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
    required InvoiceUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'payment_terms':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(PaymentTerms),
                  )
                  as PaymentTerms?;
          if (valueDes == null) continue;
          result.paymentTerms = valueDes;
          break;
        case r'payment_method':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.paymentMethod = valueDes;
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
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
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
        case r'payment_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
          result.paymentDate = valueDes;
          break;
        case r'payment_amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(PaymentAmount),
                  )
                  as PaymentAmount?;
          if (valueDes == null) continue;
          result.paymentAmount.replace(valueDes);
          break;
        case r'payment_reference':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.paymentReference = valueDes;
          break;
        case r'ordering_bank':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.orderingBank = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvoiceUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceUpdateBuilder();
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
