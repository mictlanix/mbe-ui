//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/analytics_dimension.dart';
import 'package:mbe_api_client/src/model/analytics_measure.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_catalog_response.g.dart';

/// AnalyticsCatalogResponse
///
/// Properties:
/// * [asOf] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [measures]
/// * [dimensions]
@BuiltValue()
abstract class AnalyticsCatalogResponse
    implements
        Built<AnalyticsCatalogResponse, AnalyticsCatalogResponseBuilder> {
  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'as_of')
  DateTime get asOf;

  @BuiltValueField(wireName: r'measures')
  BuiltList<AnalyticsMeasure> get measures;

  @BuiltValueField(wireName: r'dimensions')
  BuiltList<AnalyticsDimension> get dimensions;

  AnalyticsCatalogResponse._();

  factory AnalyticsCatalogResponse([
    void updates(AnalyticsCatalogResponseBuilder b),
  ]) = _$AnalyticsCatalogResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsCatalogResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsCatalogResponse> get serializer =>
      _$AnalyticsCatalogResponseSerializer();
}

class _$AnalyticsCatalogResponseSerializer
    implements PrimitiveSerializer<AnalyticsCatalogResponse> {
  @override
  final Iterable<Type> types = const [
    AnalyticsCatalogResponse,
    _$AnalyticsCatalogResponse,
  ];

  @override
  final String wireName = r'AnalyticsCatalogResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsCatalogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'as_of';
    yield serializers.serialize(
      object.asOf,
      specifiedType: const FullType(DateTime),
    );
    yield r'measures';
    yield serializers.serialize(
      object.measures,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsMeasure)]),
    );
    yield r'dimensions';
    yield serializers.serialize(
      object.dimensions,
      specifiedType: const FullType(BuiltList, [FullType(AnalyticsDimension)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsCatalogResponse object, {
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
    required AnalyticsCatalogResponseBuilder result,
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
        case r'measures':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsMeasure),
                    ]),
                  )
                  as BuiltList<AnalyticsMeasure>;
          result.measures.replace(valueDes);
          break;
        case r'dimensions':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AnalyticsDimension),
                    ]),
                  )
                  as BuiltList<AnalyticsDimension>;
          result.dimensions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsCatalogResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsCatalogResponseBuilder();
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
