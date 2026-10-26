//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'batch_account.g.dart';

/// A bank account printed on the invoice: one entry of the template's `ExtraInfo`.
///
/// Properties:
/// * [bank]
/// * [account]
/// * [clabe]
/// * [currency]
@BuiltValue()
abstract class BatchAccount
    implements Built<BatchAccount, BatchAccountBuilder> {
  @BuiltValueField(wireName: r'bank')
  String? get bank;

  @BuiltValueField(wireName: r'account')
  String? get account;

  @BuiltValueField(wireName: r'clabe')
  String? get clabe;

  @BuiltValueField(wireName: r'currency')
  String? get currency;

  BatchAccount._();

  factory BatchAccount([void updates(BatchAccountBuilder b)]) = _$BatchAccount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BatchAccountBuilder b) => b
    ..bank = ''
    ..account = ''
    ..clabe = ''
    ..currency = '';

  @BuiltValueSerializer(custom: true)
  static Serializer<BatchAccount> get serializer => _$BatchAccountSerializer();
}

class _$BatchAccountSerializer implements PrimitiveSerializer<BatchAccount> {
  @override
  final Iterable<Type> types = const [BatchAccount, _$BatchAccount];

  @override
  final String wireName = r'BatchAccount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BatchAccount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bank != null) {
      yield r'bank';
      yield serializers.serialize(
        object.bank,
        specifiedType: const FullType(String),
      );
    }
    if (object.account != null) {
      yield r'account';
      yield serializers.serialize(
        object.account,
        specifiedType: const FullType(String),
      );
    }
    if (object.clabe != null) {
      yield r'clabe';
      yield serializers.serialize(
        object.clabe,
        specifiedType: const FullType(String),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BatchAccount object, {
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
    required BatchAccountBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bank':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.bank = valueDes;
          break;
        case r'account':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.account = valueDes;
          break;
        case r'clabe':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.clabe = valueDes;
          break;
        case r'currency':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.currency = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BatchAccount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BatchAccountBuilder();
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
