//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:mbe_api_client/src/model/to_purchase_line.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'to_purchase_group.g.dart';

/// ToPurchaseGroup
///
/// Properties:
/// * [supplier]
/// * [supplierName]
/// * [facility]
/// * [lineCount]
/// * [estimatedTotal]
/// * [lines]
@BuiltValue()
abstract class ToPurchaseGroup
    implements Built<ToPurchaseGroup, ToPurchaseGroupBuilder> {
  @BuiltValueField(wireName: r'supplier')
  int? get supplier;

  @BuiltValueField(wireName: r'supplier_name')
  String? get supplierName;

  @BuiltValueField(wireName: r'facility')
  int get facility;

  @BuiltValueField(wireName: r'line_count')
  int get lineCount;

  @BuiltValueField(wireName: r'estimated_total')
  String get estimatedTotal;

  @BuiltValueField(wireName: r'lines')
  BuiltList<ToPurchaseLine> get lines;

  ToPurchaseGroup._();

  factory ToPurchaseGroup([void updates(ToPurchaseGroupBuilder b)]) =
      _$ToPurchaseGroup;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ToPurchaseGroupBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ToPurchaseGroup> get serializer =>
      _$ToPurchaseGroupSerializer();
}

class _$ToPurchaseGroupSerializer
    implements PrimitiveSerializer<ToPurchaseGroup> {
  @override
  final Iterable<Type> types = const [ToPurchaseGroup, _$ToPurchaseGroup];

  @override
  final String wireName = r'ToPurchaseGroup';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ToPurchaseGroup object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'supplier';
    yield object.supplier == null
        ? null
        : serializers.serialize(
            object.supplier,
            specifiedType: const FullType.nullable(int),
          );
    yield r'supplier_name';
    yield object.supplierName == null
        ? null
        : serializers.serialize(
            object.supplierName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'facility';
    yield serializers.serialize(
      object.facility,
      specifiedType: const FullType(int),
    );
    yield r'line_count';
    yield serializers.serialize(
      object.lineCount,
      specifiedType: const FullType(int),
    );
    yield r'estimated_total';
    yield serializers.serialize(
      object.estimatedTotal,
      specifiedType: const FullType(String),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(ToPurchaseLine)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ToPurchaseGroup object, {
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
    required ToPurchaseGroupBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'supplier':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(int),
                  )
                  as int?;
          if (valueDes == null) continue;
          result.supplier = valueDes;
          break;
        case r'supplier_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.supplierName = valueDes;
          break;
        case r'facility':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.facility = valueDes;
          break;
        case r'line_count':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.lineCount = valueDes;
          break;
        case r'estimated_total':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.estimatedTotal = valueDes;
          break;
        case r'lines':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(BuiltList, [
                      FullType(ToPurchaseLine),
                    ]),
                  )
                  as BuiltList<ToPurchaseLine>;
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
  ToPurchaseGroup deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ToPurchaseGroupBuilder();
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
