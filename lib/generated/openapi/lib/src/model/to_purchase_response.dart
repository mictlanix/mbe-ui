//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/to_purchase_group.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'to_purchase_response.g.dart';

/// ToPurchaseResponse
///
/// Properties:
/// * [groups]
@BuiltValue()
abstract class ToPurchaseResponse
    implements Built<ToPurchaseResponse, ToPurchaseResponseBuilder> {
  @BuiltValueField(wireName: r'groups')
  BuiltList<ToPurchaseGroup> get groups;

  ToPurchaseResponse._();

  factory ToPurchaseResponse([void updates(ToPurchaseResponseBuilder b)]) =
      _$ToPurchaseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ToPurchaseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ToPurchaseResponse> get serializer =>
      _$ToPurchaseResponseSerializer();
}

class _$ToPurchaseResponseSerializer
    implements PrimitiveSerializer<ToPurchaseResponse> {
  @override
  final Iterable<Type> types = const [ToPurchaseResponse, _$ToPurchaseResponse];

  @override
  final String wireName = r'ToPurchaseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ToPurchaseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'groups';
    yield serializers.serialize(
      object.groups,
      specifiedType: const FullType(BuiltList, [FullType(ToPurchaseGroup)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ToPurchaseResponse object, {
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
    required ToPurchaseResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'groups':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(ToPurchaseGroup),
                    ]),
                  )
                  as BuiltList<ToPurchaseGroup>;
          result.groups.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ToPurchaseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ToPurchaseResponseBuilder();
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
