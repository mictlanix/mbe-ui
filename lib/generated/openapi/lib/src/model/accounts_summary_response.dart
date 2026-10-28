//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/account_scope.dart';
import 'package:mbe_api_client/src/model/party_summary.dart';
import 'package:mbe_api_client/src/model/account_totals.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'accounts_summary_response.g.dart';

/// AccountsSummaryResponse
///
/// Properties:
/// * [items]
/// * [total]
/// * [scope]
/// * [totals]
/// * [cutoff] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
@BuiltValue()
abstract class AccountsSummaryResponse
    implements Built<AccountsSummaryResponse, AccountsSummaryResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<PartySummary> get items;

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'scope')
  AccountScope get scope;

  @BuiltValueField(wireName: r'totals')
  AccountTotals get totals;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'cutoff')
  DateTime? get cutoff;

  AccountsSummaryResponse._();

  factory AccountsSummaryResponse([
    void updates(AccountsSummaryResponseBuilder b),
  ]) = _$AccountsSummaryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccountsSummaryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AccountsSummaryResponse> get serializer =>
      _$AccountsSummaryResponseSerializer();
}

class _$AccountsSummaryResponseSerializer
    implements PrimitiveSerializer<AccountsSummaryResponse> {
  @override
  final Iterable<Type> types = const [
    AccountsSummaryResponse,
    _$AccountsSummaryResponse,
  ];

  @override
  final String wireName = r'AccountsSummaryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccountsSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(PartySummary)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(AccountScope),
    );
    yield r'totals';
    yield serializers.serialize(
      object.totals,
      specifiedType: const FullType(AccountTotals),
    );
    if (object.cutoff != null) {
      yield r'cutoff';
      yield serializers.serialize(
        object.cutoff,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AccountsSummaryResponse object, {
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
    required AccountsSummaryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(PartySummary),
                    ]),
                  )
                  as BuiltList<PartySummary>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.total = valueDes;
          break;
        case r'scope':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AccountScope),
                  )
                  as AccountScope;
          result.scope.replace(valueDes);
          break;
        case r'totals':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(AccountTotals),
                  )
                  as AccountTotals;
          result.totals.replace(valueDes);
          break;
        case r'cutoff':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.cutoff = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AccountsSummaryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccountsSummaryResponseBuilder();
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
