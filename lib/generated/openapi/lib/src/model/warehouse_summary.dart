//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'warehouse_summary.g.dart';

/// Flat Warehouse representation used when embedded as another resource's FK.
///
/// Properties:
/// * [warehouseId]
/// * [store]
/// * [code]
/// * [name]
/// * [comment]
/// * [disabled]
@BuiltValue()
abstract class WarehouseSummary
    implements Built<WarehouseSummary, WarehouseSummaryBuilder> {
  @BuiltValueField(wireName: r'warehouse_id')
  int get warehouseId;

  @BuiltValueField(wireName: r'store')
  int get store;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'disabled')
  bool? get disabled;

  WarehouseSummary._();

  factory WarehouseSummary([void updates(WarehouseSummaryBuilder b)]) =
      _$WarehouseSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WarehouseSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WarehouseSummary> get serializer =>
      _$WarehouseSummarySerializer();
}

class _$WarehouseSummarySerializer
    implements PrimitiveSerializer<WarehouseSummary> {
  @override
  final Iterable<Type> types = const [WarehouseSummary, _$WarehouseSummary];

  @override
  final String wireName = r'WarehouseSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WarehouseSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'warehouse_id';
    yield serializers.serialize(
      object.warehouseId,
      specifiedType: const FullType(int),
    );
    yield r'store';
    yield serializers.serialize(
      object.store,
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
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    yield r'disabled';
    yield object.disabled == null
        ? null
        : serializers.serialize(
            object.disabled,
            specifiedType: const FullType.nullable(bool),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    WarehouseSummary object, {
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
    required WarehouseSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'warehouse_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouseId = valueDes;
          break;
        case r'store':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.store = valueDes;
          break;
        case r'code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'comment':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        case r'disabled':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(bool),
                  )
                  as bool?;
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
  WarehouseSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WarehouseSummaryBuilder();
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
