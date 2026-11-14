//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analytics_kardex_row.g.dart';

/// AnalyticsKardexRow
///
/// Properties:
/// * [date] - Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
/// * [movementType]
/// * [source_]
/// * [reference]
/// * [documentId] - Null when the entry does not resolve.
/// * [quantity] - Signed: positive in, negative out.
/// * [balance]
/// * [value] - Balance × unit_cost. Cost privilege only, absent otherwise; null when the product is uncosted.
@BuiltValue()
abstract class AnalyticsKardexRow
    implements Built<AnalyticsKardexRow, AnalyticsKardexRowBuilder> {
  /// Local wall-clock time in America/Mexico_City, with no UTC offset. A value sent with an offset is converted to America/Mexico_City; a value without one is taken as already local.
  @BuiltValueField(wireName: r'date')
  DateTime get date;

  @BuiltValueField(wireName: r'movement_type')
  int get movementType;

  @BuiltValueField(wireName: r'source')
  String get source_;

  @BuiltValueField(wireName: r'reference')
  int get reference;

  /// Null when the entry does not resolve.
  @BuiltValueField(wireName: r'document_id')
  int? get documentId;

  /// Signed: positive in, negative out.
  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'balance')
  String get balance;

  /// Balance × unit_cost. Cost privilege only, absent otherwise; null when the product is uncosted.
  @BuiltValueField(wireName: r'value')
  String? get value;

  AnalyticsKardexRow._();

  factory AnalyticsKardexRow([void updates(AnalyticsKardexRowBuilder b)]) =
      _$AnalyticsKardexRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalyticsKardexRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalyticsKardexRow> get serializer =>
      _$AnalyticsKardexRowSerializer();
}

class _$AnalyticsKardexRowSerializer
    implements PrimitiveSerializer<AnalyticsKardexRow> {
  @override
  final Iterable<Type> types = const [AnalyticsKardexRow, _$AnalyticsKardexRow];

  @override
  final String wireName = r'AnalyticsKardexRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalyticsKardexRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(DateTime),
    );
    yield r'movement_type';
    yield serializers.serialize(
      object.movementType,
      specifiedType: const FullType(int),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(String),
    );
    yield r'reference';
    yield serializers.serialize(
      object.reference,
      specifiedType: const FullType(int),
    );
    yield r'document_id';
    yield object.documentId == null
        ? null
        : serializers.serialize(
            object.documentId,
            specifiedType: const FullType.nullable(int),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    if (object.value != null) {
      yield r'value';
      yield serializers.serialize(
        object.value,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalyticsKardexRow object, {
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
    required AnalyticsKardexRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )
                  as DateTime;
          result.date = valueDes;
          break;
        case r'movement_type':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.movementType = valueDes;
          break;
        case r'source':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.source_ = valueDes;
          break;
        case r'reference':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.reference = valueDes;
          break;
        case r'document_id':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.documentId = valueDes;
          break;
        case r'quantity':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.quantity = valueDes;
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
        case r'value':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.value = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalyticsKardexRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalyticsKardexRowBuilder();
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
