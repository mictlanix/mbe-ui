# Contract: Release brand `xbe.cm` and deployment `cm`

## Files

`deploy/brands/xbe.cm/brand.properties`:

```properties
BUNDLE_ID=com.mictlanix.xbe.cm
APPLICATION_ID=com.mictlanix.xbe.cm
DISPLAY_NAME=Casa Maestra
IOS_TEAM_ID=4ZJ2FWD2BR
WEB_TITLE=Casa Maestra
WEB_SHORT_NAME=Casa Maestra
WEB_THEME_COLOR=#FFFFFF
```

`deploy/cm.release`: `BRAND=xbe.cm`.

`deploy/cm.env`: `API_BASE_URL=https://api.cm.invalid`, until the production URL is known.

## Artwork sources (`deploy/brands/xbe.cm/src/`)

All three are made from `casa-maestra-mark.png` (852×562) with `sips`, never redrawn:

| File | Content |
| --- | --- |
| `app_icon_1024.png` | 1024×1024, opaque white, with the mark scaled to 720px wide and centered |
| `android_adaptive_foreground_1024.png` | 1024×1024, transparent, with the mark scaled to 600px wide and centered, inside the 66% safe zone |
| `splash_1024.png` | 1024×1024, transparent, with the mark scaled to 512px wide and centered |

`tool/release/brand_artwork.sh xbe.cm` generates `overlay/`, which is committed.

## Script changes

1. `tool/release/{web,ios,android}.sh` add `--dart-define=BRAND_ID=$BRAND` beside `--dart-define-from-file="$ENV_FILE"`.
2. The `load_deployment` preflight refuses:
   - a deployment `.env` that sets `BRAND_ID`;
   - an `API_BASE_URL` whose host ends in `.invalid`, with a message saying to fill in the real URL.
3. `tool/release/overlay-manifest.txt` adds the generated Android adaptive-icon foreground, `values/colors.xml`, pre-Android-12 splash backgrounds, `launch_background.xml` and `values-night*` styles. The exact globs come from a dry run of the generator.
4. `rewrite_web_brand` also sets `manifest.json` `background_color` and the `index.html` splash body color to `WEB_THEME_COLOR`.

Brand names are only ever used quoted in paths, so the dot in `xbe.cm` is safe. Deployment names keep `^[a-z0-9-]+$`.

## Invariants

- The `demo` deployment (brand `mbe`) builds the same output as before, except that it now passes `BRAND_ID=mbe`, which resolves to XBE (FR-024).
- `shellcheck tool/release.sh tool/release/*.sh` stays clean.
- After a run, `git status` is clean (the existing cleanup trap).
