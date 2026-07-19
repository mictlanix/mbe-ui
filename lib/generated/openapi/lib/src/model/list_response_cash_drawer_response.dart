//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/cash_drawer_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_cash_drawer_response.g.dart';

/// ListResponseCashDrawerResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseCashDrawerResponse
    implements
        Built<
          ListResponseCashDrawerResponse,
          ListResponseCashDrawerResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<CashDrawerResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseCashDrawerResponse._();

  factory ListResponseCashDrawerResponse([
    void updates(ListResponseCashDrawerResponseBuilder b),
  ]) = _$ListResponseCashDrawerResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseCashDrawerResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseCashDrawerResponse> get serializer =>
      _$ListResponseCashDrawerResponseSerializer();
}

class _$ListResponseCashDrawerResponseSerializer
    implements PrimitiveSerializer<ListResponseCashDrawerResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseCashDrawerResponse,
    _$ListResponseCashDrawerResponse,
  ];

  @override
  final String wireName = r'ListResponseCashDrawerResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseCashDrawerResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(CashDrawerResponse)]),
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
    ListResponseCashDrawerResponse object, {
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
    required ListResponseCashDrawerResponseBuilder result,
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
                      FullType(CashDrawerResponse),
                    ]),
                  )
                  as BuiltList<CashDrawerResponse>;
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
  ListResponseCashDrawerResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseCashDrawerResponseBuilder();
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
