//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stock_options.g.dart';

/// The windows and targets of velocity, cover, dead and slow stock and restock (R5).
///
/// Properties:
/// * [velocityDays] - 30-365
/// * [deadDays] - 90, 180 or 365
/// * [slowCoverDays] - 30-730
/// * [leadDays] - 0-120
/// * [coverDays] - 1-365
@BuiltValue()
abstract class StockOptions
    implements Built<StockOptions, StockOptionsBuilder> {
  /// 30-365
  @BuiltValueField(wireName: r'velocity_days')
  int? get velocityDays;

  /// 90, 180 or 365
  @BuiltValueField(wireName: r'dead_days')
  int? get deadDays;

  /// 30-730
  @BuiltValueField(wireName: r'slow_cover_days')
  int? get slowCoverDays;

  /// 0-120
  @BuiltValueField(wireName: r'lead_days')
  int? get leadDays;

  /// 1-365
  @BuiltValueField(wireName: r'cover_days')
  int? get coverDays;

  StockOptions._();

  factory StockOptions([void updates(StockOptionsBuilder b)]) = _$StockOptions;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StockOptionsBuilder b) => b
    ..velocityDays = 90
    ..deadDays = 180
    ..slowCoverDays = 180;

  @BuiltValueSerializer(custom: true)
  static Serializer<StockOptions> get serializer => _$StockOptionsSerializer();
}

class _$StockOptionsSerializer implements PrimitiveSerializer<StockOptions> {
  @override
  final Iterable<Type> types = const [StockOptions, _$StockOptions];

  @override
  final String wireName = r'StockOptions';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StockOptions object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.velocityDays != null) {
      yield r'velocity_days';
      yield serializers.serialize(
        object.velocityDays,
        specifiedType: const FullType(int),
      );
    }
    if (object.deadDays != null) {
      yield r'dead_days';
      yield serializers.serialize(
        object.deadDays,
        specifiedType: const FullType(int),
      );
    }
    if (object.slowCoverDays != null) {
      yield r'slow_cover_days';
      yield serializers.serialize(
        object.slowCoverDays,
        specifiedType: const FullType(int),
      );
    }
    if (object.leadDays != null) {
      yield r'lead_days';
      yield serializers.serialize(
        object.leadDays,
        specifiedType: const FullType(int),
      );
    }
    if (object.coverDays != null) {
      yield r'cover_days';
      yield serializers.serialize(
        object.coverDays,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StockOptions object, {
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
    required StockOptionsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'velocity_days':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.velocityDays = valueDes;
          break;
        case r'dead_days':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.deadDays = valueDes;
          break;
        case r'slow_cover_days':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.slowCoverDays = valueDes;
          break;
        case r'lead_days':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.leadDays = valueDes;
          break;
        case r'cover_days':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.coverDays = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StockOptions deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StockOptionsBuilder();
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
