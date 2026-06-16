//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/expense_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_expense_response.g.dart';

/// ListResponseExpenseResponse
///
/// Properties:
/// * [items] 
/// * [total] 
@BuiltValue()
abstract class ListResponseExpenseResponse implements Built<ListResponseExpenseResponse, ListResponseExpenseResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ExpenseResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseExpenseResponse._();

  factory ListResponseExpenseResponse([void updates(ListResponseExpenseResponseBuilder b)]) = _$ListResponseExpenseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseExpenseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseExpenseResponse> get serializer => _$ListResponseExpenseResponseSerializer();
}

class _$ListResponseExpenseResponseSerializer implements PrimitiveSerializer<ListResponseExpenseResponse> {
  @override
  final Iterable<Type> types = const [ListResponseExpenseResponse, _$ListResponseExpenseResponse];

  @override
  final String wireName = r'ListResponseExpenseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseExpenseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ExpenseResponse)]),
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
    ListResponseExpenseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListResponseExpenseResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ExpenseResponse)]),
          ) as BuiltList<ExpenseResponse>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
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
  ListResponseExpenseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseExpenseResponseBuilder();
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

