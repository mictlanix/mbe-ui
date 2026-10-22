//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bank_account_update.g.dart';

/// BankAccountUpdate
///
/// Properties:
/// * [bankName]
/// * [accountNumber]
/// * [reference]
/// * [routingNumber]
/// * [comment]
@BuiltValue()
abstract class BankAccountUpdate
    implements Built<BankAccountUpdate, BankAccountUpdateBuilder> {
  @BuiltValueField(wireName: r'bank_name')
  String? get bankName;

  @BuiltValueField(wireName: r'account_number')
  String? get accountNumber;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'routing_number')
  String? get routingNumber;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  BankAccountUpdate._();

  factory BankAccountUpdate([void updates(BankAccountUpdateBuilder b)]) =
      _$BankAccountUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BankAccountUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BankAccountUpdate> get serializer =>
      _$BankAccountUpdateSerializer();
}

class _$BankAccountUpdateSerializer
    implements PrimitiveSerializer<BankAccountUpdate> {
  @override
  final Iterable<Type> types = const [BankAccountUpdate, _$BankAccountUpdate];

  @override
  final String wireName = r'BankAccountUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BankAccountUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.bankName != null) {
      yield r'bank_name';
      yield serializers.serialize(
        object.bankName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.accountNumber != null) {
      yield r'account_number';
      yield serializers.serialize(
        object.accountNumber,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reference != null) {
      yield r'reference';
      yield serializers.serialize(
        object.reference,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.routingNumber != null) {
      yield r'routing_number';
      yield serializers.serialize(
        object.routingNumber,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    BankAccountUpdate object, {
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
    required BankAccountUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bank_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.bankName = valueDes;
          break;
        case r'account_number':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.accountNumber = valueDes;
          break;
        case r'reference':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.reference = valueDes;
          break;
        case r'routing_number':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.routingNumber = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BankAccountUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BankAccountUpdateBuilder();
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
