//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/amount2.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'expense_voucher_line_update.g.dart';

/// ExpenseVoucherLineUpdate
///
/// Properties:
/// * [expense]
/// * [amount]
/// * [comment]
@BuiltValue()
abstract class ExpenseVoucherLineUpdate
    implements
        Built<ExpenseVoucherLineUpdate, ExpenseVoucherLineUpdateBuilder> {
  @BuiltValueField(wireName: r'expense')
  int? get expense;

  @BuiltValueField(wireName: r'amount')
  Amount2? get amount;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ExpenseVoucherLineUpdate._();

  factory ExpenseVoucherLineUpdate([
    void updates(ExpenseVoucherLineUpdateBuilder b),
  ]) = _$ExpenseVoucherLineUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExpenseVoucherLineUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExpenseVoucherLineUpdate> get serializer =>
      _$ExpenseVoucherLineUpdateSerializer();
}

class _$ExpenseVoucherLineUpdateSerializer
    implements PrimitiveSerializer<ExpenseVoucherLineUpdate> {
  @override
  final Iterable<Type> types = const [
    ExpenseVoucherLineUpdate,
    _$ExpenseVoucherLineUpdate,
  ];

  @override
  final String wireName = r'ExpenseVoucherLineUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExpenseVoucherLineUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.expense != null) {
      yield r'expense';
      yield serializers.serialize(
        object.expense,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType.nullable(Amount2),
      );
    }
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
    ExpenseVoucherLineUpdate object, {
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
    required ExpenseVoucherLineUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expense':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.expense = valueDes;
          break;
        case r'amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Amount2),
                  )
                  as Amount2?;
          if (valueDes == null) continue;
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
  ExpenseVoucherLineUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExpenseVoucherLineUpdateBuilder();
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
