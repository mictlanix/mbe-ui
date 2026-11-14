//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_kardex_row.dart';
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_kardex_response.g.dart';

/// AnalyticsKardexResponse
///
/// Properties:
/// * [asOf] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [product]
/// * [warehouse]
/// * [start]
/// * [end]
/// * [opening] - The balance before start.
/// * [unitCost] - Today's list-0 cost, without VAT. Cost privilege only, absent otherwise; null when uncosted (0, or at least the placeholder).
/// * [rows]
/// * [total]
/// * [closing] - The balance at the end of end.
@BuiltValue()
abstract class AnalyticsKardexResponse
    implements Built<AnalyticsKardexResponse, AnalyticsKardexResponseBuilder> {
  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'as_of')
  DateTime get asOf;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'start')
  Date get start;

  @BuiltValueField(wireName: r'end')
  Date get end;

  /// The balance before start.
  @BuiltValueField(wireName: r'opening')
  String get opening;

  /// Today's list-0 cost, without VAT. Cost privilege only, absent otherwise; null when uncosted (0, or at least the placeholder).
  @BuiltValueField(wireName: r'unit_cost')
  String? get unitCost;

  @BuiltValueField(wireName: r'rows')
  BuiltList<AnalyticsKardexRow> get rows;

  @BuiltValueField(wireName: r'total')
  int get total;

  /// The balance at the end of end.
  @BuiltValueField(wireName: r'closing')
  String get closing;

  AnalyticsKardexResponse._();

  factory AnalyticsKardexResponse([
    void updates(AnalyticsKardexResponseBuilder b),
  ]) = _$AnalyticsKardexResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsKardexResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsKardexResponse> get serializer =>
      _$AnalyticsKardexResponseSerializer();
}

class _$AnalyticsKardexResponseSerializer
    implements PrimitiveSerializer<AnalyticsKardexResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsKardexResponse,
    _$AnalyticsKardexResponse,
  ];

  @override
  final String wireName = r'AnalyticsKardexResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsKardexResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'as_of';
    yield serializers.serialize(
      object.asOf,
      specifiedType: const FullType(DateTime),
    );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
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
    yield r'opening';
    yield serializers.serialize(
      object.opening,
      specifiedType: const FullType(String),
    );
    if (object.unitCost != null) {
      yield r'unit_cost';
      yield serializers.serialize(
        object.unitCost,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'rows';
    yield serializers.serialize(
      object.rows,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsKardexRow)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'closing';
    yield serializers.serialize(
      object.closing,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsKardexResponse object, {
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
    required AnalyticsKardexResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'as_of':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.asOf = valueDes;
          break;
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
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
        case r'opening':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.opening = valueDes;
          break;
        case r'unit_cost':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.unitCost = valueDes;
          break;
        case r'rows':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsKardexRow),
                    ]),
                  )
                  as BuiltList<AnalyticsKardexRow>;
          result.rows.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        case r'closing':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.closing = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsKardexResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsKardexResponseBuilder();
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
