//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/measure_key.dart';
import 'package:mbe_api_client/src/model/comparison.dart';
import 'package:mbe_api_client/src/model/stock_options.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/analytics_filter.dart';
import 'package:mbe_api_client/src/model/dimension_key.dart';
import 'package:mbe_api_client/src/model/grain.dart';
import 'package:mbe_api_client/src/model/vat_treatment.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_query_request.g.dart';

/// AnalyticsQueryRequest
///
/// Properties:
/// * [measures]
/// * [dimensions] - Up to three.
/// * [grain]
/// * [start]
/// * [end] - Inclusive; at most five years after start.
/// * [facility] - One facility. Omitted: the caller's own, or every facility for callers who may see them all (administrators and holders of 101).
/// * [filters]
/// * [comparison]
/// * [vat]
/// * [sort] - A requested measure or dimension key; \"-\" prefix = descending.
/// * [top]
/// * [stockOptions] - Inventory measures only; omitted gives the defaults.
@BuiltValue()
abstract class AnalyticsQueryRequest
    implements Built<AnalyticsQueryRequest, AnalyticsQueryRequestBuilder> {
  @BuiltValueField(wireName: r'measures')
  BuiltList<MeasureKey> get measures;

  /// Up to three.
  @BuiltValueField(wireName: r'dimensions')
  BuiltList<DimensionKey>? get dimensions;

  @BuiltValueField(wireName: r'grain')
  Grain? get grain;
  // enum grainEnum {  day,  week,  month,  quarter,  year,  };

  @BuiltValueField(wireName: r'start')
  Date get start;

  /// Inclusive; at most five years after start.
  @BuiltValueField(wireName: r'end')
  Date get end;

  /// One facility. Omitted: the caller's own, or every facility for callers who may see them all (administrators and holders of 101).
  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'filters')
  BuiltList<AnalyticsFilter>? get filters;

  @BuiltValueField(wireName: r'comparison')
  Comparison? get comparison;
  // enum comparisonEnum {  previous_period,  same_period_last_year,  };

  @BuiltValueField(wireName: r'vat')
  VatTreatment? get vat;
  // enum vatEnum {  excluded,  included,  };

  /// A requested measure or dimension key; \"-\" prefix = descending.
  @BuiltValueField(wireName: r'sort')
  String? get sort;

  @BuiltValueField(wireName: r'top')
  int? get top;

  /// Inventory measures only; omitted gives the defaults.
  @BuiltValueField(wireName: r'stock_options')
  StockOptions? get stockOptions;

  AnalyticsQueryRequest._();

  factory AnalyticsQueryRequest([
    void updates(AnalyticsQueryRequestBuilder b),
  ]) = _$AnalyticsQueryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsQueryRequestBuilder b) => b
    ..dimensions = ListBuilder()
    ..grain = Grain.day
    ..filters = ListBuilder()
    ..vat = VatTreatment.excluded;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsQueryRequest> get serializer =>
      _$AnalyticsQueryRequestSerializer();
}

class _$AnalyticsQueryRequestSerializer
    implements PrimitiveSerializer<AnalyticsQueryRequest> {
  @override
  final Iterable<Type> types = const [
    AnalyticsQueryRequest,
    _$AnalyticsQueryRequest,
  ];

  @override
  final String wireName = r'AnalyticsQueryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsQueryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'measures';
    yield serializers.serialize(
      object.measures,
      specifiedType: const FullType(BuiltList, [FullType(MeasureKey)]),
    );
    if (object.dimensions != null) {
      yield r'dimensions';
      yield serializers.serialize(
        object.dimensions,
        specifiedType: const FullType(BuiltList, [FullType(DimensionKey)]),
      );
    }
    if (object.grain != null) {
      yield r'grain';
      yield serializers.serialize(
        object.grain,
        specifiedType: const FullType(Grain),
      );
    }
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
    if (object.comparison != null) {
      yield r'comparison';
      yield serializers.serialize(
        object.comparison,
        specifiedType: const FullType.nullable(Comparison),
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
    if (object.top != null) {
      yield r'top';
      yield serializers.serialize(
        object.top,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.stockOptions != null) {
      yield r'stock_options';
      yield serializers.serialize(
        object.stockOptions,
        specifiedType: const FullType.nullable(StockOptions),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsQueryRequest object, {
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
    required AnalyticsQueryRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'measures':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(MeasureKey),
                    ]),
                  )
                  as BuiltList<MeasureKey>;
          result.measures.replace(valueDes);
          break;
        case r'dimensions':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(DimensionKey),
                    ]),
                  )
                  as BuiltList<DimensionKey>?;
          if (valueDes == null) continue;
          result.dimensions.replace(valueDes);
          break;
        case r'grain':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Grain),
                  )
                  as Grain?;
          if (valueDes == null) continue;
          result.grain = valueDes;
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
        case r'comparison':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Comparison),
                  )
                  as Comparison?;
          if (valueDes == null) continue;
          result.comparison = valueDes;
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
        case r'top':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.top = valueDes;
          break;
        case r'stock_options':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(StockOptions),
                  )
                  as StockOptions?;
          if (valueDes == null) continue;
          result.stockOptions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsQueryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsQueryRequestBuilder();
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
