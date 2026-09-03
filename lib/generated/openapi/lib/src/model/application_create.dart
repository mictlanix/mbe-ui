//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/amount.dart';
import 'package:mbe_api_client/src/model/amount_change.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'application_create.g.dart';

/// ApplicationCreate
///
/// Properties:
/// * [salesOrder]
/// * [amount]
/// * [amountChange]
@BuiltValue()
abstract class ApplicationCreate
    implements Built<ApplicationCreate, ApplicationCreateBuilder> {
  @BuiltValueField(wireName: r'sales_order')
  int get salesOrder;

  @BuiltValueField(wireName: r'amount')
  Amount get amount;

  @BuiltValueField(wireName: r'amount_change')
  AmountChange? get amountChange;

  ApplicationCreate._();

  factory ApplicationCreate([void updates(ApplicationCreateBuilder b)]) =
      _$ApplicationCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApplicationCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApplicationCreate> get serializer =>
      _$ApplicationCreateSerializer();
}

class _$ApplicationCreateSerializer
    implements PrimitiveSerializer<ApplicationCreate> {
  @override
  final Iterable<Type> types = const [ApplicationCreate, _$ApplicationCreate];

  @override
  final String wireName = r'ApplicationCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApplicationCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sales_order';
    yield serializers.serialize(
      object.salesOrder,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Amount),
    );
    if (object.amountChange != null) {
      yield r'amount_change';
      yield serializers.serialize(
        object.amountChange,
        specifiedType: const FullType(AmountChange),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ApplicationCreate object, {
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
    required ApplicationCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sales_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.salesOrder = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Amount),
                  )
                  as Amount;
          result.amount.replace(valueDes);
          break;
        case r'amount_change':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(AmountChange),
                  )
                  as AmountChange?;
          if (valueDes == null) continue;
          result.amountChange.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApplicationCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApplicationCreateBuilder();
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
