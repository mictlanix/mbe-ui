//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity6.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'request_line_add.g.dart';

/// RequestLineAdd
///
/// Properties:
/// * [product]
/// * [quantity]
/// * [productName]
/// * [warehouse]
@BuiltValue()
abstract class RequestLineAdd
    implements Built<RequestLineAdd, RequestLineAddBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'quantity')
  Quantity6? get quantity;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  RequestLineAdd._();

  factory RequestLineAdd([void updates(RequestLineAddBuilder b)]) =
      _$RequestLineAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RequestLineAddBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RequestLineAdd> get serializer =>
      _$RequestLineAddSerializer();
}

class _$RequestLineAddSerializer
    implements PrimitiveSerializer<RequestLineAdd> {
  @override
  final Iterable<Type> types = const [RequestLineAdd, _$RequestLineAdd];

  @override
  final String wireName = r'RequestLineAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RequestLineAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(Quantity6),
      );
    }
    if (object.productName != null) {
      yield r'product_name';
      yield serializers.serialize(
        object.productName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RequestLineAdd object, {
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
    required RequestLineAddBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Quantity6),
                  )
                  as Quantity6?;
          if (valueDes == null) continue;
          result.quantity.replace(valueDes);
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productName = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.warehouse = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RequestLineAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RequestLineAddBuilder();
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
