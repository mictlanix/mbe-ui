//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_product_label_response.g.dart';

/// CommissionProductLabelResponse
///
/// Properties:
/// * [product]
/// * [productCode]
/// * [productName]
/// * [commission]
@BuiltValue()
abstract class CommissionProductLabelResponse
    implements
        Built<
          CommissionProductLabelResponse,
          CommissionProductLabelResponseBuilder
        > {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String get productCode;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'commission')
  int get commission;

  CommissionProductLabelResponse._();

  factory CommissionProductLabelResponse([
    void updates(CommissionProductLabelResponseBuilder b),
  ]) = _$CommissionProductLabelResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionProductLabelResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionProductLabelResponse> get serializer =>
      _$CommissionProductLabelResponseSerializer();
}

class _$CommissionProductLabelResponseSerializer
    implements PrimitiveSerializer<CommissionProductLabelResponse> {
  @override
  final Iterable<Type> types = const [
    CommissionProductLabelResponse,
    _$CommissionProductLabelResponse,
  ];

  @override
  final String wireName = r'CommissionProductLabelResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionProductLabelResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_code';
    yield serializers.serialize(
      object.productCode,
      specifiedType: const FullType(String),
    );
    yield r'product_name';
    yield serializers.serialize(
      object.productName,
      specifiedType: const FullType(String),
    );
    yield r'commission';
    yield serializers.serialize(
      object.commission,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionProductLabelResponse object, {
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
    required CommissionProductLabelResponseBuilder result,
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
        case r'product_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productCode = valueDes;
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productName = valueDes;
          break;
        case r'commission':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.commission = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionProductLabelResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionProductLabelResponseBuilder();
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
