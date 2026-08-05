//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'contact_create.g.dart';

/// `contact.mobile` is `NOT NULL DEFAULT ''`, so an omitted mobile is empty, not absent.
///
/// Properties:
/// * [name]
/// * [jobTitle]
/// * [phone]
/// * [phoneExt]
/// * [mobile]
/// * [fax]
/// * [website]
/// * [email]
/// * [im]
/// * [sip]
/// * [birthday]
/// * [comment]
@BuiltValue()
abstract class ContactCreate
    implements Built<ContactCreate, ContactCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'job_title')
  String? get jobTitle;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'phone_ext')
  String? get phoneExt;

  @BuiltValueField(wireName: r'mobile')
  String? get mobile;

  @BuiltValueField(wireName: r'fax')
  String? get fax;

  @BuiltValueField(wireName: r'website')
  String? get website;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'im')
  String? get im;

  @BuiltValueField(wireName: r'sip')
  String? get sip;

  @BuiltValueField(wireName: r'birthday')
  Date? get birthday;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  ContactCreate._();

  factory ContactCreate([void updates(ContactCreateBuilder b)]) =
      _$ContactCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContactCreateBuilder b) => b..mobile = '';

  @BuiltValueSerializer(custom: true)
  static Serializer<ContactCreate> get serializer =>
      _$ContactCreateSerializer();
}

class _$ContactCreateSerializer implements PrimitiveSerializer<ContactCreate> {
  @override
  final Iterable<Type> types = const [ContactCreate, _$ContactCreate];

  @override
  final String wireName = r'ContactCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContactCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.jobTitle != null) {
      yield r'job_title';
      yield serializers.serialize(
        object.jobTitle,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.phoneExt != null) {
      yield r'phone_ext';
      yield serializers.serialize(
        object.phoneExt,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.mobile != null) {
      yield r'mobile';
      yield serializers.serialize(
        object.mobile,
        specifiedType: const FullType(String),
      );
    }
    if (object.fax != null) {
      yield r'fax';
      yield serializers.serialize(
        object.fax,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.website != null) {
      yield r'website';
      yield serializers.serialize(
        object.website,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.im != null) {
      yield r'im';
      yield serializers.serialize(
        object.im,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sip != null) {
      yield r'sip';
      yield serializers.serialize(
        object.sip,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.birthday != null) {
      yield r'birthday';
      yield serializers.serialize(
        object.birthday,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ContactCreate object, {
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
    required ContactCreateBuilder result,
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
        case r'job_title':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.jobTitle = valueDes;
          break;
        case r'phone':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'phone_ext':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.phoneExt = valueDes;
          break;
        case r'mobile':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.mobile = valueDes;
          break;
        case r'fax':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.fax = valueDes;
          break;
        case r'website':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.website = valueDes;
          break;
        case r'email':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'im':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.im = valueDes;
          break;
        case r'sip':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.sip = valueDes;
          break;
        case r'birthday':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
          result.birthday = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContactCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContactCreateBuilder();
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
