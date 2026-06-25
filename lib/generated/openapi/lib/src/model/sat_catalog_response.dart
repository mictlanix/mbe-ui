//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sat_catalog_response.g.dart';

/// SatCatalogResponse
///
/// Properties:
/// * [id] 
@BuiltValue()
abstract class SatCatalogResponse implements Built<SatCatalogResponse, SatCatalogResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  SatCatalogResponse._();

  factory SatCatalogResponse([void updates(SatCatalogResponseBuilder b)]) = _$SatCatalogResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SatCatalogResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SatCatalogResponse> get serializer => _$SatCatalogResponseSerializer();
}

class _$SatCatalogResponseSerializer implements PrimitiveSerializer<SatCatalogResponse> {
  @override
  final Iterable<Type> types = const [SatCatalogResponse, _$SatCatalogResponse];

  @override
  final String wireName = r'SatCatalogResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SatCatalogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SatCatalogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SatCatalogResponseBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SatCatalogResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SatCatalogResponseBuilder();
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

