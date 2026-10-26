//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/kardex_document.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kardex_row.g.dart';

/// KardexRow
///
/// Properties:
/// * [lotSerialTrackingId]
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [source_]
/// * [sourceName]
/// * [document]
/// * [reference]
/// * [quantityIn]
/// * [quantityOut]
/// * [balance]
@BuiltValue()
abstract class KardexRow implements Built<KardexRow, KardexRowBuilder> {
  @BuiltValueField(wireName: r'lot_serial_tracking_id')
  int get lotSerialTrackingId;

  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'source')
  int get source_;

  @BuiltValueField(wireName: r'source_name')
  String get sourceName;

  @BuiltValueField(wireName: r'document')
  KardexDocument? get document;

  @BuiltValueField(wireName: r'reference')
  int get reference;

  @BuiltValueField(wireName: r'quantity_in')
  String get quantityIn;

  @BuiltValueField(wireName: r'quantity_out')
  String get quantityOut;

  @BuiltValueField(wireName: r'balance')
  String get balance;

  KardexRow._();

  factory KardexRow([void updates(KardexRowBuilder b)]) = _$KardexRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KardexRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KardexRow> get serializer => _$KardexRowSerializer();
}

class _$KardexRowSerializer implements PrimitiveSerializer<KardexRow> {
  @override
  final Iterable<Type> types = const [KardexRow, _$KardexRow];

  @override
  final String wireName = r'KardexRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KardexRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'lot_serial_tracking_id';
    yield serializers.serialize(
      object.lotSerialTrackingId,
      specifiedType: const FullType(int),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(int),
    );
    yield r'source_name';
    yield serializers.serialize(
      object.sourceName,
      specifiedType: const FullType(String),
    );
    yield r'document';
    yield object.document == null
        ? null
        : serializers.serialize(
            object.document,
            specifiedType: const FullType.nullable(KardexDocument),
          );
    yield r'reference';
    yield serializers.serialize(
      object.reference,
      specifiedType: const FullType(int),
    );
    yield r'quantity_in';
    yield serializers.serialize(
      object.quantityIn,
      specifiedType: const FullType(String),
    );
    yield r'quantity_out';
    yield serializers.serialize(
      object.quantityOut,
      specifiedType: const FullType(String),
    );
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KardexRow object, {
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
    required KardexRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lot_serial_tracking_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lotSerialTrackingId = valueDes;
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
        case r'source':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.source_ = valueDes;
          break;
        case r'source_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.sourceName = valueDes;
          break;
        case r'document':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(KardexDocument),
                  )
                  as KardexDocument?;
          if (valueDes == null) continue;
          result.document.replace(valueDes);
          break;
        case r'reference':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.reference = valueDes;
          break;
        case r'quantity_in':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantityIn = valueDes;
          break;
        case r'quantity_out':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantityOut = valueDes;
          break;
        case r'balance':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.balance = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KardexRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KardexRowBuilder();
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
