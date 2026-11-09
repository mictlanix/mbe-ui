//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/detail_kind.dart';
import 'package:mbe_api_client/src/model/detail_flag.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_filter.dart';
import 'package:mbe_api_client/src/model/vat_treatment.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_detail_request.g.dart';

/// AnalyticsDetailRequest
///
/// Properties:
/// * [kind]
/// * [start]
/// * [end]
/// * [facility]
/// * [filters]
/// * [flag] - overdue (orders) | below_cost, without_cost (lines, cost privilege) | collected, paid_out, store_credit (payments)
/// * [vat]
/// * [sort] - date | amount | document; \"-\" = descending (default -date)
/// * [skip]
/// * [limit]
@BuiltValue()
abstract class AnalyticsDetailRequest
    implements Built<AnalyticsDetailRequest, AnalyticsDetailRequestBuilder> {
  @BuiltValueField(wireName: r'kind')
  DetailKind get kind;
  // enum kindEnum {  orders,  lines,  refunds,  credit_notes,  payments,  };

  @BuiltValueField(wireName: r'start')
  Date get start;

  @BuiltValueField(wireName: r'end')
  Date get end;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'filters')
  BuiltList<AnalyticsFilter>? get filters;

  /// overdue (orders) | below_cost, without_cost (lines, cost privilege) | collected, paid_out, store_credit (payments)
  @BuiltValueField(wireName: r'flag')
  DetailFlag? get flag;
  // enum flagEnum {  overdue,  below_cost,  without_cost,  collected,  paid_out,  store_credit,  };

  @BuiltValueField(wireName: r'vat')
  VatTreatment? get vat;
  // enum vatEnum {  excluded,  included,  };

  /// date | amount | document; \"-\" = descending (default -date)
  @BuiltValueField(wireName: r'sort')
  String? get sort;

  @BuiltValueField(wireName: r'skip')
  int? get skip;

  @BuiltValueField(wireName: r'limit')
  int? get limit;

  AnalyticsDetailRequest._();

  factory AnalyticsDetailRequest([
    void updates(AnalyticsDetailRequestBuilder b),
  ]) = _$AnalyticsDetailRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsDetailRequestBuilder b) => b
    ..filters = ListBuilder()
    ..vat = VatTreatment.excluded
    ..skip = 0
    ..limit = 20;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsDetailRequest> get serializer =>
      _$AnalyticsDetailRequestSerializer();
}

class _$AnalyticsDetailRequestSerializer
    implements PrimitiveSerializer<AnalyticsDetailRequest> {
  @override
  final Iterable<Type> types = const [
    AnalyticsDetailRequest,
    _$AnalyticsDetailRequest,
  ];

  @override
  final String wireName = r'AnalyticsDetailRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsDetailRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(DetailKind),
    );
    yield r'start';
    yield serializers.serialize(
      object.start,
      specifiedType: const FullType(Date),
    );
    yield r'end';
    yield serializers.serialize(
      object.end,
      specifiedType: const FullType(Date),
    );
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.filters != null) {
      yield r'filters';
      yield serializers.serialize(
        object.filters,
        specifiedType: const FullType(BuiltList, [FullType(AnalyticsFilter)]),
      );
    }
    if (object.flag != null) {
      yield r'flag';
      yield serializers.serialize(
        object.flag,
        specifiedType: const FullType.nullable(DetailFlag),
      );
    }
    if (object.vat != null) {
      yield r'vat';
      yield serializers.serialize(
        object.vat,
        specifiedType: const FullType(VatTreatment),
      );
    }
    if (object.sort != null) {
      yield r'sort';
      yield serializers.serialize(
        object.sort,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.skip != null) {
      yield r'skip';
      yield serializers.serialize(
        object.skip,
        specifiedType: const FullType(int),
      );
    }
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsDetailRequest object, {
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
    required AnalyticsDetailRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DetailKind),
                  )
                  as DetailKind;
          result.kind = valueDes;
          break;
        case r'start':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.start = valueDes;
          break;
        case r'end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.end = valueDes;
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
        case r'filters':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(AnalyticsFilter),
                    ]),
                  )
                  as BuiltList<AnalyticsFilter>?;
          if (valueDes == null) continue;
          result.filters.replace(valueDes);
          break;
        case r'flag':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DetailFlag),
                  )
                  as DetailFlag?;
          if (valueDes == null) continue;
          result.flag = valueDes;
          break;
        case r'vat':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(VatTreatment),
                  )
                  as VatTreatment?;
          if (valueDes == null) continue;
          result.vat = valueDes;
          break;
        case r'sort':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.sort = valueDes;
          break;
        case r'skip':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.skip = valueDes;
          break;
        case r'limit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.limit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsDetailRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsDetailRequestBuilder();
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
