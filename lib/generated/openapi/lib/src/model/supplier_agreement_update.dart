//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_agreement_update.g.dart';

/// SupplierAgreementUpdate
///
/// Properties:
/// * [start]
/// * [end]
/// * [comment]
@BuiltValue()
abstract class SupplierAgreementUpdate
    implements Built<SupplierAgreementUpdate, SupplierAgreementUpdateBuilder> {
  @BuiltValueField(wireName: r'start')
  Date? get start;

  @BuiltValueField(wireName: r'end')
  Date? get end;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SupplierAgreementUpdate._();

  factory SupplierAgreementUpdate([
    void updates(SupplierAgreementUpdateBuilder b),
  ]) = _$SupplierAgreementUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierAgreementUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierAgreementUpdate> get serializer =>
      _$SupplierAgreementUpdateSerializer();
}

class _$SupplierAgreementUpdateSerializer
    implements PrimitiveSerializer<SupplierAgreementUpdate> {
  @override
  final Iterable<Type> types = const [
    SupplierAgreementUpdate,
    _$SupplierAgreementUpdate,
  ];

  @override
  final String wireName = r'SupplierAgreementUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierAgreementUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.start != null) {
      yield r'start';
      yield serializers.serialize(
        object.start,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.end != null) {
      yield r'end';
      yield serializers.serialize(
        object.end,
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
    SupplierAgreementUpdate object, {
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
    required SupplierAgreementUpdateBuilder result,
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
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
          result.start = valueDes;
          break;
        case r'end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(Date),
                  )
                  as Date?;
          if (valueDes == null) continue;
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
  SupplierAgreementUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierAgreementUpdateBuilder();
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
