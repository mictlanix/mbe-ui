//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/credit_limit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_create.g.dart';

/// SupplierCreate
///
/// Properties:
/// * [code]
/// * [name]
/// * [zone]
/// * [creditLimit]
/// * [creditDays]
/// * [comment]
@BuiltValue()
abstract class SupplierCreate
    implements Built<SupplierCreate, SupplierCreateBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'zone')
  String? get zone;

  @BuiltValueField(wireName: r'credit_limit')
  CreditLimit? get creditLimit;

  @BuiltValueField(wireName: r'credit_days')
  int? get creditDays;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SupplierCreate._();

  factory SupplierCreate([void updates(SupplierCreateBuilder b)]) =
      _$SupplierCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierCreateBuilder b) => b..creditDays = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierCreate> get serializer =>
      _$SupplierCreateSerializer();
}

class _$SupplierCreateSerializer
    implements PrimitiveSerializer<SupplierCreate> {
  @override
  final Iterable<Type> types = const [SupplierCreate, _$SupplierCreate];

  @override
  final String wireName = r'SupplierCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.zone != null) {
      yield r'zone';
      yield serializers.serialize(
        object.zone,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.creditLimit != null) {
      yield r'credit_limit';
      yield serializers.serialize(
        object.creditLimit,
        specifiedType: const FullType(CreditLimit),
      );
    }
    if (object.creditDays != null) {
      yield r'credit_days';
      yield serializers.serialize(
        object.creditDays,
        specifiedType: const FullType(int),
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
    SupplierCreate object, {
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
    required SupplierCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'zone':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.zone = valueDes;
          break;
        case r'credit_limit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(CreditLimit),
                  )
                  as CreditLimit;
          result.creditLimit.replace(valueDes);
          break;
        case r'credit_days':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creditDays = valueDes;
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
  SupplierCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierCreateBuilder();
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
