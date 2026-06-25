import 'package:mbe_ui/core/network/dio_client.dart';

/// Resolves a raw `photo` value from mbe-api into an absolute, ready-to-
/// fetch URL, used by `Product.fromResponse`/`ProductListItem.fromResponse`.
///
/// mbe-api's `photo` field can be:
/// - `null` (no photo)
/// - an absolute URL, if mbe-api's own `IMAGES_BASE_URL` setting is
///   configured server-side
/// - a root-relative path like `/images/<file>` otherwise — resolving this
///   as-is in a browser would hit mbe-ui's own origin, not mbe-api's, since
///   they are never same-origin
/// - a legacy ASP.NET virtual-root path like `~/Photos/<file>`, migrated
///   verbatim from the old `mbe` app's `PhotosPath` ("~/Photos/") convention
///   — not a route any server serves literally
///
/// Resolving against [apiBaseUrl] client-side means photos load correctly
/// regardless of whether mbe-api's own base-URL setting is configured.
String? resolvePhotoUrl(String? raw) {
  if (raw == null) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

  final base =
      apiBaseUrl.endsWith('/') ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) : apiBaseUrl;
  if (raw.startsWith('~/')) return '$base/${raw.substring(2)}';
  if (raw.startsWith('/')) return '$base$raw';
  return '$base/$raw';
}
