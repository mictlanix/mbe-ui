import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';

const adminUser = User(
  userId: 'admin',
  email: 'admin@example.com',
  administrator: true,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

const regularUser = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.users, rawValue: 2), // read only
  ],
);

void main() {
  group('AccessControlService.can', () {
    test('unauthenticated users cannot access anything', () {
      const service = AccessControlService(AuthState.unauthenticated());

      expect(service.isAuthenticated, isFalse);
      expect(service.can(SystemObject.users, AccessRight.read), isFalse);
    });

    test('administrators can access everything regardless of privileges', () {
      const service = AccessControlService(
        AuthState.authenticated(token: 't', user: adminUser),
      );

      expect(service.isAdministrator, isTrue);
      expect(service.can(SystemObject.users, AccessRight.delete), isTrue);
      expect(service.can(SystemObject.customers, AccessRight.create), isTrue);
    });

    test('a missing privilege entry denies all access (FR-007)', () {
      const service = AccessControlService(
        AuthState.authenticated(token: 't', user: regularUser),
      );

      expect(service.can(SystemObject.customers, AccessRight.read), isFalse);
    });

    test('a partial bitmask grants only the matching right', () {
      const service = AccessControlService(
        AuthState.authenticated(token: 't', user: regularUser),
      );

      expect(service.can(SystemObject.users, AccessRight.read), isTrue);
      expect(service.can(SystemObject.users, AccessRight.update), isFalse);
      expect(service.can(SystemObject.users, AccessRight.delete), isFalse);
      expect(service.can(SystemObject.users, AccessRight.create), isFalse);
    });
  });
}
