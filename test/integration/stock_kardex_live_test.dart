import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/kardex_repository_impl.dart';
import 'package:mbe_ui/features/inventory/data/stock_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';
import 'package:mbe_ui/features/inventory/domain/entities/stock.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_selection.dart';
import 'package:mbe_ui/features/inventory/presentation/kardex/kardex_sources.dart';
import 'package:mbe_ui/l10n/app_localizations_es.dart';

/// Spec 071's repository calls against a live mbe-api (quickstart.md, task
/// T023): the Existencias list (sort, `q`, `include_zero`, the in-transit
/// refusal, `available == on hand − reserved`), a product's stock and its
/// totals, the kardex balance (SC-002) and its range refusals, the catalog
/// product list returning inactive products when `status` is omitted
/// (research R12), and the source mapping checked against every kardex row
/// seen (research R5).
///
///   flutter test test/integration/stock_kardex_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env
///
/// **Read-only: it makes no writes of any kind**, so it needs no
/// `MBE_WRITE`. Account: `MBE_POS_*` (from `.env`), the administrator, which
/// reads every warehouse, Stock (67), Kardex (32) and Products.
///
/// Fixtures are discovered at run time: the listed warehouses (mbe-api never
/// lists in-transit ones) with stock rows, a product with stock in the first
/// of them, and an in-transit warehouse from a product's in-transit stock or,
/// failing that, by probing unlisted warehouse ids. A case whose fixture is
/// missing is skipped with the reason.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _canRun = _username != '' && _password != '';

/// How many warehouses, and products in each, the source-type scan reads.
const _scanWarehouses = 4;
const _scanProducts = 4;

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// SC-002's arithmetic: totals and each row's running balance.
void _checkBalance(Kardex k) {
  expect(
    k.opening + k.totalIn - k.totalOut,
    k.closing,
    reason: 'opening + in − out != closing',
  );
  var balance = k.opening;
  for (final m in k.movements) {
    balance = balance + m.quantityIn - m.quantityOut;
    expect(m.balance, balance, reason: 'row ${m.id} balance');
  }
  if (k.movements.isNotEmpty) {
    expect(k.movements.last.balance, k.closing, reason: 'last row != closing');
  }
}

void main() {
  late Dio dio;
  late StockRepositoryImpl stock;
  late KardexRepositoryImpl kardex;
  late WarehouseRepositoryImpl warehouses;
  late ProductRepositoryImpl products;
  final steps = <_Step>[];

  Future<void> step(String name, Future<String?> Function() body) async {
    try {
      final note = await body();
      steps.add(_Step(name, true, note ?? ''));
    } on Object catch (e, st) {
      steps.add(_Step(name, false, '$e\n$st'));
    }
  }

  void skipped(String name, String why) =>
      steps.add(_Step(name, true, 'SKIPPED: $why'));

  setUpAll(() async {
    if (!_canRun) return;
    dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
    final auth = AuthRepositoryImpl(dio);
    final token = await auth.login(username: _username, password: _password);
    dio.options.headers['Authorization'] = 'Bearer $token';
    stock = StockRepositoryImpl(dio);
    kardex = KardexRepositoryImpl(dio);
    warehouses = WarehouseRepositoryImpl(dio);
    products = ProductRepositoryImpl(dio);
  });

  test(
    'Existencias and Kardex against a live mbe-api (read-only)',
    () async {
      final today = _today();

      // ---- Fixtures -----------------------------------------------------
      final listed = <int>[];
      await step('warehouses are listed', () async {
        for (var skip = 0; ; skip += 100) {
          final page = await warehouses.list(skip: skip, limit: 100);
          listed.addAll(page.items.map((w) => w.warehouseId));
          if (page.items.length < 100) break;
        }
        expect(listed, isNotEmpty);
        return '${listed.length} listed';
      });

      // Listed warehouses with stock rows, and their first page by code.
      final stocked = <int, StockPage>{};
      await step('fixtures: warehouses with stock rows', () async {
        for (final w in listed) {
          final page = await stock.list(
            warehouseId: w,
            includeZero: false,
            skip: 0,
            limit: 50,
          );
          if (page.total >= 2) stocked[w] = page;
        }
        return stocked.isEmpty
            ? 'none'
            : stocked.entries
                  .map((e) => 'W${e.key}: ${e.value.total}')
                  .join(', ');
      });
      if (stocked.isEmpty) {
        skipped('every other case', 'no listed warehouse has two stock rows');
      } else {
        final w = stocked.keys.first;
        final first = stocked[w]!;
        final p = first.items.first;

        // ---- Stock list -------------------------------------------------
        await step('stock list: a page sorted by code', () async {
          final codes = first.items.map((r) => r.productCode).toList();
          final sorted = [...codes]..sort();
          expect(codes, sorted, reason: 'W$w page not sorted by code');
          expect(first.items.every((r) => r.warehouseId == w), isTrue);
          return 'W$w: ${codes.length} rows of ${first.total}';
        });

        await step('stock list: q narrows it', () async {
          final page = await stock.list(
            warehouseId: w,
            q: p.productCode,
            includeZero: false,
            skip: 0,
            limit: 50,
          );
          expect(page.total, lessThanOrEqualTo(first.total));
          expect(page.items.any((r) => r.productId == p.productId), isTrue);
          return 'q="${p.productCode}": ${page.total} of ${first.total}';
        });

        await step('stock list: include_zero adds rows', () async {
          var gained = <int>[];
          for (final e in stocked.entries) {
            final all = await stock.list(
              warehouseId: e.key,
              includeZero: true,
              skip: 0,
              limit: 1,
            );
            expect(all.total, greaterThanOrEqualTo(e.value.total));
            if (all.total > e.value.total) {
              gained = [e.key, e.value.total, all.total];
              break;
            }
          }
          if (gained.isEmpty) {
            return 'SKIPPED: no stocked warehouse gains rows with include_zero';
          }
          return 'W${gained[0]}: ${gained[1]} -> ${gained[2]}';
        });

        await step('stock list: available == on hand − reserved', () async {
          var rows = 0;
          for (final page in stocked.values) {
            for (final r in page.items) {
              expect(
                r.available,
                r.onHand - r.reserved,
                reason: 'P${r.productId} W${r.warehouseId}',
              );
              rows++;
            }
          }
          return '$rows rows over ${stocked.length} warehouse(s)';
        });

        // ---- Product stock ----------------------------------------------
        ProductStock? ps;
        await step('product stock: its warehouses and totals', () async {
          ps = await stock.product(p.productId);
          final s = ps!;
          expect(s.productId, p.productId);
          final row = s.warehouses.where((r) => r.warehouseId == w);
          expect(row, hasLength(1), reason: 'W$w missing from product view');
          expect(row.single.onHand, p.onHand);
          var onHand = Decimal.zero;
          var reserved = Decimal.zero;
          var available = Decimal.zero;
          var incoming = Decimal.zero;
          for (final r in s.warehouses) {
            expect(r.productId, p.productId);
            expect(r.available, r.onHand - r.reserved);
            onHand += r.onHand;
            reserved += r.reserved;
            available += r.available;
            incoming += r.incoming;
          }
          expect(s.totals.onHand, onHand);
          expect(s.totals.reserved, reserved);
          expect(s.totals.available, available);
          expect(s.totals.incoming, incoming);
          return 'P${p.productId}: ${s.warehouses.length} warehouse(s), '
              'on hand ${s.totals.onHand}, ${s.inTransit.length} in transit';
        });

        // ---- In-transit refusal -----------------------------------------
        await step('stock list: in-transit warehouse refused', () async {
          int? transit = ps?.inTransit.firstOrNull?.warehouseId;
          var how = 'from product stock';
          if (transit == null) {
            // Look through the stocked products' in-transit stock.
            for (final page in stocked.values) {
              for (final r in page.items.take(10)) {
                final s = await stock.product(r.productId);
                transit = s.inTransit.firstOrNull?.warehouseId;
                if (transit != null) break;
              }
              if (transit != null) break;
            }
          }
          if (transit == null) {
            // Probe unlisted ids: in-transit warehouses are never listed.
            how = 'probed';
            final max = listed.reduce((a, b) => a > b ? a : b);
            for (var id = 1; id <= max + 10 && transit == null; id++) {
              if (listed.contains(id)) continue;
              try {
                await stock.list(
                  warehouseId: id,
                  includeZero: false,
                  skip: 0,
                  limit: 1,
                );
              } on AppError catch (e) {
                if (_code(e) == 'warehouse.in_transit_location') transit = id;
              }
            }
          }
          if (transit == null) {
            return 'SKIPPED: no in-transit warehouse found';
          }
          try {
            await stock.list(
              warehouseId: transit,
              includeZero: false,
              skip: 0,
              limit: 10,
            );
            fail('W$transit (in transit) was listed');
          } on AppError catch (e) {
            expect(_code(e), 'warehouse.in_transit_location');
          }
          return 'W$transit ($how)';
        });

        // ---- Kardex -----------------------------------------------------
        await step('kardex: last 30 days balance; closing == on hand '
            '(SC-002)', () async {
          final k = await kardex.read(
            productId: p.productId,
            warehouseId: w,
            from: today.subtract(const Duration(days: 29)),
            to: today,
          );
          expect(k.productId, p.productId);
          expect(k.warehouseId, w);
          _checkBalance(k);
          final page = await stock.list(
            warehouseId: w,
            q: p.productCode,
            includeZero: true,
            skip: 0,
            limit: 50,
          );
          final row = page.items.firstWhere((r) => r.productId == p.productId);
          expect(k.closing, row.onHand, reason: 'closing != stock on hand');
          return 'P${p.productId} W$w: ${k.opening} + ${k.totalIn} − '
              '${k.totalOut} = ${k.closing} (${k.movements.length} rows)';
        });

        await step('kardex: 367 days refused with range_too_long', () async {
          try {
            await kardex.read(
              productId: p.productId,
              warehouseId: w,
              from: today.subtract(const Duration(days: kardexMaxRangeDays)),
              to: today,
            );
            fail('a 367-day range was accepted');
          } on AppError catch (e) {
            expect(_code(e), 'kardex.range_too_long');
            expect(e.problem!.intParam('max_days'), kardexMaxRangeDays);
          }
          return null;
        });

        await step('kardex: reversed range refused', () async {
          try {
            await kardex.read(
              productId: p.productId,
              warehouseId: w,
              from: today,
              to: today.subtract(const Duration(days: 1)),
            );
            fail('a reversed range was accepted');
          } on AppError catch (e) {
            expect(_code(e), 'kardex.range_reversed');
          }
          return null;
        });

        // ---- Source types (R5) ------------------------------------------
        await step('kardex: every source type seen maps, with its '
            'document (366 days)', () async {
          final l10n = AppLocalizationsEs();
          final fallback = l10n.inventoryKardexSourceFallback;
          final seen = <int, int>{};
          final withDoc = <int, int>{};
          final unlabelled = <int>{};
          var pairs = 0;
          for (final e in stocked.entries.take(_scanWarehouses)) {
            for (final r in e.value.items.take(_scanProducts)) {
              final k = await kardex.read(
                productId: r.productId,
                warehouseId: e.key,
                from: today.subtract(
                  const Duration(days: kardexMaxRangeDays - 1),
                ),
                to: today,
              );
              pairs++;
              _checkBalance(k);
              expect(k.closing, r.onHand, reason: 'P${r.productId} W${e.key}');
              for (final m in k.movements) {
                seen.update(m.sourceType, (n) => n + 1, ifAbsent: () => 1);
                if (kardexSourceLabel(l10n, m.sourceType) == fallback) {
                  unlabelled.add(m.sourceType);
                }
                final d = m.document;
                if (d != null) {
                  expect(
                    d.type,
                    m.sourceType,
                    reason: 'row ${m.id}: document type != source type',
                  );
                  withDoc.update(m.sourceType, (n) => n + 1, ifAbsent: () => 1);
                }
              }
            }
          }
          final types = seen.keys.toList()..sort();
          return '$pairs pairs; types ${[for (final t in types) '$t×${seen[t]} (doc ${withDoc[t] ?? 0})'].join(', ')}'
              '${unlabelled.isEmpty ? '' : '; fallback for $unlabelled'}';
        });
      }

      // ---- R12 ----------------------------------------------------------
      await step('products: status omitted returns inactive stockable '
          '(R12)', () async {
        final inactive = await products.list(
          stockable: true,
          status: EntityStatus.inactive,
          limit: 5,
        );
        if (inactive.items.isEmpty) {
          return 'SKIPPED: the tenant has no inactive stockable product';
        }
        final target = inactive.items.first;
        final all = await products.list(
          search: target.code,
          stockable: true,
          limit: 50,
        );
        expect(
          all.items.any((i) => i.productId == target.productId),
          isTrue,
          reason: 'inactive P${target.productId} absent when status omitted',
        );
        return 'P${target.productId} "${target.code}" found '
            '(${inactive.total} inactive stockable)';
      });

      // ---- Report -------------------------------------------------------
      final out = StringBuffer('\n== Existencias and Kardex live run ==\n');
      for (final s in steps) {
        out.writeln(
          '${s.ok ? 'PASS' : 'FAIL'}  ${s.name}'
          '${s.detail.isEmpty ? '' : '  [${s.detail.split('\n').first}]'}',
        );
      }
      // ignore: avoid_print
      print(out);
      final failed = steps.where((s) => !s.ok).toList();
      expect(
        failed,
        isEmpty,
        reason: [
          for (final f in failed) '${f.name}: ${f.detail}',
        ].join('\n---\n'),
      );
    },
    skip: _canRun ? null : 'needs --dart-define=MBE_POS_USERNAME/PASSWORD',
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
