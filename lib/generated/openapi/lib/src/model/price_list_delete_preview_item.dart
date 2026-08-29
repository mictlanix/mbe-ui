//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'price_list_delete_preview_item.g.dart';

/// One relation referencing the list and how many of its rows do.  `category` is the `table.column` label the referential guard already uses, so a preview line and the 409 it predicts read the same. What the retirement *does* with each is in the contract, not here: `product_price.list` is deleted, `customer.price_list` is moved to the replacement, and anything else blocks.  Structurally identical to `ProductMergePreviewItem`, and deliberately not shared with it: reusing a merge-named component here would put it in a generated client's price-list call (the complaint in #175), and renaming that one to something neutral would break every current consumer of the merge preview. Worth unifying when a third caller appears.
///
/// Properties:
/// * [category]
/// * [count]
@BuiltValue()
abstract class PriceListDeletePreviewItem
    implements
        Built<PriceListDeletePreviewItem, PriceListDeletePreviewItemBuilder> {
  @BuiltValueField(wireName: r'category')
  String get category;

  @BuiltValueField(wireName: r'count')
  int get count;

  PriceListDeletePreviewItem._();

  factory PriceListDeletePreviewItem([
    void updates(PriceListDeletePreviewItemBuilder b),
  ]) = _$PriceListDeletePreviewItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PriceListDeletePreviewItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PriceListDeletePreviewItem> get serializer =>
      _$PriceListDeletePreviewItemSerializer();
}

class _$PriceListDeletePreviewItemSerializer
    implements PrimitiveSerializer<PriceListDeletePreviewItem> {
  @override
  final Iterable<Type> types = const [
    PriceListDeletePreviewItem,
    _$PriceListDeletePreviewItem,
  ];

  @override
  final String wireName = r'PriceListDeletePreviewItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PriceListDeletePreviewItem object, {
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
    PriceListDeletePreviewItem object, {
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
    required PriceListDeletePreviewItemBuilder result,
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
  PriceListDeletePreviewItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PriceListDeletePreviewItemBuilder();
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
