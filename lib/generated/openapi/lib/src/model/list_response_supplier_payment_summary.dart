//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/supplier_payment_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_supplier_payment_summary.g.dart';

/// ListResponseSupplierPaymentSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseSupplierPaymentSummary
    implements
        Built<
          ListResponseSupplierPaymentSummary,
          ListResponseSupplierPaymentSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<SupplierPaymentSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseSupplierPaymentSummary._();

  factory ListResponseSupplierPaymentSummary([
    void updates(ListResponseSupplierPaymentSummaryBuilder b),
  ]) = _$ListResponseSupplierPaymentSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseSupplierPaymentSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseSupplierPaymentSummary> get serializer =>
      _$ListResponseSupplierPaymentSummarySerializer();
}

class _$ListResponseSupplierPaymentSummarySerializer
    implements PrimitiveSerializer<ListResponseSupplierPaymentSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseSupplierPaymentSummary,
    _$ListResponseSupplierPaymentSummary,
  ];

  @override
  final String wireName = r'ListResponseSupplierPaymentSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseSupplierPaymentSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(SupplierPaymentSummary),
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
    ListResponseSupplierPaymentSummary object, {
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
    required ListResponseSupplierPaymentSummaryBuilder result,
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
                      FullType(SupplierPaymentSummary),
                    ]),
                  )
                  as BuiltList<SupplierPaymentSummary>;
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
  ListResponseSupplierPaymentSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseSupplierPaymentSummaryBuilder();
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
