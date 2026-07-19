import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/gender.dart';

void main() {
  group('Gender.fromValue', () {
    test('maps 0/1 to female/male', () {
      expect(Gender.fromValue(0), Gender.female);
      expect(Gender.fromValue(1), Gender.male);
    });

    test('returns null for an unrecognized code', () {
      expect(Gender.fromValue(99), isNull);
    });
  });
}
