import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';

void main() {
  // DateFormat requires locale symbol data initialized before use — normally
  // done once at app startup (main.dart); a plain unit test has no app
  // startup to piggyback on (money_formatters_test.dart's own convention).
  setUpAll(() async {
    await initializeDateFormatting();
  });

  DisplayFormatters display({
    Locale locale = const Locale('es', 'MX'),
    FormattingSettings settings = const FormattingSettings(),
  }) => DisplayFormatters(locale: locale, settings: settings);

  group('display.currency (contracts/formatting-surface.md)', () {
    test('formats a decimal amount at the default symbol/digits', () {
      expect(display().currency('120.5'), r'$120.50');
    });

    test('a high-precision value is not truncated to the wrong magnitude', () {
      final formatted = display().currency('1234567.891234');
      expect(formatted, r'$1,234,567.89');
      expect(formatted, isNot(contains('e')));
    });

    test('a configured symbol/digit count is honored', () {
      final custom = display(
        settings: const FormattingSettings(
          currencySymbol: 'S/',
          currencyDecimalDigits: 3,
        ),
      );
      expect(custom.currency('120.5'), 'S/120.500');
    });

    test('null renders the empty placeholder', () {
      expect(display().currency(null), emptyValuePlaceholder);
    });

    test('unparseable input renders the empty placeholder', () {
      expect(display().currency('not-a-number'), emptyValuePlaceholder);
    });
  });

  group('display.percent (contracts/formatting-surface.md)', () {
    test('renders two decimals and a % suffix at the default', () {
      expect(display().percent('0.16'), '16.00 %');
    });

    test(
      'deliberately not NumberFormat.percentPattern\'s bare form (research.md R4)',
      () {
        // percentPattern would render '16%' with no configurable decimals —
        // one of the two disagreeing behaviors this surface unifies away.
        expect(display().percent('0.16'), isNot('16%'));
      },
    );

    test('a configured decimal count is honored', () {
      final custom = display(
        settings: const FormattingSettings(percentDecimalDigits: 0),
      );
      expect(custom.percent('0.16'), '16 %');
    });

    test('null renders the empty placeholder', () {
      expect(display().percent(null), emptyValuePlaceholder);
    });

    test('unparseable input renders the empty placeholder', () {
      expect(display().percent('nope'), emptyValuePlaceholder);
    });
  });

  group('display.date (spec 028 FR-011 — ISO default)', () {
    final probe = DateTime(2026, 8, 17, 14, 30);

    test('renders ISO yyyy-MM-dd at the default', () {
      expect(display().date(probe), '2026-08-17');
    });

    test('a deployment can opt out to a local pattern', () {
      final local = display(
        settings: const FormattingSettings(datePattern: 'd/M/yyyy'),
      );
      expect(local.date(probe), '17/8/2026');
    });

    test('null renders the empty placeholder', () {
      expect(display().date(null), emptyValuePlaceholder);
    });
  });

  group('display.dateTime (spec 028 FR-011 — ISO default)', () {
    final probe = DateTime(2026, 8, 17, 14, 30);

    test('renders ISO yyyy-MM-dd HH:mm at the default', () {
      expect(display().dateTime(probe), '2026-08-17 14:30');
    });

    test('a deployment can opt out to a local pattern', () {
      final local = display(
        settings: const FormattingSettings(dateTimePattern: 'd/M/yyyy HH:mm'),
      );
      expect(local.dateTime(probe), '17/8/2026 14:30');
    });

    test('null renders the empty placeholder', () {
      expect(display().dateTime(null), emptyValuePlaceholder);
    });
  });

  group('display.quantity', () {
    test('drops trailing zeros at the default (digits=0)', () {
      expect(display().quantity('3.0000'), '3');
      expect(display().quantity('2.5000'), '2.5');
    });

    test('null renders the empty placeholder', () {
      expect(display().quantity(null), emptyValuePlaceholder);
    });

    test('unparseable input renders the empty placeholder', () {
      expect(display().quantity('nope'), emptyValuePlaceholder);
    });
  });
}
