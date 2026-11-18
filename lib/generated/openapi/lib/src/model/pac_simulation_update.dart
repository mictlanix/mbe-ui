//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pac_simulation_update.g.dart';

/// The outcome of the document's next stamp or cancellation call only. `pac_code` and `pac_message` are a `rejected` outcome's, as the `pac_simulation` columns hold them.
///
/// Properties:
/// * [stamp]
/// * [cancellation]
/// * [pacCode]
/// * [pacMessage]
@BuiltValue()
abstract class PacSimulationUpdate
    implements Built<PacSimulationUpdate, PacSimulationUpdateBuilder> {
  @BuiltValueField(wireName: r'stamp')
  PacSimulationUpdateStampEnum? get stamp;
  // enum stampEnum {  stamped,  rejected,  unavailable,  timeout_stamped,  timeout_not_stamped,  };

  @BuiltValueField(wireName: r'cancellation')
  PacSimulationUpdateCancellationEnum? get cancellation;
  // enum cancellationEnum {  accepted,  pending,  not_cancellable,  rejected,  unavailable,  timeout,  };

  @BuiltValueField(wireName: r'pac_code')
  String? get pacCode;

  @BuiltValueField(wireName: r'pac_message')
  String? get pacMessage;

  PacSimulationUpdate._();

  factory PacSimulationUpdate([void updates(PacSimulationUpdateBuilder b)]) =
      _$PacSimulationUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PacSimulationUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PacSimulationUpdate> get serializer =>
      _$PacSimulationUpdateSerializer();
}

class _$PacSimulationUpdateSerializer
    implements PrimitiveSerializer<PacSimulationUpdate> {
  @override
  final Iterable<Type> types = const [
    PacSimulationUpdate,
    _$PacSimulationUpdate,
  ];

  @override
  final String wireName = r'PacSimulationUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PacSimulationUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.stamp != null) {
      yield r'stamp';
      yield serializers.serialize(
        object.stamp,
        specifiedType: const FullType.nullable(PacSimulationUpdateStampEnum),
      );
    }
    if (object.cancellation != null) {
      yield r'cancellation';
      yield serializers.serialize(
        object.cancellation,
        specifiedType: const FullType.nullable(
          PacSimulationUpdateCancellationEnum,
        ),
      );
    }
    if (object.pacCode != null) {
      yield r'pac_code';
      yield serializers.serialize(
        object.pacCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.pacMessage != null) {
      yield r'pac_message';
      yield serializers.serialize(
        object.pacMessage,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PacSimulationUpdate object, {
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
    required PacSimulationUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stamp':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      PacSimulationUpdateStampEnum,
                    ),
                  )
                  as PacSimulationUpdateStampEnum?;
          if (valueDes == null) continue;
          result.stamp = valueDes;
          break;
        case r'cancellation':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(
                      PacSimulationUpdateCancellationEnum,
                    ),
                  )
                  as PacSimulationUpdateCancellationEnum?;
          if (valueDes == null) continue;
          result.cancellation = valueDes;
          break;
        case r'pac_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.pacCode = valueDes;
          break;
        case r'pac_message':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.pacMessage = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PacSimulationUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PacSimulationUpdateBuilder();
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

class PacSimulationUpdateStampEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'stamped')
  static const PacSimulationUpdateStampEnum stamped =
      _$pacSimulationUpdateStampEnum_stamped;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const PacSimulationUpdateStampEnum rejected =
      _$pacSimulationUpdateStampEnum_rejected;
  @BuiltValueEnumConst(wireName: r'unavailable')
  static const PacSimulationUpdateStampEnum unavailable =
      _$pacSimulationUpdateStampEnum_unavailable;
  @BuiltValueEnumConst(wireName: r'timeout_stamped')
  static const PacSimulationUpdateStampEnum timeoutStamped =
      _$pacSimulationUpdateStampEnum_timeoutStamped;
  @BuiltValueEnumConst(wireName: r'timeout_not_stamped')
  static const PacSimulationUpdateStampEnum timeoutNotStamped =
      _$pacSimulationUpdateStampEnum_timeoutNotStamped;

  static Serializer<PacSimulationUpdateStampEnum> get serializer =>
      _$pacSimulationUpdateStampEnumSerializer;

  const PacSimulationUpdateStampEnum._(String name) : super(name);

  static BuiltSet<PacSimulationUpdateStampEnum> get values =>
      _$pacSimulationUpdateStampEnumValues;
  static PacSimulationUpdateStampEnum valueOf(String name) =>
      _$pacSimulationUpdateStampEnumValueOf(name);
}

class PacSimulationUpdateCancellationEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accepted')
  static const PacSimulationUpdateCancellationEnum accepted =
      _$pacSimulationUpdateCancellationEnum_accepted;
  @BuiltValueEnumConst(wireName: r'pending')
  static const PacSimulationUpdateCancellationEnum pending =
      _$pacSimulationUpdateCancellationEnum_pending;
  @BuiltValueEnumConst(wireName: r'not_cancellable')
  static const PacSimulationUpdateCancellationEnum notCancellable =
      _$pacSimulationUpdateCancellationEnum_notCancellable;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const PacSimulationUpdateCancellationEnum rejected =
      _$pacSimulationUpdateCancellationEnum_rejected;
  @BuiltValueEnumConst(wireName: r'unavailable')
  static const PacSimulationUpdateCancellationEnum unavailable =
      _$pacSimulationUpdateCancellationEnum_unavailable;
  @BuiltValueEnumConst(wireName: r'timeout')
  static const PacSimulationUpdateCancellationEnum timeout =
      _$pacSimulationUpdateCancellationEnum_timeout;

  static Serializer<PacSimulationUpdateCancellationEnum> get serializer =>
      _$pacSimulationUpdateCancellationEnumSerializer;

  const PacSimulationUpdateCancellationEnum._(String name) : super(name);

  static BuiltSet<PacSimulationUpdateCancellationEnum> get values =>
      _$pacSimulationUpdateCancellationEnumValues;
  static PacSimulationUpdateCancellationEnum valueOf(String name) =>
      _$pacSimulationUpdateCancellationEnumValueOf(name);
}
