//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/taxpayer_certificate_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_taxpayer_certificate_response.g.dart';

/// ListResponseTaxpayerCertificateResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseTaxpayerCertificateResponse
    implements
        Built<
          ListResponseTaxpayerCertificateResponse,
          ListResponseTaxpayerCertificateResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<TaxpayerCertificateResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseTaxpayerCertificateResponse._();

  factory ListResponseTaxpayerCertificateResponse([
    void updates(ListResponseTaxpayerCertificateResponseBuilder b),
  ]) = _$ListResponseTaxpayerCertificateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseTaxpayerCertificateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseTaxpayerCertificateResponse> get serializer =>
      _$ListResponseTaxpayerCertificateResponseSerializer();
}

class _$ListResponseTaxpayerCertificateResponseSerializer
    implements PrimitiveSerializer<ListResponseTaxpayerCertificateResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseTaxpayerCertificateResponse,
    _$ListResponseTaxpayerCertificateResponse,
  ];

  @override
  final String wireName = r'ListResponseTaxpayerCertificateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseTaxpayerCertificateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(TaxpayerCertificateResponse),
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
    ListResponseTaxpayerCertificateResponse object, {
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
    required ListResponseTaxpayerCertificateResponseBuilder result,
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
                      FullType(TaxpayerCertificateResponse),
                    ]),
                  )
                  as BuiltList<TaxpayerCertificateResponse>;
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
  ListResponseTaxpayerCertificateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseTaxpayerCertificateResponseBuilder();
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
