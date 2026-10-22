//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_agreement_create.g.dart';

/// SupplierAgreementCreate
///
/// Properties:
/// * [start]
/// * [end]
/// * [comment]
@BuiltValue()
abstract class SupplierAgreementCreate
    implements Built<SupplierAgreementCreate, SupplierAgreementCreateBuilder> {
  @BuiltValueField(wireName: r'start')
  Date get start;

  @BuiltValueField(wireName: r'end')
  Date get end;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SupplierAgreementCreate._();

  factory SupplierAgreementCreate([
    void updates(SupplierAgreementCreateBuilder b),
  ]) = _$SupplierAgreementCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierAgreementCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierAgreementCreate> get serializer =>
      _$SupplierAgreementCreateSerializer();
}

class _$SupplierAgreementCreateSerializer
    implements PrimitiveSerializer<SupplierAgreementCreate> {
  @override
  final Iterable<Type> types = const [
    SupplierAgreementCreate,
    _$SupplierAgreementCreate,
  ];

  @override
  final String wireName = r'SupplierAgreementCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierAgreementCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'start';
    yield serializers.serialize(
      object.start,
      specifiedType: const FullType(Date),
    );
    yield r'end';
    yield serializers.serialize(
      object.end,
      specifiedType: const FullType(Date),
    );
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
    SupplierAgreementCreate object, {
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
    required SupplierAgreementCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'start':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.start = valueDes;
          break;
        case r'end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.end = valueDes;
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
  SupplierAgreementCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierAgreementCreateBuilder();
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
