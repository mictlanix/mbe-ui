//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxpayer_certificate_response.g.dart';

/// Metadata only. `certificate_data`, `key_data` and `key_password` hold the uploaded CSD binaries and its raw password, and are never returned by the API.
///
/// Properties:
/// * [taxpayerCertificateId]
/// * [taxpayer]
/// * [validFrom]
/// * [validTo]
/// * [status]
@BuiltValue()
abstract class TaxpayerCertificateResponse
    implements
        Built<TaxpayerCertificateResponse, TaxpayerCertificateResponseBuilder> {
  @BuiltValueField(wireName: r'taxpayer_certificate_id')
  String get taxpayerCertificateId;

  @BuiltValueField(wireName: r'taxpayer')
  String get taxpayer;

  @BuiltValueField(wireName: r'valid_from')
  DateTime get validFrom;

  @BuiltValueField(wireName: r'valid_to')
  DateTime get validTo;

  @BuiltValueField(wireName: r'status')
  EntityStatus get status;
  // enum statusEnum {  0,  1,  2,  };

  TaxpayerCertificateResponse._();

  factory TaxpayerCertificateResponse([
    void updates(TaxpayerCertificateResponseBuilder b),
  ]) = _$TaxpayerCertificateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxpayerCertificateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxpayerCertificateResponse> get serializer =>
      _$TaxpayerCertificateResponseSerializer();
}

class _$TaxpayerCertificateResponseSerializer
    implements PrimitiveSerializer<TaxpayerCertificateResponse> {
  @override
  final Iterable<Type> types = const [
    TaxpayerCertificateResponse,
    _$TaxpayerCertificateResponse,
  ];

  @override
  final String wireName = r'TaxpayerCertificateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxpayerCertificateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxpayer_certificate_id';
    yield serializers.serialize(
      object.taxpayerCertificateId,
      specifiedType: const FullType(String),
    );
    yield r'taxpayer';
    yield serializers.serialize(
      object.taxpayer,
      specifiedType: const FullType(String),
    );
    yield r'valid_from';
    yield serializers.serialize(
      object.validFrom,
      specifiedType: const FullType(DateTime),
    );
    yield r'valid_to';
    yield serializers.serialize(
      object.validTo,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EntityStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxpayerCertificateResponse object, {
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
    required TaxpayerCertificateResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taxpayer_certificate_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.taxpayerCertificateId = valueDes;
          break;
        case r'taxpayer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.taxpayer = valueDes;
          break;
        case r'valid_from':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.validFrom = valueDes;
          break;
        case r'valid_to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.validTo = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(EntityStatus),
                  )
                  as EntityStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxpayerCertificateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxpayerCertificateResponseBuilder();
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
