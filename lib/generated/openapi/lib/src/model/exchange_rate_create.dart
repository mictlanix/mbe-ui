//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/rate.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'exchange_rate_create.g.dart';

/// ExchangeRateCreate
///
/// Properties:
/// * [date] 
/// * [rate] 
/// * [base_] 
/// * [target] 
@BuiltValue()
abstract class ExchangeRateCreate implements Built<ExchangeRateCreate, ExchangeRateCreateBuilder> {
  @BuiltValueField(wireName: r'date')
  Date get date;

  @BuiltValueField(wireName: r'rate')
  Rate get rate;

  @BuiltValueField(wireName: r'base')
  int get base_;

  @BuiltValueField(wireName: r'target')
  int get target;

  ExchangeRateCreate._();

  factory ExchangeRateCreate([void updates(ExchangeRateCreateBuilder b)]) = _$ExchangeRateCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExchangeRateCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExchangeRateCreate> get serializer => _$ExchangeRateCreateSerializer();
}

class _$ExchangeRateCreateSerializer implements PrimitiveSerializer<ExchangeRateCreate> {
  @override
  final Iterable<Type> types = const [ExchangeRateCreate, _$ExchangeRateCreate];

  @override
  final String wireName = r'ExchangeRateCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExchangeRateCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(Date),
    );
    yield r'rate';
    yield serializers.serialize(
      object.rate,
      specifiedType: const FullType(Rate),
    );
    yield r'base';
    yield serializers.serialize(
      object.base_,
      specifiedType: const FullType(int),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExchangeRateCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExchangeRateCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.date = valueDes;
          break;
        case r'rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Rate),
          ) as Rate;
          result.rate.replace(valueDes);
          break;
        case r'base':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.base_ = valueDes;
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.target = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExchangeRateCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExchangeRateCreateBuilder();
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

