//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_document_relation_response.g.dart';

/// A related stamped document. `type` is the SAT code; legacy stores cfdlib's enum number.
///
/// Properties:
/// * [fiscalDocumentRelationId]
/// * [relation]
/// * [type]
/// * [stampUuid]
/// * [batch]
/// * [serial]
@BuiltValue()
abstract class FiscalDocumentRelationResponse
    implements
        Built<
          FiscalDocumentRelationResponse,
          FiscalDocumentRelationResponseBuilder
        > {
  @BuiltValueField(wireName: r'fiscal_document_relation_id')
  int get fiscalDocumentRelationId;

  @BuiltValueField(wireName: r'relation')
  int get relation;

  @BuiltValueField(wireName: r'type')
  FiscalDocumentRelationResponseTypeEnum? get type;
  // enum typeEnum {  01,  04,  07,  };

  @BuiltValueField(wireName: r'stamp_uuid')
  String? get stampUuid;

  @BuiltValueField(wireName: r'batch')
  String? get batch;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  FiscalDocumentRelationResponse._();

  factory FiscalDocumentRelationResponse([
    void updates(FiscalDocumentRelationResponseBuilder b),
  ]) = _$FiscalDocumentRelationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FiscalDocumentRelationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FiscalDocumentRelationResponse> get serializer =>
      _$FiscalDocumentRelationResponseSerializer();
}

class _$FiscalDocumentRelationResponseSerializer
    implements PrimitiveSerializer<FiscalDocumentRelationResponse> {
  @override
  final Iterable<Type> types = const [
    FiscalDocumentRelationResponse,
    _$FiscalDocumentRelationResponse,
  ];

  @override
  final String wireName = r'FiscalDocumentRelationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FiscalDocumentRelationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fiscal_document_relation_id';
    yield serializers.serialize(
      object.fiscalDocumentRelationId,
      specifiedType: const FullType(int),
    );
    yield r'relation';
    yield serializers.serialize(
      object.relation,
      specifiedType: const FullType(int),
    );
    yield r'type';
    yield object.type == null
        ? null
        : serializers.serialize(
            object.type,
            specifiedType: const FullType.nullable(
              FiscalDocumentRelationResponseTypeEnum,
            ),
          );
    yield r'stamp_uuid';
    yield object.stampUuid == null
        ? null
        : serializers.serialize(
            object.stampUuid,
            specifiedType: const FullType.nullable(String),
          );
    yield r'batch';
    yield object.batch == null
        ? null
        : serializers.serialize(
            object.batch,
            specifiedType: const FullType.nullable(String),
          );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    FiscalDocumentRelationResponse object, {
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
    required FiscalDocumentRelationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fiscal_document_relation_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.fiscalDocumentRelationId = valueDes;
          break;
        case r'relation':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.relation = valueDes;
          break;
        case r'type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      FiscalDocumentRelationResponseTypeEnum,
                    ),
                  )
                  as FiscalDocumentRelationResponseTypeEnum?;
          if (valueDes == null) continue;
          result.type = valueDes;
          break;
        case r'stamp_uuid':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.stampUuid = valueDes;
          break;
        case r'batch':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.batch = valueDes;
          break;
        case r'serial':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.serial = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FiscalDocumentRelationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FiscalDocumentRelationResponseBuilder();
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

class FiscalDocumentRelationResponseTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'01')
  static const FiscalDocumentRelationResponseTypeEnum n01 =
      _$fiscalDocumentRelationResponseTypeEnum_n01;
  @BuiltValueEnumConst(wireName: r'04')
  static const FiscalDocumentRelationResponseTypeEnum n04 =
      _$fiscalDocumentRelationResponseTypeEnum_n04;
  @BuiltValueEnumConst(wireName: r'07')
  static const FiscalDocumentRelationResponseTypeEnum n07 =
      _$fiscalDocumentRelationResponseTypeEnum_n07;

  static Serializer<FiscalDocumentRelationResponseTypeEnum> get serializer =>
      _$fiscalDocumentRelationResponseTypeEnumSerializer;

  const FiscalDocumentRelationResponseTypeEnum._(String name) : super(name);

  static BuiltSet<FiscalDocumentRelationResponseTypeEnum> get values =>
      _$fiscalDocumentRelationResponseTypeEnumValues;
  static FiscalDocumentRelationResponseTypeEnum valueOf(String name) =>
      _$fiscalDocumentRelationResponseTypeEnumValueOf(name);
}
