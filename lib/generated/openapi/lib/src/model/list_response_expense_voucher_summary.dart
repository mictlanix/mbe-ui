//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/expense_voucher_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_expense_voucher_summary.g.dart';

/// ListResponseExpenseVoucherSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseExpenseVoucherSummary
    implements
        Built<
          ListResponseExpenseVoucherSummary,
          ListResponseExpenseVoucherSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<ExpenseVoucherSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseExpenseVoucherSummary._();

  factory ListResponseExpenseVoucherSummary([
    void updates(ListResponseExpenseVoucherSummaryBuilder b),
  ]) = _$ListResponseExpenseVoucherSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseExpenseVoucherSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseExpenseVoucherSummary> get serializer =>
      _$ListResponseExpenseVoucherSummarySerializer();
}

class _$ListResponseExpenseVoucherSummarySerializer
    implements PrimitiveSerializer<ListResponseExpenseVoucherSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseExpenseVoucherSummary,
    _$ListResponseExpenseVoucherSummary,
  ];

  @override
  final String wireName = r'ListResponseExpenseVoucherSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseExpenseVoucherSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(ExpenseVoucherSummary),
      ]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListResponseExpenseVoucherSummary object, {
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
    required ListResponseExpenseVoucherSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(ExpenseVoucherSummary),
                    ]),
                  )
                  as BuiltList<ExpenseVoucherSummary>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListResponseExpenseVoucherSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseExpenseVoucherSummaryBuilder();
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
