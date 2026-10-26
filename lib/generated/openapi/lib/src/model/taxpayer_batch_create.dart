//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/batch_template.dart';
import 'package:mbe_api_client/src/model/fiscal_document_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxpayer_batch_create.g.dart';

/// TaxpayerBatchCreate
///
/// Properties:
/// * [batch]
/// * [type]
/// * [template]
@BuiltValue()
abstract class TaxpayerBatchCreate
    implements Built<TaxpayerBatchCreate, TaxpayerBatchCreateBuilder> {
  @BuiltValueField(wireName: r'batch')
  String get batch;

  @BuiltValueField(wireName: r'type')
  FiscalDocumentType get type;
  // enum typeEnum {  0,  1,  2,  3,  100,  101,  200,  };

  @BuiltValueField(wireName: r'template')
  BatchTemplate get template;

  TaxpayerBatchCreate._();

  factory TaxpayerBatchCreate([void updates(TaxpayerBatchCreateBuilder b)]) =
      _$TaxpayerBatchCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxpayerBatchCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxpayerBatchCreate> get serializer =>
      _$TaxpayerBatchCreateSerializer();
}

class _$TaxpayerBatchCreateSerializer
    implements PrimitiveSerializer<TaxpayerBatchCreate> {
  @override
  final Iterable<Type> types = const [
    TaxpayerBatchCreate,
    _$TaxpayerBatchCreate,
  ];

  @override
  final String wireName = r'TaxpayerBatchCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxpayerBatchCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'batch';
    yield serializers.serialize(
      object.batch,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(FiscalDocumentType),
    );
    yield r'template';
    yield serializers.serialize(
      object.template,
      specifiedType: const FullType(BatchTemplate),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxpayerBatchCreate object, {
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
    required TaxpayerBatchCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'batch':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.batch = valueDes;
          break;
        case r'type':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(FiscalDocumentType),
                  )
                  as FiscalDocumentType;
          result.type = valueDes;
          break;
        case r'template':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BatchTemplate),
                  )
                  as BatchTemplate;
          result.template.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxpayerBatchCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxpayerBatchCreateBuilder();
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
