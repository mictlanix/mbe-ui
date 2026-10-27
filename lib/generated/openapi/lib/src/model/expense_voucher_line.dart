//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'expense_voucher_line.g.dart';

/// ExpenseVoucherLine
///
/// Properties:
/// * [expenseVoucherDetailId]
/// * [expense]
/// * [expenseName]
/// * [amount]
/// * [comment]
@BuiltValue()
abstract class ExpenseVoucherLine
    implements Built<ExpenseVoucherLine, ExpenseVoucherLineBuilder> {
  @BuiltValueField(wireName: r'expense_voucher_detail_id')
  int get expenseVoucherDetailId;

  @BuiltValueField(wireName: r'expense')
  int get expense;

  @BuiltValueField(wireName: r'expense_name')
  String? get expenseName;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ExpenseVoucherLine._();

  factory ExpenseVoucherLine([void updates(ExpenseVoucherLineBuilder b)]) =
      _$ExpenseVoucherLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExpenseVoucherLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExpenseVoucherLine> get serializer =>
      _$ExpenseVoucherLineSerializer();
}

class _$ExpenseVoucherLineSerializer
    implements PrimitiveSerializer<ExpenseVoucherLine> {
  @override
  final Iterable<Type> types = const [ExpenseVoucherLine, _$ExpenseVoucherLine];

  @override
  final String wireName = r'ExpenseVoucherLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExpenseVoucherLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expense_voucher_detail_id';
    yield serializers.serialize(
      object.expenseVoucherDetailId,
      specifiedType: const FullType(int),
    );
    yield r'expense';
    yield serializers.serialize(
      object.expense,
      specifiedType: const FullType(int),
    );
    yield r'expense_name';
    yield object.expenseName == null
        ? null
        : serializers.serialize(
            object.expenseName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExpenseVoucherLine object, {
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
    required ExpenseVoucherLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expense_voucher_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.expenseVoucherDetailId = valueDes;
          break;
        case r'expense':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.expense = valueDes;
          break;
        case r'expense_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.expenseName = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.amount = valueDes;
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
  ExpenseVoucherLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExpenseVoucherLineBuilder();
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
