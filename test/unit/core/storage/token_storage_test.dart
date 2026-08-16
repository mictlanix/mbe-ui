import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/storage/token_storage.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage storage;
  late TokenStorage tokenStorage;

  setUp(() {
    storage = MockSecureStorage();
    tokenStorage = TokenStorage(storage: storage);
  });

  test('clear swallows a keychain PlatformException', () async {
    when(() => storage.delete(key: any(named: 'key'))).thenThrow(
      PlatformException(
        code: 'Unexpected security result code',
        message: "A required entitlement isn't present.",
        details: -34018,
      ),
    );

    // macOS answers `-34018` here on locally-signed builds; callers clear the
    // token from inside an error handler, so this must not replace the error
    // being handled.
    await expectLater(tokenStorage.clear(), completes);
  });

  test('clear delegates to the underlying storage', () async {
    when(
      () => storage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});

    await tokenStorage.clear();

    verify(() => storage.delete(key: 'access_token')).called(1);
  });

  test('read and write are not swallowed', () async {
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenThrow(PlatformException(code: 'boom'));
    when(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenThrow(PlatformException(code: 'boom'));

    expect(() => tokenStorage.read(), throwsA(isA<PlatformException>()));
    expect(() => tokenStorage.write('token'), throwsA(isA<PlatformException>()));
  });
}
