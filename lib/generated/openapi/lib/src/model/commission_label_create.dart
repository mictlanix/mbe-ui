//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/commission_rate.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_label_create.g.dart';

/// CommissionLabelCreate
///
/// Properties:
/// * [name]
/// * [commissionRate]
/// * [comment]
@BuiltValue()
abstract class CommissionLabelCreate
    implements Built<CommissionLabelCreate, CommissionLabelCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'commission_rate')
  CommissionRate get commissionRate;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  CommissionLabelCreate._();

  factory CommissionLabelCreate([
    void updates(CommissionLabelCreateBuilder b),
  ]) = _$CommissionLabelCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionLabelCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionLabelCreate> get serializer =>
      _$CommissionLabelCreateSerializer();
}

class _$CommissionLabelCreateSerializer
    implements PrimitiveSerializer<CommissionLabelCreate> {
  @override
  final Iterable<Type> types = const [
    CommissionLabelCreate,
    _$CommissionLabelCreate,
  ];

  @override
  final String wireName = r'CommissionLabelCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionLabelCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'commission_rate';
    yield serializers.serialize(
      object.commissionRate,
      specifiedType: const FullType(CommissionRate),
    );
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionLabelCreate object, {
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
    required CommissionLabelCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
                    specifiedType: const FullType(CommissionRate),
                  )
                  as CommissionRate;
          result.commissionRate.replace(valueDes);
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
  CommissionLabelCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionLabelCreateBuilder();
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
