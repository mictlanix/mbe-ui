//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/in_transit_product.dart';
import 'package:mbe_api_client/src/model/in_transit_line.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'in_transit_response.g.dart';

/// InTransitResponse
///
/// Properties:
/// * [facility]
/// * [products]
/// * [lines]
@BuiltValue()
abstract class InTransitResponse
    implements Built<InTransitResponse, InTransitResponseBuilder> {
  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'products')
  BuiltList<InTransitProduct>? get products;

  @BuiltValueField(wireName: r'lines')
  BuiltList<InTransitLine>? get lines;

  InTransitResponse._();

  factory InTransitResponse([void updates(InTransitResponseBuilder b)]) =
      _$InTransitResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InTransitResponseBuilder b) => b
    ..products = ListBuilder()
    ..lines = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<InTransitResponse> get serializer =>
      _$InTransitResponseSerializer();
}

class _$InTransitResponseSerializer
    implements PrimitiveSerializer<InTransitResponse> {
  @override
  final Iterable<Type> types = const [InTransitResponse, _$InTransitResponse];

  @override
  final String wireName = r'InTransitResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InTransitResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    if (object.products != null) {
      yield r'products';
      yield serializers.serialize(
        object.products,
        specifiedType: const FullType(BuiltList, [FullType(InTransitProduct)]),
      );
    }
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [FullType(InTransitLine)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InTransitResponse object, {
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
    required InTransitResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'products':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(InTransitProduct),
                    ]),
                  )
                  as BuiltList<InTransitProduct>?;
          if (valueDes == null) continue;
          result.products.replace(valueDes);
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(InTransitLine),
                    ]),
                  )
                  as BuiltList<InTransitLine>?;
          if (valueDes == null) continue;
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
  InTransitResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InTransitResponseBuilder();
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
