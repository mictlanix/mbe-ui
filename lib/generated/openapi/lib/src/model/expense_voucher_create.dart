//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'expense_voucher_create.g.dart';

/// ExpenseVoucherCreate
///
/// Properties:
/// * [comment]
@BuiltValue()
abstract class ExpenseVoucherCreate
    implements Built<ExpenseVoucherCreate, ExpenseVoucherCreateBuilder> {
  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ExpenseVoucherCreate._();

  factory ExpenseVoucherCreate([void updates(ExpenseVoucherCreateBuilder b)]) =
      _$ExpenseVoucherCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExpenseVoucherCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExpenseVoucherCreate> get serializer =>
      _$ExpenseVoucherCreateSerializer();
}

class _$ExpenseVoucherCreateSerializer
    implements PrimitiveSerializer<ExpenseVoucherCreate> {
  @override
  final Iterable<Type> types = const [
    ExpenseVoucherCreate,
    _$ExpenseVoucherCreate,
  ];

  @override
  final String wireName = r'ExpenseVoucherCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExpenseVoucherCreate object, {
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
    ExpenseVoucherCreate object, {
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
    required ExpenseVoucherCreateBuilder result,
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
  ExpenseVoucherCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExpenseVoucherCreateBuilder();
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
