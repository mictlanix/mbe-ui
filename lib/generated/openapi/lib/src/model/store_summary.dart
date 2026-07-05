//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'store_summary.g.dart';

/// Flat Store representation used when embedded as another resource's FK.
///
/// Properties:
/// * [storeId] 
/// * [code] 
/// * [name] 
/// * [location] 
/// * [address] 
/// * [taxpayer] 
/// * [logo] 
/// * [receiptMessage] 
/// * [defaultBatch] 
/// * [disabled] 
@BuiltValue()
abstract class StoreSummary implements Built<StoreSummary, StoreSummaryBuilder> {
  @BuiltValueField(wireName: r'store_id')
  int get storeId;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'location')
  String get location;

  @BuiltValueField(wireName: r'address')
  int get address;

  @BuiltValueField(wireName: r'taxpayer')
  String get taxpayer;

  @BuiltValueField(wireName: r'logo')
  String get logo;

  @BuiltValueField(wireName: r'receipt_message')
  String? get receiptMessage;

  @BuiltValueField(wireName: r'default_batch')
  String? get defaultBatch;

  @BuiltValueField(wireName: r'disabled')
  bool? get disabled;

  StoreSummary._();

  factory StoreSummary([void updates(StoreSummaryBuilder b)]) = _$StoreSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StoreSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StoreSummary> get serializer => _$StoreSummarySerializer();
}

class _$StoreSummarySerializer implements PrimitiveSerializer<StoreSummary> {
  @override
  final Iterable<Type> types = const [StoreSummary, _$StoreSummary];

  @override
  final String wireName = r'StoreSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StoreSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'store_id';
    yield serializers.serialize(
      object.storeId,
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
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(String),
    );
    yield r'address';
    yield serializers.serialize(
      object.address,
      specifiedType: const FullType(int),
    );
    yield r'taxpayer';
    yield serializers.serialize(
      object.taxpayer,
      specifiedType: const FullType(String),
    );
    yield r'logo';
    yield serializers.serialize(
      object.logo,
      specifiedType: const FullType(String),
    );
    yield r'receipt_message';
    yield object.receiptMessage == null ? null : serializers.serialize(
      object.receiptMessage,
      specifiedType: const FullType.nullable(String),
    );
    yield r'default_batch';
    yield object.defaultBatch == null ? null : serializers.serialize(
      object.defaultBatch,
      specifiedType: const FullType.nullable(String),
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
    StoreSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StoreSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'store_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.storeId = valueDes;
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
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.location = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.address = valueDes;
          break;
        case r'taxpayer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.taxpayer = valueDes;
          break;
        case r'logo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.logo = valueDes;
          break;
        case r'receipt_message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.receiptMessage = valueDes;
          break;
        case r'default_batch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.defaultBatch = valueDes;
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
  StoreSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StoreSummaryBuilder();
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

