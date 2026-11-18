/// The Kardex screen's selection and its range check (spec 071, research R4).
///
/// Plain Dart, no codegen. It keys a Riverpod family, so `==` and `hashCode`
/// are written by hand.
library;

/// The longest range the server accepts, counting both ends.
const int kardexMaxRangeDays = 366;

enum KardexSelectionState { incomplete, reversed, tooLong, ready }

class KardexSelection {
  const KardexSelection({
    this.productId,
    this.warehouseId,
    required this.from,
    required this.to,
  });

  /// The default range: today - 29 days through today (30 days inclusive).
  factory KardexSelection.initial({DateTime? today}) {
    final t = _dateOnly(today ?? DateTime.now());
    return KardexSelection(from: DateTime(t.year, t.month, t.day - 29), to: t);
  }

  /// Reads `product`, `warehouse`, `from` and `to` (`yyyy-MM-dd`). Missing or
  /// unreadable values fall back to the defaults.
  factory KardexSelection.fromUri(Uri uri, {DateTime? today}) {
    final defaults = KardexSelection.initial(today: today);
    final q = uri.queryParameters;
    // Missing, empty or non-numeric ids count as missing.
    int? id(String key) => int.tryParse(q[key] ?? '');

    return KardexSelection(
      productId: id('product'),
      warehouseId: id('warehouse'),
      from: _parseDate(q['from']) ?? defaults.from,
      to: _parseDate(q['to']) ?? defaults.to,
    );
  }

  final int? productId;
  final int? warehouseId;

  /// Date-only (midnight, local).
  final DateTime from;
  final DateTime to;

  /// Checks run in this order: incomplete, reversed, tooLong.
  KardexSelectionState get state {
    if (productId == null || warehouseId == null) {
      return KardexSelectionState.incomplete;
    }
    if (to.isBefore(from)) return KardexSelectionState.reversed;
    // UTC so a daylight-saving change cannot skew the day count.
    final days =
        DateTime.utc(
          to.year,
          to.month,
          to.day,
        ).difference(DateTime.utc(from.year, from.month, from.day)).inDays +
        1;
    if (days > kardexMaxRangeDays) return KardexSelectionState.tooLong;
    return KardexSelectionState.ready;
  }

  Uri toUri(String path) => Uri(
    path: path,
    queryParameters: {
      'product': ?productId?.toString(),
      'warehouse': ?warehouseId?.toString(),
      'from': _formatDate(from),
      'to': _formatDate(to),
    },
  );

  /// Wrap a value in a closure to set it, including to null.
  KardexSelection copyWith({
    int? Function()? productId,
    int? Function()? warehouseId,
    DateTime? from,
    DateTime? to,
  }) => KardexSelection(
    productId: productId != null ? productId() : this.productId,
    warehouseId: warehouseId != null ? warehouseId() : this.warehouseId,
    from: from ?? this.from,
    to: to ?? this.to,
  );

  @override
  bool operator ==(Object other) =>
      other is KardexSelection &&
      other.productId == productId &&
      other.warehouseId == warehouseId &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(productId, warehouseId, from, to);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
}

final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

DateTime? _parseDate(String? value) {
  if (value == null) return null;
  final m = _datePattern.firstMatch(value);
  if (m == null) return null;
  final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
  final date = DateTime(y, mo, d);
  // Reject dates that roll over, such as 2026-02-30.
  if (date.year != y || date.month != mo || date.day != d) return null;
  return date;
}
