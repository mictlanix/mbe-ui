//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/rate1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'exchange_rate_update.g.dart';

/// ExchangeRateUpdate
///
/// Properties:
/// * [date]
/// * [rate]
/// * [base_]
/// * [target]
@BuiltValue()
abstract class ExchangeRateUpdate
    implements Built<ExchangeRateUpdate, ExchangeRateUpdateBuilder> {
  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'rate')
  Rate1? get rate;

  @BuiltValueField(wireName: r'base')
  int? get base_;

  @BuiltValueField(wireName: r'target')
  int? get target;

  ExchangeRateUpdate._();

  factory ExchangeRateUpdate([void updates(ExchangeRateUpdateBuilder b)]) =
      _$ExchangeRateUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExchangeRateUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExchangeRateUpdate> get serializer =>
      _$ExchangeRateUpdateSerializer();
}

class _$ExchangeRateUpdateSerializer
    implements PrimitiveSerializer<ExchangeRateUpdate> {
  @override
  final Iterable<Type> types = const [ExchangeRateUpdate, _$ExchangeRateUpdate];

  @override
  final String wireName = r'ExchangeRateUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExchangeRateUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.rate != null) {
      yield r'rate';
      yield serializers.serialize(
        object.rate,
        specifiedType: const FullType.nullable(Rate1),
      );
    }
    if (object.base_ != null) {
      yield r'base';
      yield serializers.serialize(
        object.base_,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.target != null) {
      yield r'target';
      yield serializers.serialize(
        object.target,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExchangeRateUpdate object, {
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
    required ExchangeRateUpdateBuilder result,
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
        case r'rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Rate1),
                  )
                  as Rate1?;
          if (valueDes == null) continue;
          result.rate.replace(valueDes);
          break;
        case r'base':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.base_ = valueDes;
          break;
        case r'target':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
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
  ExchangeRateUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExchangeRateUpdateBuilder();
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
