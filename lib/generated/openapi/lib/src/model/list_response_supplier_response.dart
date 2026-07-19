//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/supplier_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_supplier_response.g.dart';

/// ListResponseSupplierResponse
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseSupplierResponse
    implements
        Built<
          ListResponseSupplierResponse,
          ListResponseSupplierResponseBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<SupplierResponse> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseSupplierResponse._();

  factory ListResponseSupplierResponse([
    void updates(ListResponseSupplierResponseBuilder b),
  ]) = _$ListResponseSupplierResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseSupplierResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseSupplierResponse> get serializer =>
      _$ListResponseSupplierResponseSerializer();
}

class _$ListResponseSupplierResponseSerializer
    implements PrimitiveSerializer<ListResponseSupplierResponse> {
  @override
  final Iterable<Type> types = const [
    ListResponseSupplierResponse,
    _$ListResponseSupplierResponse,
  ];

  @override
  final String wireName = r'ListResponseSupplierResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseSupplierResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(SupplierResponse)]),
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
    ListResponseSupplierResponse object, {
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
    required ListResponseSupplierResponseBuilder result,
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
                      FullType(SupplierResponse),
                    ]),
                  )
                  as BuiltList<SupplierResponse>;
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
  ListResponseSupplierResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseSupplierResponseBuilder();
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
