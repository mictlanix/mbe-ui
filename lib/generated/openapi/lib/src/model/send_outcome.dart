//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'send_outcome.g.dart';

class SendOutcome extends EnumClass {
  @BuiltValueEnumConst(wireName: r'running')
  static const SendOutcome running = _$running;
  @BuiltValueEnumConst(wireName: r'sent')
  static const SendOutcome sent = _$sent;
  @BuiltValueEnumConst(wireName: r'failed')
  static const SendOutcome failed = _$failed;
  @BuiltValueEnumConst(wireName: r'skipped')
  static const SendOutcome skipped = _$skipped;

  static Serializer<SendOutcome> get serializer => _$sendOutcomeSerializer;

  const SendOutcome._(String name) : super(name);

  static BuiltSet<SendOutcome> get values => _$values;
  static SendOutcome valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class SendOutcomeMixin = Object with _$SendOutcomeMixin;
