# Contract: `tool/release.sh` command line

```text
tool/release.sh <platform> <deployment> [options]
tool/release.sh --list
tool/release.sh --status

<platform>    web | ios | android | all
<deployment>  name of deploy/<deployment>.env + deploy/<deployment>.release
```

| Option | Effect |
|---|---|
| `--build-only` | Build (and sign) the artifact; never upload, publish or tag (FR-003). Android is always build-only (spec 3a); the flag is accepted for symmetry. |
| `--allow-dirty` | Proceed with uncommitted changes; the summary and any tag message state it (FR-006). |
| `--push-tag` | After tagging, push the tag to `origin`. |
| `--list` | Print valid deployments and their brands. |
| `--status` | Print which brand the working tree is configured for (generated files present?) and whether an overlay is staged. |

## Behaviour

1. **Preflight** (no build work; target < 30 s, SC-003). Collects *all*
   problems, then fails once listing them:
   - unknown platform/deployment (lists valid ones);
   - missing `.env`/`.release`/`.app.yaml`, unknown `BRAND`, invalid
     `brand.properties` field, missing overlay path from the manifest (non-default brand);
   - `API_BASE_URL` absent or not `https://`;
   - working tree dirty without `--allow-dirty`;
   - required tools missing for the platform;
   - credentials missing or credential files unreadable
     ([environment.md](environment.md)) — skipped for credentials only
     needed by publish when `--build-only`.
2. **Stage brand**: write generated build files; copy overlay if any; install
   an EXIT/INT/TERM trap that restores the tree.
3. **Build** with `--release --build-name <v> --build-number <n>
   --dart-define-from-file=deploy/<deployment>.env`.
4. **Publish** (unless `--build-only`): web → deploy repo push + doctl; iOS →
   export + upload.
5. **Tag** (publish only), optionally push.
6. **Summary** line(s): `deployment platform version build commit destination`.

`all` runs web, ios, android in sequence, continuing past a failure, then
prints one summary row per platform and exits non-zero if any failed (FR-002).

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success |
| 1 | build or publish failed |
| 2 | usage error (bad arguments) |
| 3 | preflight failed (nothing was built) |

## Output rules

- Never prints a secret value (FR-019); credential problems name the
  *variable*, not its value. Child tool output is passed through, with `set -x`
  never enabled.
- Never reads stdin; never waits for input (FR-005). Child tools run with
  stdin from `/dev/null`.
