//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/user_profile_list_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_profile_list_response.g.dart';

/// UserProfileListResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class UserProfileListResponse
    implements Built<UserProfileListResponse, UserProfileListResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<UserProfileListItem> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  UserProfileListResponse._();

  factory UserProfileListResponse([
    void updates(UserProfileListResponseBuilder b),
  ]) = _$UserProfileListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserProfileListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserProfileListResponse> get serializer =>
      _$UserProfileListResponseSerializer();
}

class _$UserProfileListResponseSerializer
    implements PrimitiveSerializer<UserProfileListResponse> {
  @override
  final Iterable<Type> types = const [
    UserProfileListResponse,
    _$UserProfileListResponse,
  ];

  @override
  final String wireName = r'UserProfileListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserProfileListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(UserProfileListItem)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserProfileListResponse object, {
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
    required UserProfileListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(UserProfileListItem),
                    ]),
                  )
                  as BuiltList<UserProfileListItem>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserProfileListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserProfileListResponseBuilder();
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
