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
