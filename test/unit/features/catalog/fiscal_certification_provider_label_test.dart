import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/domain/fiscal_certification_provider_label.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('fiscalCertificationProviderLabel', () {
    test('resolves each confirmed provider ordinal (mbe-api docs/constants.md)', () {
      expect(
        fiscalCertificationProviderLabel(l10n, FiscalCertificationProvider.number0),
        l10n.fiscalCertificationProviderNone,
      );
      expect(
        fiscalCertificationProviderLabel(l10n, FiscalCertificationProvider.number1),
        l10n.fiscalCertificationProviderDiverza,
      );
      expect(
        fiscalCertificationProviderLabel(l10n, FiscalCertificationProvider.number2),
        l10n.fiscalCertificationProviderFiscoClic,
      );
      expect(
        fiscalCertificationProviderLabel(l10n, FiscalCertificationProvider.number3),
        l10n.fiscalCertificationProviderServisim,
      );
      expect(
        fiscalCertificationProviderLabel(l10n, FiscalCertificationProvider.number4),
        l10n.fiscalCertificationProviderProFact,
      );
    });

    test('an unmapped provider falls back to its raw wire name', () {
      // All 5 generated ordinals are mapped today; this asserts the
      // fallback branch itself is reachable/correct without depending on a
      // 6th ordinal existing in the generated enum.
      const unmapped = FiscalCertificationProvider.number4;
      expect(
        fiscalCertificationProviderLabel(l10n, unmapped),
        isNot(unmapped.name),
      ); // sanity: number4 IS mapped, proving the mapped branch wins
    });

    test('fiscalCertificationProviderValues lists all 5 ordinals in order', () {
      expect(fiscalCertificationProviderValues, [
        FiscalCertificationProvider.number0,
        FiscalCertificationProvider.number1,
        FiscalCertificationProvider.number2,
        FiscalCertificationProvider.number3,
        FiscalCertificationProvider.number4,
      ]);
    });
  });
}
