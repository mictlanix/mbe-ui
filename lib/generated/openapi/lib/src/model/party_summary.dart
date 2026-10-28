//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/buckets.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'party_summary.g.dart';

/// PartySummary
///
/// Properties:
/// * [party]
/// * [name]
/// * [salesAgent]
/// * [salesAgentName]
/// * [owed]
/// * [overdue]
/// * [buckets]
/// * [oldest] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [credit]
/// * [net]
/// * [creditLimit]
/// * [creditDays]
/// * [owedCompany]
/// * [utilization]
/// * [availableCredit]
@BuiltValue()
abstract class PartySummary
    implements Built<PartySummary, PartySummaryBuilder> {
  @BuiltValueField(wireName: r'party')
  int get party;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'sales_agent')
  int? get salesAgent;

  @BuiltValueField(wireName: r'sales_agent_name')
  String? get salesAgentName;

  @BuiltValueField(wireName: r'owed')
  String get owed;

  @BuiltValueField(wireName: r'overdue')
  String get overdue;

  @BuiltValueField(wireName: r'buckets')
  Buckets get buckets;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'oldest')
  DateTime? get oldest;

  @BuiltValueField(wireName: r'credit')
  String get credit;

  @BuiltValueField(wireName: r'net')
  String get net;

  @BuiltValueField(wireName: r'credit_limit')
  String? get creditLimit;

  @BuiltValueField(wireName: r'credit_days')
  int? get creditDays;

  @BuiltValueField(wireName: r'owed_company')
  String get owedCompany;

  @BuiltValueField(wireName: r'utilization')
  String? get utilization;

  @BuiltValueField(wireName: r'available_credit')
  String? get availableCredit;

  PartySummary._();

  factory PartySummary([void updates(PartySummaryBuilder b)]) = _$PartySummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PartySummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PartySummary> get serializer => _$PartySummarySerializer();
}

class _$PartySummarySerializer implements PrimitiveSerializer<PartySummary> {
  @override
  final Iterable<Type> types = const [PartySummary, _$PartySummary];

  @override
  final String wireName = r'PartySummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PartySummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'party';
    yield serializers.serialize(
      object.party,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.salesAgent != null) {
      yield r'sales_agent';
      yield serializers.serialize(
        object.salesAgent,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.salesAgentName != null) {
      yield r'sales_agent_name';
      yield serializers.serialize(
        object.salesAgentName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'owed';
    yield serializers.serialize(
      object.owed,
      specifiedType: const FullType(String),
    );
    yield r'overdue';
    yield serializers.serialize(
      object.overdue,
      specifiedType: const FullType(String),
    );
    yield r'buckets';
    yield serializers.serialize(
      object.buckets,
      specifiedType: const FullType(Buckets),
    );
    yield r'oldest';
    yield object.oldest == null
        ? null
        : serializers.serialize(
            object.oldest,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'credit';
    yield serializers.serialize(
      object.credit,
      specifiedType: const FullType(String),
    );
    yield r'net';
    yield serializers.serialize(
      object.net,
      specifiedType: const FullType(String),
    );
    yield r'credit_limit';
    yield object.creditLimit == null
        ? null
        : serializers.serialize(
            object.creditLimit,
            specifiedType: const FullType.nullable(String),
          );
    yield r'credit_days';
    yield object.creditDays == null
        ? null
        : serializers.serialize(
            object.creditDays,
            specifiedType: const FullType.nullable(int),
          );
    yield r'owed_company';
    yield serializers.serialize(
      object.owedCompany,
      specifiedType: const FullType(String),
    );
    yield r'utilization';
    yield object.utilization == null
        ? null
        : serializers.serialize(
            object.utilization,
            specifiedType: const FullType.nullable(String),
          );
    yield r'available_credit';
    yield object.availableCredit == null
        ? null
        : serializers.serialize(
            object.availableCredit,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PartySummary object, {
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
    required PartySummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'party':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.party = valueDes;
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
        case r'sales_agent':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.salesAgent = valueDes;
          break;
        case r'sales_agent_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.salesAgentName = valueDes;
          break;
        case r'owed':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.owed = valueDes;
          break;
        case r'overdue':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.overdue = valueDes;
          break;
        case r'buckets':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Buckets),
                  )
                  as Buckets;
          result.buckets.replace(valueDes);
          break;
        case r'oldest':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.oldest = valueDes;
          break;
        case r'credit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.credit = valueDes;
          break;
        case r'net':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.net = valueDes;
          break;
        case r'credit_limit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.creditLimit = valueDes;
          break;
        case r'credit_days':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.creditDays = valueDes;
          break;
        case r'owed_company':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.owedCompany = valueDes;
          break;
        case r'utilization':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.utilization = valueDes;
          break;
        case r'available_credit':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.availableCredit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PartySummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PartySummaryBuilder();
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
