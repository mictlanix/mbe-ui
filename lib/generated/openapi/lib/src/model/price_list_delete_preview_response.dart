//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/price_list_delete_preview_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'price_list_delete_preview_response.g.dart';

/// PriceListDeletePreviewResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class PriceListDeletePreviewResponse
    implements
        Built<
          PriceListDeletePreviewResponse,
          PriceListDeletePreviewResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<PriceListDeletePreviewItem> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  PriceListDeletePreviewResponse._();

  factory PriceListDeletePreviewResponse([
    void updates(PriceListDeletePreviewResponseBuilder b),
  ]) = _$PriceListDeletePreviewResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PriceListDeletePreviewResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PriceListDeletePreviewResponse> get serializer =>
      _$PriceListDeletePreviewResponseSerializer();
}

class _$PriceListDeletePreviewResponseSerializer
    implements PrimitiveSerializer<PriceListDeletePreviewResponse> {
  @override
  final Iterable<Type> types = const [
    PriceListDeletePreviewResponse,
    _$PriceListDeletePreviewResponse,
  ];

  @override
  final String wireName = r'PriceListDeletePreviewResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PriceListDeletePreviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(PriceListDeletePreviewItem),
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
    PriceListDeletePreviewResponse object, {
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
    required PriceListDeletePreviewResponseBuilder result,
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
                      FullType(PriceListDeletePreviewItem),
                    ]),
                  )
                  as BuiltList<PriceListDeletePreviewItem>;
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
  PriceListDeletePreviewResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PriceListDeletePreviewResponseBuilder();
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
