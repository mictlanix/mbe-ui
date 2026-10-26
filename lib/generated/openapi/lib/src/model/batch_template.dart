//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/batch_account.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'batch_template.g.dart';

/// The print template, stored as legacy's JSON (`cfdi.batch_settings` reads it).
///
/// Properties:
/// * [name]
/// * [logo]
/// * [headerHeight]
/// * [footerHeight]
/// * [extraInfo]
@BuiltValue()
abstract class BatchTemplate
    implements Built<BatchTemplate, BatchTemplateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'logo')
  String? get logo;

  @BuiltValueField(wireName: r'header_height')
  int? get headerHeight;

  @BuiltValueField(wireName: r'footer_height')
  int? get footerHeight;

  @BuiltValueField(wireName: r'extra_info')
  BuiltList<BatchAccount>? get extraInfo;

  BatchTemplate._();

  factory BatchTemplate([void updates(BatchTemplateBuilder b)]) =
      _$BatchTemplate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BatchTemplateBuilder b) => b
    ..headerHeight = 0
    ..footerHeight = 15
    ..extraInfo = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<BatchTemplate> get serializer =>
      _$BatchTemplateSerializer();
}

class _$BatchTemplateSerializer implements PrimitiveSerializer<BatchTemplate> {
  @override
  final Iterable<Type> types = const [BatchTemplate, _$BatchTemplate];

  @override
  final String wireName = r'BatchTemplate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BatchTemplate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.logo != null) {
      yield r'logo';
      yield serializers.serialize(
        object.logo,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.headerHeight != null) {
      yield r'header_height';
      yield serializers.serialize(
        object.headerHeight,
        specifiedType: const FullType(int),
      );
    }
    if (object.footerHeight != null) {
      yield r'footer_height';
      yield serializers.serialize(
        object.footerHeight,
        specifiedType: const FullType(int),
      );
    }
    if (object.extraInfo != null) {
      yield r'extra_info';
      yield serializers.serialize(
        object.extraInfo,
        specifiedType: const FullType(BuiltList, [FullType(BatchAccount)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BatchTemplate object, {
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
    required BatchTemplateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.name = valueDes;
          break;
        case r'logo':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.logo = valueDes;
          break;
        case r'header_height':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.headerHeight = valueDes;
          break;
        case r'footer_height':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.footerHeight = valueDes;
          break;
        case r'extra_info':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(BatchAccount),
                    ]),
                  )
                  as BuiltList<BatchAccount>?;
          if (valueDes == null) continue;
          result.extraInfo.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BatchTemplate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BatchTemplateBuilder();
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
