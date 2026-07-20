//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/commission1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method_option_update.g.dart';

/// PaymentMethodOptionUpdate
///
/// Properties:
/// * [facility]
/// * [warehouse]
/// * [name]
/// * [numberOfPayments]
/// * [displayOnTicket]
/// * [paymentMethod]
/// * [commission]
/// * [enabled]
@BuiltValue()
abstract class PaymentMethodOptionUpdate
    implements
        Built<PaymentMethodOptionUpdate, PaymentMethodOptionUpdateBuilder> {
  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'number_of_payments')
  int? get numberOfPayments;

  @BuiltValueField(wireName: r'display_on_ticket')
  bool? get displayOnTicket;

  @BuiltValueField(wireName: r'payment_method')
  int? get paymentMethod;

  @BuiltValueField(wireName: r'commission')
  Commission1? get commission;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  PaymentMethodOptionUpdate._();

  factory PaymentMethodOptionUpdate([
    void updates(PaymentMethodOptionUpdateBuilder b),
  ]) = _$PaymentMethodOptionUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentMethodOptionUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentMethodOptionUpdate> get serializer =>
      _$PaymentMethodOptionUpdateSerializer();
}

class _$PaymentMethodOptionUpdateSerializer
    implements PrimitiveSerializer<PaymentMethodOptionUpdate> {
  @override
  final Iterable<Type> types = const [
    PaymentMethodOptionUpdate,
    _$PaymentMethodOptionUpdate,
  ];

  @override
  final String wireName = r'PaymentMethodOptionUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentMethodOptionUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.numberOfPayments != null) {
      yield r'number_of_payments';
      yield serializers.serialize(
        object.numberOfPayments,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.displayOnTicket != null) {
      yield r'display_on_ticket';
      yield serializers.serialize(
        object.displayOnTicket,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.paymentMethod != null) {
      yield r'payment_method';
      yield serializers.serialize(
        object.paymentMethod,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.commission != null) {
      yield r'commission';
      yield serializers.serialize(
        object.commission,
        specifiedType: const FullType.nullable(Commission1),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType.nullable(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentMethodOptionUpdate object, {
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
    required PaymentMethodOptionUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.warehouse = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'number_of_payments':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.numberOfPayments = valueDes;
          break;
        case r'display_on_ticket':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
          if (valueDes == null) continue;
          result.displayOnTicket = valueDes;
          break;
        case r'payment_method':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.paymentMethod = valueDes;
          break;
        case r'commission':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Commission1),
                  )
                  as Commission1?;
          if (valueDes == null) continue;
          result.commission.replace(valueDes);
          break;
        case r'enabled':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
          if (valueDes == null) continue;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentMethodOptionUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentMethodOptionUpdateBuilder();
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
