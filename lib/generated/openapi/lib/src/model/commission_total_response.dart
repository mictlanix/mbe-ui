//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_total_response.g.dart';

/// CommissionTotalResponse
///
/// Properties:
/// * [salesperson]
/// * [label]
/// * [labelName]
/// * [lines]
/// * [commission]
@BuiltValue()
abstract class CommissionTotalResponse
    implements Built<CommissionTotalResponse, CommissionTotalResponseBuilder> {
  @BuiltValueField(wireName: r'salesperson')
  int get salesperson;

  @BuiltValueField(wireName: r'label')
  int? get label;

  @BuiltValueField(wireName: r'label_name')
  String? get labelName;

  @BuiltValueField(wireName: r'lines')
  int get lines;

  @BuiltValueField(wireName: r'commission')
  String get commission;

  CommissionTotalResponse._();

  factory CommissionTotalResponse([
    void updates(CommissionTotalResponseBuilder b),
  ]) = _$CommissionTotalResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionTotalResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionTotalResponse> get serializer =>
      _$CommissionTotalResponseSerializer();
}

class _$CommissionTotalResponseSerializer
    implements PrimitiveSerializer<CommissionTotalResponse> {
  @override
  final Iterable<Type> types = const [
    CommissionTotalResponse,
    _$CommissionTotalResponse,
  ];

  @override
  final String wireName = r'CommissionTotalResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionTotalResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'salesperson';
    yield serializers.serialize(
      object.salesperson,
      specifiedType: const FullType(int),
    );
    yield r'label';
    yield object.label == null
        ? null
        : serializers.serialize(
            object.label,
            specifiedType: const FullType.nullable(int),
          );
    yield r'label_name';
    yield object.labelName == null
        ? null
        : serializers.serialize(
            object.labelName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(int),
    );
    yield r'commission';
    yield serializers.serialize(
      object.commission,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionTotalResponse object, {
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
    required CommissionTotalResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'salesperson':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesperson = valueDes;
          break;
        case r'label':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'label_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.labelName = valueDes;
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lines = valueDes;
          break;
        case r'commission':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.commission = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionTotalResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionTotalResponseBuilder();
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
