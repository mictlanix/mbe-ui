//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'expense_response.g.dart';

/// ExpenseResponse
///
/// Properties:
/// * [expenseId] 
/// * [expense] 
/// * [comment] 
@BuiltValue()
abstract class ExpenseResponse implements Built<ExpenseResponse, ExpenseResponseBuilder> {
  @BuiltValueField(wireName: r'expense_id')
  int get expenseId;

  @BuiltValueField(wireName: r'expense')
  String get expense;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ExpenseResponse._();

  factory ExpenseResponse([void updates(ExpenseResponseBuilder b)]) = _$ExpenseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExpenseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExpenseResponse> get serializer => _$ExpenseResponseSerializer();
}

class _$ExpenseResponseSerializer implements PrimitiveSerializer<ExpenseResponse> {
  @override
  final Iterable<Type> types = const [ExpenseResponse, _$ExpenseResponse];

  @override
  final String wireName = r'ExpenseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExpenseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expense_id';
    yield serializers.serialize(
      object.expenseId,
      specifiedType: const FullType(int),
    );
    yield r'expense';
    yield serializers.serialize(
      object.expense,
      specifiedType: const FullType(String),
    );
    yield r'comment';
    yield object.comment == null ? null : serializers.serialize(
      object.comment,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExpenseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExpenseResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expense_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expenseId = valueDes;
          break;
        case r'expense':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expense = valueDes;
          break;
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
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
  ExpenseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExpenseResponseBuilder();
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

