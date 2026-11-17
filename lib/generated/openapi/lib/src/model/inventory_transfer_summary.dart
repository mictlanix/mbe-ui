//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/transfer_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inventory_transfer_summary.g.dart';

/// InventoryTransferSummary
///
/// Properties:
/// * [inventoryTransferId]
/// * [facility]
/// * [warehouse]
/// * [warehouseTo]
/// * [serial]
/// * [status]
/// * [creator]
/// * [creationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [warehouseName]
/// * [warehouseToName]
/// * [facilityName]
/// * [creatorName]
@BuiltValue()
abstract class InventoryTransferSummary
    implements
        Built<InventoryTransferSummary, InventoryTransferSummaryBuilder> {
  @BuiltValueField(wireName: r'inventory_transfer_id')
  int get inventoryTransferId;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'warehouse_to')
  int get warehouseTo;

  @BuiltValueField(wireName: r'serial')
  int? get serial;

  @BuiltValueField(wireName: r'status')
  TransferStatus get status;
  // enum statusEnum {  draft,  in_transit,  received,  cancelled,  };

  @BuiltValueField(wireName: r'creator')
  int get creator;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'creation_time')
  DateTime get creationTime;

  @BuiltValueField(wireName: r'warehouse_name')
  String? get warehouseName;

  @BuiltValueField(wireName: r'warehouse_to_name')
  String? get warehouseToName;

  @BuiltValueField(wireName: r'facility_name')
  String? get facilityName;

  @BuiltValueField(wireName: r'creator_name')
  String? get creatorName;

  InventoryTransferSummary._();

  factory InventoryTransferSummary([
    void updates(InventoryTransferSummaryBuilder b),
  ]) = _$InventoryTransferSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InventoryTransferSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InventoryTransferSummary> get serializer =>
      _$InventoryTransferSummarySerializer();
}

class _$InventoryTransferSummarySerializer
    implements PrimitiveSerializer<InventoryTransferSummary> {
  @override
  final Iterable<Type> types = const [
    InventoryTransferSummary,
    _$InventoryTransferSummary,
  ];

  @override
  final String wireName = r'InventoryTransferSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InventoryTransferSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'inventory_transfer_id';
    yield serializers.serialize(
      object.inventoryTransferId,
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
    yield r'warehouse_to';
    yield serializers.serialize(
      object.warehouseTo,
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
      specifiedType: const FullType(TransferStatus),
    );
    yield r'creator';
    yield serializers.serialize(
      object.creator,
      specifiedType: const FullType(int),
    );
    yield r'creation_time';
    yield serializers.serialize(
      object.creationTime,
      specifiedType: const FullType(DateTime),
    );
    if (object.warehouseName != null) {
      yield r'warehouse_name';
      yield serializers.serialize(
        object.warehouseName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.warehouseToName != null) {
      yield r'warehouse_to_name';
      yield serializers.serialize(
        object.warehouseToName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.facilityName != null) {
      yield r'facility_name';
      yield serializers.serialize(
        object.facilityName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.creatorName != null) {
      yield r'creator_name';
      yield serializers.serialize(
        object.creatorName,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InventoryTransferSummary object, {
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
    required InventoryTransferSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'inventory_transfer_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.inventoryTransferId = valueDes;
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
        case r'warehouse_to':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouseTo = valueDes;
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
                    specifiedType: const FullType(TransferStatus),
                  )
                  as TransferStatus;
          result.status = valueDes;
          break;
        case r'creator':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.creator = valueDes;
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
        case r'warehouse_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.warehouseName = valueDes;
          break;
        case r'warehouse_to_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.warehouseToName = valueDes;
          break;
        case r'facility_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.facilityName = valueDes;
          break;
        case r'creator_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.creatorName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InventoryTransferSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InventoryTransferSummaryBuilder();
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
