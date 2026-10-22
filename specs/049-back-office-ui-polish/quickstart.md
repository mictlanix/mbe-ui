# Quickstart: Back-Office UI Polish

**Feature**: [spec.md](./spec.md) | **Contracts**: [contracts/ui-contracts.md](./contracts/ui-contracts.md)

## Prerequisites

- mbe-api running locally (default `http://127.0.0.1:8000`), with the dev tenant seeded.
- `.env` copied from `.env.template`.
- An administrator account from `.env`.

## Automated checks

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed: FacilityFormState
flutter gen-l10n
flutter analyze
flutter test                                               # unit + widget (C1–C7)
flutter test --update-goldens test/golden test/screenshots # then review the diffs by eye
```

`test/unit/core/formatting_guard_test.dart` must stay green, because no new display formatting is introduced.

## Manual validation

### 1. Multi-currency option off (default)

Run `flutter run -d chrome --dart-define-from-file=.env`, with `MULTI_CURRENCY_ENABLED` absent or `false`.

1. The navigation menu has no "Tipos de Cambio" entry, even for the administrator.
2. Typing `/#/exchange-rates` in the address bar lands on Home.
3. Open a back-office order and expand "Más detalles": no Moneda and no Tipo de cambio.
4. Open a quote: the header has no Moneda.
5. Create a product: there is no currency picker, and the saved product has MXN.
6. At the POS payment step, the amount field shows no "MXN" prefix.

### 2. Multi-currency option on

Set `MULTI_CURRENCY_ENABLED=true` in `.env` and restart. A hot reload doesn't re-read build defines. Each item in §1 then appears exactly as on `main`.

### 3. Facility logo

1. Go to Instalaciones and edit a facility. The logo area shows a placeholder and "Subir logotipo".
2. Pick a PNG under 2 MB. It is previewed. Click Guardar, then reopen the facility: the logo is shown.
3. Pick a `.gif` or a file over 2 MB. An inline error appears and nothing is staged.
4. Create a new facility with a logo picked. After saving, the new facility shows the logo.
5. Save the facility again without picking anything. The logo is unchanged, so its stored filename wasn't overwritten (R4).

### 4. Layout polish

Check each at about 1440px and at about 800px wide, and once at the largest text size in user settings.

- **Search box.** Empleados, Precios and any other list screen: a stadium-shaped box with one magnifier, which still searches on click or Enter.
- **Quote and order headers.** Cotizaciones → a confirmed quote: the facts are on one line, and "Más detalles" is at the right edge. Pedidos → an order: the same.
- **Certificates.** Razones Sociales → edit an issuer with one certificate: the table aligns with the fields, and the only scrollbar is the page's.
- **Pricing.** Precios: the search box, chips and table share their left edge.
- **Employees.** Empleados → Nuevo: Vendedor sits beside Número de empleado, and Estado is full width.
