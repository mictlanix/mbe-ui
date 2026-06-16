//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'point_sale_response.g.dart';

/// PointSaleResponse
///
/// Properties:
/// * [pointSaleId] 
/// * [store] 
/// * [code] 
/// * [name] 
/// * [warehouse] 
/// * [comment] 
/// * [disabled] 
@BuiltValue()
abstract class PointSaleResponse implements Built<PointSaleResponse, PointSaleResponseBuilder> {
  @BuiltValueField(wireName: r'point_sale_id')
  int get pointSaleId;

  @BuiltValueField(wireName: r'store')
  int get store;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'disabled')
  bool? get disabled;

  PointSaleResponse._();

  factory PointSaleResponse([void updates(PointSaleResponseBuilder b)]) = _$PointSaleResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PointSaleResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PointSaleResponse> get serializer => _$PointSaleResponseSerializer();
}

class _$PointSaleResponseSerializer implements PrimitiveSerializer<PointSaleResponse> {
  @override
  final Iterable<Type> types = const [PointSaleResponse, _$PointSaleResponse];

  @override
  final String wireName = r'PointSaleResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PointSaleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'point_sale_id';
    yield serializers.serialize(
      object.pointSaleId,
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
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'comment';
    yield object.comment == null ? null : serializers.serialize(
      object.comment,
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
    PointSaleResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PointSaleResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'point_sale_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pointSaleId = valueDes;
          break;
        case r'store':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.store = valueDes;
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
        case r'warehouse':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.warehouse = valueDes;
          break;
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
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
  PointSaleResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PointSaleResponseBuilder();
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

