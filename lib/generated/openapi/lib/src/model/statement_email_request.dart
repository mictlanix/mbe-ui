//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'statement_email_request.g.dart';

/// Contacts of the party and typed addresses; at most 10 recipients in all (FR-024).
///
/// Properties:
/// * [contacts]
/// * [to]
@BuiltValue()
abstract class StatementEmailRequest
    implements Built<StatementEmailRequest, StatementEmailRequestBuilder> {
  @BuiltValueField(wireName: r'contacts')
  BuiltList<int>? get contacts;

  @BuiltValueField(wireName: r'to')
  BuiltList<String>? get to;

  StatementEmailRequest._();

  factory StatementEmailRequest([
    void updates(StatementEmailRequestBuilder b),
  ]) = _$StatementEmailRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StatementEmailRequestBuilder b) => b
    ..contacts = ListBuilder()
    ..to = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<StatementEmailRequest> get serializer =>
      _$StatementEmailRequestSerializer();
}

class _$StatementEmailRequestSerializer
    implements PrimitiveSerializer<StatementEmailRequest> {
  @override
  final Iterable<Type> types = const [
    StatementEmailRequest,
    _$StatementEmailRequest,
  ];

  @override
  final String wireName = r'StatementEmailRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StatementEmailRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.contacts != null) {
      yield r'contacts';
      yield serializers.serialize(
        object.contacts,
        specifiedType: const FullType(BuiltList, [FullType(int)]),
      );
    }
    if (object.to != null) {
      yield r'to';
      yield serializers.serialize(
        object.to,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StatementEmailRequest object, {
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
    required StatementEmailRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contacts':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(int),
                    ]),
                  )
                  as BuiltList<int>?;
          if (valueDes == null) continue;
          result.contacts.replace(valueDes);
          break;
        case r'to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>?;
          if (valueDes == null) continue;
          result.to.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StatementEmailRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StatementEmailRequestBuilder();
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
