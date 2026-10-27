//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/amount1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'application_item.g.dart';

/// ApplicationItem
///
/// Properties:
/// * [purchaseOrder]
/// * [amount]
@BuiltValue()
abstract class ApplicationItem
    implements Built<ApplicationItem, ApplicationItemBuilder> {
  @BuiltValueField(wireName: r'purchase_order')
  int get purchaseOrder;

  @BuiltValueField(wireName: r'amount')
  Amount1 get amount;

  ApplicationItem._();

  factory ApplicationItem([void updates(ApplicationItemBuilder b)]) =
      _$ApplicationItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApplicationItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApplicationItem> get serializer =>
      _$ApplicationItemSerializer();
}

class _$ApplicationItemSerializer
    implements PrimitiveSerializer<ApplicationItem> {
  @override
  final Iterable<Type> types = const [ApplicationItem, _$ApplicationItem];

  @override
  final String wireName = r'ApplicationItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApplicationItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_order';
    yield serializers.serialize(
      object.purchaseOrder,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Amount1),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApplicationItem object, {
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
    required ApplicationItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_order':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseOrder = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Amount1),
                  )
                  as Amount1;
          result.amount.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApplicationItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApplicationItemBuilder();
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
