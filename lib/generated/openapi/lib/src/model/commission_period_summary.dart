//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_period_summary.g.dart';

/// CommissionPeriodSummary
///
/// Properties:
/// * [year]
/// * [month]
/// * [status]
/// * [closedBy]
/// * [closedAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [reopenedBy]
/// * [reopenedAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [paidBy]
/// * [paidAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [total] - Sum of the stored lines; 0 for a reopened month.
@BuiltValue()
abstract class CommissionPeriodSummary
    implements Built<CommissionPeriodSummary, CommissionPeriodSummaryBuilder> {
  @BuiltValueField(wireName: r'year')
  int get year;

  @BuiltValueField(wireName: r'month')
  int get month;

  @BuiltValueField(wireName: r'status')
  CommissionPeriodSummaryStatusEnum get status;
  // enum statusEnum {  open,  closed,  paid,  };

  @BuiltValueField(wireName: r'closed_by')
  int? get closedBy;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'closed_at')
  DateTime? get closedAt;

  @BuiltValueField(wireName: r'reopened_by')
  int? get reopenedBy;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'reopened_at')
  DateTime? get reopenedAt;

  @BuiltValueField(wireName: r'paid_by')
  int? get paidBy;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'paid_at')
  DateTime? get paidAt;

  /// Sum of the stored lines; 0 for a reopened month.
  @BuiltValueField(wireName: r'total')
  String get total;

  CommissionPeriodSummary._();

  factory CommissionPeriodSummary([
    void updates(CommissionPeriodSummaryBuilder b),
  ]) = _$CommissionPeriodSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionPeriodSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionPeriodSummary> get serializer =>
      _$CommissionPeriodSummarySerializer();
}

class _$CommissionPeriodSummarySerializer
    implements PrimitiveSerializer<CommissionPeriodSummary> {
  @override
  final Iterable<Type> types = const [
    CommissionPeriodSummary,
    _$CommissionPeriodSummary,
  ];

  @override
  final String wireName = r'CommissionPeriodSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionPeriodSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'year';
    yield serializers.serialize(
      object.year,
      specifiedType: const FullType(int),
    );
    yield r'month';
    yield serializers.serialize(
      object.month,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(CommissionPeriodSummaryStatusEnum),
    );
    yield r'closed_by';
    yield object.closedBy == null
        ? null
        : serializers.serialize(
            object.closedBy,
            specifiedType: const FullType.nullable(int),
          );
    yield r'closed_at';
    yield object.closedAt == null
        ? null
        : serializers.serialize(
            object.closedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'reopened_by';
    yield object.reopenedBy == null
        ? null
        : serializers.serialize(
            object.reopenedBy,
            specifiedType: const FullType.nullable(int),
          );
    yield r'reopened_at';
    yield object.reopenedAt == null
        ? null
        : serializers.serialize(
            object.reopenedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'paid_by';
    yield object.paidBy == null
        ? null
        : serializers.serialize(
            object.paidBy,
            specifiedType: const FullType.nullable(int),
          );
    yield r'paid_at';
    yield object.paidAt == null
        ? null
        : serializers.serialize(
            object.paidAt,
            specifiedType: const FullType.nullable(DateTime),
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
    CommissionPeriodSummary object, {
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
    required CommissionPeriodSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'year':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.year = valueDes;
          break;
        case r'month':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.month = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(
                      CommissionPeriodSummaryStatusEnum,
                    ),
                  )
                  as CommissionPeriodSummaryStatusEnum;
          result.status = valueDes;
          break;
        case r'closed_by':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.closedBy = valueDes;
          break;
        case r'closed_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.closedAt = valueDes;
          break;
        case r'reopened_by':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.reopenedBy = valueDes;
          break;
        case r'reopened_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.reopenedAt = valueDes;
          break;
        case r'paid_by':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.paidBy = valueDes;
          break;
        case r'paid_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.paidAt = valueDes;
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
  CommissionPeriodSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionPeriodSummaryBuilder();
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

class CommissionPeriodSummaryStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const CommissionPeriodSummaryStatusEnum open =
      _$commissionPeriodSummaryStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'closed')
  static const CommissionPeriodSummaryStatusEnum closed =
      _$commissionPeriodSummaryStatusEnum_closed;
  @BuiltValueEnumConst(wireName: r'paid')
  static const CommissionPeriodSummaryStatusEnum paid =
      _$commissionPeriodSummaryStatusEnum_paid;

  static Serializer<CommissionPeriodSummaryStatusEnum> get serializer =>
      _$commissionPeriodSummaryStatusEnumSerializer;

  const CommissionPeriodSummaryStatusEnum._(String name) : super(name);

  static BuiltSet<CommissionPeriodSummaryStatusEnum> get values =>
      _$commissionPeriodSummaryStatusEnumValues;
  static CommissionPeriodSummaryStatusEnum valueOf(String name) =>
      _$commissionPeriodSummaryStatusEnumValueOf(name);
}
