import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/config/app_settings.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/config/formatting_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer_discount.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/customer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/core/widgets/catalog_entity_picker.dart';
import 'package:mbe_ui/core/widgets/product_photo.dart';
import 'package:mbe_ui/features/catalog/presentation/customer_discount_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

const _clavo = ProductListItem(
  productId: 100,
  code: 'CLV-0125',
  name: 'Clavo estándar',
  unitOfMeasurementCode: 'KG',
  unitOfMeasurementName: 'Kilogram',
  taxRate: '0.16',
  status: EntityStatus.active,
);

const _clavoConcreto = ProductListItem(
  productId: 101,
  code: 'CLV-0140',
  name: 'Clavo para concreto',
  unitOfMeasurementCode: 'KG',
  unitOfMeasurementName: 'Kilogram',
  taxRate: '0.16',
  status: EntityStatus.active,
);

const _created = CustomerDiscount(
  customerDiscountId: 9,
  customerId: 1,
  productId: 101,
  productCode: 'CLV-0140',
  productName: 'Clavo para concreto',
  discount: '0.1',
);

const _productField = Key('customer_discount_product_field');
const _percentField = Key('customer_discount_percent_field');
const _saveButton = Key('customer_discount_save_button');
const _cancelButton = Key('customer_discount_cancel_button');

void main() {
  late MockCustomerRepository customerRepository;
  late MockProductRepository productRepository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() {
    customerRepository = MockCustomerRepository();
    productRepository = MockProductRepository();
    when(
      () => customerRepository.listDiscounts(
        customerId: any(named: 'customerId'),
      ),
    ).thenAnswer((_) async => const []);
    when(
      () => productRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          const ProductListResult(items: [_clavo, _clavoConcreto], total: 2),
    );
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    Set<int> takenProductIds = const {},
    CustomerDiscount? existing,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(1024, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          customerRepositoryProvider.overrideWithValue(customerRepository),
          productRepositoryProvider.overrideWithValue(productRepository),
          appSettingsProvider.overrideWithValue(
            AppSettings(
              apiBaseUrl: 'http://test',
              photosBaseUrl: 'http://test',
              posDefaultCustomerId: 1,
              brand: const BrandConfig(displayName: 'Test'),
              defaultLocale: const Locale('es', 'MX'),
              formatting: const FormattingSettings(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                key: const Key('open'),
                onPressed: () => showCustomerDiscountDialog(
                  context,
                  customerId: 1,
                  takenProductIds: takenProductIds,
                  existing: existing,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  Future<void> searchProducts(WidgetTester tester, String query) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(_productField),
        matching: find.byType(TextFormField),
      ),
      query,
    );
    // CatalogEntityPicker debounces its search.
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
  }

  Future<void> pickProduct(WidgetTester tester, String name) async {
    await searchProducts(tester, 'clavo');
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Future<void> typePercent(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(_percentField), text);
    await tester.pump();
  }

  bool saveEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byKey(_saveButton)).onPressed != null;

  testWidgets('the picker searches active products and leaves out the ones '
      'that already have a discount (FR-005)', (tester) async {
    await pumpDialog(tester, takenProductIds: {100});

    await searchProducts(tester, 'clavo');

    verify(
      () => productRepository.list(
        search: 'clavo',
        status: EntityStatus.active,
        limit: 20,
      ),
    ).called(1);
    expect(find.text('Clavo para concreto'), findsOneWidget);
    expect(find.text('Clavo estándar'), findsNothing);
    expect(find.text('CLV-0140'), findsOneWidget);
  });

  testWidgets('Save stays disabled until a product is picked and the '
      'percentage is valid (FR-004, FR-006)', (tester) async {
    await pumpDialog(tester);
    expect(saveEnabled(tester), isFalse);

    await typePercent(tester, '10');
    expect(saveEnabled(tester), isFalse, reason: 'no product yet');

    await pickProduct(tester, 'Clavo para concreto');
    expect(saveEnabled(tester), isTrue);

    await typePercent(tester, '101');
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('each invalid percentage says why and blocks Save (US2-3)', (
    tester,
  ) async {
    await pumpDialog(tester);
    await pickProduct(tester, 'Clavo para concreto');

    await typePercent(tester, '-1');
    expect(find.text(l10n.customerDiscountPercentOutOfRangeError), findsOne);
    expect(saveEnabled(tester), isFalse);

    await typePercent(tester, '101');
    expect(find.text(l10n.customerDiscountPercentOutOfRangeError), findsOne);

    await typePercent(tester, '1.2.3');
    expect(find.text(l10n.customerDiscountPercentInvalidError), findsOne);

    await typePercent(tester, '1.1234567');
    expect(find.text(l10n.customerDiscountPercentTooPreciseError), findsOne);

    await typePercent(tester, '');
    expect(find.text(l10n.customerDiscountPercentRequiredError), findsOne);
    expect(saveEnabled(tester), isFalse);

    await typePercent(tester, '12.5');
    expect(find.text(l10n.customerDiscountPercentRequiredError), findsNothing);
    expect(saveEnabled(tester), isTrue);
  });

  testWidgets('a picked product shows like a search row — name, code and '
      'photo — and can be cleared to search again', (tester) async {
    await pumpDialog(tester);
    await pickProduct(tester, 'Clavo para concreto');
    await typePercent(tester, '10');

    final selected = find.byKey(
      const Key('customer_discount_selected_product'),
    );
    expect(selected, findsOneWidget);
    expect(
      find.descendant(of: selected, matching: find.text('Clavo para concreto')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: selected, matching: find.text('CLV-0140')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: selected, matching: find.byType(ProductPhoto)),
      findsOneWidget,
    );
    expect(find.byKey(_productField), findsNothing);
    expect(saveEnabled(tester), isTrue);

    await tester.tap(find.byKey(const Key('customer_discount_clear_product')));
    await tester.pumpAndSettle();

    expect(selected, findsNothing);
    expect(find.byKey(_productField), findsOneWidget);
    expect(saveEnabled(tester), isFalse, reason: 'no product any more');
  });

  testWidgets('a blank dialog opens without showing an error', (tester) async {
    await pumpDialog(tester);

    expect(find.text(l10n.customerDiscountPercentRequiredError), findsNothing);
    expect(find.text(l10n.newCustomerDiscountDialogTitle), findsOneWidget);
  });

  testWidgets('saving sends the fraction, then closes the dialog', (
    tester,
  ) async {
    when(
      () => customerRepository.createDiscount(
        customerId: 1,
        productId: 101,
        discount: any(named: 'discount'),
      ),
    ).thenAnswer((_) async => _created);
    await pumpDialog(tester);
    await pickProduct(tester, 'Clavo para concreto');
    await typePercent(tester, '10');

    await tester.tap(find.byKey(_saveButton));
    await tester.pumpAndSettle();

    verify(
      () => customerRepository.createDiscount(
        customerId: 1,
        productId: 101,
        discount: '0.1',
      ),
    ).called(1);
    expect(find.byKey(_saveButton), findsNothing);
  });

  testWidgets('a duplicate refusal shows its banner and keeps the input '
      '(US2-4)', (tester) async {
    when(
      () => customerRepository.createDiscount(
        customerId: any(named: 'customerId'),
        productId: any(named: 'productId'),
        discount: any(named: 'discount'),
      ),
    ).thenThrow(const AppError.server(statusCode: 409));
    await pumpDialog(tester);
    await pickProduct(tester, 'Clavo para concreto');
    await typePercent(tester, '10');

    await tester.tap(find.byKey(_saveButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.customerDiscountDuplicateError), findsOneWidget);
    expect(find.byKey(_saveButton), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(_percentField),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      '10',
    );
    expect(find.text('Clavo para concreto'), findsOneWidget);
  });

  testWidgets('a vanished product shows its banner and keeps the dialog open '
      '(US2-5)', (tester) async {
    when(
      () => customerRepository.createDiscount(
        customerId: any(named: 'customerId'),
        productId: any(named: 'productId'),
        discount: any(named: 'discount'),
      ),
    ).thenThrow(const AppError.validation([], 'Product not found'));
    await pumpDialog(tester);
    await pickProduct(tester, 'Clavo para concreto');
    await typePercent(tester, '10');

    await tester.tap(find.byKey(_saveButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.customerDiscountProductMissingError), findsOneWidget);
    expect(find.byKey(_saveButton), findsOneWidget);
  });

  testWidgets('Cancel closes without calling the repository', (tester) async {
    await pumpDialog(tester);
    await typePercent(tester, '10');

    await tester.tap(find.byKey(_cancelButton));
    await tester.pumpAndSettle();

    expect(find.byKey(_saveButton), findsNothing);
    verifyNever(
      () => customerRepository.createDiscount(
        customerId: any(named: 'customerId'),
        productId: any(named: 'productId'),
        discount: any(named: 'discount'),
      ),
    );
  });

  group('edit mode', () {
    const existing = CustomerDiscount(
      customerDiscountId: 9,
      customerId: 1,
      productId: 100,
      productCode: 'CLV-0125',
      productName: 'Clavo estándar',
      discount: '0.12500000',
    );
    const deleteButton = Key('customer_discount_delete_button');
    const confirmDelete = Key('confirm_delete_customer_discount_button');

    String percentText(WidgetTester tester) => tester
        .widget<EditableText>(
          find.descendant(
            of: find.byKey(_percentField),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;

    void stubUpdate() => when(
      () => customerRepository.updateDiscount(
        customerId: any(named: 'customerId'),
        customerDiscountId: any(named: 'customerDiscountId'),
        discount: any(named: 'discount'),
      ),
    ).thenAnswer((_) async => existing);

    void stubDelete() => when(
      () => customerRepository.deleteDiscount(
        customerId: any(named: 'customerId'),
        customerDiscountId: any(named: 'customerDiscountId'),
      ),
    ).thenAnswer((_) async {});

    testWidgets('shows the product read-only and the percentage at full '
        'precision (US3-2, US1-3)', (tester) async {
      await pumpDialog(tester, existing: existing);

      expect(find.text(l10n.editCustomerDiscountDialogTitle), findsOneWidget);
      final selected = find.byKey(
        const Key('customer_discount_selected_product'),
      );
      expect(
        find.descendant(of: selected, matching: find.text('Clavo estándar')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: selected, matching: find.text('CLV-0125')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('customer_discount_clear_product')),
        findsNothing,
        reason: 'the product of an existing discount cannot change',
      );
      expect(find.byType(CatalogEntityPicker<ProductListItem>), findsNothing);
      expect(percentText(tester), '12.5');
      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('Remove appears only when editing', (tester) async {
      await pumpDialog(tester, existing: existing);
      expect(find.byKey(deleteButton), findsOneWidget);
      expect(find.text(l10n.deleteCustomerDiscountButton), findsOneWidget);
    });

    testWidgets('Remove does not appear when adding', (tester) async {
      await pumpDialog(tester);
      expect(find.byKey(deleteButton), findsNothing);
    });

    testWidgets('saving an untouched edit sends the stored rate back, and '
        'closes', (tester) async {
      stubUpdate();
      await pumpDialog(tester, existing: existing);

      await tester.tap(find.byKey(_saveButton));
      await tester.pumpAndSettle();

      verify(
        () => customerRepository.updateDiscount(
          customerId: 1,
          customerDiscountId: 9,
          discount: '0.12500000',
        ),
      ).called(1);
      expect(find.byKey(_saveButton), findsNothing);
    });

    testWidgets('a changed percentage is saved as the converted fraction', (
      tester,
    ) async {
      stubUpdate();
      await pumpDialog(tester, existing: existing);

      await typePercent(tester, '20');
      await tester.tap(find.byKey(_saveButton));
      await tester.pumpAndSettle();

      verify(
        () => customerRepository.updateDiscount(
          customerId: 1,
          customerDiscountId: 9,
          discount: '0.2',
        ),
      ).called(1);
    });

    testWidgets('Remove asks first, naming the product; cancelling the '
        'prompt removes nothing (FR-009)', (tester) async {
      stubDelete();
      await pumpDialog(tester, existing: existing);

      await tester.tap(find.byKey(deleteButton));
      await tester.pumpAndSettle();

      expect(find.text(l10n.deleteCustomerDiscountConfirmTitle), findsOne);
      expect(
        find.text(
          l10n.deleteCustomerDiscountConfirmMessage(
            'CLV-0125',
            'Clavo estándar',
          ),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(l10n.cancelButton).last);
      await tester.pumpAndSettle();

      verifyNever(
        () => customerRepository.deleteDiscount(
          customerId: any(named: 'customerId'),
          customerDiscountId: any(named: 'customerDiscountId'),
        ),
      );
      expect(find.byKey(_saveButton), findsOneWidget);
    });

    testWidgets('confirming removes the discount and closes the dialog '
        '(US3-3)', (tester) async {
      stubDelete();
      await pumpDialog(tester, existing: existing);

      await tester.tap(find.byKey(deleteButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(confirmDelete));
      await tester.pumpAndSettle();

      verify(
        () => customerRepository.deleteDiscount(
          customerId: 1,
          customerDiscountId: 9,
        ),
      ).called(1);
      expect(find.byKey(_saveButton), findsNothing);
    });

    testWidgets('a discount removed elsewhere shows its banner on save and on '
        'remove (US3-4)', (tester) async {
      when(
        () => customerRepository.updateDiscount(
          customerId: any(named: 'customerId'),
          customerDiscountId: any(named: 'customerDiscountId'),
          discount: any(named: 'discount'),
        ),
      ).thenThrow(const AppError.notFound('Discount not found'));
      when(
        () => customerRepository.deleteDiscount(
          customerId: any(named: 'customerId'),
          customerDiscountId: any(named: 'customerDiscountId'),
        ),
      ).thenThrow(const AppError.notFound('Discount not found'));
      await pumpDialog(tester, existing: existing);

      await tester.tap(find.byKey(_saveButton));
      await tester.pumpAndSettle();
      expect(find.text(l10n.customerDiscountMissingError), findsOneWidget);
      expect(find.byKey(_saveButton), findsOneWidget);

      await tester.tap(find.byKey(deleteButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(confirmDelete));
      await tester.pumpAndSettle();
      expect(find.text(l10n.customerDiscountMissingError), findsOneWidget);
      expect(find.byKey(_saveButton), findsOneWidget);
    });

    testWidgets('a failed remove keeps the dialog open with its message', (
      tester,
    ) async {
      when(
        () => customerRepository.deleteDiscount(
          customerId: any(named: 'customerId'),
          customerDiscountId: any(named: 'customerDiscountId'),
        ),
      ).thenThrow(const AppError.server(statusCode: 500));
      await pumpDialog(tester, existing: existing);

      await tester.tap(find.byKey(deleteButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(confirmDelete));
      await tester.pumpAndSettle();

      expect(find.text(l10n.customerDiscountDeleteFailedError), findsOne);
      expect(find.byKey(_saveButton), findsOneWidget);
    });
  });
}
