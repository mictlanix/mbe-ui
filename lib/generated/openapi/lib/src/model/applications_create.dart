//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/application_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'applications_create.g.dart';

/// ApplicationsCreate
///
/// Properties:
/// * [applications]
@BuiltValue()
abstract class ApplicationsCreate
    implements Built<ApplicationsCreate, ApplicationsCreateBuilder> {
  @BuiltValueField(wireName: r'applications')
  BuiltList<ApplicationItem> get applications;

  ApplicationsCreate._();

  factory ApplicationsCreate([void updates(ApplicationsCreateBuilder b)]) =
      _$ApplicationsCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApplicationsCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApplicationsCreate> get serializer =>
      _$ApplicationsCreateSerializer();
}

class _$ApplicationsCreateSerializer
    implements PrimitiveSerializer<ApplicationsCreate> {
  @override
  final Iterable<Type> types = const [ApplicationsCreate, _$ApplicationsCreate];

  @override
  final String wireName = r'ApplicationsCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApplicationsCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'applications';
    yield serializers.serialize(
      object.applications,
      specifiedType: const FullType(BuiltList, [FullType(ApplicationItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ApplicationsCreate object, {
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
    required ApplicationsCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'applications':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(ApplicationItem),
                    ]),
                  )
                  as BuiltList<ApplicationItem>;
          result.applications.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ApplicationsCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApplicationsCreateBuilder();
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
