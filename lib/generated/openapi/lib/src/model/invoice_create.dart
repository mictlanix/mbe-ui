//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice_create.g.dart';

/// InvoiceCreate
///
/// Properties:
/// * [customer]
/// * [recipient]
/// * [issuer]
/// * [batch]
@BuiltValue()
abstract class InvoiceCreate
    implements Built<InvoiceCreate, InvoiceCreateBuilder> {
  @BuiltValueField(wireName: r'customer')
  int get customer;

  @BuiltValueField(wireName: r'recipient')
  String get recipient;

  @BuiltValueField(wireName: r'issuer')
  String? get issuer;

  @BuiltValueField(wireName: r'batch')
  String? get batch;

  InvoiceCreate._();

  factory InvoiceCreate([void updates(InvoiceCreateBuilder b)]) =
      _$InvoiceCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvoiceCreate> get serializer =>
      _$InvoiceCreateSerializer();
}

class _$InvoiceCreateSerializer implements PrimitiveSerializer<InvoiceCreate> {
  @override
  final Iterable<Type> types = const [InvoiceCreate, _$InvoiceCreate];

  @override
  final String wireName = r'InvoiceCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvoiceCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer';
    yield serializers.serialize(
      object.customer,
      specifiedType: const FullType(int),
    );
    yield r'recipient';
    yield serializers.serialize(
      object.recipient,
      specifiedType: const FullType(String),
    );
    if (object.issuer != null) {
      yield r'issuer';
      yield serializers.serialize(
        object.issuer,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.batch != null) {
      yield r'batch';
      yield serializers.serialize(
        object.batch,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InvoiceCreate object, {
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
    required InvoiceCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customer':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.customer = valueDes;
          break;
        case r'recipient':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.recipient = valueDes;
          break;
        case r'issuer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.issuer = valueDes;
          break;
        case r'batch':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.batch = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvoiceCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceCreateBuilder();
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
