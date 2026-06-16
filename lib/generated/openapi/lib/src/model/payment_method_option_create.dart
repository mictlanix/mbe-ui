//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/commission.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method_option_create.g.dart';

/// PaymentMethodOptionCreate
///
/// Properties:
/// * [store] 
/// * [warehouse] 
/// * [name] 
/// * [numberOfPayments] 
/// * [displayOnTicket] 
/// * [paymentMethod] 
/// * [commission] 
/// * [enabled] 
@BuiltValue()
abstract class PaymentMethodOptionCreate implements Built<PaymentMethodOptionCreate, PaymentMethodOptionCreateBuilder> {
  @BuiltValueField(wireName: r'store')
  int get store;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'number_of_payments')
  int? get numberOfPayments;

  @BuiltValueField(wireName: r'display_on_ticket')
  bool? get displayOnTicket;

  @BuiltValueField(wireName: r'payment_method')
  int get paymentMethod;

  @BuiltValueField(wireName: r'commission')
  Commission? get commission;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  PaymentMethodOptionCreate._();

  factory PaymentMethodOptionCreate([void updates(PaymentMethodOptionCreateBuilder b)]) = _$PaymentMethodOptionCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentMethodOptionCreateBuilder b) => b
      ..numberOfPayments = 1
      ..displayOnTicket = true
      ..enabled = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentMethodOptionCreate> get serializer => _$PaymentMethodOptionCreateSerializer();
}

class _$PaymentMethodOptionCreateSerializer implements PrimitiveSerializer<PaymentMethodOptionCreate> {
  @override
  final Iterable<Type> types = const [PaymentMethodOptionCreate, _$PaymentMethodOptionCreate];

  @override
  final String wireName = r'PaymentMethodOptionCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentMethodOptionCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'store';
    yield serializers.serialize(
      object.store,
      specifiedType: const FullType(int),
    );
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.numberOfPayments != null) {
      yield r'number_of_payments';
      yield serializers.serialize(
        object.numberOfPayments,
        specifiedType: const FullType(int),
      );
    }
    if (object.displayOnTicket != null) {
      yield r'display_on_ticket';
      yield serializers.serialize(
        object.displayOnTicket,
        specifiedType: const FullType(bool),
      );
    }
    yield r'payment_method';
    yield serializers.serialize(
      object.paymentMethod,
      specifiedType: const FullType(int),
    );
    if (object.commission != null) {
      yield r'commission';
      yield serializers.serialize(
        object.commission,
        specifiedType: const FullType(Commission),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentMethodOptionCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentMethodOptionCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'store':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.store = valueDes;
          break;
        case r'warehouse':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warehouse = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'number_of_payments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.numberOfPayments = valueDes;
          break;
        case r'display_on_ticket':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.displayOnTicket = valueDes;
          break;
        case r'payment_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.paymentMethod = valueDes;
          break;
        case r'commission':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Commission),
          ) as Commission;
          result.commission.replace(valueDes);
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
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
  PaymentMethodOptionCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentMethodOptionCreateBuilder();
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

