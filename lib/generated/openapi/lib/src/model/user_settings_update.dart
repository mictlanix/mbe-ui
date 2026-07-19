//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_settings_update.g.dart';

/// UserSettingsUpdate
///
/// Properties:
/// * [storeId]
/// * [pointSaleId]
/// * [cashDrawerId]
@BuiltValue()
abstract class UserSettingsUpdate
    implements Built<UserSettingsUpdate, UserSettingsUpdateBuilder> {
  @BuiltValueField(wireName: r'store_id')
  int? get storeId;

  @BuiltValueField(wireName: r'point_sale_id')
  int? get pointSaleId;

  @BuiltValueField(wireName: r'cash_drawer_id')
  int? get cashDrawerId;

  UserSettingsUpdate._();

  factory UserSettingsUpdate([void updates(UserSettingsUpdateBuilder b)]) =
      _$UserSettingsUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserSettingsUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserSettingsUpdate> get serializer =>
      _$UserSettingsUpdateSerializer();
}

class _$UserSettingsUpdateSerializer
    implements PrimitiveSerializer<UserSettingsUpdate> {
  @override
  final Iterable<Type> types = const [UserSettingsUpdate, _$UserSettingsUpdate];

  @override
  final String wireName = r'UserSettingsUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserSettingsUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.storeId != null) {
      yield r'store_id';
      yield serializers.serialize(
        object.storeId,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.pointSaleId != null) {
      yield r'point_sale_id';
      yield serializers.serialize(
        object.pointSaleId,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.cashDrawerId != null) {
      yield r'cash_drawer_id';
      yield serializers.serialize(
        object.cashDrawerId,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserSettingsUpdate object, {
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
    required UserSettingsUpdateBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserSettingsUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserSettingsUpdateBuilder();
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
