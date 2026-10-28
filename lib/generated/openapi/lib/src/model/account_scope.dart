//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'account_scope.g.dart';

/// AccountScope
///
/// Properties:
/// * [facility]
/// * [allFacilities]
@BuiltValue()
abstract class AccountScope
    implements Built<AccountScope, AccountScopeBuilder> {
  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'all_facilities')
  bool get allFacilities;

  AccountScope._();

  factory AccountScope([void updates(AccountScopeBuilder b)]) = _$AccountScope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccountScopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AccountScope> get serializer => _$AccountScopeSerializer();
}

class _$AccountScopeSerializer implements PrimitiveSerializer<AccountScope> {
  @override
  final Iterable<Type> types = const [AccountScope, _$AccountScope];

  @override
  final String wireName = r'AccountScope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccountScope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'facility';
    yield object.facility == null
        ? null
        : serializers.serialize(
            object.facility,
            specifiedType: const FullType.nullable(int),
          );
    yield r'all_facilities';
    yield serializers.serialize(
      object.allFacilities,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AccountScope object, {
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
    required AccountScopeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        case r'all_facilities':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.allFacilities = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AccountScope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccountScopeBuilder();
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
