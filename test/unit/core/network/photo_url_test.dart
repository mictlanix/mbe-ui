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

  test('resolves a legacy "~/Photos/<file>" virtual-root path by '
      'replacing "~" with apiBaseUrl', () {
    expect(
      resolvePhotoUrl('~/Photos/fe18d04c.png'),
      '$apiBaseUrl/Photos/fe18d04c.png',
    );
  });

  test('resolves a bare filename against apiBaseUrl as a fallback', () {
    expect(resolvePhotoUrl('abc.png'), '$apiBaseUrl/abc.png');
  });
}
