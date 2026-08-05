//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cash_session_status.g.dart';

class CashSessionStatus extends EnumClass {
  /// A stored session's own state, used as a list facet (#142).  Deliberately not `SessionState`: `NONE` describes a cashier with no session, which no row can be, and a stored session can be closed, which `SessionState` has no member for. The three members here derive from `end` and `start` exactly as `session_state` does.
  @BuiltValueEnumConst(wireName: r'open')
  static const CashSessionStatus open = _$open;

  /// A stored session's own state, used as a list facet (#142).  Deliberately not `SessionState`: `NONE` describes a cashier with no session, which no row can be, and a stored session can be closed, which `SessionState` has no member for. The three members here derive from `end` and `start` exactly as `session_state` does.
  @BuiltValueEnumConst(wireName: r'stale')
  static const CashSessionStatus stale = _$stale;

  /// A stored session's own state, used as a list facet (#142).  Deliberately not `SessionState`: `NONE` describes a cashier with no session, which no row can be, and a stored session can be closed, which `SessionState` has no member for. The three members here derive from `end` and `start` exactly as `session_state` does.
  @BuiltValueEnumConst(wireName: r'closed')
  static const CashSessionStatus closed = _$closed;

  static Serializer<CashSessionStatus> get serializer =>
      _$cashSessionStatusSerializer;

  const CashSessionStatus._(String name) : super(name);

  static BuiltSet<CashSessionStatus> get values => _$values;
  static CashSessionStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class CashSessionStatusMixin = Object with _$CashSessionStatusMixin;
