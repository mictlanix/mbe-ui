//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'request_status.g.dart';

class RequestStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'draft')
  static const RequestStatus draft = _$draft;
  @BuiltValueEnumConst(wireName: r'submitted')
  static const RequestStatus submitted = _$submitted;
  @BuiltValueEnumConst(wireName: r'approved')
  static const RequestStatus approved = _$approved;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const RequestStatus cancelled = _$cancelled;

  static Serializer<RequestStatus> get serializer => _$requestStatusSerializer;

  const RequestStatus._(String name) : super(name);

  static BuiltSet<RequestStatus> get values => _$values;
  static RequestStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RequestStatusMixin = Object with _$RequestStatusMixin;
