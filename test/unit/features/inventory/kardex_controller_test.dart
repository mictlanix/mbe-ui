import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/kardex_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/kardex_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_selection.dart';

import 'kardex_fixtures.dart';

class MockKardexRepository extends Mock implements KardexRepository {}

/// Spec 071 US3, research R4 (T019).
void main() {
  late MockKardexRepository repository;

  setUp(() => repository = MockKardexRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [kardexRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<Kardex>> whenRead() => when(
    () => repository.read(
      productId: any(named: 'productId'),
      warehouseId: any(named: 'warehouseId'),
      from: any(named: 'from'),
      to: any(named: 'to'),
    ),
  );

  final from = DateTime(2026, 10, 19);
  final to = DateTime(2026, 11, 17);

  group('no request unless the selection is ready', () {
    final cases = {
      'incomplete (no product)': KardexSelection(
        warehouseId: 3,
        from: from,
        to: to,
      ),
      'incomplete (no warehouse)': KardexSelection(
        productId: 7,
        from: from,
        to: to,
      ),
      'reversed': KardexSelection(
        productId: 7,
        warehouseId: 3,
        from: to,
        to: from,
      ),
      'tooLong': KardexSelection(
        productId: 7,
        warehouseId: 3,
        from: DateTime(2025, 1, 1),
        to: to,
      ),
    };
    for (final MapEntry(key: name, value: selection) in cases.entries) {
      test(name, () async {
        whenRead().thenAnswer((_) async => aKardex());

        final result = await container().read(
          kardexControllerProvider(selection).future,
        );

        expect(result, isNull);
        verifyNever(
          () => repository.read(
            productId: any(named: 'productId'),
            warehouseId: any(named: 'warehouseId'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        );
      });
    }
  });

  test('a ready selection makes one request with its params', () async {
    whenRead().thenAnswer((_) async => aKardex());
    final selection = KardexSelection(
      productId: 7,
      warehouseId: 3,
      from: from,
      to: to,
    );

    await container().read(kardexControllerProvider(selection).future);

    verify(
      () => repository.read(productId: 7, warehouseId: 3, from: from, to: to),
    ).called(1);
  });

  test('the movements, totals and balances pass through unchanged', () async {
    final kardex = aKardex(
      opening: '-2',
      totalIn: '5',
      totalOut: '10',
      closing: '-7',
      movements: [
        aKardexMovement(id: 2, quantityIn: '5', balance: '3'),
        aKardexMovement(id: 1, quantityOut: '10', balance: '-7'),
      ],
    );
    whenRead().thenAnswer((_) async => kardex);

    final result = await container().read(
      kardexControllerProvider(
        KardexSelection(productId: 7, warehouseId: 3, from: from, to: to),
      ).future,
    );

    expect(result, kardex);
    expect([for (final m in result!.movements) m.id], [2, 1]);
    expect(result.closing, Decimal.parse('-7'));
    expect(result.movements.last.balance, Decimal.parse('-7'));
  });

  test('an error is kept as an AppError', () async {
    whenRead().thenThrow(const AppError.network());
    final c = container();
    final selection = KardexSelection(
      productId: 7,
      warehouseId: 3,
      from: from,
      to: to,
    );
    final sub = c.listen(kardexControllerProvider(selection), (_, _) {});
    addTearDown(sub.close);

    await expectLater(
      c.read(kardexControllerProvider(selection).future),
      throwsA(isA<NetworkError>()),
    );
    expect(c.read(kardexControllerProvider(selection)).error, isA<AppError>());
  });
}
