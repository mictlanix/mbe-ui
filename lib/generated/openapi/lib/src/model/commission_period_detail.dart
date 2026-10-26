//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/commission_total_response.dart';
import 'package:mbe_api_client/src/model/commission_line_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_period_detail.g.dart';

/// A month as the report reads it (FR-012): final once closed, computed live while open.
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
/// * [final_]
/// * [totals]
/// * [lines]
@BuiltValue()
abstract class CommissionPeriodDetail
    implements Built<CommissionPeriodDetail, CommissionPeriodDetailBuilder> {
  @BuiltValueField(wireName: r'year')
  int get year;

  @BuiltValueField(wireName: r'month')
  int get month;

  @BuiltValueField(wireName: r'status')
  CommissionPeriodDetailStatusEnum get status;
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

  @BuiltValueField(wireName: r'final')
  bool get final_;

  @BuiltValueField(wireName: r'totals')
  BuiltList<CommissionTotalResponse> get totals;

  @BuiltValueField(wireName: r'lines')
  BuiltList<CommissionLineResponse> get lines;

  CommissionPeriodDetail._();

  factory CommissionPeriodDetail([
    void updates(CommissionPeriodDetailBuilder b),
  ]) = _$CommissionPeriodDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionPeriodDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionPeriodDetail> get serializer =>
      _$CommissionPeriodDetailSerializer();
}

class _$CommissionPeriodDetailSerializer
    implements PrimitiveSerializer<CommissionPeriodDetail> {
  @override
  final Iterable<Type> types = const [
    CommissionPeriodDetail,
    _$CommissionPeriodDetail,
  ];

  @override
  final String wireName = r'CommissionPeriodDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionPeriodDetail object, {
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
      specifiedType: const FullType(CommissionPeriodDetailStatusEnum),
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
    yield r'final';
    yield serializers.serialize(
      object.final_,
      specifiedType: const FullType(bool),
    );
    yield r'totals';
    yield serializers.serialize(
      object.totals,
      specifiedType: const FullType(BuiltList, [
        FullType(CommissionTotalResponse),
      ]),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [
        FullType(CommissionLineResponse),
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionPeriodDetail object, {
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
    required CommissionPeriodDetailBuilder result,
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
                      CommissionPeriodDetailStatusEnum,
                    ),
                  )
                  as CommissionPeriodDetailStatusEnum;
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
        case r'final':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.final_ = valueDes;
          break;
        case r'totals':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(CommissionTotalResponse),
                    ]),
                  )
                  as BuiltList<CommissionTotalResponse>;
          result.totals.replace(valueDes);
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(CommissionLineResponse),
                    ]),
                  )
                  as BuiltList<CommissionLineResponse>;
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
  CommissionPeriodDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionPeriodDetailBuilder();
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

class CommissionPeriodDetailStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const CommissionPeriodDetailStatusEnum open =
      _$commissionPeriodDetailStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'closed')
  static const CommissionPeriodDetailStatusEnum closed =
      _$commissionPeriodDetailStatusEnum_closed;
  @BuiltValueEnumConst(wireName: r'paid')
  static const CommissionPeriodDetailStatusEnum paid =
      _$commissionPeriodDetailStatusEnum_paid;

  static Serializer<CommissionPeriodDetailStatusEnum> get serializer =>
      _$commissionPeriodDetailStatusEnumSerializer;

  const CommissionPeriodDetailStatusEnum._(String name) : super(name);

  static BuiltSet<CommissionPeriodDetailStatusEnum> get values =>
      _$commissionPeriodDetailStatusEnumValues;
  static CommissionPeriodDetailStatusEnum valueOf(String name) =>
      _$commissionPeriodDetailStatusEnumValueOf(name);
}
