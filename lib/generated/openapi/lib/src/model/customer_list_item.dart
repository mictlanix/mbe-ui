//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/employee_response.dart';
import 'package:mbe_api_client/src/model/price_list_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'customer_list_item.g.dart';

/// CustomerListItem
///
/// Properties:
/// * [customerId] 
/// * [code] 
/// * [name] 
/// * [zone] 
/// * [creditLimit] 
/// * [creditDays] 
/// * [priceList] 
/// * [salesperson] 
/// * [disabled] 
@BuiltValue()
abstract class CustomerListItem implements Built<CustomerListItem, CustomerListItemBuilder> {
  @BuiltValueField(wireName: r'customer_id')
  int get customerId;

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

  @BuiltValueField(wireName: r'price_list')
  PriceListResponse get priceList;

  @BuiltValueField(wireName: r'salesperson')
  EmployeeResponse? get salesperson;

  @BuiltValueField(wireName: r'disabled')
  bool? get disabled;

  CustomerListItem._();

  factory CustomerListItem([void updates(CustomerListItemBuilder b)]) = _$CustomerListItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CustomerListItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CustomerListItem> get serializer => _$CustomerListItemSerializer();
}

class _$CustomerListItemSerializer implements PrimitiveSerializer<CustomerListItem> {
  @override
  final Iterable<Type> types = const [CustomerListItem, _$CustomerListItem];

  @override
  final String wireName = r'CustomerListItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CustomerListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'customer_id';
    yield serializers.serialize(
      object.customerId,
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
    yield r'price_list';
    yield serializers.serialize(
      object.priceList,
      specifiedType: const FullType(PriceListResponse),
    );
    yield r'salesperson';
    yield object.salesperson == null ? null : serializers.serialize(
      object.salesperson,
      specifiedType: const FullType.nullable(EmployeeResponse),
    );
    yield r'disabled';
    yield object.disabled == null ? null : serializers.serialize(
      object.disabled,
      specifiedType: const FullType.nullable(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CustomerListItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CustomerListItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'customer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.customerId = valueDes;
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
        case r'price_list':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PriceListResponse),
          ) as PriceListResponse;
          result.priceList.replace(valueDes);
          break;
        case r'salesperson':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(EmployeeResponse),
          ) as EmployeeResponse?;
          if (valueDes == null) continue;
          result.salesperson.replace(valueDes);
          break;
        case r'disabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.disabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CustomerListItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CustomerListItemBuilder();
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

