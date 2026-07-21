//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:mbe_api_client/src/model/address_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'address_create.g.dart';

/// AddressCreate
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
abstract class AddressCreate
    implements Built<AddressCreate, AddressCreateBuilder> {
  @BuiltValueField(wireName: r'nickname')
  String? get nickname;

  @BuiltValueField(wireName: r'type')
  AddressType? get type;
  // enum typeEnum {  0,  1,  2,  3,  4,  };

  @BuiltValueField(wireName: r'street')
  String get street;

  @BuiltValueField(wireName: r'exterior_number')
  String get exteriorNumber;

  @BuiltValueField(wireName: r'interior_number')
  String? get interiorNumber;

  @BuiltValueField(wireName: r'postal_code')
  String get postalCode;

  @BuiltValueField(wireName: r'neighborhood')
  String get neighborhood;

  @BuiltValueField(wireName: r'locality')
  String? get locality;

  @BuiltValueField(wireName: r'borough')
  String get borough;

  @BuiltValueField(wireName: r'state')
  String get state;

  @BuiltValueField(wireName: r'city')
  String? get city;

  @BuiltValueField(wireName: r'country')
  String get country;

  @BuiltValueField(wireName: r'url_address')
  String? get urlAddress;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'status')
  EntityStatus? get status;
  // enum statusEnum {  0,  1,  2,  };

  AddressCreate._();

  factory AddressCreate([void updates(AddressCreateBuilder b)]) =
      _$AddressCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddressCreateBuilder b) => b
    ..type = AddressType.number0
    ..status = EntityStatus.number0;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddressCreate> get serializer =>
      _$AddressCreateSerializer();
}

class _$AddressCreateSerializer implements PrimitiveSerializer<AddressCreate> {
  @override
  final Iterable<Type> types = const [AddressCreate, _$AddressCreate];

  @override
  final String wireName = r'AddressCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddressCreate object, {
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
        specifiedType: const FullType(AddressType),
      );
    }
    yield r'street';
    yield serializers.serialize(
      object.street,
      specifiedType: const FullType(String),
    );
    yield r'exterior_number';
    yield serializers.serialize(
      object.exteriorNumber,
      specifiedType: const FullType(String),
    );
    if (object.interiorNumber != null) {
      yield r'interior_number';
      yield serializers.serialize(
        object.interiorNumber,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'postal_code';
    yield serializers.serialize(
      object.postalCode,
      specifiedType: const FullType(String),
    );
    yield r'neighborhood';
    yield serializers.serialize(
      object.neighborhood,
      specifiedType: const FullType(String),
    );
    if (object.locality != null) {
      yield r'locality';
      yield serializers.serialize(
        object.locality,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'borough';
    yield serializers.serialize(
      object.borough,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(String),
    );
    if (object.city != null) {
      yield r'city';
      yield serializers.serialize(
        object.city,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'country';
    yield serializers.serialize(
      object.country,
      specifiedType: const FullType(String),
    );
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
        specifiedType: const FullType(EntityStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AddressCreate object, {
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
    required AddressCreateBuilder result,
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
                    specifiedType: const FullType(AddressType),
                  )
                  as AddressType;
          result.type = valueDes;
          break;
        case r'street':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.street = valueDes;
          break;
        case r'exterior_number':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.postalCode = valueDes;
          break;
        case r'neighborhood':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.borough = valueDes;
          break;
        case r'state':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
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
                    specifiedType: const FullType(String),
                  )
                  as String;
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
  AddressCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddressCreateBuilder();
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
