//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/credit_limit1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_update.g.dart';

/// SupplierUpdate
///
/// Properties:
/// * [code] 
/// * [name] 
/// * [zone] 
/// * [creditLimit] 
/// * [creditDays] 
/// * [comment] 
@BuiltValue()
abstract class SupplierUpdate implements Built<SupplierUpdate, SupplierUpdateBuilder> {
  @BuiltValueField(wireName: r'code')
  String? get code;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'zone')
  String? get zone;

  @BuiltValueField(wireName: r'credit_limit')
  CreditLimit1? get creditLimit;

  @BuiltValueField(wireName: r'credit_days')
  int? get creditDays;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SupplierUpdate._();

  factory SupplierUpdate([void updates(SupplierUpdateBuilder b)]) = _$SupplierUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierUpdate> get serializer => _$SupplierUpdateSerializer();
}

class _$SupplierUpdateSerializer implements PrimitiveSerializer<SupplierUpdate> {
  @override
  final Iterable<Type> types = const [SupplierUpdate, _$SupplierUpdate];

  @override
  final String wireName = r'SupplierUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
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
        specifiedType: const FullType.nullable(CreditLimit1),
      );
    }
    if (object.creditDays != null) {
      yield r'credit_days';
      yield serializers.serialize(
        object.creditDays,
        specifiedType: const FullType.nullable(int),
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
    SupplierUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'zone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.zone = valueDes;
          break;
        case r'credit_limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CreditLimit1),
          ) as CreditLimit1?;
          if (valueDes == null) continue;
          result.creditLimit.replace(valueDes);
          break;
        case r'credit_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.creditDays = valueDes;
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
  SupplierUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierUpdateBuilder();
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

