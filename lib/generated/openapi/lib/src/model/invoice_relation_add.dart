//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invoice_relation_add.g.dart';

/// InvoiceRelationAdd
///
/// Properties:
/// * [relation]
/// * [type]
@BuiltValue()
abstract class InvoiceRelationAdd
    implements Built<InvoiceRelationAdd, InvoiceRelationAddBuilder> {
  @BuiltValueField(wireName: r'relation')
  int get relation;

  @BuiltValueField(wireName: r'type')
  InvoiceRelationAddTypeEnum get type;
  // enum typeEnum {  04,  07,  };

  InvoiceRelationAdd._();

  factory InvoiceRelationAdd([void updates(InvoiceRelationAddBuilder b)]) =
      _$InvoiceRelationAdd;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InvoiceRelationAddBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InvoiceRelationAdd> get serializer =>
      _$InvoiceRelationAddSerializer();
}

class _$InvoiceRelationAddSerializer
    implements PrimitiveSerializer<InvoiceRelationAdd> {
  @override
  final Iterable<Type> types = const [InvoiceRelationAdd, _$InvoiceRelationAdd];

  @override
  final String wireName = r'InvoiceRelationAdd';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InvoiceRelationAdd object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'relation';
    yield serializers.serialize(
      object.relation,
      specifiedType: const FullType(int),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(InvoiceRelationAddTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InvoiceRelationAdd object, {
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
    required InvoiceRelationAddBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'relation':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.relation = valueDes;
          break;
        case r'type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(InvoiceRelationAddTypeEnum),
                  )
                  as InvoiceRelationAddTypeEnum;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InvoiceRelationAdd deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InvoiceRelationAddBuilder();
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

class InvoiceRelationAddTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'04')
  static const InvoiceRelationAddTypeEnum n04 =
      _$invoiceRelationAddTypeEnum_n04;
  @BuiltValueEnumConst(wireName: r'07')
  static const InvoiceRelationAddTypeEnum n07 =
      _$invoiceRelationAddTypeEnum_n07;

  static Serializer<InvoiceRelationAddTypeEnum> get serializer =>
      _$invoiceRelationAddTypeEnumSerializer;

  const InvoiceRelationAddTypeEnum._(String name) : super(name);

  static BuiltSet<InvoiceRelationAddTypeEnum> get values =>
      _$invoiceRelationAddTypeEnumValues;
  static InvoiceRelationAddTypeEnum valueOf(String name) =>
      _$invoiceRelationAddTypeEnumValueOf(name);
}
