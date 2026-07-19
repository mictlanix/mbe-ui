//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/high_profit_margin1.dart';
import 'package:mbe_api_client/src/model/low_profit_margin1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'price_list_update.g.dart';

/// PriceListUpdate
///
/// Properties:
/// * [name]
/// * [highProfitMargin]
/// * [lowProfitMargin]
@BuiltValue()
abstract class PriceListUpdate
    implements Built<PriceListUpdate, PriceListUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'high_profit_margin')
  HighProfitMargin1? get highProfitMargin;

  @BuiltValueField(wireName: r'low_profit_margin')
  LowProfitMargin1? get lowProfitMargin;

  PriceListUpdate._();

  factory PriceListUpdate([void updates(PriceListUpdateBuilder b)]) =
      _$PriceListUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PriceListUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PriceListUpdate> get serializer =>
      _$PriceListUpdateSerializer();
}

class _$PriceListUpdateSerializer
    implements PrimitiveSerializer<PriceListUpdate> {
  @override
  final Iterable<Type> types = const [PriceListUpdate, _$PriceListUpdate];

  @override
  final String wireName = r'PriceListUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PriceListUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.highProfitMargin != null) {
      yield r'high_profit_margin';
      yield serializers.serialize(
        object.highProfitMargin,
        specifiedType: const FullType.nullable(HighProfitMargin1),
      );
    }
    if (object.lowProfitMargin != null) {
      yield r'low_profit_margin';
      yield serializers.serialize(
        object.lowProfitMargin,
        specifiedType: const FullType.nullable(LowProfitMargin1),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PriceListUpdate object, {
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
    required PriceListUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'high_profit_margin':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(HighProfitMargin1),
                  )
                  as HighProfitMargin1?;
          if (valueDes == null) continue;
          result.highProfitMargin.replace(valueDes);
          break;
        case r'low_profit_margin':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(LowProfitMargin1),
                  )
                  as LowProfitMargin1?;
          if (valueDes == null) continue;
          result.lowProfitMargin.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PriceListUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PriceListUpdateBuilder();
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
