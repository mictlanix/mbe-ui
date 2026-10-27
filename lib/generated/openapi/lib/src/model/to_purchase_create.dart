//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'to_purchase_create.g.dart';

/// ToPurchaseCreate
///
/// Properties:
/// * [supplier]
/// * [facility]
@BuiltValue()
abstract class ToPurchaseCreate
    implements Built<ToPurchaseCreate, ToPurchaseCreateBuilder> {
  @BuiltValueField(wireName: r'supplier')
  int get supplier;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  ToPurchaseCreate._();

  factory ToPurchaseCreate([void updates(ToPurchaseCreateBuilder b)]) =
      _$ToPurchaseCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ToPurchaseCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ToPurchaseCreate> get serializer =>
      _$ToPurchaseCreateSerializer();
}

class _$ToPurchaseCreateSerializer
    implements PrimitiveSerializer<ToPurchaseCreate> {
  @override
  final Iterable<Type> types = const [ToPurchaseCreate, _$ToPurchaseCreate];

  @override
  final String wireName = r'ToPurchaseCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ToPurchaseCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier';
    yield serializers.serialize(
      object.supplier,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ToPurchaseCreate object, {
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
    required ToPurchaseCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.supplier = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ToPurchaseCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ToPurchaseCreateBuilder();
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
