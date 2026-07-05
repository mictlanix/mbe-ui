//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/store_summary.dart';
import 'package:mbe_api_client/src/model/warehouse_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method_option_response.g.dart';

/// PaymentMethodOptionResponse
///
/// Properties:
/// * [paymentMethodOptionId] 
/// * [store] 
/// * [warehouse] 
/// * [name] 
/// * [numberOfPayments] 
/// * [displayOnTicket] 
/// * [paymentMethod] 
/// * [commission] 
/// * [enabled] 
@BuiltValue()
abstract class PaymentMethodOptionResponse implements Built<PaymentMethodOptionResponse, PaymentMethodOptionResponseBuilder> {
  @BuiltValueField(wireName: r'payment_method_option_id')
  int get paymentMethodOptionId;

  @BuiltValueField(wireName: r'store')
  StoreSummary get store;

  @BuiltValueField(wireName: r'warehouse')
  WarehouseSummary? get warehouse;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'number_of_payments')
  int get numberOfPayments;

  @BuiltValueField(wireName: r'display_on_ticket')
  bool get displayOnTicket;

  @BuiltValueField(wireName: r'payment_method')
  int get paymentMethod;

  @BuiltValueField(wireName: r'commission')
  String get commission;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  PaymentMethodOptionResponse._();

  factory PaymentMethodOptionResponse([void updates(PaymentMethodOptionResponseBuilder b)]) = _$PaymentMethodOptionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentMethodOptionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentMethodOptionResponse> get serializer => _$PaymentMethodOptionResponseSerializer();
}

class _$PaymentMethodOptionResponseSerializer implements PrimitiveSerializer<PaymentMethodOptionResponse> {
  @override
  final Iterable<Type> types = const [PaymentMethodOptionResponse, _$PaymentMethodOptionResponse];

  @override
  final String wireName = r'PaymentMethodOptionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentMethodOptionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'payment_method_option_id';
    yield serializers.serialize(
      object.paymentMethodOptionId,
      specifiedType: const FullType(int),
    );
    yield r'store';
    yield serializers.serialize(
      object.store,
      specifiedType: const FullType(StoreSummary),
    );
    yield r'warehouse';
    yield object.warehouse == null ? null : serializers.serialize(
      object.warehouse,
      specifiedType: const FullType.nullable(WarehouseSummary),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'number_of_payments';
    yield serializers.serialize(
      object.numberOfPayments,
      specifiedType: const FullType(int),
    );
    yield r'display_on_ticket';
    yield serializers.serialize(
      object.displayOnTicket,
      specifiedType: const FullType(bool),
    );
    yield r'payment_method';
    yield serializers.serialize(
      object.paymentMethod,
      specifiedType: const FullType(int),
    );
    yield r'commission';
    yield serializers.serialize(
      object.commission,
      specifiedType: const FullType(String),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentMethodOptionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentMethodOptionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'payment_method_option_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.paymentMethodOptionId = valueDes;
          break;
        case r'store':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StoreSummary),
          ) as StoreSummary;
          result.store.replace(valueDes);
          break;
        case r'warehouse':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WarehouseSummary),
          ) as WarehouseSummary?;
          if (valueDes == null) continue;
          result.warehouse.replace(valueDes);
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
            specifiedType: const FullType(String),
          ) as String;
          result.commission = valueDes;
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
  PaymentMethodOptionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentMethodOptionResponseBuilder();
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

