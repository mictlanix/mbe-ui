//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fiscal_document_line.g.dart';

/// FiscalDocumentLine
///
/// Properties:
/// * [fiscalDocumentDetailId]
/// * [productService]
/// * [productCode]
/// * [productName]
/// * [unitOfMeasurement]
/// * [unitOfMeasurementName]
/// * [quantity]
/// * [price]
/// * [discount]
/// * [taxRate]
/// * [taxIncluded]
/// * [comment]
@BuiltValue()
abstract class FiscalDocumentLine
    implements Built<FiscalDocumentLine, FiscalDocumentLineBuilder> {
  @BuiltValueField(wireName: r'fiscal_document_detail_id')
  int get fiscalDocumentDetailId;

  @BuiltValueField(wireName: r'product_service')
  String? get productService;

  @BuiltValueField(wireName: r'product_code')
  String? get productCode;

  @BuiltValueField(wireName: r'product_name')
  String get productName;

  @BuiltValueField(wireName: r'unit_of_measurement')
  String? get unitOfMeasurement;

  @BuiltValueField(wireName: r'unit_of_measurement_name')
  String? get unitOfMeasurementName;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'discount')
  String get discount;

  @BuiltValueField(wireName: r'tax_rate')
  String get taxRate;

  @BuiltValueField(wireName: r'tax_included')
  bool get taxIncluded;

  @BuiltValueField(wireName: r'comment')
  String? get comment;

  FiscalDocumentLine._();

  factory FiscalDocumentLine([void updates(FiscalDocumentLineBuilder b)]) =
      _$FiscalDocumentLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FiscalDocumentLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FiscalDocumentLine> get serializer =>
      _$FiscalDocumentLineSerializer();
}

class _$FiscalDocumentLineSerializer
    implements PrimitiveSerializer<FiscalDocumentLine> {
  @override
  final Iterable<Type> types = const [FiscalDocumentLine, _$FiscalDocumentLine];

  @override
  final String wireName = r'FiscalDocumentLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FiscalDocumentLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fiscal_document_detail_id';
    yield serializers.serialize(
      object.fiscalDocumentDetailId,
      specifiedType: const FullType(int),
    );
    yield r'product_service';
    yield object.productService == null
        ? null
        : serializers.serialize(
            object.productService,
            specifiedType: const FullType.nullable(String),
          );
    yield r'product_code';
    yield object.productCode == null
        ? null
        : serializers.serialize(
            object.productCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'product_name';
    yield serializers.serialize(
      object.productName,
      specifiedType: const FullType(String),
    );
    yield r'unit_of_measurement';
    yield object.unitOfMeasurement == null
        ? null
        : serializers.serialize(
            object.unitOfMeasurement,
            specifiedType: const FullType.nullable(String),
          );
    yield r'unit_of_measurement_name';
    yield object.unitOfMeasurementName == null
        ? null
        : serializers.serialize(
            object.unitOfMeasurementName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'discount';
    yield serializers.serialize(
      object.discount,
      specifiedType: const FullType(String),
    );
    yield r'tax_rate';
    yield serializers.serialize(
      object.taxRate,
      specifiedType: const FullType(String),
    );
    yield r'tax_included';
    yield serializers.serialize(
      object.taxIncluded,
      specifiedType: const FullType(bool),
    );
    yield r'comment';
    yield object.comment == null
        ? null
        : serializers.serialize(
            object.comment,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    FiscalDocumentLine object, {
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
    required FiscalDocumentLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fiscal_document_detail_id':
          final valueDes =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int;
          result.fiscalDocumentDetailId = valueDes;
          break;
        case r'product_service':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productService = valueDes;
          break;
        case r'product_code':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.productCode = valueDes;
          break;
        case r'product_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.productName = valueDes;
          break;
        case r'unit_of_measurement':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.unitOfMeasurement = valueDes;
          break;
        case r'unit_of_measurement_name':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType.nullable(String),
                  )
                  as String?;
          if (valueDes == null) continue;
          result.unitOfMeasurementName = valueDes;
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
        case r'price':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.price = valueDes;
          break;
        case r'discount':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.discount = valueDes;
          break;
        case r'tax_rate':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )
                  as String;
          result.taxRate = valueDes;
          break;
        case r'tax_included':
          final valueDes =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )
                  as bool;
          result.taxIncluded = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FiscalDocumentLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FiscalDocumentLineBuilder();
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
