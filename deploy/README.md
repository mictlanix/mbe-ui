# Deployment configuration

Per-customer deployment configuration files, using the same
`--dart-define-from-file` mechanism as this repo's developer-local `.env`
(see `.env.template` — the "App settings" section is the one that applies
here; the test-credential section does not).

```bash
flutter build web --dart-define-from-file=deploy/<customer>.env
```

Every key is optional and defaults to something reasonable; set only what a
given deployment needs to override (endpoints, brand tokens, default
locale). Whether a customer's file is committed here or kept private is that
deployment's own call — none of these keys are secrets.

## Example: a deployment preferring local date formatting

The app's built-in default renders dates as ISO 8601 (`2026-08-17`) rather
than a locale-derived format, so that one deployment serving multiple
locales still shows one unambiguous date everywhere. A deployment that wants
the short local rendering instead (`17/8/2026`) opts out explicitly:

```bash
# deploy/acme.env
DATE_FORMAT=d/M/yyyy
DATE_TIME_FORMAT=d/M/yyyy HH:mm
```

See `.env.template`'s formatting section for the full set of keys and
worked examples of every supported pattern.
