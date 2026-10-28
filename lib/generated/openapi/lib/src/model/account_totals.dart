//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/buckets.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'account_totals.g.dart';

/// AccountTotals
///
/// Properties:
/// * [owed]
/// * [overdue]
/// * [buckets]
@BuiltValue()
abstract class AccountTotals
    implements Built<AccountTotals, AccountTotalsBuilder> {
  @BuiltValueField(wireName: r'owed')
  String get owed;

  @BuiltValueField(wireName: r'overdue')
  String get overdue;

  @BuiltValueField(wireName: r'buckets')
  Buckets get buckets;

  AccountTotals._();

  factory AccountTotals([void updates(AccountTotalsBuilder b)]) =
      _$AccountTotals;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccountTotalsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AccountTotals> get serializer =>
      _$AccountTotalsSerializer();
}

class _$AccountTotalsSerializer implements PrimitiveSerializer<AccountTotals> {
  @override
  final Iterable<Type> types = const [AccountTotals, _$AccountTotals];

  @override
  final String wireName = r'AccountTotals';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccountTotals object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'owed';
    yield serializers.serialize(
      object.owed,
      specifiedType: const FullType(String),
    );
    yield r'overdue';
    yield serializers.serialize(
      object.overdue,
      specifiedType: const FullType(String),
    );
    yield r'buckets';
    yield serializers.serialize(
      object.buckets,
      specifiedType: const FullType(Buckets),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AccountTotals object, {
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
    required AccountTotalsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'owed':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.owed = valueDes;
          break;
        case r'overdue':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.overdue = valueDes;
          break;
        case r'buckets':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Buckets),
                  )
                  as Buckets;
          result.buckets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AccountTotals deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccountTotalsBuilder();
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
