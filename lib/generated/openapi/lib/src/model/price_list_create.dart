//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/low_profit_margin.dart';
import 'package:mbe_api_client/src/model/high_profit_margin.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'price_list_create.g.dart';

/// PriceListCreate
///
/// Properties:
/// * [name]
/// * [highProfitMargin]
/// * [lowProfitMargin]
@BuiltValue()
abstract class PriceListCreate
    implements Built<PriceListCreate, PriceListCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'high_profit_margin')
  HighProfitMargin? get highProfitMargin;

  @BuiltValueField(wireName: r'low_profit_margin')
  LowProfitMargin? get lowProfitMargin;

  PriceListCreate._();

  factory PriceListCreate([void updates(PriceListCreateBuilder b)]) =
      _$PriceListCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PriceListCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PriceListCreate> get serializer =>
      _$PriceListCreateSerializer();
}

class _$PriceListCreateSerializer
    implements PrimitiveSerializer<PriceListCreate> {
  @override
  final Iterable<Type> types = const [PriceListCreate, _$PriceListCreate];

  @override
  final String wireName = r'PriceListCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PriceListCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.highProfitMargin != null) {
      yield r'high_profit_margin';
      yield serializers.serialize(
        object.highProfitMargin,
        specifiedType: const FullType(HighProfitMargin),
      );
    }
    if (object.lowProfitMargin != null) {
      yield r'low_profit_margin';
      yield serializers.serialize(
        object.lowProfitMargin,
        specifiedType: const FullType(LowProfitMargin),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PriceListCreate object, {
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
    required PriceListCreateBuilder result,
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
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'high_profit_margin':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(HighProfitMargin),
                  )
                  as HighProfitMargin;
          result.highProfitMargin.replace(valueDes);
          break;
        case r'low_profit_margin':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(LowProfitMargin),
                  )
                  as LowProfitMargin;
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
  PriceListCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PriceListCreateBuilder();
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
