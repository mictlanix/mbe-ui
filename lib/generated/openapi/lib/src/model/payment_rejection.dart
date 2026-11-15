//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_rejection.g.dart';

/// A payment's latest rejection, read back from its incidence (#310).
///
/// Properties:
/// * [reason]
/// * [rejectedBy]
/// * [rejectedAt] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
@BuiltValue()
abstract class PaymentRejection
    implements Built<PaymentRejection, PaymentRejectionBuilder> {
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'rejected_by')
  int get rejectedBy;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'rejected_at')
  DateTime? get rejectedAt;

  PaymentRejection._();

  factory PaymentRejection([void updates(PaymentRejectionBuilder b)]) =
      _$PaymentRejection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentRejectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentRejection> get serializer =>
      _$PaymentRejectionSerializer();
}

class _$PaymentRejectionSerializer
    implements PrimitiveSerializer<PaymentRejection> {
  @override
  final Iterable<Type> types = const [PaymentRejection, _$PaymentRejection];

  @override
  final String wireName = r'PaymentRejection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentRejection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield object.reason == null
        ? null
        : serializers.serialize(
            object.reason,
            specifiedType: const FullType.nullable(String),
          );
    yield r'rejected_by';
    yield serializers.serialize(
      object.rejectedBy,
      specifiedType: const FullType(int),
    );
    yield r'rejected_at';
    yield object.rejectedAt == null
        ? null
        : serializers.serialize(
            object.rejectedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentRejection object, {
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
    required PaymentRejectionBuilder result,
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
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'rejected_by':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.rejectedBy = valueDes;
          break;
        case r'rejected_at':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.rejectedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentRejection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentRejectionBuilder();
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
