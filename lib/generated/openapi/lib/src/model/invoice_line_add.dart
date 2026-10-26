//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice_line_add.g.dart';

/// InvoiceLineAdd
///
/// Properties:
/// * [product]
@BuiltValue()
abstract class InvoiceLineAdd
    implements Built<InvoiceLineAdd, InvoiceLineAddBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  InvoiceLineAdd._();

  factory InvoiceLineAdd([void updates(InvoiceLineAddBuilder b)]) =
      _$InvoiceLineAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceLineAddBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvoiceLineAdd> get serializer =>
      _$InvoiceLineAddSerializer();
}

class _$InvoiceLineAddSerializer
    implements PrimitiveSerializer<InvoiceLineAdd> {
  @override
  final Iterable<Type> types = const [InvoiceLineAdd, _$InvoiceLineAdd];

  @override
  final String wireName = r'InvoiceLineAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvoiceLineAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InvoiceLineAdd object, {
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
    required InvoiceLineAddBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvoiceLineAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceLineAddBuilder();
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
