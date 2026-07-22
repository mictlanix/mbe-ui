//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/sat_catalog_response.dart';
import 'package:mbe_api_client/src/model/fiscal_certification_provider.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxpayer_issuer_response.g.dart';

/// TaxpayerIssuerResponse
///
/// Properties:
/// * [taxpayerIssuerId]
/// * [name]
/// * [regime]
/// * [provider]
/// * [postalCode]
/// * [comment]
@BuiltValue()
abstract class TaxpayerIssuerResponse
    implements Built<TaxpayerIssuerResponse, TaxpayerIssuerResponseBuilder> {
  @BuiltValueField(wireName: r'taxpayer_issuer_id')
  String get taxpayerIssuerId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'regime')
  SatCatalogResponse? get regime;

  @BuiltValueField(wireName: r'provider')
  FiscalCertificationProvider get provider;
  // enum providerEnum {  0,  1,  2,  3,  4,  };

  @BuiltValueField(wireName: r'postal_code')
  SatCatalogResponse? get postalCode;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  TaxpayerIssuerResponse._();

  factory TaxpayerIssuerResponse([
    void updates(TaxpayerIssuerResponseBuilder b),
  ]) = _$TaxpayerIssuerResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxpayerIssuerResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxpayerIssuerResponse> get serializer =>
      _$TaxpayerIssuerResponseSerializer();
}

class _$TaxpayerIssuerResponseSerializer
    implements PrimitiveSerializer<TaxpayerIssuerResponse> {
  @override
  final Iterable<Type> types = const [
    TaxpayerIssuerResponse,
    _$TaxpayerIssuerResponse,
  ];

  @override
  final String wireName = r'TaxpayerIssuerResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxpayerIssuerResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxpayer_issuer_id';
    yield serializers.serialize(
      object.taxpayerIssuerId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null
        ? null
        : serializers.serialize(
            object.name,
            specifiedType: const FullType.nullable(String),
          );
    yield r'regime';
    yield object.regime == null
        ? null
        : serializers.serialize(
            object.regime,
            specifiedType: const FullType.nullable(SatCatalogResponse),
          );
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(FiscalCertificationProvider),
    );
    yield r'postal_code';
    yield object.postalCode == null
        ? null
        : serializers.serialize(
            object.postalCode,
            specifiedType: const FullType.nullable(SatCatalogResponse),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxpayerIssuerResponse object, {
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
    required TaxpayerIssuerResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taxpayer_issuer_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.taxpayerIssuerId = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'regime':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(SatCatalogResponse),
                  )
                  as SatCatalogResponse?;
          if (valueDes == null) continue;
          result.regime.replace(valueDes);
          break;
        case r'provider':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(FiscalCertificationProvider),
                  )
                  as FiscalCertificationProvider;
          result.provider = valueDes;
          break;
        case r'postal_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(SatCatalogResponse),
                  )
                  as SatCatalogResponse?;
          if (valueDes == null) continue;
          result.postalCode.replace(valueDes);
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxpayerIssuerResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxpayerIssuerResponseBuilder();
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
