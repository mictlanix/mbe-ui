//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/fiscal_document_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_response_fiscal_document_summary.g.dart';

/// ListResponseFiscalDocumentSummary
///
/// Properties:
/// * [items]
/// * [total]
@BuiltValue()
abstract class ListResponseFiscalDocumentSummary
    implements
        Built<
          ListResponseFiscalDocumentSummary,
          ListResponseFiscalDocumentSummaryBuilder
        > {
  @BuiltValueField(wireName: r'items')
  BuiltList<FiscalDocumentSummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  ListResponseFiscalDocumentSummary._();

  factory ListResponseFiscalDocumentSummary([
    void updates(ListResponseFiscalDocumentSummaryBuilder b),
  ]) = _$ListResponseFiscalDocumentSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListResponseFiscalDocumentSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListResponseFiscalDocumentSummary> get serializer =>
      _$ListResponseFiscalDocumentSummarySerializer();
}

class _$ListResponseFiscalDocumentSummarySerializer
    implements PrimitiveSerializer<ListResponseFiscalDocumentSummary> {
  @override
  final Iterable<Type> types = const [
    ListResponseFiscalDocumentSummary,
    _$ListResponseFiscalDocumentSummary,
  ];

  @override
  final String wireName = r'ListResponseFiscalDocumentSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListResponseFiscalDocumentSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(FiscalDocumentSummary),
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
    ListResponseFiscalDocumentSummary object, {
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
    required ListResponseFiscalDocumentSummaryBuilder result,
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
                      FullType(FiscalDocumentSummary),
                    ]),
                  )
                  as BuiltList<FiscalDocumentSummary>;
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
  ListResponseFiscalDocumentSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListResponseFiscalDocumentSummaryBuilder();
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
