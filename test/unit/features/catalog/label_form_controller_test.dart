import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/label_form_controller.dart';

class MockLabelRepository extends Mock implements LabelRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.labels, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.labels, rawValue: 15)],
);

ProviderContainer _containerFor(User user, LabelRepository repository) {
  return ProviderContainer(
    overrides: [
      labelRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockLabelRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockLabelRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('LabelFormController field updates', () {
    test('nameChanged updates state and clears prior errors', () {
      final notifier = container.read(labelFormControllerProvider.notifier);
      notifier.nameChanged('Clearance');
      expect(container.read(labelFormControllerProvider).name, 'Clearance');
    });
  });

  group('LabelFormController.submitCreate validation (FR-012, FR-013)', () {
    test('an empty name is rejected before submit', () async {
      final notifier = container.read(labelFormControllerProvider.notifier);

      await notifier.submitCreate();

      final state = container.read(labelFormControllerProvider);
      expect(state.fieldErrors['name'], LabelFormErrorCode.nameRequired);
      verifyNever(
        () => repository.create(
          name: any(named: 'name'),
          comment: any(named: 'comment'),
        ),
      );
    });

    test(
      'a valid submission creates the label and invalidates the list',
      () async {
        when(
          () => repository.create(name: 'Clearance', comment: null),
        ).thenAnswer((_) async => const Label(labelId: 1, name: 'Clearance'));

        final notifier = container.read(labelFormControllerProvider.notifier);
        notifier.nameChanged('Clearance');

        await notifier.submitCreate();

        expect(container.read(labelFormControllerProvider).saved, isTrue);
      },
    );

    test('a server validation error surfaces as field errors', () async {
      when(
        () => repository.create(
          name: 'Clearance',
          comment: any(named: 'comment'),
        ),
      ).thenThrow(
        const AppError.validation([
          FieldError(
            loc: ['body', 'name'],
            msg: 'Name already in use',
            type: 'value_error',
          ),
        ]),
      );

      final notifier = container.read(labelFormControllerProvider.notifier);
      notifier.nameChanged('Clearance');

      await notifier.submitCreate();

      final state = container.read(labelFormControllerProvider);
      expect(state.fieldErrors['name'], 'Name already in use');
    });
  });

  group('LabelFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        labelFormControllerProvider.notifier,
      );
      notifier.nameChanged('Clearance');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(labelFormControllerProvider);
      expect(state.error, LabelFormErrorCode.createPermissionDenied);
      verifyNever(
        () => repository.create(
          name: any(named: 'name'),
          comment: any(named: 'comment'),
        ),
      );
    });
  });

  group('LabelFormController.submitUpdate', () {
    test('sends the changed fields when editing an existing label', () async {
      when(
        () => repository.get(labelId: 1),
      ).thenAnswer((_) async => const Label(labelId: 1, name: 'Clearance'));
      when(
        () =>
            repository.update(labelId: 1, name: 'Clearance Sale', comment: ''),
      ).thenAnswer(
        (_) async => const Label(labelId: 1, name: 'Clearance Sale'),
      );

      final notifier = container.read(labelFormControllerProvider.notifier);
      await notifier.loadForEdit(1);
      notifier.nameChanged('Clearance Sale');

      await notifier.submitUpdate();

      expect(container.read(labelFormControllerProvider).saved, isTrue);
    });
  });

  group('LabelFormController.delete', () {
    test(
      'a still-assigned rejection is surfaced and the label stays loaded',
      () async {
        when(
          () => repository.get(labelId: 1),
        ).thenAnswer((_) async => const Label(labelId: 1, name: 'Clearance'));
        when(() => repository.delete(labelId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Label is assigned to a product',
          ),
        );

        final notifier = container.read(labelFormControllerProvider.notifier);
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(labelFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, LabelFormErrorCode.deleteFailed);
        expect(state.errorDetail, 'Label is assigned to a product');
      },
    );
  });
}
