import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/l10n/app_localizations.dart';

/// Display-label mapping over the **generated** `FiscalCertificationProvider`
/// enum (spec 015 research §7) — not a new domain enum, following the exact
/// `EntityStatus`/`Gender`/`FacilityType` label-mapping precedent
/// (`lib/core/widgets/entity_status_controls.dart`'s `entityStatusLabel`).
///
/// mbe-api's `FiscalCertificationProvider` (`mbe-api/docs/constants.md`
/// §FiscalCertificationProvider) names each of the five generated
/// `number0`-`number4` ordinals: `0 None`, `1 Diverza`, `2 FiscoClic`,
/// `3 Servisim`, `4 ProFact` — PAC (Proveedor Autorizado de Certificación)
/// integrations for CFDI stamping.
String fiscalCertificationProviderLabel(
  AppLocalizations l10n,
  FiscalCertificationProvider provider,
) {
  if (provider == FiscalCertificationProvider.number0) {
    return l10n.fiscalCertificationProviderNone;
  }
  if (provider == FiscalCertificationProvider.number1) {
    return l10n.fiscalCertificationProviderDiverza;
  }
  if (provider == FiscalCertificationProvider.number2) {
    return l10n.fiscalCertificationProviderFiscoClic;
  }
  if (provider == FiscalCertificationProvider.number3) {
    return l10n.fiscalCertificationProviderServisim;
  }
  if (provider == FiscalCertificationProvider.number4) {
    return l10n.fiscalCertificationProviderProFact;
  }
  // Unmapped value (a future server-side addition): fall back to the raw
  // wire name rather than crash, same posture as `EntityStatus.fromApi`.
  return provider.name;
}

/// The full option list for a provider dropdown, in ordinal order.
const fiscalCertificationProviderValues = [
  FiscalCertificationProvider.number0,
  FiscalCertificationProvider.number1,
  FiscalCertificationProvider.number2,
  FiscalCertificationProvider.number3,
  FiscalCertificationProvider.number4,
];
