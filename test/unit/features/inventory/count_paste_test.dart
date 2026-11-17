import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/features/inventory/domain/count_paste.dart';

void main() {
  List<String> rowsOf(CountPaste p) =>
      p.rows.map((r) => '${r.row}|${r.code}|${r.quantity}').toList();
  List<String> problemsOf(CountPaste p) =>
      p.problems.map((r) => '${r.row}|${r.kind.name}').toList();

  test('tab, semicolon and comma separators', () {
    final p = parseCountPaste('A-1\t3\nA-2;4\nA-3,5');
    expect(rowsOf(p), ['1|A-1|3', '2|A-2|4', '3|A-3|5']);
    expect(p.problems, isEmpty);
    expect(p.readCount, 3);
    expect(p.canSend, isTrue);
  });

  test('decimal comma with tab or semicolon, and dot as point', () {
    final p = parseCountPaste('A\t4,5\nB;2,25\nC,1.5\nD\t7.125');
    expect(rowsOf(p), ['1|A|4.5', '2|B|2.25', '3|C|1.5', '4|D|7.125']);
    expect(p.problems, isEmpty);
  });

  test('comma separator with decimal comma is fieldCount, not guessed', () {
    final p = parseCountPaste('A-100,4,5');
    expect(p.rows, isEmpty);
    expect(problemsOf(p), ['1|fieldCount']);
    expect(p.problems.single.raw, 'A-100,4,5');
    expect(p.canSend, isFalse);
  });

  test('a row without separator is fieldCount', () {
    expect(problemsOf(parseCountPaste('A-100')), ['1|fieldCount']);
  });

  test('blank rows skipped but counted in row numbers', () {
    final p = parseCountPaste('A,1\n\n  \nB,2\n');
    expect(rowsOf(p), ['1|A|1', '4|B|2']);
    expect(p.readCount, 2);
  });

  test('missing code', () {
    final p = parseCountPaste('\t5\n ;5');
    expect(problemsOf(p), ['1|missingCode', '2|missingCode']);
  });

  test('non-numeric quantity including a header row', () {
    final p = parseCountPaste('Código\tCantidad\nA,x\nB,');
    expect(problemsOf(p), ['1|notANumber', '2|notANumber', '3|notANumber']);
    expect(p.canSend, isFalse);
  });

  test('negative quantity', () {
    expect(problemsOf(parseCountPaste('A,-1')), ['1|negative']);
    expect(problemsOf(parseCountPaste('A;-0,5')), ['1|negative']);
  });

  test('more than 4 decimals', () {
    expect(problemsOf(parseCountPaste('A,1.23456')), ['1|tooManyDecimals']);
    expect(rowsOf(parseCountPaste('A,1.2345')), ['1|A|1.2345']);
  });

  test('repeated code is case-insensitive, reported on every repeat', () {
    final p = parseCountPaste('A-1,1\na-1,2\nB,3\nA-1,4');
    expect(rowsOf(p), ['1|A-1|1', '3|B|3']);
    expect(problemsOf(p), ['2|repeatedCode', '4|repeatedCode']);
    expect(p.canSend, isFalse);
  });

  test('0 is a valid quantity', () {
    final p = parseCountPaste('A,0\nB\t0,0');
    expect(rowsOf(p), ['1|A|0', '2|B|0.0']);
    expect(p.canSend, isTrue);
  });

  test('Windows line breaks', () {
    final p = parseCountPaste('A\t1\r\nB\t2\r\n');
    expect(rowsOf(p), ['1|A|1', '2|B|2']);
    expect(p.readCount, 2);
  });

  test('empty paste cannot be sent', () {
    final p = parseCountPaste('');
    expect(p.readCount, 0);
    expect(p.canSend, isFalse);
  });

  test('good rows with problems: canSend false, counts kept', () {
    final p = parseCountPaste('A,1\nB,x');
    expect(p.readCount, 2);
    expect(p.rows, hasLength(1));
    expect(p.canSend, isFalse);
  });
}
