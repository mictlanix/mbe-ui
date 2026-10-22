//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/contact_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/bank_account_response.dart';
import 'package:mbe_api_client/src/model/supplier_agreement_response.dart';
import 'package:mbe_api_client/src/model/address_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_detail_response.g.dart';

/// The supplier with its sub-panels. Only the detail carries them: a page of suppliers, and the `ProductResponse.supplier` embed, must not cost four queries per row.
///
/// Properties:
/// * [supplierId]
/// * [code]
/// * [name]
/// * [zone]
/// * [creditLimit]
/// * [creditDays]
/// * [comment]
/// * [addresses]
/// * [contacts]
/// * [bankAccounts]
/// * [agreements]
@BuiltValue()
abstract class SupplierDetailResponse
    implements Built<SupplierDetailResponse, SupplierDetailResponseBuilder> {
  @BuiltValueField(wireName: r'supplier_id')
  int get supplierId;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'zone')
  String? get zone;

  @BuiltValueField(wireName: r'credit_limit')
  String get creditLimit;

  @BuiltValueField(wireName: r'credit_days')
  int get creditDays;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'addresses')
  BuiltList<AddressResponse>? get addresses;

  @BuiltValueField(wireName: r'contacts')
  BuiltList<ContactResponse>? get contacts;

  @BuiltValueField(wireName: r'bank_accounts')
  BuiltList<BankAccountResponse>? get bankAccounts;

  @BuiltValueField(wireName: r'agreements')
  BuiltList<SupplierAgreementResponse>? get agreements;

  SupplierDetailResponse._();

  factory SupplierDetailResponse([
    void updates(SupplierDetailResponseBuilder b),
  ]) = _$SupplierDetailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierDetailResponseBuilder b) => b
    ..addresses = ListBuilder()
    ..contacts = ListBuilder()
    ..bankAccounts = ListBuilder()
    ..agreements = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierDetailResponse> get serializer =>
      _$SupplierDetailResponseSerializer();
}

class _$SupplierDetailResponseSerializer
    implements PrimitiveSerializer<SupplierDetailResponse> {
  @override
  final Iterable<Type> types = const [
    SupplierDetailResponse,
    _$SupplierDetailResponse,
  ];

  @override
  final String wireName = r'SupplierDetailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierDetailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier_id';
    yield serializers.serialize(
      object.supplierId,
      specifiedType: const FullType(int),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'zone';
    yield object.zone == null
        ? null
        : serializers.serialize(
            object.zone,
            specifiedType: const FullType.nullable(String),
          );
    yield r'credit_limit';
    yield serializers.serialize(
      object.creditLimit,
      specifiedType: const FullType(String),
    );
    yield r'credit_days';
    yield serializers.serialize(
      object.creditDays,
      specifiedType: const FullType(int),
    );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    if (object.addresses != null) {
      yield r'addresses';
      yield serializers.serialize(
        object.addresses,
        specifiedType: const FullType(BuiltList, [FullType(AddressResponse)]),
      );
    }
    if (object.contacts != null) {
      yield r'contacts';
      yield serializers.serialize(
        object.contacts,
        specifiedType: const FullType(BuiltList, [FullType(ContactResponse)]),
      );
    }
    if (object.bankAccounts != null) {
      yield r'bank_accounts';
      yield serializers.serialize(
        object.bankAccounts,
        specifiedType: const FullType(BuiltList, [
          FullType(BankAccountResponse),
        ]),
      );
    }
    if (object.agreements != null) {
      yield r'agreements';
      yield serializers.serialize(
        object.agreements,
        specifiedType: const FullType(BuiltList, [
          FullType(SupplierAgreementResponse),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierDetailResponse object, {
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
    required SupplierDetailResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.supplierId = valueDes;
          break;
        case r'code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'zone':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.zone = valueDes;
          break;
        case r'credit_limit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.creditLimit = valueDes;
          break;
        case r'credit_days':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creditDays = valueDes;
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
        case r'addresses':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(AddressResponse),
                    ]),
                  )
                  as BuiltList<AddressResponse>?;
          if (valueDes == null) continue;
          result.addresses.replace(valueDes);
          break;
        case r'contacts':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(ContactResponse),
                    ]),
                  )
                  as BuiltList<ContactResponse>?;
          if (valueDes == null) continue;
          result.contacts.replace(valueDes);
          break;
        case r'bank_accounts':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(BankAccountResponse),
                    ]),
                  )
                  as BuiltList<BankAccountResponse>?;
          if (valueDes == null) continue;
          result.bankAccounts.replace(valueDes);
          break;
        case r'agreements':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(SupplierAgreementResponse),
                    ]),
                  )
                  as BuiltList<SupplierAgreementResponse>?;
          if (valueDes == null) continue;
          result.agreements.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierDetailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierDetailResponseBuilder();
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
