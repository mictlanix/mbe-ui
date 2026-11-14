//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dimension_key.g.dart';

class DimensionKey extends EnumClass {
  @BuiltValueEnumConst(wireName: r'date')
  static const DimensionKey date = _$date;
  @BuiltValueEnumConst(wireName: r'weekday')
  static const DimensionKey weekday = _$weekday;
  @BuiltValueEnumConst(wireName: r'hour')
  static const DimensionKey hour = _$hour;
  @BuiltValueEnumConst(wireName: r'facility')
  static const DimensionKey facility = _$facility;
  @BuiltValueEnumConst(wireName: r'point_of_sale')
  static const DimensionKey pointOfSale = _$pointOfSale;
  @BuiltValueEnumConst(wireName: r'salesperson')
  static const DimensionKey salesperson = _$salesperson;
  @BuiltValueEnumConst(wireName: r'cash_session')
  static const DimensionKey cashSession = _$cashSession;
  @BuiltValueEnumConst(wireName: r'customer')
  static const DimensionKey customer = _$customer;
  @BuiltValueEnumConst(wireName: r'customer_type')
  static const DimensionKey customerType = _$customerType;
  @BuiltValueEnumConst(wireName: r'product')
  static const DimensionKey product = _$product;
  @BuiltValueEnumConst(wireName: r'brand')
  static const DimensionKey brand = _$brand;
  @BuiltValueEnumConst(wireName: r'model')
  static const DimensionKey model = _$model;
  @BuiltValueEnumConst(wireName: r'label')
  static const DimensionKey label = _$label;
  @BuiltValueEnumConst(wireName: r'payment_terms')
  static const DimensionKey paymentTerms = _$paymentTerms;
  @BuiltValueEnumConst(wireName: r'payment_method')
  static const DimensionKey paymentMethod = _$paymentMethod;
  @BuiltValueEnumConst(wireName: r'warehouse')
  static const DimensionKey warehouse = _$warehouse;
  @BuiltValueEnumConst(wireName: r'movement_type')
  static const DimensionKey movementType = _$movementType;
  @BuiltValueEnumConst(wireName: r'supplier')
  static const DimensionKey supplier = _$supplier;
  @BuiltValueEnumConst(wireName: r'aging_bucket')
  static const DimensionKey agingBucket = _$agingBucket;
  @BuiltValueEnumConst(wireName: r'due_bucket')
  static const DimensionKey dueBucket = _$dueBucket;
  @BuiltValueEnumConst(wireName: r'sales_agent')
  static const DimensionKey salesAgent = _$salesAgent;
  @BuiltValueEnumConst(wireName: r'commission_participation')
  static const DimensionKey commissionParticipation = _$commissionParticipation;
  @BuiltValueEnumConst(wireName: r'commission_status')
  static const DimensionKey commissionStatus = _$commissionStatus;
  @BuiltValueEnumConst(wireName: r'issuer')
  static const DimensionKey issuer = _$issuer;
  @BuiltValueEnumConst(wireName: r'document_status')
  static const DimensionKey documentStatus = _$documentStatus;
  @BuiltValueEnumConst(wireName: r'document_type')
  static const DimensionKey documentType = _$documentType;

  static Serializer<DimensionKey> get serializer => _$dimensionKeySerializer;

  const DimensionKey._(String name) : super(name);

  static BuiltSet<DimensionKey> get values => _$values;
  static DimensionKey valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DimensionKeyMixin = Object with _$DimensionKeyMixin;
