//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/opening_amount.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cash_session_open.g.dart';

/// CashSessionOpen
///
/// Properties:
/// * [cashDrawer]
/// * [openingAmount]
@BuiltValue()
abstract class CashSessionOpen
    implements Built<CashSessionOpen, CashSessionOpenBuilder> {
  @BuiltValueField(wireName: r'cash_drawer')
  int? get cashDrawer;

  @BuiltValueField(wireName: r'opening_amount')
  OpeningAmount? get openingAmount;

  CashSessionOpen._();

  factory CashSessionOpen([void updates(CashSessionOpenBuilder b)]) =
      _$CashSessionOpen;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CashSessionOpenBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CashSessionOpen> get serializer =>
      _$CashSessionOpenSerializer();
}

class _$CashSessionOpenSerializer
    implements PrimitiveSerializer<CashSessionOpen> {
  @override
  final Iterable<Type> types = const [CashSessionOpen, _$CashSessionOpen];

  @override
  final String wireName = r'CashSessionOpen';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CashSessionOpen object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.cashDrawer != null) {
      yield r'cash_drawer';
      yield serializers.serialize(
        object.cashDrawer,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.openingAmount != null) {
      yield r'opening_amount';
      yield serializers.serialize(
        object.openingAmount,
        specifiedType: const FullType(OpeningAmount),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CashSessionOpen object, {
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
    required CashSessionOpenBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cash_drawer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.cashDrawer = valueDes;
          break;
        case r'opening_amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(OpeningAmount),
                  )
                  as OpeningAmount;
          result.openingAmount.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CashSessionOpen deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CashSessionOpenBuilder();
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
