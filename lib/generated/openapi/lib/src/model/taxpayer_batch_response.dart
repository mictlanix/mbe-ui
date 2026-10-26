//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/batch_template.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'taxpayer_batch_response.g.dart';

/// TaxpayerBatchResponse
///
/// Properties:
/// * [taxpayerBatchId]
/// * [taxpayer]
/// * [batch]
/// * [type]
/// * [template]
/// * [inUse]
@BuiltValue()
abstract class TaxpayerBatchResponse
    implements Built<TaxpayerBatchResponse, TaxpayerBatchResponseBuilder> {
  @BuiltValueField(wireName: r'taxpayer_batch_id')
  int get taxpayerBatchId;

  @BuiltValueField(wireName: r'taxpayer')
  String get taxpayer;

  @BuiltValueField(wireName: r'batch')
  String get batch;

  @BuiltValueField(wireName: r'type')
  int get type;

  @BuiltValueField(wireName: r'template')
  BatchTemplate get template;

  @BuiltValueField(wireName: r'in_use')
  bool get inUse;

  TaxpayerBatchResponse._();

  factory TaxpayerBatchResponse([
    void updates(TaxpayerBatchResponseBuilder b),
  ]) = _$TaxpayerBatchResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxpayerBatchResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxpayerBatchResponse> get serializer =>
      _$TaxpayerBatchResponseSerializer();
}

class _$TaxpayerBatchResponseSerializer
    implements PrimitiveSerializer<TaxpayerBatchResponse> {
  @override
  final Iterable<Type> types = const [
    TaxpayerBatchResponse,
    _$TaxpayerBatchResponse,
  ];

  @override
  final String wireName = r'TaxpayerBatchResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxpayerBatchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxpayer_batch_id';
    yield serializers.serialize(
      object.taxpayerBatchId,
      specifiedType: const FullType(int),
    );
    yield r'taxpayer';
    yield serializers.serialize(
      object.taxpayer,
      specifiedType: const FullType(String),
    );
    yield r'batch';
    yield serializers.serialize(
      object.batch,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(int),
    );
    yield r'template';
    yield serializers.serialize(
      object.template,
      specifiedType: const FullType(BatchTemplate),
    );
    yield r'in_use';
    yield serializers.serialize(
      object.inUse,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxpayerBatchResponse object, {
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
    required TaxpayerBatchResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taxpayer_batch_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.taxpayerBatchId = valueDes;
          break;
        case r'taxpayer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.taxpayer = valueDes;
          break;
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
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
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
        case r'in_use':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.inUse = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxpayerBatchResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxpayerBatchResponseBuilder();
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
