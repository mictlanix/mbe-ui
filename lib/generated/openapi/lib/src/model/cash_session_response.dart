//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/cash_drawer_summary.dart';
import 'package:mbe_api_client/src/model/employee_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/method_total.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cash_session_response.g.dart';

/// CashSessionResponse
///
/// Properties:
/// * [cashSessionId]
/// * [cashDrawer]
/// * [cashier]
/// * [start]
/// * [end]
/// * [cashSupervisor]
/// * [openingAmount]
/// * [paymentsByMethod]
@BuiltValue()
abstract class CashSessionResponse
    implements Built<CashSessionResponse, CashSessionResponseBuilder> {
  @BuiltValueField(wireName: r'cash_session_id')
  int get cashSessionId;

  @BuiltValueField(wireName: r'cash_drawer')
  CashDrawerSummary get cashDrawer;

  @BuiltValueField(wireName: r'cashier')
  EmployeeResponse get cashier;

  @BuiltValueField(wireName: r'start')
  DateTime get start;

  @BuiltValueField(wireName: r'end')
  DateTime? get end;

  @BuiltValueField(wireName: r'cash_supervisor')
  EmployeeResponse? get cashSupervisor;

  @BuiltValueField(wireName: r'opening_amount')
  String get openingAmount;

  @BuiltValueField(wireName: r'payments_by_method')
  BuiltList<MethodTotal>? get paymentsByMethod;

  CashSessionResponse._();

  factory CashSessionResponse([void updates(CashSessionResponseBuilder b)]) =
      _$CashSessionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CashSessionResponseBuilder b) =>
      b..paymentsByMethod = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<CashSessionResponse> get serializer =>
      _$CashSessionResponseSerializer();
}

class _$CashSessionResponseSerializer
    implements PrimitiveSerializer<CashSessionResponse> {
  @override
  final Iterable<Type> types = const [
    CashSessionResponse,
    _$CashSessionResponse,
  ];

  @override
  final String wireName = r'CashSessionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CashSessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cash_session_id';
    yield serializers.serialize(
      object.cashSessionId,
      specifiedType: const FullType(int),
    );
    yield r'cash_drawer';
    yield serializers.serialize(
      object.cashDrawer,
      specifiedType: const FullType(CashDrawerSummary),
    );
    yield r'cashier';
    yield serializers.serialize(
      object.cashier,
      specifiedType: const FullType(EmployeeResponse),
    );
    yield r'start';
    yield serializers.serialize(
      object.start,
      specifiedType: const FullType(DateTime),
    );
    yield r'end';
    yield object.end == null
        ? null
        : serializers.serialize(
            object.end,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'cash_supervisor';
    yield object.cashSupervisor == null
        ? null
        : serializers.serialize(
            object.cashSupervisor,
            specifiedType: const FullType.nullable(EmployeeResponse),
          );
    yield r'opening_amount';
    yield serializers.serialize(
      object.openingAmount,
      specifiedType: const FullType(String),
    );
    if (object.paymentsByMethod != null) {
      yield r'payments_by_method';
      yield serializers.serialize(
        object.paymentsByMethod,
        specifiedType: const FullType(BuiltList, [FullType(MethodTotal)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CashSessionResponse object, {
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
    required CashSessionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cash_session_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.cashSessionId = valueDes;
          break;
        case r'cash_drawer':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(CashDrawerSummary),
                  )
                  as CashDrawerSummary;
          result.cashDrawer.replace(valueDes);
          break;
        case r'cashier':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(EmployeeResponse),
                  )
                  as EmployeeResponse;
          result.cashier.replace(valueDes);
          break;
        case r'start':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.start = valueDes;
          break;
        case r'end':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.end = valueDes;
          break;
        case r'cash_supervisor':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(EmployeeResponse),
                  )
                  as EmployeeResponse?;
          if (valueDes == null) continue;
          result.cashSupervisor.replace(valueDes);
          break;
        case r'opening_amount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.openingAmount = valueDes;
          break;
        case r'payments_by_method':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(MethodTotal),
                    ]),
                  )
                  as BuiltList<MethodTotal>?;
          if (valueDes == null) continue;
          result.paymentsByMethod.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CashSessionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CashSessionResponseBuilder();
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
