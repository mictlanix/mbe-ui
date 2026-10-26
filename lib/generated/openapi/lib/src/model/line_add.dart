//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity5.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'line_add.g.dart';

/// LineAdd
///
/// Properties:
/// * [product]
/// * [quantity]
@BuiltValue()
abstract class LineAdd implements Built<LineAdd, LineAddBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'quantity')
  Quantity5 get quantity;

  LineAdd._();

  factory LineAdd([void updates(LineAddBuilder b)]) = _$LineAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LineAddBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LineAdd> get serializer => _$LineAddSerializer();
}

class _$LineAddSerializer implements PrimitiveSerializer<LineAdd> {
  @override
  final Iterable<Type> types = const [LineAdd, _$LineAdd];

  @override
  final String wireName = r'LineAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LineAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(Quantity5),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LineAdd object, {
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
    required LineAddBuilder result,
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
                    specifiedType: const FullType(Quantity5),
                  )
                  as Quantity5;
          result.quantity.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LineAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LineAddBuilder();
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
