//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sat_unit_of_measurement_response.g.dart';

/// Full sat_unit_of_measurement record, used when embedding it as a product's unit_of_measurement FK (as opposed to the generic id/description shape used by the standalone /api/v1/sat/units-of-measurement endpoints).
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [description] 
/// * [symbol] 
@BuiltValue()
abstract class SatUnitOfMeasurementResponse implements Built<SatUnitOfMeasurementResponse, SatUnitOfMeasurementResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'symbol')
  String? get symbol;

  SatUnitOfMeasurementResponse._();

  factory SatUnitOfMeasurementResponse([void updates(SatUnitOfMeasurementResponseBuilder b)]) = _$SatUnitOfMeasurementResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SatUnitOfMeasurementResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SatUnitOfMeasurementResponse> get serializer => _$SatUnitOfMeasurementResponseSerializer();
}

class _$SatUnitOfMeasurementResponseSerializer implements PrimitiveSerializer<SatUnitOfMeasurementResponse> {
  @override
  final Iterable<Type> types = const [SatUnitOfMeasurementResponse, _$SatUnitOfMeasurementResponse];

  @override
  final String wireName = r'SatUnitOfMeasurementResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SatUnitOfMeasurementResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.symbol != null) {
      yield r'symbol';
      yield serializers.serialize(
        object.symbol,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SatUnitOfMeasurementResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SatUnitOfMeasurementResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'symbol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.symbol = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SatUnitOfMeasurementResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SatUnitOfMeasurementResponseBuilder();
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

