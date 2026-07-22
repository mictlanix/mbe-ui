//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:mbe_api_client/src/model/address_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'address_update.g.dart';

/// AddressUpdate
///
/// Properties:
/// * [nickname]
/// * [type]
/// * [street]
/// * [exteriorNumber]
/// * [interiorNumber]
/// * [postalCode]
/// * [neighborhood]
/// * [locality]
/// * [borough]
/// * [state]
/// * [city]
/// * [country]
/// * [urlAddress]
/// * [comment]
/// * [status]
@BuiltValue()
abstract class AddressUpdate
    implements Built<AddressUpdate, AddressUpdateBuilder> {
  @BuiltValueField(wireName: r'nickname')
  String? get nickname;

  @BuiltValueField(wireName: r'type')
  AddressType? get type;
  // enum typeEnum {  0,  1,  2,  3,  4,  };

  @BuiltValueField(wireName: r'street')
  String? get street;

  @BuiltValueField(wireName: r'exterior_number')
  String? get exteriorNumber;

  @BuiltValueField(wireName: r'interior_number')
  String? get interiorNumber;

  @BuiltValueField(wireName: r'postal_code')
  String? get postalCode;

  @BuiltValueField(wireName: r'neighborhood')
  String? get neighborhood;

  @BuiltValueField(wireName: r'locality')
  String? get locality;

  @BuiltValueField(wireName: r'borough')
  String? get borough;

  @BuiltValueField(wireName: r'state')
  String? get state;

  @BuiltValueField(wireName: r'city')
  String? get city;

  @BuiltValueField(wireName: r'country')
  String? get country;

  @BuiltValueField(wireName: r'url_address')
  String? get urlAddress;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'status')
  EntityStatus? get status;
  // enum statusEnum {  0,  1,  2,  };

  AddressUpdate._();

  factory AddressUpdate([void updates(AddressUpdateBuilder b)]) =
      _$AddressUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddressUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddressUpdate> get serializer =>
      _$AddressUpdateSerializer();
}

class _$AddressUpdateSerializer implements PrimitiveSerializer<AddressUpdate> {
  @override
  final Iterable<Type> types = const [AddressUpdate, _$AddressUpdate];

  @override
  final String wireName = r'AddressUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddressUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.nickname != null) {
      yield r'nickname';
      yield serializers.serialize(
        object.nickname,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType.nullable(AddressType),
      );
    }
    if (object.street != null) {
      yield r'street';
      yield serializers.serialize(
        object.street,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.exteriorNumber != null) {
      yield r'exterior_number';
      yield serializers.serialize(
        object.exteriorNumber,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.interiorNumber != null) {
      yield r'interior_number';
      yield serializers.serialize(
        object.interiorNumber,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.postalCode != null) {
      yield r'postal_code';
      yield serializers.serialize(
        object.postalCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.neighborhood != null) {
      yield r'neighborhood';
      yield serializers.serialize(
        object.neighborhood,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.locality != null) {
      yield r'locality';
      yield serializers.serialize(
        object.locality,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.borough != null) {
      yield r'borough';
      yield serializers.serialize(
        object.borough,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.state != null) {
      yield r'state';
      yield serializers.serialize(
        object.state,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.city != null) {
      yield r'city';
      yield serializers.serialize(
        object.city,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.country != null) {
      yield r'country';
      yield serializers.serialize(
        object.country,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.urlAddress != null) {
      yield r'url_address';
      yield serializers.serialize(
        object.urlAddress,
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
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType.nullable(EntityStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AddressUpdate object, {
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
    required AddressUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'nickname':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.nickname = valueDes;
          break;
        case r'type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(AddressType),
                  )
                  as AddressType?;
          if (valueDes == null) continue;
          result.type = valueDes;
          break;
        case r'street':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.street = valueDes;
          break;
        case r'exterior_number':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.exteriorNumber = valueDes;
          break;
        case r'interior_number':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.interiorNumber = valueDes;
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
        case r'neighborhood':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.neighborhood = valueDes;
          break;
        case r'locality':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.locality = valueDes;
          break;
        case r'borough':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.borough = valueDes;
          break;
        case r'state':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.state = valueDes;
          break;
        case r'city':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.city = valueDes;
          break;
        case r'country':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.country = valueDes;
          break;
        case r'url_address':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.urlAddress = valueDes;
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(EntityStatus),
                  )
                  as EntityStatus?;
          if (valueDes == null) continue;
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
  AddressUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddressUpdateBuilder();
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
