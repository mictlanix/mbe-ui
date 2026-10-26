//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/quantity4.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice_line_copy.g.dart';

/// A line of the credit note's invoice; the quantity defaults to the invoice line's.
///
/// Properties:
/// * [line]
/// * [quantity]
@BuiltValue()
abstract class InvoiceLineCopy
    implements Built<InvoiceLineCopy, InvoiceLineCopyBuilder> {
  @BuiltValueField(wireName: r'line')
  int get line;

  @BuiltValueField(wireName: r'quantity')
  Quantity4? get quantity;

  InvoiceLineCopy._();

  factory InvoiceLineCopy([void updates(InvoiceLineCopyBuilder b)]) =
      _$InvoiceLineCopy;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceLineCopyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvoiceLineCopy> get serializer =>
      _$InvoiceLineCopySerializer();
}

class _$InvoiceLineCopySerializer
    implements PrimitiveSerializer<InvoiceLineCopy> {
  @override
  final Iterable<Type> types = const [InvoiceLineCopy, _$InvoiceLineCopy];

  @override
  final String wireName = r'InvoiceLineCopy';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvoiceLineCopy object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'line';
    yield serializers.serialize(
      object.line,
      specifiedType: const FullType(int),
    );
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType.nullable(Quantity4),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InvoiceLineCopy object, {
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
    required InvoiceLineCopyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'line':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.line = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Quantity4),
                  )
                  as Quantity4?;
          if (valueDes == null) continue;
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
  InvoiceLineCopy deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceLineCopyBuilder();
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
