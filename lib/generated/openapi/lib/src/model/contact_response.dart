//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'contact_response.g.dart';

/// ContactResponse
///
/// Properties:
/// * [contactId]
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
abstract class ContactResponse
    implements Built<ContactResponse, ContactResponseBuilder> {
  @BuiltValueField(wireName: r'contact_id')
  int get contactId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'job_title')
  String? get jobTitle;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'phone_ext')
  String? get phoneExt;

  @BuiltValueField(wireName: r'mobile')
  String get mobile;

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

  ContactResponse._();

  factory ContactResponse([void updates(ContactResponseBuilder b)]) =
      _$ContactResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContactResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContactResponse> get serializer =>
      _$ContactResponseSerializer();
}

class _$ContactResponseSerializer
    implements PrimitiveSerializer<ContactResponse> {
  @override
  final Iterable<Type> types = const [ContactResponse, _$ContactResponse];

  @override
  final String wireName = r'ContactResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContactResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'contact_id';
    yield serializers.serialize(
      object.contactId,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'job_title';
    yield object.jobTitle == null
        ? null
        : serializers.serialize(
            object.jobTitle,
            specifiedType: const FullType.nullable(String),
          );
    yield r'phone';
    yield object.phone == null
        ? null
        : serializers.serialize(
            object.phone,
            specifiedType: const FullType.nullable(String),
          );
    yield r'phone_ext';
    yield object.phoneExt == null
        ? null
        : serializers.serialize(
            object.phoneExt,
            specifiedType: const FullType.nullable(String),
          );
    yield r'mobile';
    yield serializers.serialize(
      object.mobile,
      specifiedType: const FullType(String),
    );
    yield r'fax';
    yield object.fax == null
        ? null
        : serializers.serialize(
            object.fax,
            specifiedType: const FullType.nullable(String),
          );
    yield r'website';
    yield object.website == null
        ? null
        : serializers.serialize(
            object.website,
            specifiedType: const FullType.nullable(String),
          );
    yield r'email';
    yield object.email == null
        ? null
        : serializers.serialize(
            object.email,
            specifiedType: const FullType.nullable(String),
          );
    yield r'im';
    yield object.im == null
        ? null
        : serializers.serialize(
            object.im,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sip';
    yield object.sip == null
        ? null
        : serializers.serialize(
            object.sip,
            specifiedType: const FullType.nullable(String),
          );
    yield r'birthday';
    yield object.birthday == null
        ? null
        : serializers.serialize(
            object.birthday,
            specifiedType: const FullType.nullable(Date),
          );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ContactResponse object, {
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
    required ContactResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contact_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.contactId = valueDes;
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
  ContactResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContactResponseBuilder();
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
