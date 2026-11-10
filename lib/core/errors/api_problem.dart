import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/network/api_serializers.dart';

part 'api_problem.freezed.dart';

/// Typed, never-throwing reads of a problem's raw `params` (spec 058 FR-004).
///
/// mbe-api sends params as raw JSON values: ints, decimal strings at the
/// stored scale (`"18450.00"`), ISO dates, enum values, lists and maps. Each
/// accessor returns `null` for a missing key or a value of the wrong type, so
/// a localizer case that needs the param can fall back instead of failing.
abstract interface class HasParams {
  Map<String, Object?> get params;
}

extension ProblemParamAccess on HasParams {
  /// An int, or a string that parses as one.
  int? intParam(String key) {
    final value = params[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String? stringParam(String key) {
    final value = params[key];
    return value is String ? value : null;
  }

  /// A decimal as the string the formatters take, or `null` when the value is
  /// not numeric. A JSON number is rendered back to a string.
  String? decimalParam(String key) {
    final value = params[key];
    if (value is String) return num.tryParse(value) == null ? null : value;
    if (value is num) return value.toString();
    return null;
  }

  /// An ISO date or datetime as a wall-clock value (mbe-api sends naive
  /// business time; an offset, if one ever arrives, is converted to local, as
  /// `WallClockDateTimeSerializer` does).
  DateTime? dateParam(String key) {
    final value = params[key];
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  List<Object?>? listParam(String key) {
    final value = params[key];
    return value is List ? List<Object?>.from(value) : null;
  }

  /// A list whose every element is a JSON object, or `null` otherwise.
  List<Map<String, Object?>>? mapListParam(String key) {
    final list = listParam(key);
    if (list == null) return null;
    if (!list.every((element) => element is Map)) return null;
    return [for (final element in list) _stringKeyed(element! as Map)];
  }
}

/// The server's coded explanation of a refusal, read from an error body
/// (mbe-api spec 036 `Problem`; data-model.md).
///
/// [codeName] is always the string the server sent. [code] is the generated
/// `ErrorCode` for it, or `null` when this client does not know it (a server
/// newer than the app): that case must fall back, never throw (FR-002).
@freezed
abstract class ApiProblem with _$ApiProblem implements HasParams {
  const ApiProblem._();

  const factory ApiProblem({
    required String codeName,
    api.ErrorCode? code,
    @Default(<String, Object?>{}) Map<String, Object?> params,
    @Default(<ApiProblemPart>[]) List<ApiProblemPart> parts,

    /// The server's English text: a string `detail`, or `detail.message` for
    /// the four dict details that stay until mbe-api's phase 3.
    String? detail,

    /// The per-line English prose of today's dict refusals
    /// (`detail.lines` / `detail.missing`). Empty once phase 3 moves them to
    /// [parts].
    @Default(<String>[]) List<String> detailItems,
  }) = _ApiProblem;

  /// The problem in [body], or `null` when the body is not a JSON object with
  /// a string `code` (an older server, a framework 422, a non-JSON body), in
  /// which case the caller maps the error exactly as before (FR-001).
  static ApiProblem? fromBody(Object? body) {
    if (body is! Map) return null;
    final code = body['code'];
    if (code is! String) return null;

    String? detailText;
    var items = const <String>[];
    final detail = body['detail'];
    if (detail is String) {
      detailText = detail;
    } else if (detail is Map) {
      final message = detail['message'];
      if (message is String) detailText = message;
      final raw = detail['lines'] ?? detail['missing'];
      if (raw is List) items = raw.map((e) => e.toString()).toList();
    }

    final params = body['params'];
    final errors = body['errors'];
    return ApiProblem(
      codeName: code,
      code: _resolveCode(code),
      params: params is Map ? _stringKeyed(params) : const {},
      parts: errors is List
          ? errors.whereType<Map>().map(ApiProblemPart.fromJson).toList()
          : const [],
      detail: detailText,
      detailItems: items,
    );
  }
}

/// One item of `errors[]`, such as one stock line of a refusal.
@freezed
abstract class ApiProblemPart with _$ApiProblemPart implements HasParams {
  const ApiProblemPart._();

  const factory ApiProblemPart({
    @Default('') String codeName,
    api.ErrorCode? code,
    @Default(<String, Object?>{}) Map<String, Object?> params,

    /// The item's other keys, kept as sent (the inventory count batch keeps
    /// `index`, `product_code` and `reason`).
    @Default(<String, Object?>{}) Map<String, Object?> extra,
  }) = _ApiProblemPart;

  factory ApiProblemPart.fromJson(Map<dynamic, dynamic> json) {
    final code = json['code'];
    final params = json['params'];
    return ApiProblemPart(
      codeName: code is String ? code : '',
      code: code is String ? _resolveCode(code) : null,
      params: params is Map ? _stringKeyed(params) : const {},
      extra: {
        for (final entry in json.entries)
          if (entry.key != 'code' && entry.key != 'params')
            entry.key.toString(): entry.value,
      },
    );
  }
}

/// The generated enum for a wire name, or `null` for a name this client does
/// not know: `ErrorCode.valueOf` throws on those, and a code newer than the
/// app must fall back rather than fail (research R2).
api.ErrorCode? _resolveCode(String name) {
  try {
    return appSerializers.deserializeWith(api.ErrorCode.serializer, name);
  } on Object {
    return null;
  }
}

Map<String, Object?> _stringKeyed(Map<dynamic, dynamic> map) => {
  for (final entry in map.entries) entry.key.toString(): entry.value,
};
