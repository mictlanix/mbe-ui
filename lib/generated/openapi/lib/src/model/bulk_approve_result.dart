//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_approve_result.g.dart';

/// BulkApproveResult
///
/// Properties:
/// * [purchaseRequestId]
/// * [approved]
/// * [reason]
@BuiltValue()
abstract class BulkApproveResult
    implements Built<BulkApproveResult, BulkApproveResultBuilder> {
  @BuiltValueField(wireName: r'purchase_request_id')
  int get purchaseRequestId;

  @BuiltValueField(wireName: r'approved')
  bool get approved;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  BulkApproveResult._();

  factory BulkApproveResult([void updates(BulkApproveResultBuilder b)]) =
      _$BulkApproveResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkApproveResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkApproveResult> get serializer =>
      _$BulkApproveResultSerializer();
}

class _$BulkApproveResultSerializer
    implements PrimitiveSerializer<BulkApproveResult> {
  @override
  final Iterable<Type> types = const [BulkApproveResult, _$BulkApproveResult];

  @override
  final String wireName = r'BulkApproveResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkApproveResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_request_id';
    yield serializers.serialize(
      object.purchaseRequestId,
      specifiedType: const FullType(int),
    );
    yield r'approved';
    yield serializers.serialize(
      object.approved,
      specifiedType: const FullType(bool),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkApproveResult object, {
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
    required BulkApproveResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_request_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseRequestId = valueDes;
          break;
        case r'approved':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.approved = valueDes;
          break;
        case r'reason':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BulkApproveResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkApproveResultBuilder();
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
