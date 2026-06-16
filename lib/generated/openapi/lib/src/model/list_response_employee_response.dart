//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/employee_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_employee_response.g.dart';

/// ListResponseEmployeeResponse
///
/// Properties:
/// * [items] 
/// * [total] 
@BuiltValue()
abstract class ListResponseEmployeeResponse implements Built<ListResponseEmployeeResponse, ListResponseEmployeeResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<EmployeeResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseEmployeeResponse._();

  factory ListResponseEmployeeResponse([void updates(ListResponseEmployeeResponseBuilder b)]) = _$ListResponseEmployeeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseEmployeeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseEmployeeResponse> get serializer => _$ListResponseEmployeeResponseSerializer();
}

class _$ListResponseEmployeeResponseSerializer implements PrimitiveSerializer<ListResponseEmployeeResponse> {
  @override
  final Iterable<Type> types = const [ListResponseEmployeeResponse, _$ListResponseEmployeeResponse];

  @override
  final String wireName = r'ListResponseEmployeeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseEmployeeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(EmployeeResponse)]),
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
    ListResponseEmployeeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListResponseEmployeeResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EmployeeResponse)]),
          ) as BuiltList<EmployeeResponse>;
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
  ListResponseEmployeeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseEmployeeResponseBuilder();
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

