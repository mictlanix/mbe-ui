//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'itinerary_update.g.dart';

/// ItineraryUpdate
///
/// Properties:
/// * [date]
/// * [vehicle]
/// * [vehicleOperator]
/// * [comment]
@BuiltValue()
abstract class ItineraryUpdate
    implements Built<ItineraryUpdate, ItineraryUpdateBuilder> {
  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'vehicle')
  int? get vehicle;

  @BuiltValueField(wireName: r'vehicle_operator')
  int? get vehicleOperator;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ItineraryUpdate._();

  factory ItineraryUpdate([void updates(ItineraryUpdateBuilder b)]) =
      _$ItineraryUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItineraryUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItineraryUpdate> get serializer =>
      _$ItineraryUpdateSerializer();
}

class _$ItineraryUpdateSerializer
    implements PrimitiveSerializer<ItineraryUpdate> {
  @override
  final Iterable<Type> types = const [ItineraryUpdate, _$ItineraryUpdate];

  @override
  final String wireName = r'ItineraryUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItineraryUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.vehicle != null) {
      yield r'vehicle';
      yield serializers.serialize(
        object.vehicle,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.vehicleOperator != null) {
      yield r'vehicle_operator';
      yield serializers.serialize(
        object.vehicleOperator,
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
    ItineraryUpdate object, {
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
    required ItineraryUpdateBuilder result,
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
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'vehicle':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.vehicle = valueDes;
          break;
        case r'vehicle_operator':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.vehicleOperator = valueDes;
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
  ItineraryUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItineraryUpdateBuilder();
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
