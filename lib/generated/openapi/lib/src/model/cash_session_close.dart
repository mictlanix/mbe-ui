//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/denomination_count.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cash_session_close.g.dart';

/// CashSessionClose
///
/// Properties:
/// * [counts]
@BuiltValue()
abstract class CashSessionClose
    implements Built<CashSessionClose, CashSessionCloseBuilder> {
  @BuiltValueField(wireName: r'counts')
  BuiltList<DenominationCount>? get counts;

  CashSessionClose._();

  factory CashSessionClose([void updates(CashSessionCloseBuilder b)]) =
      _$CashSessionClose;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CashSessionCloseBuilder b) => b..counts = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<CashSessionClose> get serializer =>
      _$CashSessionCloseSerializer();
}

class _$CashSessionCloseSerializer
    implements PrimitiveSerializer<CashSessionClose> {
  @override
  final Iterable<Type> types = const [CashSessionClose, _$CashSessionClose];

  @override
  final String wireName = r'CashSessionClose';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CashSessionClose object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.counts != null) {
      yield r'counts';
      yield serializers.serialize(
        object.counts,
        specifiedType: const FullType(BuiltList, [FullType(DenominationCount)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CashSessionClose object, {
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
    required CashSessionCloseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'counts':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(DenominationCount),
                    ]),
                  )
                  as BuiltList<DenominationCount>?;
          if (valueDes == null) continue;
          result.counts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CashSessionClose deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CashSessionCloseBuilder();
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
