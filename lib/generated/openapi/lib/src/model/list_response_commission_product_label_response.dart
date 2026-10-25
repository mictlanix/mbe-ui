//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/commission_product_label_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_commission_product_label_response.g.dart';

/// ListResponseCommissionProductLabelResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseCommissionProductLabelResponse
    implements
        Built<
          ListResponseCommissionProductLabelResponse,
          ListResponseCommissionProductLabelResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<CommissionProductLabelResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseCommissionProductLabelResponse._();

  factory ListResponseCommissionProductLabelResponse([
    void updates(ListResponseCommissionProductLabelResponseBuilder b),
  ]) = _$ListResponseCommissionProductLabelResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseCommissionProductLabelResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseCommissionProductLabelResponse>
  get serializer => _$ListResponseCommissionProductLabelResponseSerializer();
}

class _$ListResponseCommissionProductLabelResponseSerializer
    implements PrimitiveSerializer<ListResponseCommissionProductLabelResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseCommissionProductLabelResponse,
    _$ListResponseCommissionProductLabelResponse,
  ];

  @override
  final String wireName = r'ListResponseCommissionProductLabelResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseCommissionProductLabelResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(CommissionProductLabelResponse),
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
    ListResponseCommissionProductLabelResponse object, {
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
    required ListResponseCommissionProductLabelResponseBuilder result,
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
                      FullType(CommissionProductLabelResponse),
                    ]),
                  )
                  as BuiltList<CommissionProductLabelResponse>;
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
  ListResponseCommissionProductLabelResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseCommissionProductLabelResponseBuilder();
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
