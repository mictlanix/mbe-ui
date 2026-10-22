//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bank_account_response.g.dart';

/// BankAccountResponse
///
/// Properties:
/// * [bankAccountId]
/// * [bankName]
/// * [accountNumber]
/// * [reference]
/// * [routingNumber]
/// * [comment]
@BuiltValue()
abstract class BankAccountResponse
    implements Built<BankAccountResponse, BankAccountResponseBuilder> {
  @BuiltValueField(wireName: r'bank_account_id')
  int get bankAccountId;

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

  BankAccountResponse._();

  factory BankAccountResponse([void updates(BankAccountResponseBuilder b)]) =
      _$BankAccountResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BankAccountResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BankAccountResponse> get serializer =>
      _$BankAccountResponseSerializer();
}

class _$BankAccountResponseSerializer
    implements PrimitiveSerializer<BankAccountResponse> {
  @override
  final Iterable<Type> types = const [
    BankAccountResponse,
    _$BankAccountResponse,
  ];

  @override
  final String wireName = r'BankAccountResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BankAccountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'bank_account_id';
    yield serializers.serialize(
      object.bankAccountId,
      specifiedType: const FullType(int),
    );
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
    yield r'reference';
    yield object.reference == null
        ? null
        : serializers.serialize(
            object.reference,
            specifiedType: const FullType.nullable(String),
          );
    yield r'routing_number';
    yield object.routingNumber == null
        ? null
        : serializers.serialize(
            object.routingNumber,
            specifiedType: const FullType.nullable(String),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    BankAccountResponse object, {
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
    required BankAccountResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bank_account_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.bankAccountId = valueDes;
          break;
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
  BankAccountResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BankAccountResponseBuilder();
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
