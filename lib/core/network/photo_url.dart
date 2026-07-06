import 'package:mbe_ui/core/network/dio_client.dart';

/// Base URL for resolving legacy `~/Photos/<file>` virtual-root photo
/// paths (mictlanix/mbe-api#72) into real, fetchable URLs. Those files are
/// served by the old `mbe` app's still-running web server, not mbe-api's
/// own image storage, so this is intentionally independent of [apiBaseUrl]
/// and typically points at a separate host/CDN. Override via
/// `--dart-define=PHOTOS_BASE_URL=https://...`; defaults to
/// [apiBaseUrl] so local dev (where nothing else is configured) at least
/// produces a same-origin-with-the-API guess rather than a broken one.
///
/// Known limitation (web only, accepted — research.md §6): the browser
/// blocks loading the resolved URL unless that host sends
/// `Access-Control-Allow-Origin`, since Flutter Web's `Image.network`
/// decodes images via a programmatic fetch (CORS-checked), not a passive
/// `<img src>` load. Desktop/mobile builds are unaffected — `dart:io` HTTP
/// has no CORS concept. Fixing this requires CORS configuration on
/// whatever host this points to, outside mbe-ui's/mbe-api's control.
const photosBaseUrl = String.fromEnvironment(
  'PHOTOS_BASE_URL',
  defaultValue: apiBaseUrl,
);

/// Resolves a raw `photo` value from mbe-api into an absolute, ready-to-
/// fetch URL, used by `Product.fromResponse`/`ProductListItem.fromResponse`.
///
/// mbe-api's `photo` field can be:
/// - `null` (no photo)
/// - an absolute URL, if mbe-api's own `IMAGES_BASE_URL` setting is
///   configured server-side
/// - a root-relative path like `/images/<file>` otherwise — resolving this
///   as-is in a browser would hit mbe-ui's own origin, not mbe-api's, since
///   they are never same-origin. Resolved against [apiBaseUrl].
/// - a legacy ASP.NET virtual-root path containing `~`, e.g.
///   `/images/~/Photos/<file>` — `_photo_url()` blindly prepends `/images/`
///   to whatever's stored, so the literal `~/Photos/...` segment (migrated
///   verbatim from the old `mbe` app's `PhotosPath` convention) can appear
///   anywhere after that prefix, not just at the start. Everything from
///   `~` onward (minus the `~` itself) is resolved against
///   [photosBaseUrl] instead — that's where these files actually live.
String? resolvePhotoUrl(String? raw) {
  if (raw == null) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

  final tildeIndex = raw.indexOf('~');
  if (tildeIndex != -1) {
    return '${_withoutTrailingSlash(photosBaseUrl)}${raw.substring(tildeIndex + 1)}';
  }
  if (raw.startsWith('/')) return '${_withoutTrailingSlash(apiBaseUrl)}$raw';
  return '${_withoutTrailingSlash(apiBaseUrl)}/$raw';
}

String _withoutTrailingSlash(String url) =>
    url.endsWith('/') ? url.substring(0, url.length - 1) : url;
