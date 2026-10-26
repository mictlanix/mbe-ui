//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/corrected_by_other_count.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:mbe_api_client/src/model/negative_available.dart';
import 'package:mbe_api_client/src/model/inventory_count_line_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inventory_count_confirm_response.g.dart';

/// The confirmed count and its two warnings; neither stops the confirm (FR-010, FR-010a).
///
/// Properties:
/// * [inventoryCountId]
/// * [facility]
/// * [warehouse]
/// * [serial]
/// * [status]
/// * [comment]
/// * [creator]
/// * [updater]
/// * [creationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [modificationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [lines]
/// * [negativeAvailable]
/// * [correctedByOtherCounts]
@BuiltValue()
abstract class InventoryCountConfirmResponse
    implements
        Built<
          InventoryCountConfirmResponse,
          InventoryCountConfirmResponseBuilder
        > {
  @BuiltValueField(wireName: r'inventory_count_id')
  int get inventoryCountId;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'creator')
  int get creator;

  @BuiltValueField(wireName: r'updater')
  int get updater;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'creation_time')
  DateTime get creationTime;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'modification_time')
  DateTime get modificationTime;

  @BuiltValueField(wireName: r'lines')
  BuiltList<InventoryCountLineResponse>? get lines;

  @BuiltValueField(wireName: r'negative_available')
  BuiltList<NegativeAvailable>? get negativeAvailable;

  @BuiltValueField(wireName: r'corrected_by_other_counts')
  BuiltList<CorrectedByOtherCount>? get correctedByOtherCounts;

  InventoryCountConfirmResponse._();

  factory InventoryCountConfirmResponse([
    void updates(InventoryCountConfirmResponseBuilder b),
  ]) = _$InventoryCountConfirmResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InventoryCountConfirmResponseBuilder b) => b
    ..lines = ListBuilder()
    ..negativeAvailable = ListBuilder()
    ..correctedByOtherCounts = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<InventoryCountConfirmResponse> get serializer =>
      _$InventoryCountConfirmResponseSerializer();
}

class _$InventoryCountConfirmResponseSerializer
    implements PrimitiveSerializer<InventoryCountConfirmResponse> {
  @override
  final Iterable<Type> types = const [
    InventoryCountConfirmResponse,
    _$InventoryCountConfirmResponse,
  ];

  @override
  final String wireName = r'InventoryCountConfirmResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InventoryCountConfirmResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'inventory_count_id';
    yield serializers.serialize(
      object.inventoryCountId,
      specifiedType: const FullType(int),
    );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
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
      specifiedType: const FullType(DocumentStatus),
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
    yield r'creation_time';
    yield serializers.serialize(
      object.creationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'modification_time';
    yield serializers.serialize(
      object.modificationTime,
      specifiedType: const FullType(DateTime),
    );
    if (object.lines != null) {
      yield r'lines';
      yield serializers.serialize(
        object.lines,
        specifiedType: const FullType(BuiltList, [
          FullType(InventoryCountLineResponse),
        ]),
      );
    }
    if (object.negativeAvailable != null) {
      yield r'negative_available';
      yield serializers.serialize(
        object.negativeAvailable,
        specifiedType: const FullType(BuiltList, [FullType(NegativeAvailable)]),
      );
    }
    if (object.correctedByOtherCounts != null) {
      yield r'corrected_by_other_counts';
      yield serializers.serialize(
        object.correctedByOtherCounts,
        specifiedType: const FullType(BuiltList, [
          FullType(CorrectedByOtherCount),
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InventoryCountConfirmResponse object, {
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
    required InventoryCountConfirmResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'inventory_count_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.inventoryCountId = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
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
                    specifiedType: const FullType(DocumentStatus),
                  )
                  as DocumentStatus;
          result.status = valueDes;
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
        case r'creation_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.creationTime = valueDes;
          break;
        case r'modification_time':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.modificationTime = valueDes;
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(InventoryCountLineResponse),
                    ]),
                  )
                  as BuiltList<InventoryCountLineResponse>?;
          if (valueDes == null) continue;
          result.lines.replace(valueDes);
          break;
        case r'negative_available':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(NegativeAvailable),
                    ]),
                  )
                  as BuiltList<NegativeAvailable>?;
          if (valueDes == null) continue;
          result.negativeAvailable.replace(valueDes);
          break;
        case r'corrected_by_other_counts':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(CorrectedByOtherCount),
                    ]),
                  )
                  as BuiltList<CorrectedByOtherCount>?;
          if (valueDes == null) continue;
          result.correctedByOtherCounts.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InventoryCountConfirmResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InventoryCountConfirmResponseBuilder();
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
