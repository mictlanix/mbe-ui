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
/// * [storeId]
/// * [storeCode]
/// * [storeName]
/// * [pointSaleId]
/// * [pointSaleCode]
/// * [pointSaleName]
/// * [cashDrawerId]
/// * [cashDrawerCode]
/// * [cashDrawerName]
@BuiltValue()
abstract class UserSettingsResponse
    implements Built<UserSettingsResponse, UserSettingsResponseBuilder> {
  @BuiltValueField(wireName: r'store_id')
  int? get storeId;

  @BuiltValueField(wireName: r'store_code')
  String? get storeCode;

  @BuiltValueField(wireName: r'store_name')
  String? get storeName;

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
    yield r'store_id';
    yield object.storeId == null
        ? null
        : serializers.serialize(
            object.storeId,
            specifiedType: const FullType.nullable(int),
          );
    if (object.storeCode != null) {
      yield r'store_code';
      yield serializers.serialize(
        object.storeCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.storeName != null) {
      yield r'store_name';
      yield serializers.serialize(
        object.storeName,
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
        case r'store_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.storeId = valueDes;
          break;
        case r'store_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.storeCode = valueDes;
          break;
        case r'store_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.storeName = valueDes;
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
