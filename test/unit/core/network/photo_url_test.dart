import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/network/photo_url.dart';

void main() {
  test('returns null for a null photo', () {
    expect(resolvePhotoUrl(null), isNull);
  });

  test('leaves an absolute http(s) URL unchanged', () {
    expect(
      resolvePhotoUrl('https://cdn.example.com/images/abc.png'),
      'https://cdn.example.com/images/abc.png',
    );
    expect(
      resolvePhotoUrl('http://cdn.example.com/images/abc.png'),
      'http://cdn.example.com/images/abc.png',
    );
  });

  test('resolves a root-relative path against apiBaseUrl (mbe-api '
      'IMAGES_BASE_URL unset)', () {
    expect(resolvePhotoUrl('/images/abc.png'), '$apiBaseUrl/images/abc.png');
  });

  test('resolves a legacy "~/Photos/<file>" virtual-root path against '
      'photosBaseUrl', () {
    expect(
      resolvePhotoUrl('~/Photos/fe18d04c.png'),
      '$photosBaseUrl/Photos/fe18d04c.png',
    );
  });

  test('resolves the real-world shape — "~" appearing after a bogus '
      '"/images/" prefix, not at the start — against photosBaseUrl '
      '(mictlanix/mbe-api#72)', () {
    expect(
      resolvePhotoUrl(
        '/images/~/Photos/fe18d04c7c4a0dda4b685d1293b649bb16ab95f2.png',
      ),
      '$photosBaseUrl/Photos/fe18d04c7c4a0dda4b685d1293b649bb16ab95f2.png',
    );
  });

  test('resolves a bare filename against apiBaseUrl as a fallback', () {
    expect(resolvePhotoUrl('abc.png'), '$apiBaseUrl/abc.png');
  });
}
