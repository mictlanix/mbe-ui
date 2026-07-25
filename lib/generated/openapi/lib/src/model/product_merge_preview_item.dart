//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_merge_preview_item.g.dart';

/// One referencing relation and how many of its rows point at the duplicate.  `category` is the `table.column` label the referential guard already uses, so the same vocabulary appears in a merge preview and in a delete conflict.
///
/// Properties:
/// * [category]
/// * [count]
@BuiltValue()
abstract class ProductMergePreviewItem
    implements Built<ProductMergePreviewItem, ProductMergePreviewItemBuilder> {
  @BuiltValueField(wireName: r'category')
  String get category;

  @BuiltValueField(wireName: r'count')
  int get count;

  ProductMergePreviewItem._();

  factory ProductMergePreviewItem([
    void updates(ProductMergePreviewItemBuilder b),
  ]) = _$ProductMergePreviewItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductMergePreviewItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductMergePreviewItem> get serializer =>
      _$ProductMergePreviewItemSerializer();
}

class _$ProductMergePreviewItemSerializer
    implements PrimitiveSerializer<ProductMergePreviewItem> {
  @override
  final Iterable<Type> types = const [
    ProductMergePreviewItem,
    _$ProductMergePreviewItem,
  ];

  @override
  final String wireName = r'ProductMergePreviewItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductMergePreviewItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(String),
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
    ProductMergePreviewItem object, {
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
    required ProductMergePreviewItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.category = valueDes;
          break;
        case r'count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
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
  ProductMergePreviewItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductMergePreviewItemBuilder();
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
