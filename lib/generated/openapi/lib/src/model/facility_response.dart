//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:mbe_api_client/src/model/sat_catalog_response.dart';
import 'package:mbe_api_client/src/model/facility_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'facility_response.g.dart';

/// FacilityResponse
///
/// Properties:
/// * [facilityId]
/// * [code]
/// * [name]
/// * [type]
/// * [location]
/// * [address]
/// * [taxpayer]
/// * [logo]
/// * [receiptMessage]
/// * [defaultBatch]
/// * [status]
@BuiltValue()
abstract class FacilityResponse
    implements Built<FacilityResponse, FacilityResponseBuilder> {
  @BuiltValueField(wireName: r'facility_id')
  int get facilityId;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'type')
  FacilityType get type;
  // enum typeEnum {  0,  1,  };

  @BuiltValueField(wireName: r'location')
  SatCatalogResponse get location;

  @BuiltValueField(wireName: r'address')
  int get address;

  @BuiltValueField(wireName: r'taxpayer')
  String get taxpayer;

  @BuiltValueField(wireName: r'logo')
  String? get logo;

  @BuiltValueField(wireName: r'receipt_message')
  String? get receiptMessage;

  @BuiltValueField(wireName: r'default_batch')
  String? get defaultBatch;

  @BuiltValueField(wireName: r'status')
  EntityStatus get status;
  // enum statusEnum {  0,  1,  2,  };

  FacilityResponse._();

  factory FacilityResponse([void updates(FacilityResponseBuilder b)]) =
      _$FacilityResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FacilityResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FacilityResponse> get serializer =>
      _$FacilityResponseSerializer();
}

class _$FacilityResponseSerializer
    implements PrimitiveSerializer<FacilityResponse> {
  @override
  final Iterable<Type> types = const [FacilityResponse, _$FacilityResponse];

  @override
  final String wireName = r'FacilityResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FacilityResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'facility_id';
    yield serializers.serialize(
      object.facilityId,
      specifiedType: const FullType(int),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(FacilityType),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(SatCatalogResponse),
    );
    yield r'address';
    yield serializers.serialize(
      object.address,
      specifiedType: const FullType(int),
    );
    yield r'taxpayer';
    yield serializers.serialize(
      object.taxpayer,
      specifiedType: const FullType(String),
    );
    yield r'logo';
    yield object.logo == null
        ? null
        : serializers.serialize(
            object.logo,
            specifiedType: const FullType.nullable(String),
          );
    yield r'receipt_message';
    yield object.receiptMessage == null
        ? null
        : serializers.serialize(
            object.receiptMessage,
            specifiedType: const FullType.nullable(String),
          );
    yield r'default_batch';
    yield object.defaultBatch == null
        ? null
        : serializers.serialize(
            object.defaultBatch,
            specifiedType: const FullType.nullable(String),
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
    FacilityResponse object, {
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
    required FacilityResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'facility_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facilityId = valueDes;
          break;
        case r'code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(FacilityType),
                  )
                  as FacilityType;
          result.type = valueDes;
          break;
        case r'location':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(SatCatalogResponse),
                  )
                  as SatCatalogResponse;
          result.location.replace(valueDes);
          break;
        case r'address':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.address = valueDes;
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
        case r'logo':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.logo = valueDes;
          break;
        case r'receipt_message':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.receiptMessage = valueDes;
          break;
        case r'default_batch':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.defaultBatch = valueDes;
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
  FacilityResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FacilityResponseBuilder();
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
