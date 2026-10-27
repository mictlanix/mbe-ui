//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'expense_voucher_update.g.dart';

/// ExpenseVoucherUpdate
///
/// Properties:
/// * [comment]
@BuiltValue()
abstract class ExpenseVoucherUpdate
    implements Built<ExpenseVoucherUpdate, ExpenseVoucherUpdateBuilder> {
  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ExpenseVoucherUpdate._();

  factory ExpenseVoucherUpdate([void updates(ExpenseVoucherUpdateBuilder b)]) =
      _$ExpenseVoucherUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExpenseVoucherUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExpenseVoucherUpdate> get serializer =>
      _$ExpenseVoucherUpdateSerializer();
}

class _$ExpenseVoucherUpdateSerializer
    implements PrimitiveSerializer<ExpenseVoucherUpdate> {
  @override
  final Iterable<Type> types = const [
    ExpenseVoucherUpdate,
    _$ExpenseVoucherUpdate,
  ];

  @override
  final String wireName = r'ExpenseVoucherUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExpenseVoucherUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExpenseVoucherUpdate object, {
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
    required ExpenseVoucherUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExpenseVoucherUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExpenseVoucherUpdateBuilder();
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
