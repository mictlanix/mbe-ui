//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/product_merge_preview_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_merge_preview_response.g.dart';

/// ProductMergePreviewResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ProductMergePreviewResponse
    implements
        Built<ProductMergePreviewResponse, ProductMergePreviewResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ProductMergePreviewItem> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ProductMergePreviewResponse._();

  factory ProductMergePreviewResponse([
    void updates(ProductMergePreviewResponseBuilder b),
  ]) = _$ProductMergePreviewResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductMergePreviewResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductMergePreviewResponse> get serializer =>
      _$ProductMergePreviewResponseSerializer();
}

class _$ProductMergePreviewResponseSerializer
    implements PrimitiveSerializer<ProductMergePreviewResponse> {
  @override
  final Iterable<Type> types = const [
    ProductMergePreviewResponse,
    _$ProductMergePreviewResponse,
  ];

  @override
  final String wireName = r'ProductMergePreviewResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductMergePreviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(ProductMergePreviewItem),
      ]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductMergePreviewResponse object, {
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
    required ProductMergePreviewResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(ProductMergePreviewItem),
                    ]),
                  )
                  as BuiltList<ProductMergePreviewItem>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductMergePreviewResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductMergePreviewResponseBuilder();
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
