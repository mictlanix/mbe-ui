//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inventory_issue_line_response.g.dart';

/// InventoryIssueLineResponse
///
/// Properties:
/// * [issueDetailId]
/// * [product]
/// * [productCode]
/// * [productName]
/// * [quantity]
@BuiltValue()
abstract class InventoryIssueLineResponse
    implements
        Built<InventoryIssueLineResponse, InventoryIssueLineResponseBuilder> {
  @BuiltValueField(wireName: r'issue_detail_id')
  int get issueDetailId;

  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  InventoryIssueLineResponse._();

  factory InventoryIssueLineResponse([
    void updates(InventoryIssueLineResponseBuilder b),
  ]) = _$InventoryIssueLineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InventoryIssueLineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InventoryIssueLineResponse> get serializer =>
      _$InventoryIssueLineResponseSerializer();
}

class _$InventoryIssueLineResponseSerializer
    implements PrimitiveSerializer<InventoryIssueLineResponse> {
  @override
  final Iterable<Type> types = const [
    InventoryIssueLineResponse,
    _$InventoryIssueLineResponse,
  ];

  @override
  final String wireName = r'InventoryIssueLineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InventoryIssueLineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'issue_detail_id';
    yield serializers.serialize(
      object.issueDetailId,
      specifiedType: const FullType(int),
    );
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'product_code';
    yield object.productCode == null
        ? null
        : serializers.serialize(
            object.productCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'product_name';
    yield object.productName == null
        ? null
        : serializers.serialize(
            object.productName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InventoryIssueLineResponse object, {
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
    required InventoryIssueLineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'issue_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.issueDetailId = valueDes;
          break;
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'product_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productCode = valueDes;
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productName = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InventoryIssueLineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InventoryIssueLineResponseBuilder();
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
