# Contract: release credentials (environment)

Every secret comes from the environment, or from a file whose path comes from
the environment (FR-019). None is ever committed; `.gitignore` covers the
conventional local names (`*.jks`, `*.keystore`, `*.p8`, `AuthKey_*.p8`,
`key.properties`) as a backstop (FR-018).

| Variable | Needed for | Content | Preflight check |
|---|---|---|---|
| `MBE_ASC_KEY_ID` | iOS publish | App Store Connect API key id | non-empty |
| `MBE_ASC_ISSUER_ID` | iOS publish | API key issuer id (UUID) | UUID shape |
| `MBE_ASC_KEY_PATH` | iOS publish | path to the `.p8` private key | file readable; outside the repo |
| `MBE_ANDROID_KEYSTORE_PATH` | Android build | path to the upload keystore (PKCS12) | file readable; outside the repo |
| `MBE_ANDROID_KEYSTORE_PASSWORD` | Android build | keystore password | non-empty |
| `MBE_ANDROID_KEY_ALIAS` | Android build | key alias (convention `upload`) | non-empty |
| `MBE_ANDROID_KEY_PASSWORD` | Android build | key password | non-empty |

Notes:

- The App Store Connect key needs the **Admin** role (cloud-managed
  distribution signing, research R3).
- The Android variables are read by Gradle, not only by the script, so a
  manual `flutter build appbundle` without them fails naming them (FR-023)
  instead of signing with the debug key.
- iOS builds in `--build-only` need no credentials (the archive is unsigned).
- For local convenience an operator may keep these in a file outside the repo
  and `source` it before running; the scripts do not read any such file
  implicitly.
