//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/request_status.dart';
import 'package:mbe_api_client/src/model/purchase_request_line.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_request_response.g.dart';

/// PurchaseRequestResponse
///
/// Properties:
/// * [purchaseRequestId]
/// * [serial]
/// * [status]
/// * [warehouse]
/// * [facility]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [comment]
/// * [creator]
/// * [updater]
/// * [approver]
/// * [approvalTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [lineCount]
/// * [warnings]
/// * [lines]
@BuiltValue()
abstract class PurchaseRequestResponse
    implements Built<PurchaseRequestResponse, PurchaseRequestResponseBuilder> {
  @BuiltValueField(wireName: r'purchase_request_id')
  int get purchaseRequestId;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'status')
  RequestStatus get status;
  // enum statusEnum {  draft,  submitted,  approved,  cancelled,  };

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'facility')
  int? get facility;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'creator')
  int get creator;

  @BuiltValueField(wireName: r'updater')
  int get updater;

  @BuiltValueField(wireName: r'approver')
  int? get approver;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'approval_time')
  DateTime? get approvalTime;

  @BuiltValueField(wireName: r'line_count')
  int get lineCount;

  @BuiltValueField(wireName: r'warnings')
  BuiltList<String>? get warnings;

  @BuiltValueField(wireName: r'lines')
  BuiltList<PurchaseRequestLine>? get lines;

  PurchaseRequestResponse._();

  factory PurchaseRequestResponse([
    void updates(PurchaseRequestResponseBuilder b),
  ]) = _$PurchaseRequestResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseRequestResponseBuilder b) => b
    ..warnings = ListBuilder()
    ..lines = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseRequestResponse> get serializer =>
      _$PurchaseRequestResponseSerializer();
}

class _$PurchaseRequestResponseSerializer
    implements PrimitiveSerializer<PurchaseRequestResponse> {
  @override
  final Iterable<Type> types = const [
    PurchaseRequestResponse,
    _$PurchaseRequestResponse,
  ];

  @override
  final String wireName = r'PurchaseRequestResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseRequestResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'purchase_request_id';
    yield serializers.serialize(
      object.purchaseRequestId,
      specifiedType: const FullType(int),
    );
    yield r'serial';
    yield object.serial == null
        ? null
        : serializers.serialize(
            object.serial,
            specifiedType: const FullType.nullable(int),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RequestStatus),
    );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield object.facility == null
        ? null
        : serializers.serialize(
            object.facility,
            specifiedType: const FullType.nullable(int),
          );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
    yield r'creator';
    yield serializers.serialize(
      object.creator,
      specifiedType: const FullType(int),
    );
    yield r'updater';
    yield serializers.serialize(
      object.updater,
      specifiedType: const FullType(int),
    );
    yield r'approver';
    yield object.approver == null
        ? null
        : serializers.serialize(
            object.approver,
            specifiedType: const FullType.nullable(int),
          );
    yield r'approval_time';
    yield object.approvalTime == null
        ? null
        : serializers.serialize(
            object.approvalTime,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'line_count';
    yield serializers.serialize(
      object.lineCount,
      specifiedType: const FullType(int),
    );
    if (object.warnings != null) {
      yield r'warnings';
      yield serializers.serialize(
        object.warnings,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [
          FullType(PurchaseRequestLine),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseRequestResponse object, {
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
    required PurchaseRequestResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'purchase_request_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.purchaseRequestId = valueDes;
          break;
        case r'serial':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.serial = valueDes;
          break;
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(RequestStatus),
                  )
                  as RequestStatus;
          result.status = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.facility = valueDes;
          break;
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
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
        case r'creator':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creator = valueDes;
          break;
        case r'updater':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.updater = valueDes;
          break;
        case r'approver':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.approver = valueDes;
          break;
        case r'approval_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(DateTime),
                  )
                  as DateTime?;
          if (valueDes == null) continue;
          result.approvalTime = valueDes;
          break;
        case r'line_count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lineCount = valueDes;
          break;
        case r'warnings':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(String),
                    ]),
                  )
                  as BuiltList<String>?;
          if (valueDes == null) continue;
          result.warnings.replace(valueDes);
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(PurchaseRequestLine),
                    ]),
                  )
                  as BuiltList<PurchaseRequestLine>?;
          if (valueDes == null) continue;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PurchaseRequestResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseRequestResponseBuilder();
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
