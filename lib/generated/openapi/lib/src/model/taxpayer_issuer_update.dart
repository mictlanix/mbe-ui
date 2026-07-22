//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/fiscal_certification_provider.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxpayer_issuer_update.g.dart';

/// TaxpayerIssuerUpdate
///
/// Properties:
/// * [name]
/// * [regime]
/// * [provider]
/// * [postalCode]
/// * [comment]
@BuiltValue()
abstract class TaxpayerIssuerUpdate
    implements Built<TaxpayerIssuerUpdate, TaxpayerIssuerUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'regime')
  String? get regime;

  @BuiltValueField(wireName: r'provider')
  FiscalCertificationProvider? get provider;
  // enum providerEnum {  0,  1,  2,  3,  4,  };

  @BuiltValueField(wireName: r'postal_code')
  String? get postalCode;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  TaxpayerIssuerUpdate._();

  factory TaxpayerIssuerUpdate([void updates(TaxpayerIssuerUpdateBuilder b)]) =
      _$TaxpayerIssuerUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxpayerIssuerUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxpayerIssuerUpdate> get serializer =>
      _$TaxpayerIssuerUpdateSerializer();
}

class _$TaxpayerIssuerUpdateSerializer
    implements PrimitiveSerializer<TaxpayerIssuerUpdate> {
  @override
  final Iterable<Type> types = const [
    TaxpayerIssuerUpdate,
    _$TaxpayerIssuerUpdate,
  ];

  @override
  final String wireName = r'TaxpayerIssuerUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxpayerIssuerUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.regime != null) {
      yield r'regime';
      yield serializers.serialize(
        object.regime,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType.nullable(FiscalCertificationProvider),
      );
    }
    if (object.postalCode != null) {
      yield r'postal_code';
      yield serializers.serialize(
        object.postalCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxpayerIssuerUpdate object, {
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
    required TaxpayerIssuerUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.regime = valueDes;
          break;
        case r'provider':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      FiscalCertificationProvider,
                    ),
                  )
                  as FiscalCertificationProvider?;
          if (valueDes == null) continue;
          result.provider = valueDes;
          break;
        case r'postal_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.postalCode = valueDes;
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
  TaxpayerIssuerUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxpayerIssuerUpdateBuilder();
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
