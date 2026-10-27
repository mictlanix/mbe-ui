//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_order_email_request.g.dart';

/// PurchaseOrderEmailRequest
///
/// Properties:
/// * [to]
/// * [message]
@BuiltValue()
abstract class PurchaseOrderEmailRequest
    implements
        Built<PurchaseOrderEmailRequest, PurchaseOrderEmailRequestBuilder> {
  @BuiltValueField(wireName: r'to')
  BuiltList<String> get to;

  @BuiltValueField(wireName: r'message')
  String? get message;

  PurchaseOrderEmailRequest._();

  factory PurchaseOrderEmailRequest([
    void updates(PurchaseOrderEmailRequestBuilder b),
  ]) = _$PurchaseOrderEmailRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseOrderEmailRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseOrderEmailRequest> get serializer =>
      _$PurchaseOrderEmailRequestSerializer();
}

class _$PurchaseOrderEmailRequestSerializer
    implements PrimitiveSerializer<PurchaseOrderEmailRequest> {
  @override
  final Iterable<Type> types = const [
    PurchaseOrderEmailRequest,
    _$PurchaseOrderEmailRequest,
  ];

  @override
  final String wireName = r'PurchaseOrderEmailRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseOrderEmailRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseOrderEmailRequest object, {
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
    required PurchaseOrderEmailRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>;
          result.to.replace(valueDes);
          break;
        case r'message':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurchaseOrderEmailRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseOrderEmailRequestBuilder();
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
