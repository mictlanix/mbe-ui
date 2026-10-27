//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/purchase_request_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_purchase_request_summary.g.dart';

/// ListResponsePurchaseRequestSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponsePurchaseRequestSummary
    implements
        Built<
          ListResponsePurchaseRequestSummary,
          ListResponsePurchaseRequestSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<PurchaseRequestSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponsePurchaseRequestSummary._();

  factory ListResponsePurchaseRequestSummary([
    void updates(ListResponsePurchaseRequestSummaryBuilder b),
  ]) = _$ListResponsePurchaseRequestSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponsePurchaseRequestSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponsePurchaseRequestSummary> get serializer =>
      _$ListResponsePurchaseRequestSummarySerializer();
}

class _$ListResponsePurchaseRequestSummarySerializer
    implements PrimitiveSerializer<ListResponsePurchaseRequestSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponsePurchaseRequestSummary,
    _$ListResponsePurchaseRequestSummary,
  ];

  @override
  final String wireName = r'ListResponsePurchaseRequestSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponsePurchaseRequestSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(PurchaseRequestSummary),
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
    ListResponsePurchaseRequestSummary object, {
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
    required ListResponsePurchaseRequestSummaryBuilder result,
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
                      FullType(PurchaseRequestSummary),
                    ]),
                  )
                  as BuiltList<PurchaseRequestSummary>;
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
  ListResponsePurchaseRequestSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponsePurchaseRequestSummaryBuilder();
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
