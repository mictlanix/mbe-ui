//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/cash_session_response.dart';
import 'package:mbe_api_client/src/model/session_state.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'current_session_response.g.dart';

/// CurrentSessionResponse
///
/// Properties:
/// * [state]
/// * [session]
@BuiltValue()
abstract class CurrentSessionResponse
    implements Built<CurrentSessionResponse, CurrentSessionResponseBuilder> {
  @BuiltValueField(wireName: r'state')
  SessionState get state;
  // enum stateEnum {  none,  open,  stale,  };

  @BuiltValueField(wireName: r'session')
  CashSessionResponse? get session;

  CurrentSessionResponse._();

  factory CurrentSessionResponse([
    void updates(CurrentSessionResponseBuilder b),
  ]) = _$CurrentSessionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CurrentSessionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CurrentSessionResponse> get serializer =>
      _$CurrentSessionResponseSerializer();
}

class _$CurrentSessionResponseSerializer
    implements PrimitiveSerializer<CurrentSessionResponse> {
  @override
  final Iterable<Type> types = const [
    CurrentSessionResponse,
    _$CurrentSessionResponse,
  ];

  @override
  final String wireName = r'CurrentSessionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CurrentSessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(SessionState),
    );
    if (object.session != null) {
      yield r'session';
      yield serializers.serialize(
        object.session,
        specifiedType: const FullType.nullable(CashSessionResponse),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CurrentSessionResponse object, {
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
    required CurrentSessionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'state':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(SessionState),
                  )
                  as SessionState;
          result.state = valueDes;
          break;
        case r'session':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(CashSessionResponse),
                  )
                  as CashSessionResponse?;
          if (valueDes == null) continue;
          result.session.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CurrentSessionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CurrentSessionResponseBuilder();
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
