//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/account_payment.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/open_document.dart';
import 'package:mbe_api_client/src/model/party_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'party_detail.g.dart';

/// PartyDetail
///
/// Properties:
/// * [summary]
/// * [documents]
/// * [payments]
@BuiltValue()
abstract class PartyDetail implements Built<PartyDetail, PartyDetailBuilder> {
  @BuiltValueField(wireName: r'summary')
  PartySummary get summary;

  @BuiltValueField(wireName: r'documents')
  BuiltList<OpenDocument> get documents;

  @BuiltValueField(wireName: r'payments')
  BuiltList<AccountPayment> get payments;

  PartyDetail._();

  factory PartyDetail([void updates(PartyDetailBuilder b)]) = _$PartyDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PartyDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PartyDetail> get serializer => _$PartyDetailSerializer();
}

class _$PartyDetailSerializer implements PrimitiveSerializer<PartyDetail> {
  @override
  final Iterable<Type> types = const [PartyDetail, _$PartyDetail];

  @override
  final String wireName = r'PartyDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PartyDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'summary';
    yield serializers.serialize(
      object.summary,
      specifiedType: const FullType(PartySummary),
    );
    yield r'documents';
    yield serializers.serialize(
      object.documents,
      specifiedType: const FullType(BuiltList, [FullType(OpenDocument)]),
    );
    yield r'payments';
    yield serializers.serialize(
      object.payments,
      specifiedType: const FullType(BuiltList, [FullType(AccountPayment)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PartyDetail object, {
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
    required PartyDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'summary':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(PartySummary),
                  )
                  as PartySummary;
          result.summary.replace(valueDes);
          break;
        case r'documents':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(OpenDocument),
                    ]),
                  )
                  as BuiltList<OpenDocument>;
          result.documents.replace(valueDes);
          break;
        case r'payments':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(AccountPayment),
                    ]),
                  )
                  as BuiltList<AccountPayment>;
          result.payments.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PartyDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PartyDetailBuilder();
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
