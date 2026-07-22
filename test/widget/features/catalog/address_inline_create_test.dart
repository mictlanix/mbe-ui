import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/address_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/address_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/address_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/address_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/address_inline_create.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAddressRepository extends Mock implements AddressRepository {}

class _FakePayload extends Fake implements AddressCreatePayload {}

void main() {
  setUpAll(() => registerFallbackValue(_FakePayload()));

  late MockAddressRepository repository;

  setUp(() => repository = MockAddressRepository());

  /// Pumps a host with a button that opens the dialog and records its result.
  Future<AddressListItem?> pumpAndOpen(WidgetTester tester) async {
    AddressListItem? result;
    var opened = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          addressRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showAddressInlineCreateDialog(context);
                    opened = true;
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(opened, isFalse); // dialog still up
    return result;
  }

  Future<void> fillRequired(WidgetTester tester) async {
    await tester.enterText(find.byKey(const Key('address_street_field')), 'Reforma');
    await tester.enterText(
      find.byKey(const Key('address_exterior_number_field')),
      '100',
    );
    await tester.enterText(
      find.byKey(const Key('address_postal_code_field')),
      '06600',
    );
    await tester.enterText(
      find.byKey(const Key('address_neighborhood_field')),
      'Juárez',
    );
    await tester.enterText(
      find.byKey(const Key('address_borough_field')),
      'Cuauhtémoc',
    );
    await tester.enterText(find.byKey(const Key('address_state_field')), 'CDMX');
    await tester.enterText(
      find.byKey(const Key('address_country_field')),
      'México',
    );
  }

  testWidgets('validates the required address fields before submitting', (
    tester,
  ) async {
    await pumpAndOpen(tester);

    // Submit empty — no create call, field errors shown.
    await tester.ensureVisible(find.byKey(const Key('create_address_button')));
    await tester.tap(find.byKey(const Key('create_address_button')));
    await tester.pumpAndSettle();

    verifyNever(() => repository.create(any()));
    expect(find.text('Street is required.'), findsOneWidget);
    expect(find.text('Country is required.'), findsOneWidget);
  });

  testWidgets('on success the created address is returned to the caller', (
    tester,
  ) async {
    when(() => repository.create(any())).thenAnswer(
      (_) async => const AddressListItem(
        addressId: 99,
        label: 'Reforma 100, Juárez, CDMX',
        type: AddressType.other,
      ),
    );

    // Drive the dialog directly so we can read the returned value after it
    // pops.
    AddressListItem? returned;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [addressRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    returned = await showAddressInlineCreateDialog(context);
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await fillRequired(tester);
    await tester.ensureVisible(find.byKey(const Key('create_address_button')));
    await tester.tap(find.byKey(const Key('create_address_button')));
    await tester.pumpAndSettle();

    expect(returned, isNotNull);
    expect(returned!.addressId, 99);
    verify(() => repository.create(any())).called(1);
    // Dialog has popped.
    expect(find.byKey(const Key('create_address_button')), findsNothing);
  });

  testWidgets('a server rejection is surfaced and the dialog stays open', (
    tester,
  ) async {
    when(() => repository.create(any())).thenThrow(
      AppError.validation([
        const FieldError(
          loc: ['postalCode'],
          msg: 'Invalid postal code',
          type: 'value_error',
        ),
      ]),
    );

    await pumpAndOpen(tester);
    await fillRequired(tester);
    await tester.ensureVisible(find.byKey(const Key('create_address_button')));
    await tester.tap(find.byKey(const Key('create_address_button')));
    await tester.pumpAndSettle();

    expect(find.text('Invalid postal code'), findsOneWidget);
    // Still open — the user can correct and retry without re-entering.
    expect(find.byKey(const Key('create_address_button')), findsOneWidget);
    expect(find.text('Reforma'), findsOneWidget);
  });
}
