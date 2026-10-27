//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/amount1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'expense_voucher_line_create.g.dart';

/// ExpenseVoucherLineCreate
///
/// Properties:
/// * [expense]
/// * [amount]
/// * [comment]
@BuiltValue()
abstract class ExpenseVoucherLineCreate
    implements
        Built<ExpenseVoucherLineCreate, ExpenseVoucherLineCreateBuilder> {
  @BuiltValueField(wireName: r'expense')
  int get expense;

  @BuiltValueField(wireName: r'amount')
  Amount1 get amount;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ExpenseVoucherLineCreate._();

  factory ExpenseVoucherLineCreate([
    void updates(ExpenseVoucherLineCreateBuilder b),
  ]) = _$ExpenseVoucherLineCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExpenseVoucherLineCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExpenseVoucherLineCreate> get serializer =>
      _$ExpenseVoucherLineCreateSerializer();
}

class _$ExpenseVoucherLineCreateSerializer
    implements PrimitiveSerializer<ExpenseVoucherLineCreate> {
  @override
  final Iterable<Type> types = const [
    ExpenseVoucherLineCreate,
    _$ExpenseVoucherLineCreate,
  ];

  @override
  final String wireName = r'ExpenseVoucherLineCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExpenseVoucherLineCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expense';
    yield serializers.serialize(
      object.expense,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(Amount1),
    );
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
    ExpenseVoucherLineCreate object, {
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
    required ExpenseVoucherLineCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expense':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.expense = valueDes;
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
  ExpenseVoucherLineCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExpenseVoucherLineCreateBuilder();
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
