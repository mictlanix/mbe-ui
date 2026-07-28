//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:mbe_api_client/src/model/pending_delivery_line.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pending_delivery_bucket.g.dart';

/// One tab of the sliding window. Always present, possibly empty (FR-031).
///
/// Properties:
/// * [key]
/// * [date]
/// * [items]
/// * [total]
@BuiltValue()
abstract class PendingDeliveryBucket
    implements Built<PendingDeliveryBucket, PendingDeliveryBucketBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'items')
  BuiltList<PendingDeliveryLine> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  PendingDeliveryBucket._();

  factory PendingDeliveryBucket([
    void updates(PendingDeliveryBucketBuilder b),
  ]) = _$PendingDeliveryBucket;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PendingDeliveryBucketBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PendingDeliveryBucket> get serializer =>
      _$PendingDeliveryBucketSerializer();
}

class _$PendingDeliveryBucketSerializer
    implements PrimitiveSerializer<PendingDeliveryBucket> {
  @override
  final Iterable<Type> types = const [
    PendingDeliveryBucket,
    _$PendingDeliveryBucket,
  ];

  @override
  final String wireName = r'PendingDeliveryBucket';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PendingDeliveryBucket object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'date';
    yield object.date == null
        ? null
        : serializers.serialize(
            object.date,
            specifiedType: const FullType.nullable(Date),
          );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(PendingDeliveryLine)]),
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
    PendingDeliveryBucket object, {
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
    required PendingDeliveryBucketBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.key = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(PendingDeliveryLine),
                    ]),
                  )
                  as BuiltList<PendingDeliveryLine>;
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
  PendingDeliveryBucket deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PendingDeliveryBucketBuilder();
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
