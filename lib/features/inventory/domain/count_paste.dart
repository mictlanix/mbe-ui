/// Parser for a pasted "code, quantity" list (spec 070, research R7).
///
/// Pure and synchronous: it reads the whole paste, so a paste never fails
/// halfway because of formatting.
enum CountPasteProblemKind {
  fieldCount,
  missingCode,
  notANumber,
  negative,
  tooManyDecimals,
  repeatedCode,
}

class CountPasteRow {
  const CountPasteRow({
    required this.row,
    required this.code,
    required this.quantity,
  });

  /// 1-based row number in the pasted text (blank rows count).
  final int row;
  final String code;

  /// Decimal string with '.' as the point, e.g. "4.5".
  final String quantity;
}

class CountPasteProblem {
  const CountPasteProblem({
    required this.row,
    required this.raw,
    required this.kind,
  });

  final int row;
  final String raw;
  final CountPasteProblemKind kind;
}

class CountPaste {
  const CountPaste({
    required this.rows,
    required this.problems,
    required this.readCount,
  });

  final List<CountPasteRow> rows;
  final List<CountPasteProblem> problems;

  /// Non-blank rows read.
  final int readCount;

  bool get canSend => rows.isNotEmpty && problems.isEmpty;
}

// simplified: thousands separators are not accepted, add a locale-aware reader if clerks paste "1,234.5".
final _quantity = RegExp(r'^(-?)(\d+)(?:[.,](\d+))?$');

CountPaste parseCountPaste(String text) {
  final rows = <CountPasteRow>[];
  final problems = <CountPasteProblem>[];
  final seen = <String>{};
  var readCount = 0;

  final lines = text.split(RegExp(r'\r\n|\n|\r'));
  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i];
    if (raw.trim().isEmpty) continue;
    readCount++;
    final row = i + 1;

    CountPasteProblemKind? problem;
    String code = '';
    String quantity = '';

    final separator = raw.contains('\t')
        ? '\t'
        : raw.contains(';')
        ? ';'
        : ',';
    final fields = raw.split(separator).map((f) => f.trim()).toList();
    if (fields.length != 2) {
      problem = CountPasteProblemKind.fieldCount;
    } else {
      code = fields[0];
      final match = _quantity.firstMatch(fields[1]);
      if (code.isEmpty) {
        problem = CountPasteProblemKind.missingCode;
      } else if (match == null) {
        problem = CountPasteProblemKind.notANumber;
      } else if (match[1]!.isNotEmpty) {
        problem = CountPasteProblemKind.negative;
      } else if ((match[3] ?? '').length > 4) {
        problem = CountPasteProblemKind.tooManyDecimals;
      } else {
        quantity = match[3] == null ? match[2]! : '${match[2]}.${match[3]}';
      }
      // A repeat is flagged on every occurrence after the first, whatever
      // else is wrong with the row.
      if (code.isNotEmpty && !seen.add(code.toLowerCase())) {
        problem ??= CountPasteProblemKind.repeatedCode;
      }
    }

    if (problem != null) {
      problems.add(CountPasteProblem(row: row, raw: raw, kind: problem));
    } else {
      rows.add(CountPasteRow(row: row, code: code, quantity: quantity));
    }
  }

  return CountPaste(rows: rows, problems: problems, readCount: readCount);
}
