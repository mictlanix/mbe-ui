//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/bank_account_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_bank_account_response.g.dart';

/// ListResponseBankAccountResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseBankAccountResponse
    implements
        Built<
          ListResponseBankAccountResponse,
          ListResponseBankAccountResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<BankAccountResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseBankAccountResponse._();

  factory ListResponseBankAccountResponse([
    void updates(ListResponseBankAccountResponseBuilder b),
  ]) = _$ListResponseBankAccountResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseBankAccountResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseBankAccountResponse> get serializer =>
      _$ListResponseBankAccountResponseSerializer();
}

class _$ListResponseBankAccountResponseSerializer
    implements PrimitiveSerializer<ListResponseBankAccountResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseBankAccountResponse,
    _$ListResponseBankAccountResponse,
  ];

  @override
  final String wireName = r'ListResponseBankAccountResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseBankAccountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(BankAccountResponse)]),
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
    ListResponseBankAccountResponse object, {
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
    required ListResponseBankAccountResponseBuilder result,
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
                      FullType(BankAccountResponse),
                    ]),
                  )
                  as BuiltList<BankAccountResponse>;
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
  ListResponseBankAccountResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseBankAccountResponseBuilder();
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
