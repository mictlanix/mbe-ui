//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/credit_limit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_create.g.dart';

/// CustomerCreate
///
/// Properties:
/// * [code] 
/// * [name] 
/// * [zone] 
/// * [creditLimit] 
/// * [creditDays] 
/// * [priceList] 
/// * [shipping] 
/// * [shippingRequiredDocument] 
/// * [salesperson] 
/// * [comment] 
@BuiltValue()
abstract class CustomerCreate implements Built<CustomerCreate, CustomerCreateBuilder> {
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

  @BuiltValueField(wireName: r'price_list')
  int get priceList;

  @BuiltValueField(wireName: r'shipping')
  bool? get shipping;

  @BuiltValueField(wireName: r'shipping_required_document')
  bool? get shippingRequiredDocument;

  @BuiltValueField(wireName: r'salesperson')
  int? get salesperson;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  CustomerCreate._();

  factory CustomerCreate([void updates(CustomerCreateBuilder b)]) = _$CustomerCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerCreateBuilder b) => b
      ..creditDays = 0
      ..shipping = false
      ..shippingRequiredDocument = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerCreate> get serializer => _$CustomerCreateSerializer();
}

class _$CustomerCreateSerializer implements PrimitiveSerializer<CustomerCreate> {
  @override
  final Iterable<Type> types = const [CustomerCreate, _$CustomerCreate];

  @override
  final String wireName = r'CustomerCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerCreate object, {
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
    yield r'price_list';
    yield serializers.serialize(
      object.priceList,
      specifiedType: const FullType(int),
    );
    if (object.shipping != null) {
      yield r'shipping';
      yield serializers.serialize(
        object.shipping,
        specifiedType: const FullType(bool),
      );
    }
    if (object.shippingRequiredDocument != null) {
      yield r'shipping_required_document';
      yield serializers.serialize(
        object.shippingRequiredDocument,
        specifiedType: const FullType(bool),
      );
    }
    if (object.salesperson != null) {
      yield r'salesperson';
      yield serializers.serialize(
        object.salesperson,
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
    CustomerCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CustomerCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(CreditLimit),
          ) as CreditLimit;
          result.creditLimit.replace(valueDes);
          break;
        case r'credit_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.creditDays = valueDes;
          break;
        case r'price_list':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceList = valueDes;
          break;
        case r'shipping':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.shipping = valueDes;
          break;
        case r'shipping_required_document':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.shippingRequiredDocument = valueDes;
          break;
        case r'salesperson':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.salesperson = valueDes;
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
  CustomerCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerCreateBuilder();
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

