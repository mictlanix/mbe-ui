//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delivery_order_update.g.dart';

/// DeliveryOrderUpdate
///
/// Properties:
/// * [date]
/// * [priority]
/// * [shipTo]
/// * [contact]
/// * [comment]
@BuiltValue()
abstract class DeliveryOrderUpdate
    implements Built<DeliveryOrderUpdate, DeliveryOrderUpdateBuilder> {
  @BuiltValueField(wireName: r'date')
  DateTime? get date;

  @BuiltValueField(wireName: r'priority')
  int? get priority;

  @BuiltValueField(wireName: r'ship_to')
  int? get shipTo;

  @BuiltValueField(wireName: r'contact')
  int? get contact;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  DeliveryOrderUpdate._();

  factory DeliveryOrderUpdate([void updates(DeliveryOrderUpdateBuilder b)]) =
      _$DeliveryOrderUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeliveryOrderUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeliveryOrderUpdate> get serializer =>
      _$DeliveryOrderUpdateSerializer();
}

class _$DeliveryOrderUpdateSerializer
    implements PrimitiveSerializer<DeliveryOrderUpdate> {
  @override
  final Iterable<Type> types = const [
    DeliveryOrderUpdate,
    _$DeliveryOrderUpdate,
  ];

  @override
  final String wireName = r'DeliveryOrderUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeliveryOrderUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.priority != null) {
      yield r'priority';
      yield serializers.serialize(
        object.priority,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.shipTo != null) {
      yield r'ship_to';
      yield serializers.serialize(
        object.shipTo,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.contact != null) {
      yield r'contact';
      yield serializers.serialize(
        object.contact,
        specifiedType: const FullType.nullable(int),
      );
    }
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
    DeliveryOrderUpdate object, {
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
    required DeliveryOrderUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'priority':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.priority = valueDes;
          break;
        case r'ship_to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.shipTo = valueDes;
          break;
        case r'contact':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.contact = valueDes;
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
  DeliveryOrderUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeliveryOrderUpdateBuilder();
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
