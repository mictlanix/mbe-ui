//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bank_account_create.g.dart';

/// BankAccountCreate
///
/// Properties:
/// * [bankName]
/// * [accountNumber]
/// * [reference]
/// * [routingNumber]
/// * [comment]
@BuiltValue()
abstract class BankAccountCreate
    implements Built<BankAccountCreate, BankAccountCreateBuilder> {
  @BuiltValueField(wireName: r'bank_name')
  String get bankName;

  @BuiltValueField(wireName: r'account_number')
  String get accountNumber;

  @BuiltValueField(wireName: r'reference')
  String? get reference;

  @BuiltValueField(wireName: r'routing_number')
  String? get routingNumber;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  BankAccountCreate._();

  factory BankAccountCreate([void updates(BankAccountCreateBuilder b)]) =
      _$BankAccountCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BankAccountCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BankAccountCreate> get serializer =>
      _$BankAccountCreateSerializer();
}

class _$BankAccountCreateSerializer
    implements PrimitiveSerializer<BankAccountCreate> {
  @override
  final Iterable<Type> types = const [BankAccountCreate, _$BankAccountCreate];

  @override
  final String wireName = r'BankAccountCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BankAccountCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'bank_name';
    yield serializers.serialize(
      object.bankName,
      specifiedType: const FullType(String),
    );
    yield r'account_number';
    yield serializers.serialize(
      object.accountNumber,
      specifiedType: const FullType(String),
    );
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
    BankAccountCreate object, {
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
    required BankAccountCreateBuilder result,
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.bankName = valueDes;
          break;
        case r'account_number':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
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
  BankAccountCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BankAccountCreateBuilder();
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
