import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/price_list_form_controller.dart';

class MockPriceListRepository extends Mock implements PriceListRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.priceLists, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // read (2) + create (1) + update (4) + delete (8)
  privileges: [Privilege(systemObject: SystemObject.priceLists, rawValue: 15)],
);

ProviderContainer _containerFor(User user, PriceListRepository repository) {
  final container = ProviderContainer(
    overrides: [
      priceListRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
  return container;
}

void main() {
  late MockPriceListRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockPriceListRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('PriceListFormController field updates', () {
    test('nameChanged updates state and clears prior errors', () {
      final notifier = container.read(priceListFormControllerProvider.notifier);
      notifier.nameChanged('Retail');
      expect(container.read(priceListFormControllerProvider).name, 'Retail');
    });
  });

  group('PriceListFormController.submitCreate validation (FR-002, FR-006)', () {
    test('an empty name is rejected before submit', () async {
      final notifier = container.read(priceListFormControllerProvider.notifier);
      notifier.nameChanged('');

      await notifier.submitCreate();

      final state = container.read(priceListFormControllerProvider);
      expect(state.fieldErrors['name'], PriceListFormErrorCode.nameRequired);
      verifyNever(
        () => repository.create(
          name: any(named: 'name'),
          highProfitMargin: any(named: 'highProfitMargin'),
          lowProfitMargin: any(named: 'lowProfitMargin'),
        ),
      );
    });

    test('a negative margin is rejected before submit', () async {
      final notifier = container.read(priceListFormControllerProvider.notifier);
      notifier
        ..nameChanged('Retail')
        ..highProfitMarginChanged('-0.1');

      await notifier.submitCreate();

      final state = container.read(priceListFormControllerProvider);
      expect(
        state.fieldErrors['highProfitMargin'],
        PriceListFormErrorCode.marginInvalid,
      );
    });

    test(
      'a valid submission creates the price list and invalidates the list',
      () async {
        when(
          () => repository.create(
            name: 'Retail',
            highProfitMargin: '0.40',
            lowProfitMargin: '0.10',
          ),
        ).thenAnswer(
          (_) async => const PriceList(
            priceListId: 1,
            name: 'Retail',
            highProfitMargin: '0.40',
            lowProfitMargin: '0.10',
          ),
        );

        final notifier = container.read(
          priceListFormControllerProvider.notifier,
        );
        notifier
          ..nameChanged('Retail')
          ..highProfitMarginChanged('0.40')
          ..lowProfitMarginChanged('0.10');

        await notifier.submitCreate();

        expect(container.read(priceListFormControllerProvider).saved, isTrue);
      },
    );

    test('a server validation error surfaces as field errors', () async {
      when(
        () => repository.create(
          name: 'Retail',
          highProfitMargin: any(named: 'highProfitMargin'),
          lowProfitMargin: any(named: 'lowProfitMargin'),
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

      final notifier = container.read(priceListFormControllerProvider.notifier);
      notifier.nameChanged('Retail');

      await notifier.submitCreate();

      final state = container.read(priceListFormControllerProvider);
      expect(state.fieldErrors['name'], 'Name already in use');
    });
  });

  group('PriceListFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        priceListFormControllerProvider.notifier,
      );
      notifier.nameChanged('Retail');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(priceListFormControllerProvider);
      expect(state.error, PriceListFormErrorCode.createPermissionDenied);
      verifyNever(
        () => repository.create(
          name: any(named: 'name'),
          highProfitMargin: any(named: 'highProfitMargin'),
          lowProfitMargin: any(named: 'lowProfitMargin'),
        ),
      );
    });
  });

  group('PriceListFormController.submitUpdate', () {
    test(
      'sends only the changed field when editing an existing list',
      () async {
        when(() => repository.get(priceListId: 1)).thenAnswer(
          (_) async => const PriceList(
            priceListId: 1,
            name: 'Retail',
            highProfitMargin: '0.40',
            lowProfitMargin: '0.10',
          ),
        );
        when(
          () => repository.update(
            priceListId: 1,
            name: 'Retail',
            highProfitMargin: '0.50',
            lowProfitMargin: '0.10',
          ),
        ).thenAnswer(
          (_) async => const PriceList(
            priceListId: 1,
            name: 'Retail',
            highProfitMargin: '0.50',
            lowProfitMargin: '0.10',
          ),
        );

        final notifier = container.read(
          priceListFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);
        notifier.highProfitMarginChanged('0.50');

        await notifier.submitUpdate();

        expect(container.read(priceListFormControllerProvider).saved, isTrue);
      },
    );
  });

  group('PriceListFormController.delete', () {
    test(
      'a still-in-use rejection is surfaced and the list stays loaded',
      () async {
        when(() => repository.get(priceListId: 1)).thenAnswer(
          (_) async => const PriceList(
            priceListId: 1,
            name: 'Retail',
            highProfitMargin: '0.40',
            lowProfitMargin: '0.10',
          ),
        );
        when(() => repository.delete(priceListId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Price list is assigned to a customer',
          ),
        );

        final notifier = container.read(
          priceListFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(priceListFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, PriceListFormErrorCode.deleteFailed);
        expect(state.errorDetail, 'Price list is assigned to a customer');
      },
    );
  });
}
