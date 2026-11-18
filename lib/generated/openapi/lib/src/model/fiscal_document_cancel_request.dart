//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_document_cancel_request.g.dart';

/// SAT's cancellation reason, 01–04, and for 01 the substitute document's UUID.
///
/// Properties:
/// * [reason]
/// * [substitution]
@BuiltValue()
abstract class FiscalDocumentCancelRequest
    implements
        Built<FiscalDocumentCancelRequest, FiscalDocumentCancelRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'substitution')
  String? get substitution;

  FiscalDocumentCancelRequest._();

  factory FiscalDocumentCancelRequest([
    void updates(FiscalDocumentCancelRequestBuilder b),
  ]) = _$FiscalDocumentCancelRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FiscalDocumentCancelRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FiscalDocumentCancelRequest> get serializer =>
      _$FiscalDocumentCancelRequestSerializer();
}

class _$FiscalDocumentCancelRequestSerializer
    implements PrimitiveSerializer<FiscalDocumentCancelRequest> {
  @override
  final Iterable<Type> types = const [
    FiscalDocumentCancelRequest,
    _$FiscalDocumentCancelRequest,
  ];

  @override
  final String wireName = r'FiscalDocumentCancelRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FiscalDocumentCancelRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    if (object.substitution != null) {
      yield r'substitution';
      yield serializers.serialize(
        object.substitution,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FiscalDocumentCancelRequest object, {
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
    required FiscalDocumentCancelRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.reason = valueDes;
          break;
        case r'substitution':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.substitution = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FiscalDocumentCancelRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FiscalDocumentCancelRequestBuilder();
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
