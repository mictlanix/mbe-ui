//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_merge_request.g.dart';

/// ProductMergeRequest
///
/// Properties:
/// * [productId]
/// * [duplicateId]
@BuiltValue()
abstract class ProductMergeRequest
    implements Built<ProductMergeRequest, ProductMergeRequestBuilder> {
  @BuiltValueField(wireName: r'product_id')
  int get productId;

  @BuiltValueField(wireName: r'duplicate_id')
  int get duplicateId;

  ProductMergeRequest._();

  factory ProductMergeRequest([void updates(ProductMergeRequestBuilder b)]) =
      _$ProductMergeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductMergeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductMergeRequest> get serializer =>
      _$ProductMergeRequestSerializer();
}

class _$ProductMergeRequestSerializer
    implements PrimitiveSerializer<ProductMergeRequest> {
  @override
  final Iterable<Type> types = const [
    ProductMergeRequest,
    _$ProductMergeRequest,
  ];

  @override
  final String wireName = r'ProductMergeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductMergeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product_id';
    yield serializers.serialize(
      object.productId,
      specifiedType: const FullType(int),
    );
    yield r'duplicate_id';
    yield serializers.serialize(
      object.duplicateId,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductMergeRequest object, {
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
    required ProductMergeRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.productId = valueDes;
          break;
        case r'duplicate_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.duplicateId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductMergeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductMergeRequestBuilder();
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
