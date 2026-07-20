//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_settings_response.g.dart';

/// UserSettingsResponse
///
/// Properties:
/// * [facilityId]
/// * [facilityCode]
/// * [facilityName]
/// * [pointSaleId]
/// * [pointSaleCode]
/// * [pointSaleName]
/// * [cashDrawerId]
/// * [cashDrawerCode]
/// * [cashDrawerName]
@BuiltValue()
abstract class UserSettingsResponse
    implements Built<UserSettingsResponse, UserSettingsResponseBuilder> {
  @BuiltValueField(wireName: r'facility_id')
  int? get facilityId;

  @BuiltValueField(wireName: r'facility_code')
  String? get facilityCode;

  @BuiltValueField(wireName: r'facility_name')
  String? get facilityName;

  @BuiltValueField(wireName: r'point_sale_id')
  int? get pointSaleId;

  @BuiltValueField(wireName: r'point_sale_code')
  String? get pointSaleCode;

  @BuiltValueField(wireName: r'point_sale_name')
  String? get pointSaleName;

  @BuiltValueField(wireName: r'cash_drawer_id')
  int? get cashDrawerId;

  @BuiltValueField(wireName: r'cash_drawer_code')
  String? get cashDrawerCode;

  @BuiltValueField(wireName: r'cash_drawer_name')
  String? get cashDrawerName;

  UserSettingsResponse._();

  factory UserSettingsResponse([void updates(UserSettingsResponseBuilder b)]) =
      _$UserSettingsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserSettingsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserSettingsResponse> get serializer =>
      _$UserSettingsResponseSerializer();
}

class _$UserSettingsResponseSerializer
    implements PrimitiveSerializer<UserSettingsResponse> {
  @override
  final Iterable<Type> types = const [
    UserSettingsResponse,
    _$UserSettingsResponse,
  ];

  @override
  final String wireName = r'UserSettingsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserSettingsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'facility_id';
    yield object.facilityId == null
        ? null
        : serializers.serialize(
            object.facilityId,
            specifiedType: const FullType.nullable(int),
          );
    if (object.facilityCode != null) {
      yield r'facility_code';
      yield serializers.serialize(
        object.facilityCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.facilityName != null) {
      yield r'facility_name';
      yield serializers.serialize(
        object.facilityName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'point_sale_id';
    yield object.pointSaleId == null
        ? null
        : serializers.serialize(
            object.pointSaleId,
            specifiedType: const FullType.nullable(int),
          );
    if (object.pointSaleCode != null) {
      yield r'point_sale_code';
      yield serializers.serialize(
        object.pointSaleCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.pointSaleName != null) {
      yield r'point_sale_name';
      yield serializers.serialize(
        object.pointSaleName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'cash_drawer_id';
    yield object.cashDrawerId == null
        ? null
        : serializers.serialize(
            object.cashDrawerId,
            specifiedType: const FullType.nullable(int),
          );
    if (object.cashDrawerCode != null) {
      yield r'cash_drawer_code';
      yield serializers.serialize(
        object.cashDrawerCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.cashDrawerName != null) {
      yield r'cash_drawer_name';
      yield serializers.serialize(
        object.cashDrawerName,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserSettingsResponse object, {
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
    required UserSettingsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'facility_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facilityId = valueDes;
          break;
        case r'facility_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.facilityCode = valueDes;
          break;
        case r'facility_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.facilityName = valueDes;
          break;
        case r'point_sale_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.pointSaleId = valueDes;
          break;
        case r'point_sale_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.pointSaleCode = valueDes;
          break;
        case r'point_sale_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.pointSaleName = valueDes;
          break;
        case r'cash_drawer_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.cashDrawerId = valueDes;
          break;
        case r'cash_drawer_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.cashDrawerCode = valueDes;
          break;
        case r'cash_drawer_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.cashDrawerName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserSettingsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserSettingsResponseBuilder();
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
