import 'dart:typed_data';

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
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/product_form_controller.dart';

class MockProductRepository extends Mock implements ProductRepository {}

const _createUser = User(
  userId: 'creator',
  email: 'creator@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 1)],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 2)],
);

const _editUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // read (2) + update (4)
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 6)],
);

const _deleteUser = User(
  userId: 'deleter',
  email: 'deleter@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // read (2) + update (4) + delete (8)
  privileges: [Privilege(systemObject: SystemObject.products, rawValue: 14)],
);

Product _product() => Product(
  productId: 1,
  code: 'SKU-001',
  name: 'Widget',
  unitOfMeasurementCode: 'PCE',
  unitOfMeasurementName: 'Piece',
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
  status: EntityStatus.active,
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

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repository = MockProductRepository();
  });

  group('client-side validation', () {
    test('empty code is rejected', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.nameChanged('Widget');
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
      await controller.submitCreate();

      final state = container.read(productFormControllerProvider);
      expect(state.fieldErrors['code'], isNotNull);
      verifyNever(
        () => repository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
        ),
      );
    });

    test('code with whitespace is rejected', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU 001');
      controller.nameChanged('Widget');
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
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
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
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
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
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
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
      controller.barCodeChanged('12345');
      await controller.submitCreate();

      expect(
        container.read(productFormControllerProvider).fieldErrors['barCode'],
        isNotNull,
      );
    });

    test('an empty barcode is valid', () async {
      when(
        () => repository.create(
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
          currency: any(named: 'currency'),
        ),
      ).thenAnswer((_) async => _product());

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
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
      when(
        () => repository.create(
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
          currency: 0,
        ),
      ).thenAnswer((_) async => _product());

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
      controller.brandChanged('Acme');
      controller.taxRateChanged('0.16');
      controller.stockableChanged(true);
      controller.purchasableChanged(true);
      controller.salableChanged(true);

      await controller.submitCreate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isTrue);
      expect(state.submitting, isFalse);
      verify(
        () => repository.create(
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
          currency: 0,
        ),
      ).called(1);
    });

    test('sends a set sku (FR-010)', () async {
      when(
        () => repository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
          sku: 'SKU-NEW',
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
          currency: any(named: 'currency'),
        ),
      ).thenAnswer((_) async => _product());

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
      controller.skuChanged('SKU-NEW');

      await controller.submitCreate();

      verify(
        () => repository.create(
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
          sku: 'SKU-NEW',
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
          currency: any(named: 'currency'),
        ),
      ).called(1);
    });

    test('uploads a staged photo using the newly-created product id and '
        're-invalidates the list (FR-003, FR-011)', () async {
      when(
        () => repository.create(
          code: 'SKU-001',
          name: 'Widget',
          unitOfMeasurement: 'PCE',
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
          currency: any(named: 'currency'),
        ),
      ).thenAnswer((_) async => _product());
      when(
        () => repository.uploadPhoto(
          productId: 1,
          bytes: Uint8List.fromList([1, 2, 3]),
          filename: 'photo.jpg',
        ),
      ).thenAnswer(
        (_) async => _product().copyWith(photo: 'http://test/p.png'),
      );

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
      controller.photoPicked(Uint8List.fromList([1, 2, 3]), 'photo.jpg');
      await controller.submitCreate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isTrue);
      expect(state.photo, 'http://test/p.png');
      verify(
        () => repository.uploadPhoto(
          productId: 1,
          bytes: Uint8List.fromList([1, 2, 3]),
          filename: 'photo.jpg',
        ),
      ).called(1);
    });

    test('a failed photo upload after a successful create still marks the '
        'product as saved (data-model.md "Save (create)")', () async {
      when(
        () => repository.create(
          code: 'SKU-001',
          name: 'Widget',
          unitOfMeasurement: 'PCE',
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
          currency: any(named: 'currency'),
        ),
      ).thenAnswer((_) async => _product());
      when(
        () => repository.uploadPhoto(
          productId: 1,
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).thenThrow(const AppError.network());

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
      controller.photoPicked(Uint8List.fromList([1, 2, 3]), 'photo.jpg');
      await controller.submitCreate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isTrue);
      expect(state.error, ProductFormErrorCode.photoUploadFailed);
    });

    test(
      'without products.create privilege, does not call the repository '
      '(spec.md Edge Cases — privilege revoked while form is open)',
      () async {
        final container = _containerFor(_readOnlyUser, repository);
        addTearDown(container.dispose);
        final controller = container.read(
          productFormControllerProvider.notifier,
        );

        controller.codeChanged('SKU-001');
        controller.nameChanged('Widget');
        controller.unitSelected(const SatCatalogItem(code: 'PCE'));
        await controller.submitCreate();

        final state = container.read(productFormControllerProvider);
        expect(state.saved, isFalse);
        expect(state.error, isNotNull);
        verifyNever(
          () => repository.create(
            code: any(named: 'code'),
            name: any(named: 'name'),
            unitOfMeasurement: any(named: 'unitOfMeasurement'),
          ),
        );
      },
    );

    test(
      'a 422 duplicate-code response maps to fieldErrors (FR-004, FR-014)',
      () async {
        when(
          () => repository.create(
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
            currency: any(named: 'currency'),
          ),
        ).thenThrow(
          const AppError.validation([
            FieldError(
              loc: ['body', 'code'],
              msg: 'Code already in use',
              type: 'value_error',
            ),
          ]),
        );

        final container = _containerFor(_createUser, repository);
        addTearDown(container.dispose);
        final controller = container.read(
          productFormControllerProvider.notifier,
        );

        controller.codeChanged('SKU-001');
        controller.nameChanged('Widget');
        controller.unitSelected(const SatCatalogItem(code: 'PCE'));
        await controller.submitCreate();

        final state = container.read(productFormControllerProvider);
        expect(state.fieldErrors['code'], 'Code already in use');
        expect(state.saved, isFalse);
      },
    );

    test('a server bar_code rejection maps to the barCode field key '
        '(snake_case -> camelCase)', () async {
      when(
        () => repository.create(
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
          currency: any(named: 'currency'),
        ),
      ).thenThrow(
        const AppError.validation([
          FieldError(
            loc: ['body', 'bar_code'],
            msg: 'Barcode must be empty or exactly 13 digits (EAN-13)',
            type: 'value_error',
          ),
        ]),
      );

      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.codeChanged('SKU-001');
      controller.nameChanged('Widget');
      controller.unitSelected(const SatCatalogItem(code: 'PCE'));
      await controller.submitCreate();

      expect(
        container.read(productFormControllerProvider).fieldErrors['barCode'],
        'Barcode must be empty or exactly 13 digits (EAN-13)',
      );
    });
  });

  group('loadForEdit', () {
    test(
      'populates the form from the loaded product (FR-008, FR-009)',
      () async {
        when(
          () => repository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        final container = _containerFor(_editUser, repository);
        addTearDown(container.dispose);
        final controller = container.read(
          productFormControllerProvider.notifier,
        );

        await controller.loadForEdit(1);

        final state = container.read(productFormControllerProvider);
        expect(state.productId, 1);
        expect(state.code, 'SKU-001');
        expect(state.name, 'Widget');
        expect(state.unitOfMeasurementCode, 'PCE');
        expect(state.loading, isFalse);
      },
    );

    test('populates photo from the loaded product (FR-001)', () async {
      when(() => repository.get(productId: 1)).thenAnswer(
        (_) async => _product().copyWith(photo: 'http://test/images/p.png'),
      );

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);

      expect(
        container.read(productFormControllerProvider).photo,
        'http://test/images/p.png',
      );
    });

    test('seeds sku from the loaded product (FR-010)', () async {
      when(
        () => repository.get(productId: 1),
      ).thenAnswer((_) async => _product().copyWith(sku: 'SKU-ABC'));

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);

      expect(container.read(productFormControllerProvider).sku, 'SKU-ABC');
    });

    test(
      'seeds an empty sku when the loaded product has none (FR-010)',
      () async {
        when(
          () => repository.get(productId: 1),
        ).thenAnswer((_) async => _product());

        final container = _containerFor(_editUser, repository);
        addTearDown(container.dispose);
        final controller = container.read(
          productFormControllerProvider.notifier,
        );

        await controller.loadForEdit(1);

        expect(container.read(productFormControllerProvider).sku, '');
      },
    );
  });

  group('photoPicked', () {
    test(
      'stages a valid JPEG and clears photoMarkedForRemoval (FR-003)',
      () async {
        final container = _containerFor(_createUser, repository);
        addTearDown(container.dispose);
        final controller = container.read(
          productFormControllerProvider.notifier,
        );
        controller.photoRemoveRequested();

        controller.photoPicked(Uint8List.fromList([1, 2, 3]), 'photo.jpg');

        final state = container.read(productFormControllerProvider);
        expect(state.pendingPhotoBytes, [1, 2, 3]);
        expect(state.pendingPhotoFilename, 'photo.jpg');
        expect(state.photoMarkedForRemoval, isFalse);
        expect(state.fieldErrors.containsKey('photo'), isFalse);
      },
    );

    test('stages a valid PNG (FR-003)', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.photoPicked(Uint8List.fromList([1, 2, 3]), 'photo.PNG');

      expect(container.read(productFormControllerProvider).pendingPhotoBytes, [
        1,
        2,
        3,
      ]);
    });

    test(
      'rejects a non-JPEG/PNG file and does not stage it (FR-006)',
      () async {
        final container = _containerFor(_createUser, repository);
        addTearDown(container.dispose);
        final controller = container.read(
          productFormControllerProvider.notifier,
        );

        controller.photoPicked(Uint8List.fromList([1, 2, 3]), 'document.pdf');

        final state = container.read(productFormControllerProvider);
        expect(state.pendingPhotoBytes, isNull);
        expect(
          state.fieldErrors['photo'],
          ProductFormErrorCode.photoInvalidType,
        );
      },
    );

    test('rejects a file over 2 MB and does not stage it (FR-007)', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.photoPicked(Uint8List(2 * 1024 * 1024 + 1), 'photo.jpg');

      final state = container.read(productFormControllerProvider);
      expect(state.pendingPhotoBytes, isNull);
      expect(state.fieldErrors['photo'], ProductFormErrorCode.photoTooLarge);
    });
  });

  group('photoRemoveRequested', () {
    test('marks the current photo for removal and clears any staged pick '
        '(FR-005)', () async {
      when(() => repository.get(productId: 1)).thenAnswer(
        (_) async => _product().copyWith(photo: 'http://test/p.png'),
      );
      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);
      await controller.loadForEdit(1);
      controller.photoPicked(Uint8List.fromList([1, 2, 3]), 'photo.jpg');

      controller.photoRemoveRequested();

      final state = container.read(productFormControllerProvider);
      expect(state.photoMarkedForRemoval, isTrue);
      expect(state.pendingPhotoBytes, isNull);
      expect(state.pendingPhotoFilename, isNull);
    });

    test('picking a new photo after a removal request clears '
        'photoMarkedForRemoval again (mutually exclusive)', () async {
      when(() => repository.get(productId: 1)).thenAnswer(
        (_) async => _product().copyWith(photo: 'http://test/p.png'),
      );
      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);
      await controller.loadForEdit(1);
      controller.photoRemoveRequested();

      controller.photoPicked(Uint8List.fromList([1, 2, 3]), 'photo.jpg');

      expect(
        container.read(productFormControllerProvider).photoMarkedForRemoval,
        isFalse,
      );
    });

    test('is a no-op when there is no current photo and nothing staged '
        '(spec.md Edge Cases)', () async {
      final container = _containerFor(_createUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      controller.photoRemoveRequested();

      expect(
        container.read(productFormControllerProvider).photoMarkedForRemoval,
        isFalse,
      );
    });
  });

  group('submitUpdate', () {
    test(
      'sends the current form fields for the loaded product (FR-009)',
      () async {
        when(
          () => repository.get(productId: 1),
        ).thenAnswer((_) async => _product());
        when(
          () => repository.update(
            productId: 1,
            code: 'SKU-001',
            name: 'Updated Widget',
            unitOfMeasurement: 'PCE',
            sku: null,
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
            currency: 0,
            supplier: null,
            key: null,
            labels: const [],
          ),
        ).thenAnswer((_) async => _product());

        final container = _containerFor(_editUser, repository);
        addTearDown(container.dispose);
        final controller = container.read(
          productFormControllerProvider.notifier,
        );

        await controller.loadForEdit(1);
        controller.nameChanged('Updated Widget');
        await controller.submitUpdate();

        final state = container.read(productFormControllerProvider);
        expect(state.saved, isTrue);
        verify(
          () => repository.update(
            productId: 1,
            code: 'SKU-001',
            name: 'Updated Widget',
            unitOfMeasurement: 'PCE',
            sku: null,
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
            currency: 0,
            supplier: null,
            key: null,
            labels: const [],
          ),
        ).called(1);
      },
    );

    test('sends an updated sku (FR-010)', () async {
      when(
        () => repository.get(productId: 1),
      ).thenAnswer((_) async => _product());
      when(
        () => repository.update(
          productId: 1,
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
          sku: 'SKU-NEW',
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
          currency: any(named: 'currency'),
          supplier: any(named: 'supplier'),
          key: any(named: 'key'),
          labels: any(named: 'labels'),
        ),
      ).thenAnswer((_) async => _product());

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      controller.skuChanged('SKU-NEW');
      await controller.submitUpdate();

      verify(
        () => repository.update(
          productId: 1,
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
          sku: 'SKU-NEW',
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
          currency: any(named: 'currency'),
          supplier: any(named: 'supplier'),
          key: any(named: 'key'),
          labels: any(named: 'labels'),
        ),
      ).called(1);
    });

    test('uploads a staged photo after the field update and re-invalidates '
        'the list (FR-004, FR-011)', () async {
      when(
        () => repository.get(productId: 1),
      ).thenAnswer((_) async => _product());
      when(
        () => repository.update(
          productId: 1,
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
          currency: any(named: 'currency'),
          supplier: any(named: 'supplier'),
          key: any(named: 'key'),
          labels: any(named: 'labels'),
        ),
      ).thenAnswer((_) async => _product());
      when(
        () => repository.uploadPhoto(
          productId: 1,
          bytes: Uint8List.fromList([1, 2, 3]),
          filename: 'photo.jpg',
        ),
      ).thenAnswer(
        (_) async => _product().copyWith(photo: 'http://test/p.png'),
      );

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      controller.photoPicked(Uint8List.fromList([1, 2, 3]), 'photo.jpg');
      await controller.submitUpdate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isTrue);
      expect(state.photo, 'http://test/p.png');
      verify(
        () => repository.uploadPhoto(
          productId: 1,
          bytes: Uint8List.fromList([1, 2, 3]),
          filename: 'photo.jpg',
        ),
      ).called(1);
    });

    test('removes the photo after the field update when marked for removal '
        '(FR-005, FR-011)', () async {
      when(() => repository.get(productId: 1)).thenAnswer(
        (_) async => _product().copyWith(photo: 'http://test/p.png'),
      );
      when(
        () => repository.update(
          productId: 1,
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
          currency: any(named: 'currency'),
          supplier: any(named: 'supplier'),
          key: any(named: 'key'),
          labels: any(named: 'labels'),
        ),
      ).thenAnswer(
        (_) async => _product().copyWith(photo: 'http://test/p.png'),
      );
      when(
        () => repository.removePhoto(productId: 1),
      ).thenAnswer((_) async => _product());

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      controller.photoRemoveRequested();
      await controller.submitUpdate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isTrue);
      expect(state.photo, isNull);
      verify(() => repository.removePhoto(productId: 1)).called(1);
      verifyNever(
        () => repository.uploadPhoto(
          productId: any(named: 'productId'),
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      );
    });

    test('without products.update privilege, does not call the repository '
        '(spec.md Edge Cases)', () async {
      when(
        () => repository.get(productId: 1),
      ).thenAnswer((_) async => _product());

      final container = _containerFor(_readOnlyUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.submitUpdate();

      final state = container.read(productFormControllerProvider);
      expect(state.saved, isFalse);
      expect(state.error, isNotNull);
      verifyNever(
        () => repository.update(
          productId: any(named: 'productId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
        ),
      );
    });

    test(
      'a duplicate-code-on-rename rejection maps to fieldErrors (FR-004)',
      () async {
        when(
          () => repository.get(productId: 1),
        ).thenAnswer((_) async => _product());
        when(
          () => repository.update(
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
            currency: 0,
            supplier: null,
            key: null,
            labels: const [],
          ),
        ).thenThrow(
          const AppError.validation([
            FieldError(
              loc: ['body', 'code'],
              msg: 'Code already in use',
              type: 'value_error',
            ),
          ]),
        );

        final container = _containerFor(_editUser, repository);
        addTearDown(container.dispose);
        final controller = container.read(
          productFormControllerProvider.notifier,
        );

        await controller.loadForEdit(1);
        controller.codeChanged('SKU-EXISTING');
        await controller.submitUpdate();

        final state = container.read(productFormControllerProvider);
        expect(state.fieldErrors['code'], 'Code already in use');
        expect(state.saved, isFalse);
      },
    );

    test('is a no-op when no product has been loaded', () async {
      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.submitUpdate();

      verifyNever(
        () => repository.update(
          productId: any(named: 'productId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          unitOfMeasurement: any(named: 'unitOfMeasurement'),
        ),
      );
    });
  });

  group('delete', () {
    test('calls ProductRepository.delete and sets deleted (FR-016a)', () async {
      when(
        () => repository.get(productId: 1),
      ).thenAnswer((_) async => _product());
      when(() => repository.delete(productId: 1)).thenAnswer((_) async {});

      final container = _containerFor(_deleteUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.delete();

      final state = container.read(productFormControllerProvider);
      expect(state.deleted, isTrue);
      expect(state.submitting, isFalse);
      verify(() => repository.delete(productId: 1)).called(1);
    });

    test('deletes an already-deactivated product (FR-015 — not gated by '
        'deactivated state)', () async {
      when(() => repository.get(productId: 1)).thenAnswer(
        (_) async => _product().copyWith(status: EntityStatus.inactive),
      );
      when(() => repository.delete(productId: 1)).thenAnswer((_) async {});

      final container = _containerFor(_deleteUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.delete();

      expect(container.read(productFormControllerProvider).deleted, isTrue);
      verify(() => repository.delete(productId: 1)).called(1);
    });

    test('without products.delete privilege, does not call the repository '
        '(spec.md Edge Cases)', () async {
      when(
        () => repository.get(productId: 1),
      ).thenAnswer((_) async => _product());

      final container = _containerFor(_editUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.delete();

      final state = container.read(productFormControllerProvider);
      expect(state.deleted, isFalse);
      expect(state.error, ProductFormErrorCode.deletePermissionDenied);
      verifyNever(() => repository.delete(productId: any(named: 'productId')));
    });

    test('is a no-op when no product has been loaded', () async {
      final container = _containerFor(_deleteUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.delete();

      verifyNever(() => repository.delete(productId: any(named: 'productId')));
    });

    test('a server rejection (e.g. referential integrity) surfaces an error '
        'and leaves the product in place (FR-016b)', () async {
      when(
        () => repository.get(productId: 1),
      ).thenAnswer((_) async => _product());
      when(() => repository.delete(productId: 1)).thenThrow(
        const AppError.server(
          statusCode: 409,
          message: 'Product is referenced by other records',
        ),
      );

      final container = _containerFor(_deleteUser, repository);
      addTearDown(container.dispose);
      final controller = container.read(productFormControllerProvider.notifier);

      await controller.loadForEdit(1);
      await controller.delete();

      final state = container.read(productFormControllerProvider);
      expect(state.deleted, isFalse);
      expect(state.error, ProductFormErrorCode.deleteFailed);
      expect(state.submitting, isFalse);
    });
  });
}
