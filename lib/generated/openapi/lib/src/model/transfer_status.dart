//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transfer_status.g.dart';

class TransferStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const TransferStatus draft = _$draft;
  @BuiltValueEnumConst(wireName: r'in_transit')
  static const TransferStatus inTransit = _$inTransit;
  @BuiltValueEnumConst(wireName: r'received')
  static const TransferStatus received = _$received;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const TransferStatus cancelled = _$cancelled;

  static Serializer<TransferStatus> get serializer =>
      _$transferStatusSerializer;

  const TransferStatus._(String name) : super(name);

  static BuiltSet<TransferStatus> get values => _$values;
  static TransferStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class TransferStatusMixin = Object with _$TransferStatusMixin;
