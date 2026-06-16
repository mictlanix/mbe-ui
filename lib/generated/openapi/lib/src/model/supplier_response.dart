//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_response.g.dart';

/// SupplierResponse
///
/// Properties:
/// * [supplierId] 
/// * [code] 
/// * [name] 
/// * [zone] 
/// * [creditLimit] 
/// * [creditDays] 
/// * [comment] 
@BuiltValue()
abstract class SupplierResponse implements Built<SupplierResponse, SupplierResponseBuilder> {
  @BuiltValueField(wireName: r'supplier_id')
  int get supplierId;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'zone')
  String? get zone;

  @BuiltValueField(wireName: r'credit_limit')
  String get creditLimit;

  @BuiltValueField(wireName: r'credit_days')
  int get creditDays;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SupplierResponse._();

  factory SupplierResponse([void updates(SupplierResponseBuilder b)]) = _$SupplierResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierResponse> get serializer => _$SupplierResponseSerializer();
}

class _$SupplierResponseSerializer implements PrimitiveSerializer<SupplierResponse> {
  @override
  final Iterable<Type> types = const [SupplierResponse, _$SupplierResponse];

  @override
  final String wireName = r'SupplierResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier_id';
    yield serializers.serialize(
      object.supplierId,
      specifiedType: const FullType(int),
    );
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
    yield r'zone';
    yield object.zone == null ? null : serializers.serialize(
      object.zone,
      specifiedType: const FullType.nullable(String),
    );
    yield r'credit_limit';
    yield serializers.serialize(
      object.creditLimit,
      specifiedType: const FullType(String),
    );
    yield r'credit_days';
    yield serializers.serialize(
      object.creditDays,
      specifiedType: const FullType(int),
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
    SupplierResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.supplierId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
            specifiedType: const FullType(String),
          ) as String;
          result.creditLimit = valueDes;
          break;
        case r'credit_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
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
  SupplierResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierResponseBuilder();
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

