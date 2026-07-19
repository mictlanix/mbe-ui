//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/store_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'production_site_response.g.dart';

/// ProductionSiteResponse
///
/// Properties:
/// * [productionSiteId]
/// * [store]
/// * [code]
/// * [name]
/// * [comment]
/// * [disabled]
@BuiltValue()
abstract class ProductionSiteResponse
    implements Built<ProductionSiteResponse, ProductionSiteResponseBuilder> {
  @BuiltValueField(wireName: r'production_site_id')
  int get productionSiteId;

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

  ProductionSiteResponse._();

  factory ProductionSiteResponse([
    void updates(ProductionSiteResponseBuilder b),
  ]) = _$ProductionSiteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductionSiteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductionSiteResponse> get serializer =>
      _$ProductionSiteResponseSerializer();
}

class _$ProductionSiteResponseSerializer
    implements PrimitiveSerializer<ProductionSiteResponse> {
  @override
  final Iterable<Type> types = const [
    ProductionSiteResponse,
    _$ProductionSiteResponse,
  ];

  @override
  final String wireName = r'ProductionSiteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductionSiteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'production_site_id';
    yield serializers.serialize(
      object.productionSiteId,
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
    ProductionSiteResponse object, {
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
    required ProductionSiteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'production_site_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.productionSiteId = valueDes;
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
  ProductionSiteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductionSiteResponseBuilder();
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
