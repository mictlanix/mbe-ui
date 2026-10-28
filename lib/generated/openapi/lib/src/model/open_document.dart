//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/linked_document.dart';
import 'package:mbe_api_client/src/model/currency_code.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'open_document.g.dart';

/// OpenDocument
///
/// Properties:
/// * [id]
/// * [serial]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [dueDate] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [daysPastDue]
/// * [bucket]
/// * [facility]
/// * [facilityCode]
/// * [salesperson]
/// * [linked]
/// * [currency]
/// * [exchangeRate]
/// * [total]
/// * [deductions]
/// * [applied]
/// * [balance]
@BuiltValue()
abstract class OpenDocument
    implements Built<OpenDocument, OpenDocumentBuilder> {
  @BuiltValueField(wireName: r'id')
  int get id;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'due_date')
  DateTime? get dueDate;

  @BuiltValueField(wireName: r'days_past_due')
  int get daysPastDue;

  @BuiltValueField(wireName: r'bucket')
  String get bucket;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'facility_code')
  String? get facilityCode;

  @BuiltValueField(wireName: r'salesperson')
  int? get salesperson;

  @BuiltValueField(wireName: r'linked')
  BuiltList<LinkedDocument> get linked;

  @BuiltValueField(wireName: r'currency')
  CurrencyCode get currency;
  // enum currencyEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'exchange_rate')
  String get exchangeRate;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'deductions')
  String get deductions;

  @BuiltValueField(wireName: r'applied')
  String get applied;

  @BuiltValueField(wireName: r'balance')
  String get balance;

  OpenDocument._();

  factory OpenDocument([void updates(OpenDocumentBuilder b)]) = _$OpenDocument;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpenDocumentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpenDocument> get serializer => _$OpenDocumentSerializer();
}

class _$OpenDocumentSerializer implements PrimitiveSerializer<OpenDocument> {
  @override
  final Iterable<Type> types = const [OpenDocument, _$OpenDocument];

  @override
  final String wireName = r'OpenDocument';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpenDocument object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(object.id, specifiedType: const FullType(int));
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'due_date';
    yield object.dueDate == null
        ? null
        : serializers.serialize(
            object.dueDate,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'days_past_due';
    yield serializers.serialize(
      object.daysPastDue,
      specifiedType: const FullType(int),
    );
    yield r'bucket';
    yield serializers.serialize(
      object.bucket,
      specifiedType: const FullType(String),
    );
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.facilityCode != null) {
      yield r'facility_code';
      yield serializers.serialize(
        object.facilityCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.salesperson != null) {
      yield r'salesperson';
      yield serializers.serialize(
        object.salesperson,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'linked';
    yield serializers.serialize(
      object.linked,
      specifiedType: const FullType(BuiltList, [FullType(LinkedDocument)]),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(CurrencyCode),
    );
    yield r'exchange_rate';
    yield serializers.serialize(
      object.exchangeRate,
      specifiedType: const FullType(String),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'deductions';
    yield serializers.serialize(
      object.deductions,
      specifiedType: const FullType(String),
    );
    yield r'applied';
    yield serializers.serialize(
      object.applied,
      specifiedType: const FullType(String),
    );
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpenDocument object, {
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
    required OpenDocumentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.id = valueDes;
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
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
          break;
        case r'due_date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.dueDate = valueDes;
          break;
        case r'days_past_due':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.daysPastDue = valueDes;
          break;
        case r'bucket':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.bucket = valueDes;
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
        case r'facility_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.facilityCode = valueDes;
          break;
        case r'salesperson':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.salesperson = valueDes;
          break;
        case r'linked':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(LinkedDocument),
                    ]),
                  )
                  as BuiltList<LinkedDocument>;
          result.linked.replace(valueDes);
          break;
        case r'currency':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(CurrencyCode),
                  )
                  as CurrencyCode;
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
        case r'total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.total = valueDes;
          break;
        case r'deductions':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.deductions = valueDes;
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
        case r'balance':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.balance = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpenDocument deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpenDocumentBuilder();
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
