//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'in_transit_stock.g.dart';

/// InTransitStock
///
/// Properties:
/// * [facility]
/// * [warehouse]
/// * [onHand]
@BuiltValue()
abstract class InTransitStock
    implements Built<InTransitStock, InTransitStockBuilder> {
  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'on_hand')
  String get onHand;

  InTransitStock._();

  factory InTransitStock([void updates(InTransitStockBuilder b)]) =
      _$InTransitStock;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InTransitStockBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InTransitStock> get serializer =>
      _$InTransitStockSerializer();
}

class _$InTransitStockSerializer
    implements PrimitiveSerializer<InTransitStock> {
  @override
  final Iterable<Type> types = const [InTransitStock, _$InTransitStock];

  @override
  final String wireName = r'InTransitStock';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InTransitStock object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'on_hand';
    yield serializers.serialize(
      object.onHand,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InTransitStock object, {
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
    required InTransitStockBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
        case r'on_hand':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.onHand = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InTransitStock deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InTransitStockBuilder();
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
