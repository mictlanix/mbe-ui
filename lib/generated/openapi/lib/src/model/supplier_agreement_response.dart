//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_agreement_response.g.dart';

/// SupplierAgreementResponse
///
/// Properties:
/// * [supplierAgreementId]
/// * [supplier]
/// * [start]
/// * [end]
/// * [comment]
@BuiltValue()
abstract class SupplierAgreementResponse
    implements
        Built<SupplierAgreementResponse, SupplierAgreementResponseBuilder> {
  @BuiltValueField(wireName: r'supplier_agreement_id')
  int get supplierAgreementId;

  @BuiltValueField(wireName: r'supplier')
  int get supplier;

  @BuiltValueField(wireName: r'start')
  Date get start;

  @BuiltValueField(wireName: r'end')
  Date get end;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  SupplierAgreementResponse._();

  factory SupplierAgreementResponse([
    void updates(SupplierAgreementResponseBuilder b),
  ]) = _$SupplierAgreementResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierAgreementResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierAgreementResponse> get serializer =>
      _$SupplierAgreementResponseSerializer();
}

class _$SupplierAgreementResponseSerializer
    implements PrimitiveSerializer<SupplierAgreementResponse> {
  @override
  final Iterable<Type> types = const [
    SupplierAgreementResponse,
    _$SupplierAgreementResponse,
  ];

  @override
  final String wireName = r'SupplierAgreementResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierAgreementResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier_agreement_id';
    yield serializers.serialize(
      object.supplierAgreementId,
      specifiedType: const FullType(int),
    );
    yield r'supplier';
    yield serializers.serialize(
      object.supplier,
      specifiedType: const FullType(int),
    );
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
    SupplierAgreementResponse object, {
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
    required SupplierAgreementResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier_agreement_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.supplierAgreementId = valueDes;
          break;
        case r'supplier':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.supplier = valueDes;
          break;
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
  SupplierAgreementResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierAgreementResponseBuilder();
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
