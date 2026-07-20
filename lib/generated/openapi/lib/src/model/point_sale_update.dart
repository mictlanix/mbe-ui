//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'point_sale_update.g.dart';

/// PointSaleUpdate
///
/// Properties:
/// * [facility]
/// * [code]
/// * [name]
/// * [warehouse]
/// * [comment]
/// * [status]
@BuiltValue()
abstract class PointSaleUpdate
    implements Built<PointSaleUpdate, PointSaleUpdateBuilder> {
  @BuiltValueField(wireName: r'facility')
  int? get facility;

  @BuiltValueField(wireName: r'code')
  String? get code;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'warehouse')
  int? get warehouse;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'status')
  EntityStatus? get status;
  // enum statusEnum {  0,  1,  2,  };

  PointSaleUpdate._();

  factory PointSaleUpdate([void updates(PointSaleUpdateBuilder b)]) =
      _$PointSaleUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PointSaleUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PointSaleUpdate> get serializer =>
      _$PointSaleUpdateSerializer();
}

class _$PointSaleUpdateSerializer
    implements PrimitiveSerializer<PointSaleUpdate> {
  @override
  final Iterable<Type> types = const [PointSaleUpdate, _$PointSaleUpdate];

  @override
  final String wireName = r'PointSaleUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PointSaleUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.facility != null) {
      yield r'facility';
      yield serializers.serialize(
        object.facility,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.code != null) {
      yield r'code';
      yield serializers.serialize(
        object.code,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.warehouse != null) {
      yield r'warehouse';
      yield serializers.serialize(
        object.warehouse,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType.nullable(EntityStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PointSaleUpdate object, {
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
    required PointSaleUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        case r'code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.code = valueDes;
          break;
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.warehouse = valueDes;
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(EntityStatus),
                  )
                  as EntityStatus?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PointSaleUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PointSaleUpdateBuilder();
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
