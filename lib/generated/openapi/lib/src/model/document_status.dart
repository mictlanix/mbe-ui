//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'document_status.g.dart';

/// One lifecycle state, derived from the completed/cancelled/paid flags.  Clients get a single state rather than three raw booleans they would have to combine themselves — and combine identically everywhere, or disagree about what an order is.
class DocumentStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const DocumentStatus draft = _$draft;
  @BuiltValueEnumConst(wireName: r'completed')
  static const DocumentStatus completed = _$completed;
  @BuiltValueEnumConst(wireName: r'paid')
  static const DocumentStatus paid = _$paid;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const DocumentStatus cancelled = _$cancelled;

  static Serializer<DocumentStatus> get serializer =>
      _$documentStatusSerializer;

  const DocumentStatus._(String name) : super(name);

  static BuiltSet<DocumentStatus> get values => _$values;
  static DocumentStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DocumentStatusMixin = Object with _$DocumentStatusMixin;
