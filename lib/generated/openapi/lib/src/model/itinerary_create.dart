//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'itinerary_create.g.dart';

/// ItineraryCreate
///
/// Properties:
/// * [date]
/// * [vehicle]
/// * [vehicleOperator]
/// * [warehouse]
/// * [comment]
@BuiltValue()
abstract class ItineraryCreate
    implements Built<ItineraryCreate, ItineraryCreateBuilder> {
  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'vehicle')
  int? get vehicle;

  @BuiltValueField(wireName: r'vehicle_operator')
  int? get vehicleOperator;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ItineraryCreate._();

  factory ItineraryCreate([void updates(ItineraryCreateBuilder b)]) =
      _$ItineraryCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ItineraryCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ItineraryCreate> get serializer =>
      _$ItineraryCreateSerializer();
}

class _$ItineraryCreateSerializer
    implements PrimitiveSerializer<ItineraryCreate> {
  @override
  final Iterable<Type> types = const [ItineraryCreate, _$ItineraryCreate];

  @override
  final String wireName = r'ItineraryCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ItineraryCreate object, {
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
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
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
    ItineraryCreate object, {
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
    required ItineraryCreateBuilder result,
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
  ItineraryCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ItineraryCreateBuilder();
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
