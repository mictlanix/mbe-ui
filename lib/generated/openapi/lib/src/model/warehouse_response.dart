//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/store_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'warehouse_response.g.dart';

/// WarehouseResponse
///
/// Properties:
/// * [warehouseId]
/// * [store]
/// * [code]
/// * [name]
/// * [comment]
/// * [disabled]
@BuiltValue()
abstract class WarehouseResponse
    implements Built<WarehouseResponse, WarehouseResponseBuilder> {
  @BuiltValueField(wireName: r'warehouse_id')
  int get warehouseId;

  @BuiltValueField(wireName: r'store')
  StoreSummary get store;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'disabled')
  bool? get disabled;

  WarehouseResponse._();

  factory WarehouseResponse([void updates(WarehouseResponseBuilder b)]) =
      _$WarehouseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WarehouseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WarehouseResponse> get serializer =>
      _$WarehouseResponseSerializer();
}

class _$WarehouseResponseSerializer
    implements PrimitiveSerializer<WarehouseResponse> {
  @override
  final Iterable<Type> types = const [WarehouseResponse, _$WarehouseResponse];

  @override
  final String wireName = r'WarehouseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WarehouseResponse object, {
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
      specifiedType: const FullType(StoreSummary),
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
    WarehouseResponse object, {
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
    required WarehouseResponseBuilder result,
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
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(StoreSummary),
                  )
                  as StoreSummary;
          result.store.replace(valueDes);
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
  WarehouseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WarehouseResponseBuilder();
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
