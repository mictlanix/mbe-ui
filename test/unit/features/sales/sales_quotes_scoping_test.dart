import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/sales/data/sales_quote_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sales_quote_summary.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_quote_repository.dart';
import 'package:mbe_ui/features/sales/presentation/quotes/sales_quotes_list_controller.dart';

class MockSalesQuoteRepository extends Mock implements SalesQuoteRepository {}

/// FR-034: the quotes list is the facility's own, never filtered to the
/// current user — `mine` is always `false`, with no toggle anywhere in
/// `SalesQuotesFilter` that could flip it (unlike the orders list, which
/// derives `mine` from the caller's role). This test guards that constant
/// independently of `sales_quotes_filter_test.dart`'s own decode coverage,
/// so a filter built any other way still can't leak `mine: true` to the
/// request.
void main() {
  late MockSalesQuoteRepository repository;

  setUp(() {
    repository = MockSalesQuoteRepository();
    when(
      () => repository.listQuotes(
        mine: any(named: 'mine'),
        customer: any(named: 'customer'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const SalesQuotePage(items: [], total: 0));
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [salesQuoteRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('mine is always false, whatever the filter carries', () async {
    final c = container();

    await c.read(
      salesQuotesListControllerProvider(const SalesQuotesFilter()).future,
    );

    verify(
      () => repository.listQuotes(
        mine: false,
        customer: any(named: 'customer'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(1);
  });

  test('customer, salesperson, status and search thread through unchanged', () async {
    final c = container();

    await c.read(
      salesQuotesListControllerProvider(
        const SalesQuotesFilter(
          customer: 7,
          salesperson: 100,
          status: SaleStatus.draft,
          search: 'Acme',
        ),
      ).future,
    );

    verify(
      () => repository.listQuotes(
        mine: false,
        customer: 7,
        salesperson: 100,
        status: SaleStatus.draft,
        search: 'Acme',
        skip: 0,
        limit: any(named: 'limit'),
      ),
    ).called(1);
  });

  test('an empty search string is not sent — `null`, not `""` (matches '
      'the orders list\'s own convention)', () async {
    final c = container();

    await c.read(
      salesQuotesListControllerProvider(const SalesQuotesFilter()).future,
    );

    verify(
      () => repository.listQuotes(
        mine: false,
        customer: any(named: 'customer'),
        salesperson: any(named: 'salesperson'),
        status: any(named: 'status'),
        search: null,
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(1);
  });
}
