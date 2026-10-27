//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/bulk_approve_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_approve_response.g.dart';

/// BulkApproveResponse
///
/// Properties:
/// * [results]
@BuiltValue()
abstract class BulkApproveResponse
    implements Built<BulkApproveResponse, BulkApproveResponseBuilder> {
  @BuiltValueField(wireName: r'results')
  BuiltList<BulkApproveResult> get results;

  BulkApproveResponse._();

  factory BulkApproveResponse([void updates(BulkApproveResponseBuilder b)]) =
      _$BulkApproveResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkApproveResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkApproveResponse> get serializer =>
      _$BulkApproveResponseSerializer();
}

class _$BulkApproveResponseSerializer
    implements PrimitiveSerializer<BulkApproveResponse> {
  @override
  final Iterable<Type> types = const [
    BulkApproveResponse,
    _$BulkApproveResponse,
  ];

  @override
  final String wireName = r'BulkApproveResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkApproveResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltList, [FullType(BulkApproveResult)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkApproveResponse object, {
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
    required BulkApproveResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'results':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(BulkApproveResult),
                    ]),
                  )
                  as BuiltList<BulkApproveResult>;
          result.results.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BulkApproveResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkApproveResponseBuilder();
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
