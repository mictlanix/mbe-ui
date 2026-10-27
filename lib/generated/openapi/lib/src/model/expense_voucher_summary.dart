//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'expense_voucher_summary.g.dart';

/// ExpenseVoucherSummary
///
/// Properties:
/// * [expenseVoucherId]
/// * [status]
/// * [voided]
/// * [facility]
/// * [cashSession]
/// * [creator]
/// * [creatorName]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [comment]
/// * [total]
/// * [lineCount]
@BuiltValue()
abstract class ExpenseVoucherSummary
    implements Built<ExpenseVoucherSummary, ExpenseVoucherSummaryBuilder> {
  @BuiltValueField(wireName: r'expense_voucher_id')
  int get expenseVoucherId;

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'voided')
  bool get voided;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'cash_session')
  int get cashSession;

  @BuiltValueField(wireName: r'creator')
  int get creator;

  @BuiltValueField(wireName: r'creator_name')
  String? get creatorName;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'line_count')
  int get lineCount;

  ExpenseVoucherSummary._();

  factory ExpenseVoucherSummary([
    void updates(ExpenseVoucherSummaryBuilder b),
  ]) = _$ExpenseVoucherSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExpenseVoucherSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExpenseVoucherSummary> get serializer =>
      _$ExpenseVoucherSummarySerializer();
}

class _$ExpenseVoucherSummarySerializer
    implements PrimitiveSerializer<ExpenseVoucherSummary> {
  @override
  final Iterable<Type> types = const [
    ExpenseVoucherSummary,
    _$ExpenseVoucherSummary,
  ];

  @override
  final String wireName = r'ExpenseVoucherSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExpenseVoucherSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expense_voucher_id';
    yield serializers.serialize(
      object.expenseVoucherId,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DocumentStatus),
    );
    yield r'voided';
    yield serializers.serialize(
      object.voided,
      specifiedType: const FullType(bool),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    yield r'cash_session';
    yield serializers.serialize(
      object.cashSession,
      specifiedType: const FullType(int),
    );
    yield r'creator';
    yield serializers.serialize(
      object.creator,
      specifiedType: const FullType(int),
    );
    yield r'creator_name';
    yield object.creatorName == null
        ? null
        : serializers.serialize(
            object.creatorName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'line_count';
    yield serializers.serialize(
      object.lineCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExpenseVoucherSummary object, {
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
    required ExpenseVoucherSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expense_voucher_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.expenseVoucherId = valueDes;
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
        case r'voided':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.voided = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'cash_session':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.cashSession = valueDes;
          break;
        case r'creator':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creator = valueDes;
          break;
        case r'creator_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.creatorName = valueDes;
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
        case r'total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.total = valueDes;
          break;
        case r'line_count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lineCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExpenseVoucherSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExpenseVoucherSummaryBuilder();
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
