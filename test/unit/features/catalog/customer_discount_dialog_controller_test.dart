import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/app_formatters.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discount_dialog_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discounts_controller.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

const _product = ProductListItem(
  productId: 100,
  code: 'CLV-0125',
  name: 'Clavo estándar',
  unitOfMeasurementCode: 'KG',
  unitOfMeasurementName: 'Kilogram',
  taxRate: '0.16',
  status: EntityStatus.active,
);

const _created = CustomerDiscount(
  customerDiscountId: 9,
  customerId: 1,
  productId: 100,
  productCode: 'CLV-0125',
  productName: 'Clavo estándar',
  discount: '0.1',
);

void main() {
  late MockCustomerRepository repository;
  late ProviderContainer container;

  final provider = customerDiscountDialogControllerProvider(1, null);

  setUpAll(() async => initializeDateFormatting());

  setUp(() {
    repository = MockCustomerRepository();
    when(
      () => repository.listDiscounts(customerId: any(named: 'customerId')),
    ).thenAnswer((_) async => const []);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerRepositoryProvider.overrideWithValue(repository),
        formattersProvider.overrideWithValue(
          AppFormatters(
            locale: const Locale('es', 'MX'),
            settings: const FormattingSettings(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // The dialog controller is auto-disposed: keep it alive for the test.
    container.listen(provider, (_, _) {});
  });

  CustomerDiscountDialogController notifier() =>
      container.read(provider.notifier);
  CustomerDiscountDialogState state() => container.read(provider);

  void stubCreate(Object error) => when(
    () => repository.createDiscount(
      customerId: any(named: 'customerId'),
      productId: any(named: 'productId'),
      discount: any(named: 'discount'),
    ),
  ).thenThrow(error);

  group('validateCustomerDiscountPercent (FR-006)', () {
    test('refuses empty, non-numeric, out-of-range and over-precise text', () {
      expect(
        validateCustomerDiscountPercent(''),
        CustomerDiscountPercentError.required,
      );
      expect(
        validateCustomerDiscountPercent('   '),
        CustomerDiscountPercentError.required,
      );
      expect(
        validateCustomerDiscountPercent('abc'),
        CustomerDiscountPercentError.invalid,
      );
      expect(
        validateCustomerDiscountPercent('-1'),
        CustomerDiscountPercentError.outOfRange,
      );
      expect(
        validateCustomerDiscountPercent('101'),
        CustomerDiscountPercentError.outOfRange,
      );
      expect(
        validateCustomerDiscountPercent('1.1234567'),
        CustomerDiscountPercentError.tooPrecise,
      );
    });

    test('accepts the bounds, a fraction of a percent and trailing zeros '
        '(which carry no precision)', () {
      for (final ok in [
        '0',
        '100',
        '12.5',
        '0.000001',
        '10.000000',
        '10.0000000',
      ]) {
        expect(validateCustomerDiscountPercent(ok), isNull, reason: ok);
      }
    });
  });

  group('add mode', () {
    test('Save needs a picked product and a valid percentage', () {
      expect(notifier().canSubmit, isFalse);

      notifier().percentChanged('10');
      expect(notifier().canSubmit, isFalse, reason: 'no product yet');

      notifier().productSelected(_product);
      expect(notifier().canSubmit, isTrue);

      notifier().percentChanged('101');
      expect(notifier().canSubmit, isFalse);
    });

    test('a blank dialog shows no percentage error until the user types', () {
      expect(state().percentError, isNull);

      notifier().percentChanged('');
      expect(state().percentError, CustomerDiscountPercentError.required);
    });

    test('submit sends the fraction and the picked product, refreshes the '
        'list and finishes', () async {
      when(
        () => repository.createDiscount(
          customerId: 1,
          productId: 100,
          discount: any(named: 'discount'),
        ),
      ).thenAnswer((_) async => _created);
      // Keep the list provider alive so its rebuild can be observed.
      container.listen(customerDiscountsControllerProvider(1), (_, _) {});
      await container.read(customerDiscountsControllerProvider(1).future);

      notifier().productSelected(_product);
      notifier().percentChanged('10');
      await notifier().submit();

      verify(
        () => repository.createDiscount(
          customerId: 1,
          productId: 100,
          discount: '0.1',
        ),
      ).called(1);
      expect(state().done, isTrue);
      expect(state().submitting, isFalse);
      await container.read(customerDiscountsControllerProvider(1).future);
      verify(() => repository.listDiscounts(customerId: 1)).called(2);
    });

    test('a fractional percentage converts exactly (12.5 -> 0.125)', () async {
      when(
        () => repository.createDiscount(
          customerId: 1,
          productId: 100,
          discount: any(named: 'discount'),
        ),
      ).thenAnswer((_) async => _created);

      notifier().productSelected(_product);
      notifier().percentChanged('12.5');
      await notifier().submit();

      verify(
        () => repository.createDiscount(
          customerId: 1,
          productId: 100,
          discount: '0.125',
        ),
      ).called(1);
    });

    test('an invalid percentage never reaches the repository', () async {
      notifier().productSelected(_product);
      notifier().percentChanged('150');
      await notifier().submit();

      verifyNever(
        () => repository.createDiscount(
          customerId: any(named: 'customerId'),
          productId: any(named: 'productId'),
          discount: any(named: 'discount'),
        ),
      );
    });

    test('a 409 reports the duplicate, keeps the input and refreshes the '
        'list (FR-011)', () async {
      stubCreate(
        const AppError.server(
          statusCode: 409,
          message: 'Customer already has a discount for this product',
        ),
      );
      container.listen(customerDiscountsControllerProvider(1), (_, _) {});
      await container.read(customerDiscountsControllerProvider(1).future);

      notifier().productSelected(_product);
      notifier().percentChanged('10');
      await notifier().submit();

      expect(state().error, CustomerDiscountDialogErrorCode.duplicateProduct);
      expect(state().done, isFalse);
      expect(state().submitting, isFalse);
      expect(state().product, _product);
      expect(state().percent, '10');
      await container.read(customerDiscountsControllerProvider(1).future);
      verify(() => repository.listDiscounts(customerId: 1)).called(2);
    });

    test('a 422 with a plain detail reports the missing product and keeps the '
        'input', () async {
      stubCreate(const AppError.validation([], 'Product not found'));

      notifier().productSelected(_product);
      notifier().percentChanged('10');
      await notifier().submit();

      expect(state().error, CustomerDiscountDialogErrorCode.productMissing);
      expect(state().product, _product);
      expect(state().percent, '10');
    });

    test('a 422 with field errors lands under the field', () async {
      stubCreate(
        const AppError.validation([
          FieldError(
            loc: ['body', 'discount'],
            msg: 'Input should be less than or equal to 1',
            type: 'less_than_equal',
          ),
        ]),
      );

      notifier().productSelected(_product);
      notifier().percentChanged('10');
      await notifier().submit();

      expect(state().error, isNull);
      expect(
        state().fieldErrors['discount'],
        'Input should be less than or equal to 1',
      );
      expect(state().percent, '10');
    });

    test('any other failure is a generic save failure carrying the server '
        'message', () async {
      stubCreate(const AppError.server(statusCode: 500, message: 'boom'));

      notifier().productSelected(_product);
      notifier().percentChanged('10');
      await notifier().submit();

      expect(state().error, CustomerDiscountDialogErrorCode.saveFailed);
      expect(state().errorDetail, 'boom');
      expect(state().done, isFalse);
    });

    test('editing after a refusal clears the error', () async {
      stubCreate(const AppError.server(statusCode: 500));
      notifier().productSelected(_product);
      notifier().percentChanged('10');
      await notifier().submit();
      expect(state().error, isNotNull);

      notifier().percentChanged('11');

      expect(state().error, isNull);
    });
  });

  group('edit and remove (existing discount)', () {
    const existing = CustomerDiscount(
      customerDiscountId: 9,
      customerId: 1,
      productId: 100,
      productCode: 'CLV-0125',
      productName: 'Clavo estándar',
      discount: '0.12500000',
    );
    final editProvider = customerDiscountDialogControllerProvider(1, existing);

    CustomerDiscountDialogController edit() =>
        container.read(editProvider.notifier);
    CustomerDiscountDialogState editState() => container.read(editProvider);

    setUp(() => container.listen(editProvider, (_, _) {}));

    void stubUpdate() => when(
      () => repository.updateDiscount(
        customerId: any(named: 'customerId'),
        customerDiscountId: any(named: 'customerDiscountId'),
        discount: any(named: 'discount'),
      ),
    ).thenAnswer((_) async => existing);

    void stubUpdateError(Object error) => when(
      () => repository.updateDiscount(
        customerId: any(named: 'customerId'),
        customerDiscountId: any(named: 'customerDiscountId'),
        discount: any(named: 'discount'),
      ),
    ).thenThrow(error);

    void stubDelete() => when(
      () => repository.deleteDiscount(
        customerId: any(named: 'customerId'),
        customerDiscountId: any(named: 'customerDiscountId'),
      ),
    ).thenAnswer((_) async {});

    void stubDeleteError(Object error) => when(
      () => repository.deleteDiscount(
        customerId: any(named: 'customerId'),
        customerDiscountId: any(named: 'customerDiscountId'),
      ),
    ).thenThrow(error);

    test('the percentage is seeded at the stored rate\'s full precision', () {
      expect(editState().percent, '12.5');
      expect(editState().percentDirty, isFalse);
      expect(edit().canSubmit, isTrue, reason: 'no product pick is needed');
    });

    test(
      'an untouched edit sends the stored rate back exactly as it was',
      () async {
        stubUpdate();

        await edit().submit();

        verify(
          () => repository.updateDiscount(
            customerId: 1,
            customerDiscountId: 9,
            discount: '0.12500000',
          ),
        ).called(1);
        expect(editState().done, isTrue);
      },
    );

    test('a changed percentage sends the converted fraction, and never a '
        'product', () async {
      stubUpdate();

      edit().percentChanged('20');
      await edit().submit();

      verify(
        () => repository.updateDiscount(
          customerId: 1,
          customerDiscountId: 9,
          discount: '0.2',
        ),
      ).called(1);
      verifyNever(
        () => repository.createDiscount(
          customerId: any(named: 'customerId'),
          productId: any(named: 'productId'),
          discount: any(named: 'discount'),
        ),
      );
    });

    test('an edit is refused for an out-of-range percentage', () async {
      stubUpdate();

      edit().percentChanged('150');
      await edit().submit();

      verifyNever(
        () => repository.updateDiscount(
          customerId: any(named: 'customerId'),
          customerDiscountId: any(named: 'customerDiscountId'),
          discount: any(named: 'discount'),
        ),
      );
      expect(editState().percentError, CustomerDiscountPercentError.outOfRange);
    });

    test('saving refreshes the list', () async {
      stubUpdate();
      container.listen(customerDiscountsControllerProvider(1), (_, _) {});
      await container.read(customerDiscountsControllerProvider(1).future);

      edit().percentChanged('20');
      await edit().submit();

      await container.read(customerDiscountsControllerProvider(1).future);
      verify(() => repository.listDiscounts(customerId: 1)).called(2);
    });

    test('a 404 on save reports the missing discount and refreshes the '
        'list (US3-4)', () async {
      stubUpdateError(const AppError.notFound('Discount not found'));
      container.listen(customerDiscountsControllerProvider(1), (_, _) {});
      await container.read(customerDiscountsControllerProvider(1).future);

      edit().percentChanged('20');
      await edit().submit();

      expect(
        editState().error,
        CustomerDiscountDialogErrorCode.discountMissing,
      );
      expect(editState().done, isFalse);
      expect(editState().percent, '20');
      await container.read(customerDiscountsControllerProvider(1).future);
      verify(() => repository.listDiscounts(customerId: 1)).called(2);
    });

    test(
      'a failed save keeps the dialog open with the server message',
      () async {
        stubUpdateError(
          const AppError.server(statusCode: 500, message: 'boom'),
        );

        edit().percentChanged('20');
        await edit().submit();

        expect(editState().error, CustomerDiscountDialogErrorCode.saveFailed);
        expect(editState().errorDetail, 'boom');
        expect(editState().done, isFalse);
      },
    );

    test('a 422 with a plain detail on an edit is a generic save failure, '
        'not a missing product', () async {
      stubUpdateError(const AppError.validation([], 'Nope'));

      edit().percentChanged('20');
      await edit().submit();

      expect(editState().error, CustomerDiscountDialogErrorCode.saveFailed);
      expect(editState().errorDetail, 'Nope');
    });

    test('delete calls the repository once, refreshes the list and '
        'finishes', () async {
      stubDelete();
      container.listen(customerDiscountsControllerProvider(1), (_, _) {});
      await container.read(customerDiscountsControllerProvider(1).future);

      await edit().delete();

      verify(
        () => repository.deleteDiscount(customerId: 1, customerDiscountId: 9),
      ).called(1);
      expect(editState().done, isTrue);
      await container.read(customerDiscountsControllerProvider(1).future);
      verify(() => repository.listDiscounts(customerId: 1)).called(2);
    });

    test('a 404 on delete reports the missing discount and refreshes the '
        'list', () async {
      stubDeleteError(const AppError.notFound('Discount not found'));
      container.listen(customerDiscountsControllerProvider(1), (_, _) {});
      await container.read(customerDiscountsControllerProvider(1).future);

      await edit().delete();

      expect(
        editState().error,
        CustomerDiscountDialogErrorCode.discountMissing,
      );
      expect(editState().done, isFalse);
      await container.read(customerDiscountsControllerProvider(1).future);
      verify(() => repository.listDiscounts(customerId: 1)).called(2);
    });

    test(
      'a failed delete keeps the dialog open with a delete failure',
      () async {
        stubDeleteError(
          const AppError.server(statusCode: 500, message: 'boom'),
        );

        await edit().delete();

        expect(editState().error, CustomerDiscountDialogErrorCode.deleteFailed);
        expect(editState().errorDetail, 'boom');
        expect(editState().done, isFalse);
      },
    );

    test('delete does nothing in add mode', () async {
      await notifier().delete();

      verifyNever(
        () => repository.deleteDiscount(
          customerId: any(named: 'customerId'),
          customerDiscountId: any(named: 'customerDiscountId'),
        ),
      );
    });
  });
}
