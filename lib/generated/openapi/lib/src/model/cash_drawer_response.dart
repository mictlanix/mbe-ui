//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/facility_summary.dart';
import 'package:mbe_api_client/src/model/entity_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cash_drawer_response.g.dart';

/// CashDrawerResponse
///
/// Properties:
/// * [cashDrawerId]
/// * [facility]
/// * [code]
/// * [name]
/// * [comment]
/// * [status]
@BuiltValue()
abstract class CashDrawerResponse
    implements Built<CashDrawerResponse, CashDrawerResponseBuilder> {
  @BuiltValueField(wireName: r'cash_drawer_id')
  int get cashDrawerId;

  @BuiltValueField(wireName: r'facility')
  FacilitySummary get facility;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'status')
  EntityStatus get status;
  // enum statusEnum {  0,  1,  2,  };

  CashDrawerResponse._();

  factory CashDrawerResponse([void updates(CashDrawerResponseBuilder b)]) =
      _$CashDrawerResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CashDrawerResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CashDrawerResponse> get serializer =>
      _$CashDrawerResponseSerializer();
}

class _$CashDrawerResponseSerializer
    implements PrimitiveSerializer<CashDrawerResponse> {
  @override
  final Iterable<Type> types = const [CashDrawerResponse, _$CashDrawerResponse];

  @override
  final String wireName = r'CashDrawerResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CashDrawerResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cash_drawer_id';
    yield serializers.serialize(
      object.cashDrawerId,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(FacilitySummary),
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
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EntityStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CashDrawerResponse object, {
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
    required CashDrawerResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cash_drawer_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.cashDrawerId = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(FacilitySummary),
                  )
                  as FacilitySummary;
          result.facility.replace(valueDes);
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(EntityStatus),
                  )
                  as EntityStatus;
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
  CashDrawerResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CashDrawerResponseBuilder();
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
