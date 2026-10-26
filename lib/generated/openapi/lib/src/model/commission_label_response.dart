//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_label_response.g.dart';

/// CommissionLabelResponse
///
/// Properties:
/// * [commissionId]
/// * [name]
/// * [commissionRate]
/// * [comment]
@BuiltValue()
abstract class CommissionLabelResponse
    implements Built<CommissionLabelResponse, CommissionLabelResponseBuilder> {
  @BuiltValueField(wireName: r'commission_id')
  int get commissionId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'commission_rate')
  String get commissionRate;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  CommissionLabelResponse._();

  factory CommissionLabelResponse([
    void updates(CommissionLabelResponseBuilder b),
  ]) = _$CommissionLabelResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionLabelResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionLabelResponse> get serializer =>
      _$CommissionLabelResponseSerializer();
}

class _$CommissionLabelResponseSerializer
    implements PrimitiveSerializer<CommissionLabelResponse> {
  @override
  final Iterable<Type> types = const [
    CommissionLabelResponse,
    _$CommissionLabelResponse,
  ];

  @override
  final String wireName = r'CommissionLabelResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionLabelResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'commission_id';
    yield serializers.serialize(
      object.commissionId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'commission_rate';
    yield serializers.serialize(
      object.commissionRate,
      specifiedType: const FullType(String),
    );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionLabelResponse object, {
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
    required CommissionLabelResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'commission_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.commissionId = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'commission_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.commissionRate = valueDes;
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionLabelResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionLabelResponseBuilder();
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
