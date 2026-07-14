//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_label_facet.g.dart';

/// ProductLabelFacet
///
/// Properties:
/// * [labelId] 
/// * [count] 
@BuiltValue()
abstract class ProductLabelFacet implements Built<ProductLabelFacet, ProductLabelFacetBuilder> {
  @BuiltValueField(wireName: r'label_id')
  int get labelId;

  @BuiltValueField(wireName: r'count')
  int get count;

  ProductLabelFacet._();

  factory ProductLabelFacet([void updates(ProductLabelFacetBuilder b)]) = _$ProductLabelFacet;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductLabelFacetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductLabelFacet> get serializer => _$ProductLabelFacetSerializer();
}

class _$ProductLabelFacetSerializer implements PrimitiveSerializer<ProductLabelFacet> {
  @override
  final Iterable<Type> types = const [ProductLabelFacet, _$ProductLabelFacet];

  @override
  final String wireName = r'ProductLabelFacet';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductLabelFacet object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'label_id';
    yield serializers.serialize(
      object.labelId,
      specifiedType: const FullType(int),
    );
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductLabelFacet object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductLabelFacetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'label_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.labelId = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductLabelFacet deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductLabelFacetBuilder();
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

