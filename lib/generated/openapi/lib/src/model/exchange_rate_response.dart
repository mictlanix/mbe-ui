//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'exchange_rate_response.g.dart';

/// ExchangeRateResponse
///
/// Properties:
/// * [exchangeRateId]
/// * [date]
/// * [rate]
/// * [base_]
/// * [target]
@BuiltValue()
abstract class ExchangeRateResponse
    implements Built<ExchangeRateResponse, ExchangeRateResponseBuilder> {
  @BuiltValueField(wireName: r'exchange_rate_id')
  int get exchangeRateId;

  @BuiltValueField(wireName: r'date')
  Date get date;

  @BuiltValueField(wireName: r'rate')
  String get rate;

  @BuiltValueField(wireName: r'base')
  int get base_;

  @BuiltValueField(wireName: r'target')
  int get target;

  ExchangeRateResponse._();

  factory ExchangeRateResponse([void updates(ExchangeRateResponseBuilder b)]) =
      _$ExchangeRateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExchangeRateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExchangeRateResponse> get serializer =>
      _$ExchangeRateResponseSerializer();
}

class _$ExchangeRateResponseSerializer
    implements PrimitiveSerializer<ExchangeRateResponse> {
  @override
  final Iterable<Type> types = const [
    ExchangeRateResponse,
    _$ExchangeRateResponse,
  ];

  @override
  final String wireName = r'ExchangeRateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExchangeRateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'exchange_rate_id';
    yield serializers.serialize(
      object.exchangeRateId,
      specifiedType: const FullType(int),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(Date),
    );
    yield r'rate';
    yield serializers.serialize(
      object.rate,
      specifiedType: const FullType(String),
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
    ExchangeRateResponse object, {
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
    required ExchangeRateResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'exchange_rate_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.exchangeRateId = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.date = valueDes;
          break;
        case r'rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.rate = valueDes;
          break;
        case r'base':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.base_ = valueDes;
          break;
        case r'target':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
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
  ExchangeRateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExchangeRateResponseBuilder();
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
