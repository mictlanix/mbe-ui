//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/denomination.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'denomination_count.g.dart';

/// DenominationCount
///
/// Properties:
/// * [denomination]
/// * [quantity]
@BuiltValue()
abstract class DenominationCount
    implements Built<DenominationCount, DenominationCountBuilder> {
  @BuiltValueField(wireName: r'denomination')
  Denomination get denomination;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  DenominationCount._();

  factory DenominationCount([void updates(DenominationCountBuilder b)]) =
      _$DenominationCount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DenominationCountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DenominationCount> get serializer =>
      _$DenominationCountSerializer();
}

class _$DenominationCountSerializer
    implements PrimitiveSerializer<DenominationCount> {
  @override
  final Iterable<Type> types = const [DenominationCount, _$DenominationCount];

  @override
  final String wireName = r'DenominationCount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DenominationCount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'denomination';
    yield serializers.serialize(
      object.denomination,
      specifiedType: const FullType(Denomination),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DenominationCount object, {
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
    required DenominationCountBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'denomination':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Denomination),
                  )
                  as Denomination;
          result.denomination.replace(valueDes);
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.quantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DenominationCount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DenominationCountBuilder();
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
