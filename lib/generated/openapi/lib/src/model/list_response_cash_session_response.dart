//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/cash_session_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_cash_session_response.g.dart';

/// ListResponseCashSessionResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseCashSessionResponse
    implements
        Built<
          ListResponseCashSessionResponse,
          ListResponseCashSessionResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<CashSessionResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseCashSessionResponse._();

  factory ListResponseCashSessionResponse([
    void updates(ListResponseCashSessionResponseBuilder b),
  ]) = _$ListResponseCashSessionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseCashSessionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseCashSessionResponse> get serializer =>
      _$ListResponseCashSessionResponseSerializer();
}

class _$ListResponseCashSessionResponseSerializer
    implements PrimitiveSerializer<ListResponseCashSessionResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseCashSessionResponse,
    _$ListResponseCashSessionResponse,
  ];

  @override
  final String wireName = r'ListResponseCashSessionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseCashSessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(CashSessionResponse)]),
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
    ListResponseCashSessionResponse object, {
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
    required ListResponseCashSessionResponseBuilder result,
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
                      FullType(CashSessionResponse),
                    ]),
                  )
                  as BuiltList<CashSessionResponse>;
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
  ListResponseCashSessionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseCashSessionResponseBuilder();
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
