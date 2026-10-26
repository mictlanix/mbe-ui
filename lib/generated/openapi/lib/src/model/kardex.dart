//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:mbe_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/kardex_row.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kardex.g.dart';

/// Kardex
///
/// Properties:
/// * [product]
/// * [warehouse]
/// * [from]
/// * [to]
/// * [opening]
/// * [rows]
/// * [totalIn]
/// * [totalOut]
/// * [closing]
@BuiltValue()
abstract class Kardex implements Built<Kardex, KardexBuilder> {
  @BuiltValueField(wireName: r'product')
  int get product;

  @BuiltValueField(wireName: r'warehouse')
  int get warehouse;

  @BuiltValueField(wireName: r'from')
  Date get from;

  @BuiltValueField(wireName: r'to')
  Date get to;

  @BuiltValueField(wireName: r'opening')
  String get opening;

  @BuiltValueField(wireName: r'rows')
  BuiltList<KardexRow>? get rows;

  @BuiltValueField(wireName: r'total_in')
  String get totalIn;

  @BuiltValueField(wireName: r'total_out')
  String get totalOut;

  @BuiltValueField(wireName: r'closing')
  String get closing;

  Kardex._();

  factory Kardex([void updates(KardexBuilder b)]) = _$Kardex;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KardexBuilder b) => b..rows = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<Kardex> get serializer => _$KardexSerializer();
}

class _$KardexSerializer implements PrimitiveSerializer<Kardex> {
  @override
  final Iterable<Type> types = const [Kardex, _$Kardex];

  @override
  final String wireName = r'Kardex';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Kardex object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'product';
    yield serializers.serialize(
      object.product,
      specifiedType: const FullType(int),
    );
    yield r'warehouse';
    yield serializers.serialize(
      object.warehouse,
      specifiedType: const FullType(int),
    );
    yield r'from';
    yield serializers.serialize(
      object.from,
      specifiedType: const FullType(Date),
    );
    yield r'to';
    yield serializers.serialize(object.to, specifiedType: const FullType(Date));
    yield r'opening';
    yield serializers.serialize(
      object.opening,
      specifiedType: const FullType(String),
    );
    if (object.rows != null) {
      yield r'rows';
      yield serializers.serialize(
        object.rows,
        specifiedType: const FullType(BuiltList, [FullType(KardexRow)]),
      );
    }
    yield r'total_in';
    yield serializers.serialize(
      object.totalIn,
      specifiedType: const FullType(String),
    );
    yield r'total_out';
    yield serializers.serialize(
      object.totalOut,
      specifiedType: const FullType(String),
    );
    yield r'closing';
    yield serializers.serialize(
      object.closing,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Kardex object, {
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
    required KardexBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'product':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.product = valueDes;
          break;
        case r'warehouse':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.warehouse = valueDes;
          break;
        case r'from':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.from = valueDes;
          break;
        case r'to':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(Date),
                  )
                  as Date;
          result.to = valueDes;
          break;
        case r'opening':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.opening = valueDes;
          break;
        case r'rows':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(BuiltList, [
                      FullType(KardexRow),
                    ]),
                  )
                  as BuiltList<KardexRow>?;
          if (valueDes == null) continue;
          result.rows.replace(valueDes);
          break;
        case r'total_in':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.totalIn = valueDes;
          break;
        case r'total_out':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.totalOut = valueDes;
          break;
        case r'closing':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.closing = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Kardex deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KardexBuilder();
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
