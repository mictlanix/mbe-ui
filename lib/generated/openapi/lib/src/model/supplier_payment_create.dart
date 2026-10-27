//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/application_item.dart';
import 'package:mbe_api_client/src/model/payment_method.dart';
import 'package:mbe_api_client/src/model/amount1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_payment_create.g.dart';

/// SupplierPaymentCreate
///
/// Properties:
/// * [supplier]
/// * [amount]
/// * [method]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [reference]
/// * [comment]
/// * [facility]
/// * [applications]
@BuiltValue()
abstract class SupplierPaymentCreate
    implements Built<SupplierPaymentCreate, SupplierPaymentCreateBuilder> {
  @BuiltValueField(wireName: r'supplier')
  int get supplier;

  @BuiltValueField(wireName: r'amount')
  Amount1 get amount;

  @BuiltValueField(wireName: r'method')
  PaymentMethod get method;
  // enum methodEnum {  0,  1,  2,  3,  4,  5,  6,  8,  12,  27,  28,  29,  30,  99,  1001,  };

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'applications')
  BuiltList<ApplicationItem>? get applications;

  SupplierPaymentCreate._();

  factory SupplierPaymentCreate([
    void updates(SupplierPaymentCreateBuilder b),
  ]) = _$SupplierPaymentCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierPaymentCreateBuilder b) =>
      b..applications = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierPaymentCreate> get serializer =>
      _$SupplierPaymentCreateSerializer();
}

class _$SupplierPaymentCreateSerializer
    implements PrimitiveSerializer<SupplierPaymentCreate> {
  @override
  final Iterable<Type> types = const [
    SupplierPaymentCreate,
    _$SupplierPaymentCreate,
  ];

  @override
  final String wireName = r'SupplierPaymentCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierPaymentCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier';
    yield serializers.serialize(
      object.supplier,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Amount1),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(PaymentMethod),
    );
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType.nullable(DateTime),
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
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.applications != null) {
      yield r'applications';
      yield serializers.serialize(
        object.applications,
        specifiedType: const FullType(BuiltList, [FullType(ApplicationItem)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierPaymentCreate object, {
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
    required SupplierPaymentCreateBuilder result,
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
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Amount1),
                  )
                  as Amount1;
          result.amount.replace(valueDes);
          break;
        case r'method':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(PaymentMethod),
                  )
                  as PaymentMethod;
          result.method = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
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
        case r'applications':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(ApplicationItem),
                    ]),
                  )
                  as BuiltList<ApplicationItem>?;
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
  SupplierPaymentCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierPaymentCreateBuilder();
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
