//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'application.g.dart';

/// Application
///
/// Properties:
/// * [purchaseOrderPaymentId]
/// * [purchaseOrder]
/// * [amount]
/// * [applier]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [cancelled]
@BuiltValue()
abstract class Application implements Built<Application, ApplicationBuilder> {
  @BuiltValueField(wireName: r'purchase_order_payment_id')
  int get purchaseOrderPaymentId;

  @BuiltValueField(wireName: r'purchase_order')
  int get purchaseOrder;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'applier')
  int get applier;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'cancelled')
  bool get cancelled;

  Application._();

  factory Application([void updates(ApplicationBuilder b)]) = _$Application;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApplicationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Application> get serializer => _$ApplicationSerializer();
}

class _$ApplicationSerializer implements PrimitiveSerializer<Application> {
  @override
  final Iterable<Type> types = const [Application, _$Application];

  @override
  final String wireName = r'Application';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Application object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_order_payment_id';
    yield serializers.serialize(
      object.purchaseOrderPaymentId,
      specifiedType: const FullType(int),
    );
    yield r'purchase_order';
    yield serializers.serialize(
      object.purchaseOrder,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'applier';
    yield serializers.serialize(
      object.applier,
      specifiedType: const FullType(int),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'cancelled';
    yield serializers.serialize(
      object.cancelled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Application object, {
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
    required ApplicationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_order_payment_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseOrderPaymentId = valueDes;
          break;
        case r'purchase_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseOrder = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.amount = valueDes;
          break;
        case r'applier':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.applier = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
          break;
        case r'cancelled':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.cancelled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Application deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApplicationBuilder();
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
