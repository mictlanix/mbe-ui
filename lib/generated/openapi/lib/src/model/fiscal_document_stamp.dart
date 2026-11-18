//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_document_stamp.g.dart';

/// The PAC's stamp (spec 039). `stamped` repeats the top-level field, so this is complete on its own; `simulated` is true when the simulated PAC stamped it.
///
/// Properties:
/// * [uuid]
/// * [stamped] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [satCertificate]
/// * [providerRfc]
/// * [simulated]
@BuiltValue()
abstract class FiscalDocumentStamp
    implements Built<FiscalDocumentStamp, FiscalDocumentStampBuilder> {
  @BuiltValueField(wireName: r'uuid')
  String get uuid;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'stamped')
  DateTime? get stamped;

  @BuiltValueField(wireName: r'sat_certificate')
  String? get satCertificate;

  @BuiltValueField(wireName: r'provider_rfc')
  String? get providerRfc;

  @BuiltValueField(wireName: r'simulated')
  bool get simulated;

  FiscalDocumentStamp._();

  factory FiscalDocumentStamp([void updates(FiscalDocumentStampBuilder b)]) =
      _$FiscalDocumentStamp;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FiscalDocumentStampBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FiscalDocumentStamp> get serializer =>
      _$FiscalDocumentStampSerializer();
}

class _$FiscalDocumentStampSerializer
    implements PrimitiveSerializer<FiscalDocumentStamp> {
  @override
  final Iterable<Type> types = const [
    FiscalDocumentStamp,
    _$FiscalDocumentStamp,
  ];

  @override
  final String wireName = r'FiscalDocumentStamp';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FiscalDocumentStamp object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'uuid';
    yield serializers.serialize(
      object.uuid,
      specifiedType: const FullType(String),
    );
    yield r'stamped';
    yield object.stamped == null
        ? null
        : serializers.serialize(
            object.stamped,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'sat_certificate';
    yield object.satCertificate == null
        ? null
        : serializers.serialize(
            object.satCertificate,
            specifiedType: const FullType.nullable(String),
          );
    yield r'provider_rfc';
    yield object.providerRfc == null
        ? null
        : serializers.serialize(
            object.providerRfc,
            specifiedType: const FullType.nullable(String),
          );
    yield r'simulated';
    yield serializers.serialize(
      object.simulated,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FiscalDocumentStamp object, {
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
    required FiscalDocumentStampBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'uuid':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.uuid = valueDes;
          break;
        case r'stamped':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.stamped = valueDes;
          break;
        case r'sat_certificate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.satCertificate = valueDes;
          break;
        case r'provider_rfc':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.providerRfc = valueDes;
          break;
        case r'simulated':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.simulated = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FiscalDocumentStamp deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FiscalDocumentStampBuilder();
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
