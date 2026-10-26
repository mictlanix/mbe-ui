//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity2.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'count_line_set.g.dart';

/// CountLineSet
///
/// Properties:
/// * [product]
/// * [productCode]
/// * [quantity]
@BuiltValue()
abstract class CountLineSet
    implements Built<CountLineSet, CountLineSetBuilder> {
  @BuiltValueField(wireName: r'product')
  int? get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'quantity')
  Quantity2 get quantity;

  CountLineSet._();

  factory CountLineSet([void updates(CountLineSetBuilder b)]) = _$CountLineSet;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CountLineSetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CountLineSet> get serializer => _$CountLineSetSerializer();
}

class _$CountLineSetSerializer implements PrimitiveSerializer<CountLineSet> {
  @override
  final Iterable<Type> types = const [CountLineSet, _$CountLineSet];

  @override
  final String wireName = r'CountLineSet';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CountLineSet object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.product != null) {
      yield r'product';
      yield serializers.serialize(
        object.product,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.productCode != null) {
      yield r'product_code';
      yield serializers.serialize(
        object.productCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(Quantity2),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CountLineSet object, {
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
    required CountLineSetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.product = valueDes;
          break;
        case r'product_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productCode = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Quantity2),
                  )
                  as Quantity2;
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
  CountLineSet deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CountLineSetBuilder();
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
