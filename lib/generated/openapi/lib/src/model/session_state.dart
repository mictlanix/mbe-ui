//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_state.g.dart';

class SessionState extends EnumClass {
  /// Three states, because a client routes differently for each (FR-053).  `STALE` is an open session started before today: selling continues to be refused until it is closed, which is a different remedy from having no session at all.
  @BuiltValueEnumConst(wireName: r'none')
  static const SessionState none = _$none;

  /// Three states, because a client routes differently for each (FR-053).  `STALE` is an open session started before today: selling continues to be refused until it is closed, which is a different remedy from having no session at all.
  @BuiltValueEnumConst(wireName: r'open')
  static const SessionState open = _$open;

  /// Three states, because a client routes differently for each (FR-053).  `STALE` is an open session started before today: selling continues to be refused until it is closed, which is a different remedy from having no session at all.
  @BuiltValueEnumConst(wireName: r'stale')
  static const SessionState stale = _$stale;

  static Serializer<SessionState> get serializer => _$sessionStateSerializer;

  const SessionState._(String name) : super(name);

  static BuiltSet<SessionState> get values => _$values;
  static SessionState valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class SessionStateMixin = Object with _$SessionStateMixin;
