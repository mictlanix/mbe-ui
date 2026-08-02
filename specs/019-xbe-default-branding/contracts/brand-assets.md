# Contract: Brand Asset Inventory

**Feature**: 019-xbe-default-branding

Every asset traces to the approved design project
`XBE Look and Feel proposal`. No brand asset is hand-authored.

---

## Repository layout

```text
assets/
├── brand/                          # NEW — brand identity assets
│   ├── xbe-lockup.svg              # source of truth, full color
│   ├── xbe-lockup-white.svg        # single-ink white
│   ├── xbe-lockup-gray.svg         # grayscale / light background
│   ├── xbe-mark.svg                # isologo, full color
│   ├── xbe-mark-white.svg          # isologo, white (watermark)
│   ├── login_lockup.png            # 1x  ─┐ resolution-aware
│   ├── 2.0x/login_lockup.png       #      │ variants consumed
│   ├── 3.0x/login_lockup.png       #     ─┘ by Image.asset
│   ├── nav_lockup.png              # 1x  ─┐
│   ├── 2.0x/nav_lockup.png         #      │
│   └── 3.0x/nav_lockup.png         #     ─┘
├── branding/                       # EXISTING — per-deployment welcome
│   └── default_welcome.png
├── fonts/                          # NEW
│   ├── Archivo-Variable.ttf  + OFL.txt
│   └── RobotoMono-Variable.ttf + OFL.txt
└── icons_src/                      # NEW — generator inputs only, not shipped
    ├── app_icon_dark_1024.png
    ├── app_icon_light_1024.png
    ├── android_adaptive_foreground_1024.png
    └── splash_lockup_1024.png
```

`assets/icons_src/` is **not** declared in `pubspec.yaml`'s `assets:` — it
feeds `flutter_launcher_icons`/`flutter_native_splash` at build time only and
must not ship in the app bundle.

## Web assets (replaced in place)

| Path | Source | Note |
|---|---|---|
| `web/favicon.png` | `favicon_32.png` | replaces Flutter default |
| `web/icons/Icon-192.png` | `favicon_192.png` | |
| `web/icons/Icon-512.png` | `favicon_512.png` | |
| `web/icons/Icon-maskable-192.png` | `favicon_192.png` | maskable variant |
| `web/icons/Icon-maskable-512.png` | `favicon_512.png` | maskable variant |

`web/manifest.json`: `background_color` and `theme_color` change from
`#0175C2` (Flutter default blue) to `#14120F`.

## Variant selection rule

The correct logo variant is a function of the **background it sits on** —
this is a correctness rule, not a preference:

| Background | Variant |
|---|---|
| Dark surfaces (`#0F0D0B`–`#221E19`) | full color (`xbe-lockup` / `xbe-mark`) |
| White / light surfaces | grayscale (`xbe-lockup-gray`) |
| A brand color fill (gold/orange/red) | white single-ink (`*-white`) |
| Decorative watermark, dark surfaces | white mark at 7% opacity |
| Decorative watermark, light surfaces | full-color mark at 6% opacity |

## Generator configuration

`flutter_launcher_icons`:

- `image_path`: `assets/icons_src/app_icon_dark_1024.png`
- `adaptive_icon_foreground`: `assets/icons_src/android_adaptive_foreground_1024.png`
- `adaptive_icon_background`: `#14120F`
- targets: `android`, `ios`, `macos`, `windows`, `web`
- **Linux is unsupported by the tool** — keeps its current icon (accepted)

`flutter_native_splash`:

- `image`: `assets/icons_src/splash_lockup_1024.png`
- `color`: `#14120F`
- `android_12` block set to the same image/color
- targets: `android`, `ios`, `web`

Generated native outputs are **committed** so CI builds need no generation
step.
