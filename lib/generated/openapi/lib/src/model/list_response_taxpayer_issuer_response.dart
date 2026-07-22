//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/taxpayer_issuer_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_taxpayer_issuer_response.g.dart';

/// ListResponseTaxpayerIssuerResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseTaxpayerIssuerResponse
    implements
        Built<
          ListResponseTaxpayerIssuerResponse,
          ListResponseTaxpayerIssuerResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<TaxpayerIssuerResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseTaxpayerIssuerResponse._();

  factory ListResponseTaxpayerIssuerResponse([
    void updates(ListResponseTaxpayerIssuerResponseBuilder b),
  ]) = _$ListResponseTaxpayerIssuerResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseTaxpayerIssuerResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseTaxpayerIssuerResponse> get serializer =>
      _$ListResponseTaxpayerIssuerResponseSerializer();
}

class _$ListResponseTaxpayerIssuerResponseSerializer
    implements PrimitiveSerializer<ListResponseTaxpayerIssuerResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseTaxpayerIssuerResponse,
    _$ListResponseTaxpayerIssuerResponse,
  ];

  @override
  final String wireName = r'ListResponseTaxpayerIssuerResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseTaxpayerIssuerResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(TaxpayerIssuerResponse),
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
    ListResponseTaxpayerIssuerResponse object, {
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
    required ListResponseTaxpayerIssuerResponseBuilder result,
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
                      FullType(TaxpayerIssuerResponse),
                    ]),
                  )
                  as BuiltList<TaxpayerIssuerResponse>;
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
  ListResponseTaxpayerIssuerResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseTaxpayerIssuerResponseBuilder();
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
