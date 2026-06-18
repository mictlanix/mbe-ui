import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/product_form_controller.dart';

class MockProductRepository extends Mock implements ProductRepository {}

const _createUser = User(
  userId: 'creator',
  email: 'creator@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 1)],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 2)],
);

const _editUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  // read (2) + update (4)
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 6)],
);

const _deleteUser = User(
  userId: 'deleter',
  email: 'deleter@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  // read (2) + update (4) + delete (8)
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 14)],
);

Product _product() => Product(
      productId: 1,
      code: 'SKU-001',
      name: 'Widget',
      unitOfMeasurement: 'PCE',
      taxRate: '0.16',
      taxIncluded: false,
      priceType: 0,
      currency: 0,
      minOrderQty: 1,
      stockable: false,
      perishable: false,
      seriable: false,
      purchasable: false,
      salable: false,
      invoiceable: false,
      stockRequired: false,
      deactivated: false,
      prices: const [],
    );

ProviderContainer _containerFor(User user, ProductRepository repository) {
  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
  return container;
}

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  group('client-side validation', () {
    test('empty code is rejected', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      await controller.submitCreate();

      final state = container.read(productFormControllerProvider);
      expect(state.fieldErrors['code'], isNotNull);
      verifyNever(() => repository.create(
            code: any(named: 'code'),
            name: any(named: 'name'),
            unitOfMeasurement: any(named: 'unitOfMeasurement'),
          ));
    });

    test('code with whitespace is rejected', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU 001');
      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      await controller.submitCreate();

      expect(
        container.read(productFormControllerProvider).fieldErrors['code'],
        isNotNull,
      );
    });

    test('code longer than 25 characters is rejected', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('A' * 26);
      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      await controller.submitCreate();

      expect(
        container.read(productFormControllerProvider).fieldErrors['code'],
        isNotNull,
      );
    });

    test('name shorter than 4 characters is rejected', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Hi');
      controller.unitOfMeasurementChanged('PCE');
      await controller.submitCreate();

      expect(
        container.read(productFormControllerProvider).fieldErrors['name'],
        isNotNull,
      );
    });

    test('barcode with the wrong digit count is rejected', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      controller.barCodeChanged('12345');
      await controller.submitCreate();

      expect(
        container.read(productFormControllerProvider).fieldErrors['barCode'],
        isNotNull,
      );
    });

    test('an empty barcode is valid', () async {
      when(() => repository.create(
            code: any(named: 'code'),
            name: any(named: 'name'),
            unitOfMeasurement: any(named: 'unitOfMeasurement'),
            brand: any(named: 'brand'),
            model: any(named: 'model'),
            barCode: any(named: 'barCode'),
            location: any(named: 'location'),
            taxRate: any(named: 'taxRate'),
            comment: any(named: 'comment'),
            stockable: any(named: 'stockable'),
            perishable: any(named: 'perishable'),
            seriable: any(named: 'seriable'),
            purchasable: any(named: 'purchasable'),
            salable: any(named: 'salable'),
            invoiceable: any(named: 'invoiceable'),
          )).thenAnswer((_) async => _product());

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      await controller.submitCreate();

      expect(
        container.read(productFormControllerProvider).fieldErrors['barCode'],
        isNull,
      );
      expect(container.read(productFormControllerProvider).saved, isTrue);
    });
  });

  group('submitCreate', () {
    test('sends trimmed/normalized fields and defaults deactivated to false '
        '(FR-015, by simply never sending the field)', () async {
      when(() => repository.create(
            code: 'SKU-001',
            name: 'Widget',
            unitOfMeasurement: 'PCE',
            brand: 'Acme',
            model: null,
            barCode: null,
            location: null,
            taxRate: '0.16',
            comment: null,
            stockable: true,
            perishable: false,
            seriable: false,
            purchasable: true,
            salable: true,
            invoiceable: false,
          )).thenAnswer((_) async => _product());

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      controller.brandChanged('Acme');
      controller.taxRateChanged('0.16');
      controller.stockableChanged(true);
      controller.purchasableChanged(true);
      controller.salableChanged(true);

      await controller.submitCreate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isTrue);
      expect(state.submitting, isFalse);
      verify(() => repository.create(
            code: 'SKU-001',
            name: 'Widget',
            unitOfMeasurement: 'PCE',
            brand: 'Acme',
            model: null,
            barCode: null,
            location: null,
            taxRate: '0.16',
            comment: null,
            stockable: true,
            perishable: false,
            seriable: false,
            purchasable: true,
            salable: true,
            invoiceable: false,
          )).called(1);
    });

    test('without products.create privilege, does not call the repository '
        '(spec.md Edge Cases — privilege revoked while form is open)', () async {
      final container = _containerFor(_readOnlyUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      await controller.submitCreate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isFalse);
      expect(state.error, isNotNull);
      verifyNever(() => repository.create(
            code: any(named: 'code'),
            name: any(named: 'name'),
            unitOfMeasurement: any(named: 'unitOfMeasurement'),
          ));
    });

    test('a 422 duplicate-code response maps to fieldErrors (FR-004, FR-014)',
        () async {
      when(() => repository.create(
            code: any(named: 'code'),
            name: any(named: 'name'),
            unitOfMeasurement: any(named: 'unitOfMeasurement'),
            brand: any(named: 'brand'),
            model: any(named: 'model'),
            barCode: any(named: 'barCode'),
            location: any(named: 'location'),
            taxRate: any(named: 'taxRate'),
            comment: any(named: 'comment'),
            stockable: any(named: 'stockable'),
            perishable: any(named: 'perishable'),
            seriable: any(named: 'seriable'),
            purchasable: any(named: 'purchasable'),
            salable: any(named: 'salable'),
            invoiceable: any(named: 'invoiceable'),
          )).thenThrow(const AppError.validation([
        FieldError(loc: ['body', 'code'], msg: 'Code already in use', type: 'value_error'),
      ]));

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      await controller.submitCreate();

      final state = container.read(productFormControllerProvider);
      expect(state.fieldErrors['code'], 'Code already in use');
      expect(state.saved, isFalse);
    });

    test('a server bar_code rejection maps to the barCode field key '
        '(snake_case -> camelCase)', () async {
      when(() => repository.create(
            code: any(named: 'code'),
            name: any(named: 'name'),
            unitOfMeasurement: any(named: 'unitOfMeasurement'),
            brand: any(named: 'brand'),
            model: any(named: 'model'),
            barCode: any(named: 'barCode'),
            location: any(named: 'location'),
            taxRate: any(named: 'taxRate'),
            comment: any(named: 'comment'),
            stockable: any(named: 'stockable'),
            perishable: any(named: 'perishable'),
            seriable: any(named: 'seriable'),
            purchasable: any(named: 'purchasable'),
            salable: any(named: 'salable'),
            invoiceable: any(named: 'invoiceable'),
          )).thenThrow(const AppError.validation([
        FieldError(
          loc: ['body', 'bar_code'],
          msg: 'Barcode must be empty or exactly 13 digits (EAN-13)',
          type: 'value_error',
        ),
      ]));

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitOfMeasurementChanged('PCE');
      await controller.submitCreate();

      expect(
        container.read(productFormControllerProvider).fieldErrors['barCode'],
        'Barcode must be empty or exactly 13 digits (EAN-13)',
      );
    });
  });

  group('loadForEdit', () {
    test('populates the form from the loaded product (FR-008, FR-009)',
        () async {
      when(() => repository.get(productId: 1)).thenAnswer((_) async => _product());

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);

      final state = container.read(productFormControllerProvider);
      expect(state.productId, 1);
      expect(state.code, 'SKU-001');
      expect(state.name, 'Widget');
      expect(state.unitOfMeasurement, 'PCE');
      expect(state.loading, isFalse);
    });
  });

  group('submitUpdate', () {
    test('sends the current form fields for the loaded product (FR-009)',
        () async {
      when(() => repository.get(productId: 1)).thenAnswer((_) async => _product());
      when(() => repository.update(
            productId: 1,
            code: 'SKU-001',
            name: 'Updated Widget',
            unitOfMeasurement: 'PCE',
            brand: null,
            model: null,
            barCode: null,
            location: null,
            taxRate: '0.16',
            comment: null,
            stockable: false,
            perishable: false,
            seriable: false,
            purchasable: false,
            salable: false,
            invoiceable: false,
          )).thenAnswer((_) async => _product());

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      controller.nameChanged('Updated Widget');
      await controller.submitUpdate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isTrue);
      verify(() => repository.update(
            productId: 1,
            code: 'SKU-001',
            name: 'Updated Widget',
            unitOfMeasurement: 'PCE',
            brand: null,
            model: null,
            barCode: null,
            location: null,
            taxRate: '0.16',
            comment: null,
            stockable: false,
            perishable: false,
            seriable: false,
            purchasable: false,
            salable: false,
            invoiceable: false,
          )).called(1);
    });

    test('without products.update privilege, does not call the repository '
        '(spec.md Edge Cases)', () async {
      when(() => repository.get(productId: 1)).thenAnswer((_) async => _product());

      final container = _containerFor(_readOnlyUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.submitUpdate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isFalse);
      expect(state.error, isNotNull);
      verifyNever(() => repository.update(
            productId: any(named: 'productId'),
            code: any(named: 'code'),
            name: any(named: 'name'),
            unitOfMeasurement: any(named: 'unitOfMeasurement'),
          ));
    });

    test('a duplicate-code-on-rename rejection maps to fieldErrors (FR-004)',
        () async {
      when(() => repository.get(productId: 1)).thenAnswer((_) async => _product());
      when(() => repository.update(
            productId: 1,
            code: 'SKU-EXISTING',
            name: 'Widget',
            unitOfMeasurement: 'PCE',
            brand: null,
            model: null,
            barCode: null,
            location: null,
            taxRate: '0.16',
            comment: null,
            stockable: false,
            perishable: false,
            seriable: false,
            purchasable: false,
            salable: false,
            invoiceable: false,
          )).thenThrow(const AppError.validation([
        FieldError(loc: ['body', 'code'], msg: 'Code already in use', type: 'value_error'),
      ]));

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      controller.codeChanged('SKU-EXISTING');
      await controller.submitUpdate();

      final state = container.read(productFormControllerProvider);
      expect(state.fieldErrors['code'], 'Code already in use');
      expect(state.saved, isFalse);
    });

    test('is a no-op when no product has been loaded', () async {
      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.submitUpdate();

      verifyNever(() => repository.update(
            productId: any(named: 'productId'),
            code: any(named: 'code'),
            name: any(named: 'name'),
            unitOfMeasurement: any(named: 'unitOfMeasurement'),
          ));
    });
  });

  group('deactivate', () {
    test('sends only {deactivated: true} (FR-010)', () async {
      when(() => repository.get(productId: 1)).thenAnswer((_) async => _product());
      when(() => repository.update(productId: 1, deactivated: true))
          .thenAnswer((_) async => _product());

      final container = _containerFor(_deleteUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.deactivate();

      final state = container.read(productFormControllerProvider);
      expect(state.deactivated, isTrue);
      verify(() => repository.update(productId: 1, deactivated: true)).called(1);
    });

    test('is a no-op when the product is already deactivated (edge case)',
        () async {
      when(() => repository.get(productId: 1))
          .thenAnswer((_) async => _product().copyWith(deactivated: true));

      final container = _containerFor(_deleteUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.deactivate();

      verifyNever(() => repository.update(
            productId: any(named: 'productId'),
            deactivated: any(named: 'deactivated'),
          ));
    });

    test('without products.delete privilege, does not call the repository '
        '(spec.md Edge Cases)', () async {
      when(() => repository.get(productId: 1)).thenAnswer((_) async => _product());

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.deactivate();

      final state = container.read(productFormControllerProvider);
      expect(state.deactivated, isFalse);
      expect(state.error, isNotNull);
      verifyNever(() => repository.update(
            productId: any(named: 'productId'),
            deactivated: any(named: 'deactivated'),
          ));
    });

    test('is a no-op when no product has been loaded', () async {
      final container = _containerFor(_deleteUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.deactivate();

      verifyNever(() => repository.update(
            productId: any(named: 'productId'),
            deactivated: any(named: 'deactivated'),
          ));
    });
  });
}
