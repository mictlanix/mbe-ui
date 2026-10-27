//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'skipped_line.g.dart';

/// SkippedLine
///
/// Properties:
/// * [purchaseRequestDetail]
/// * [reason]
@BuiltValue()
abstract class SkippedLine implements Built<SkippedLine, SkippedLineBuilder> {
  @BuiltValueField(wireName: r'purchase_request_detail')
  int get purchaseRequestDetail;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  SkippedLine._();

  factory SkippedLine([void updates(SkippedLineBuilder b)]) = _$SkippedLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SkippedLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SkippedLine> get serializer => _$SkippedLineSerializer();
}

class _$SkippedLineSerializer implements PrimitiveSerializer<SkippedLine> {
  @override
  final Iterable<Type> types = const [SkippedLine, _$SkippedLine];

  @override
  final String wireName = r'SkippedLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SkippedLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_request_detail';
    yield serializers.serialize(
      object.purchaseRequestDetail,
      specifiedType: const FullType(int),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SkippedLine object, {
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
    required SkippedLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_request_detail':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseRequestDetail = valueDes;
          break;
        case r'reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SkippedLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SkippedLineBuilder();
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
