//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/document_status.dart';
import 'package:mbe_api_client/src/model/inventory_count_line_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'inventory_count_lines_changed.g.dart';

/// A `/line-changes` write: the header's state and only what the request set (#333).  The header fields keep `InventoryCountResponse`'s names.
///
/// Properties:
/// * [inventoryCountId]
/// * [status]
/// * [updater]
/// * [modificationTime] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [lineCount]
/// * [lines]
/// * [removedLineId]
@BuiltValue()
abstract class InventoryCountLinesChanged
    implements
        Built<InventoryCountLinesChanged, InventoryCountLinesChangedBuilder> {
  @BuiltValueField(wireName: r'inventory_count_id')
  int get inventoryCountId;

  @BuiltValueField(wireName: r'status')
  DocumentStatus get status;
  // enum statusEnum {  draft,  completed,  paid,  cancelled,  };

  @BuiltValueField(wireName: r'updater')
  int get updater;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'modification_time')
  DateTime get modificationTime;

  @BuiltValueField(wireName: r'line_count')
  int get lineCount;

  @BuiltValueField(wireName: r'lines')
  BuiltList<InventoryCountLineResponse>? get lines;

  @BuiltValueField(wireName: r'removed_line_id')
  int? get removedLineId;

  InventoryCountLinesChanged._();

  factory InventoryCountLinesChanged([
    void updates(InventoryCountLinesChangedBuilder b),
  ]) = _$InventoryCountLinesChanged;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InventoryCountLinesChangedBuilder b) =>
      b..lines = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<InventoryCountLinesChanged> get serializer =>
      _$InventoryCountLinesChangedSerializer();
}

class _$InventoryCountLinesChangedSerializer
    implements PrimitiveSerializer<InventoryCountLinesChanged> {
  @override
  final Iterable<Type> types = const [
    InventoryCountLinesChanged,
    _$InventoryCountLinesChanged,
  ];

  @override
  final String wireName = r'InventoryCountLinesChanged';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InventoryCountLinesChanged object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'inventory_count_id';
    yield serializers.serialize(
      object.inventoryCountId,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DocumentStatus),
    );
    yield r'updater';
    yield serializers.serialize(
      object.updater,
      specifiedType: const FullType(int),
    );
    yield r'modification_time';
    yield serializers.serialize(
      object.modificationTime,
      specifiedType: const FullType(DateTime),
    );
    yield r'line_count';
    yield serializers.serialize(
      object.lineCount,
      specifiedType: const FullType(int),
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
    if (object.removedLineId != null) {
      yield r'removed_line_id';
      yield serializers.serialize(
        object.removedLineId,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InventoryCountLinesChanged object, {
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
    required InventoryCountLinesChangedBuilder result,
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
        case r'status':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DocumentStatus),
                  )
                  as DocumentStatus;
          result.status = valueDes;
          break;
        case r'updater':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.updater = valueDes;
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
        case r'line_count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lineCount = valueDes;
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
        case r'removed_line_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.removedLineId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InventoryCountLinesChanged deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InventoryCountLinesChangedBuilder();
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
