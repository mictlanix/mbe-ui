//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/payment_status.dart';
import 'package:mbe_api_client/src/model/application.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_payment_response.g.dart';

/// SupplierPaymentResponse
///
/// Properties:
/// * [supplierPaymentId]
/// * [facility]
/// * [serial]
/// * [status]
/// * [supplier]
/// * [supplierName]
/// * [amount]
/// * [method]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [reference]
/// * [comment]
/// * [cashSession]
/// * [creator]
/// * [applied]
/// * [credit]
/// * [applications]
@BuiltValue()
abstract class SupplierPaymentResponse
    implements Built<SupplierPaymentResponse, SupplierPaymentResponseBuilder> {
  @BuiltValueField(wireName: r'supplier_payment_id')
  int get supplierPaymentId;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'status')
  PaymentStatus get status;
  // enum statusEnum {  completed,  cancelled,  };

  @BuiltValueField(wireName: r'supplier')
  int get supplier;

  @BuiltValueField(wireName: r'supplier_name')
  String? get supplierName;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'method')
  int get method;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'cash_session')
  int? get cashSession;

  @BuiltValueField(wireName: r'creator')
  int get creator;

  @BuiltValueField(wireName: r'applied')
  String get applied;

  @BuiltValueField(wireName: r'credit')
  String get credit;

  @BuiltValueField(wireName: r'applications')
  BuiltList<Application>? get applications;

  SupplierPaymentResponse._();

  factory SupplierPaymentResponse([
    void updates(SupplierPaymentResponseBuilder b),
  ]) = _$SupplierPaymentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierPaymentResponseBuilder b) =>
      b..applications = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierPaymentResponse> get serializer =>
      _$SupplierPaymentResponseSerializer();
}

class _$SupplierPaymentResponseSerializer
    implements PrimitiveSerializer<SupplierPaymentResponse> {
  @override
  final Iterable<Type> types = const [
    SupplierPaymentResponse,
    _$SupplierPaymentResponse,
  ];

  @override
  final String wireName = r'SupplierPaymentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierPaymentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier_payment_id';
    yield serializers.serialize(
      object.supplierPaymentId,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield object.facility == null
        ? null
        : serializers.serialize(
            object.facility,
            specifiedType: const FullType.nullable(int),
          );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PaymentStatus),
    );
    yield r'supplier';
    yield serializers.serialize(
      object.supplier,
      specifiedType: const FullType(int),
    );
    yield r'supplier_name';
    yield object.supplierName == null
        ? null
        : serializers.serialize(
            object.supplierName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(int),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
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
    yield r'cash_session';
    yield object.cashSession == null
        ? null
        : serializers.serialize(
            object.cashSession,
            specifiedType: const FullType.nullable(int),
          );
    yield r'creator';
    yield serializers.serialize(
      object.creator,
      specifiedType: const FullType(int),
    );
    yield r'applied';
    yield serializers.serialize(
      object.applied,
      specifiedType: const FullType(String),
    );
    yield r'credit';
    yield serializers.serialize(
      object.credit,
      specifiedType: const FullType(String),
    );
    if (object.applications != null) {
      yield r'applications';
      yield serializers.serialize(
        object.applications,
        specifiedType: const FullType(BuiltList, [FullType(Application)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierPaymentResponse object, {
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
    required SupplierPaymentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier_payment_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.supplierPaymentId = valueDes;
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(PaymentStatus),
                  )
                  as PaymentStatus;
          result.status = valueDes;
          break;
        case r'supplier':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
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
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.amount = valueDes;
          break;
        case r'method':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.method = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
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
        case r'cash_session':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.cashSession = valueDes;
          break;
        case r'creator':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creator = valueDes;
          break;
        case r'applied':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.applied = valueDes;
          break;
        case r'credit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.credit = valueDes;
          break;
        case r'applications':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(Application),
                    ]),
                  )
                  as BuiltList<Application>?;
          if (valueDes == null) continue;
          result.applications.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierPaymentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierPaymentResponseBuilder();
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
