import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

/// Spec 070's repository calls against a live mbe-api (quickstart.md, task
/// T031): the Conteos físicos list, its filters and a count's detail, and,
/// with `MBE_WRITE=true`, the draft flow (lines by id and by code, replace,
/// edit, remove, header), blind drafts (SC-003), the refused batch, confirm
/// with the stock check (SC-002), `include_uncounted`, both warnings, cancel
/// and the empty-draft refusal.
///
///   flutter test test/integration/inventory_counts_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env \
///     [--dart-define=MBE_WRITE=true]
///
/// Accounts: `MBE_POS_*` (from `.env`) is the administrator, the only seeded
/// account with rights on PhysicalCountAdjustment (74). No seeded
/// non-administrator has them, so the non-administrator cases (facility
/// scope of the warehouse picker, the other-facility refusal) stay manual
/// (quickstart step 14).
///
/// Fixtures are discovered at run time with `StockApi`: the listed warehouse
/// (mbe-api never lists in-transit ones) with the fewest stock rows that
/// holds at least two active stockable products, has no negative on hand,
/// and has at most [_maxRows] rows (`include_uncounted` zeroes every one of
/// them, and the run must put each back); a non-stockable product; and a
/// product reserved by an open sales order (the reservation warning is
/// skipped when none is found; this test never creates sales orders).
///
/// **Each write run leaves on the tenant:** confirmed counts and cancelled
/// drafts tagged "QA070 …", with the stock of every product it counted put
/// back to its original on hand by a final count. Run writes only against
/// dev.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _canRun = _username != '' && _password != '';

/// The most stock rows the counted warehouse may have (see above).
const _maxRows = 25;

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

Decimal _d(int value) => Decimal.fromInt(value);

void main() {
  late Dio dio;
  late InventoryCountRepositoryImpl counts;
  late WarehouseRepositoryImpl warehouses;
  late ProductRepositoryImpl products;
  late api.StockApi stock;
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
    counts = InventoryCountRepositoryImpl(dio);
    warehouses = WarehouseRepositoryImpl(dio);
    products = ProductRepositoryImpl(dio);
    stock = api.StockApi(dio, appSerializers);
  });

  /// Every stock row of [warehouse] (non-zero on hand, as the server lists).
  Future<List<api.StockRow>> stockRows(int warehouse) async {
    final rows = <api.StockRow>[];
    for (var skip = 0; ; skip += 100) {
      final page = (await stock.listStockApiV1StockGet(
        warehouse: warehouse,
        skip: skip,
        limit: 100,
      )).data!;
      rows.addAll(page.items);
      if (page.items.length < 100) break;
    }
    return rows;
  }

  /// On hand per product in [warehouse].
  Future<Map<int, Decimal>> onHandOf(int warehouse) async => {
    for (final r in await stockRows(warehouse))
      r.product: Decimal.parse(r.onHand),
  };

  /// On hand of [product] in [warehouse].
  Future<Decimal> onHand(int product, int warehouse) async {
    final s = (await stock.getProductStockApiV1StockProductsProductGet(
      product: product,
    )).data!;
    final row = s.warehouses
        ?.where((w) => w.warehouse == warehouse)
        .firstOrNull;
    return row == null ? Decimal.zero : Decimal.parse(row.onHand);
  }

  test(
    'Conteos físicos against a live mbe-api',
    () async {
      // ---- Read-only ----------------------------------------------------
      late InventoryCountPage opening;
      await step('list opens, newest first', () async {
        opening = await counts.list(skip: 0, limit: 20);
        final dates = opening.items.map((r) => r.createdAt).toList();
        final sorted = [...dates]..sort((a, b) => b.compareTo(a));
        expect(dates, sorted, reason: 'not newest first');
        return '${opening.total} counts (administrator: all of them)';
      });

      await step('status filter: only that status', () async {
        for (final status in InventoryDocumentStatus.values) {
          final page = await counts.list(status: status, skip: 0, limit: 50);
          expect(page.items.every((r) => r.status == status), isTrue);
        }
        return null;
      });

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

      await step('warehouse filter: only that warehouse', () async {
        final w = opening.items.isEmpty
            ? listed.first
            : opening.items.first.warehouseId;
        final page = await counts.list(warehouseId: w, skip: 0, limit: 50);
        expect(page.items.every((r) => r.warehouseId == w), isTrue);
        final both = await counts.list(
          status: InventoryDocumentStatus.completed,
          warehouseId: w,
          skip: 0,
          limit: 50,
        );
        expect(
          both.items.every(
            (r) =>
                r.warehouseId == w &&
                r.status == InventoryDocumentStatus.completed,
          ),
          isTrue,
        );
        return '${page.total} in W$w, ${both.total} confirmed';
      });

      await step('a count\'s detail loads', () async {
        if (opening.items.isEmpty) return 'SKIPPED: the tenant has none';
        final first = opening.items.first;
        final detail = await counts.get(first.id);
        expect(detail.id, first.id);
        expect(detail.status, first.status);
        expect(detail.warehouseId, first.warehouseId);
        if (detail.isCompleted) {
          expect(detail.serial, isNotNull);
          expect(detail.lines.every((l) => l.quantityOnHand != null), isTrue);
        }
        return '#${detail.id}: ${detail.lines.length} line(s)';
      });

      await step('an existing draft is blind (SC-003)', () async {
        final drafts = await counts.list(
          status: InventoryDocumentStatus.draft,
          skip: 0,
          limit: 1,
        );
        if (drafts.items.isEmpty) return 'SKIPPED: no draft on the tenant';
        final d = await counts.get(drafts.items.first.id);
        expect(d.lines.every((l) => l.quantityOnHand == null), isTrue);
        expect(d.lines.every((l) => l.difference == null), isTrue);
        return '#${d.id}: ${d.lines.length} line(s)';
      });

      // ---- Writes -------------------------------------------------------
      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        final tag = 'QA070 ${DateTime.now().millisecondsSinceEpoch % 100000}';
        late int w;
        late int p1;
        late String p1Code;
        late int p2;
        late String p2Code;
        // The counted warehouse's on hand before any write: what the final
        // count puts back.
        late Map<int, Decimal> original;
        int? nonStockable;
        // Drafts this run created; any left as drafts are cancelled at the end.
        final created = <int>[];

        await step(
          'fixtures: a small warehouse with two stocked products',
          () async {
            final sized = <({int warehouse, int total})>[];
            for (final candidate in listed) {
              final page = (await stock.listStockApiV1StockGet(
                warehouse: candidate,
                limit: 1,
              )).data!;
              if (page.total >= 2 && page.total <= _maxRows) {
                sized.add((warehouse: candidate, total: page.total));
              }
            }
            sized.sort((a, b) => a.total.compareTo(b.total));
            for (final c in sized) {
              final rows = await stockRows(c.warehouse);
              if (rows.any((r) => Decimal.parse(r.onHand) < Decimal.zero)) {
                continue;
              }
              final ok = <(int, String)>[];
              for (final r in rows) {
                final p = await products.get(productId: r.product);
                if (p.stockable && p.status.name == 'active') {
                  ok.add((p.productId, p.code));
                }
                if (ok.length == 2) break;
              }
              if (ok.length < 2) continue;
              w = c.warehouse;
              (p1, p1Code) = ok[0];
              (p2, p2Code) = ok[1];
              original = {
                for (final r in rows) r.product: Decimal.parse(r.onHand),
              };
              final ns = await products.list(
                stockable: false,
                status: EntityStatus.active,
                limit: 1,
              );
              nonStockable = ns.items.firstOrNull?.productId;
              return 'W$w (${rows.length} rows), P1 $p1 "$p1Code" '
                  '(${original[p1]}), P2 $p2 "$p2Code" (${original[p2]}), '
                  'non-stockable $nonStockable; original on hand $original';
            }
            fail(
              'no listed warehouse with 2–$_maxRows stock rows, none negative, '
              'and two active stockable products',
            );
          },
        );

        // The write steps depend on the fixtures; stop here when missing.
        if (steps.last.ok) {
          final o1 = original[p1]!;
          final o2 = original[p2]!;
          InventoryCount? uncounted;
          try {
            InventoryCount? draft;
            await step('create a draft with notes', () async {
              draft = await counts.create(warehouseId: w, comment: tag);
              created.add(draft!.id);
              expect(draft!.status, InventoryDocumentStatus.draft);
              expect(draft!.serial, isNull);
              expect(draft!.comment, tag);
              expect(draft!.warehouseId, w);
              expect(draft!.lines, isEmpty);
              return '#${draft!.id}';
            });

            if (draft != null) {
              final id = draft!.id;

              await step('header: clear the notes, set them again', () async {
                final cleared = await counts.updateHeader(id);
                expect(cleared.comment, isNull);
                expect((await counts.get(id)).comment, isNull);
                await counts.updateHeader(id, comment: '$tag again');
                expect((await counts.get(id)).comment, '$tag again');
                return null;
              });

              await step('header: change the warehouse and back', () async {
                final other = listed.where((x) => x != w).firstOrNull;
                if (other == null) return 'SKIPPED: only one warehouse listed';
                final moved = await counts.updateHeader(
                  id,
                  warehouseId: other,
                  comment: tag,
                );
                expect(moved.warehouseId, other);
                final back = await counts.updateHeader(
                  id,
                  warehouseId: w,
                  comment: tag,
                );
                expect(back.warehouseId, w);
                return 'W$w → W$other → W$w';
              });

              await step(
                'set lines by id and by code; blind (SC-003)',
                () async {
                  final r = await counts.setLines(id, [
                    CountLineInput.byProduct(
                      productId: p1,
                      quantity: o1 + _d(1),
                    ),
                    CountLineInput.byCode(code: p2Code, quantity: o2),
                  ]);
                  expect(
                    r.lines.map((l) => l.productId),
                    unorderedEquals([p1, p2]),
                  );
                  expect(
                    r.lines.every((l) => l.quantityOnHand == null),
                    isTrue,
                  );
                  expect(r.lines.every((l) => l.difference == null), isTrue);
                  expect(r.lineCount, 2);
                  final again = await counts.get(id);
                  expect(
                    again.lines.every((l) => l.quantityOnHand == null),
                    isTrue,
                  );
                  expect(
                    again.lines.every((l) => l.difference == null),
                    isTrue,
                  );
                  return null;
                },
              );

              await step('set P1 again: its one line is replaced', () async {
                final r = await counts.setLines(id, [
                  CountLineInput.byCode(code: p1Code, quantity: o1 + _d(2)),
                ]);
                final lines = r.lines.where((l) => l.productId == p1);
                expect(lines, hasLength(1));
                expect(lines.single.quantity, o1 + _d(2));
                // Only the line the write set comes back (mbe-api#333).
                expect(r.lines, hasLength(1));
                expect(r.lineCount, 2);
                return null;
              });

              await step(
                'edit the P1 line; remove P2 and set it back',
                () async {
                  final r0 = await counts.get(id);
                  final line = r0.lines.singleWhere((l) => l.productId == p1);
                  var r = await counts.updateLine(
                    id,
                    line.id,
                    quantity: o1 + _d(3),
                  );
                  expect(
                    r.lines.singleWhere((l) => l.id == line.id).quantity,
                    o1 + _d(3),
                  );
                  expect(r.lines, hasLength(1));
                  expect(r.lineCount, 2);
                  final l2 = r0.lines.singleWhere((l) => l.productId == p2);
                  r = await counts.removeLine(id, l2.id);
                  expect(r.lines, isEmpty);
                  expect(r.removedLineId, l2.id);
                  expect(r.lineCount, 1);
                  r = await counts.setLines(id, [
                    CountLineInput.byProduct(productId: p2, quantity: o2),
                  ]);
                  expect(r.lines.map((l) => l.productId), [p2]);
                  expect(r.lineCount, 2);
                  final after = await counts.get(id);
                  expect(
                    after.lines.map((l) => l.productId),
                    unorderedEquals([p1, p2]),
                  );
                  return null;
                },
              );

              await step(
                'a bad batch is refused whole (batch_invalid)',
                () async {
                  final unknown = 'NOEXISTE-070-$tag';
                  final items = [
                    CountLineInput.byProduct(productId: p1, quantity: _d(99)),
                    CountLineInput.byCode(code: unknown, quantity: _d(1)),
                    if (nonStockable != null)
                      CountLineInput.byProduct(
                        productId: nonStockable!,
                        quantity: _d(1),
                      ),
                    CountLineInput.byCode(code: p1Code, quantity: _d(98)),
                  ];
                  try {
                    await counts.setLines(id, items);
                    fail('the batch was applied');
                  } on AppError catch (e) {
                    expect(_code(e), 'inventory_count.batch_invalid');
                    final parts = {
                      for (final p in e.problem!.parts)
                        p.extra['index']: p.codeName,
                    };
                    expect(parts, {
                      1: 'inventory_count_line.product_unknown',
                      if (nonStockable != null)
                        2: 'inventory_count_line.not_stockable',
                      items.length - 1: 'inventory_count_line.repeated',
                    });
                  }
                  final r = await counts.get(id);
                  expect(r.lines, hasLength(2));
                  expect(
                    r.lines.singleWhere((l) => l.productId == p1).quantity,
                    o1 + _d(3),
                  );
                  return nonStockable == null
                      ? 'no non-stockable product: unknown + repeated only'
                      : null;
                },
              );

              await step(
                'confirm: stock = counted (SC-002), zero difference posts nothing',
                () async {
                  final r = await counts.confirm(id, includeUncounted: false);
                  expect(r.count.status, InventoryDocumentStatus.completed);
                  expect(r.count.serial, isNotNull);
                  final l1 = r.count.lines.singleWhere(
                    (l) => l.productId == p1,
                  );
                  final l2 = r.count.lines.singleWhere(
                    (l) => l.productId == p2,
                  );
                  expect(l1.quantityOnHand, o1);
                  expect(l1.difference, _d(3));
                  expect(l2.quantityOnHand, o2);
                  expect(l2.difference, Decimal.zero);
                  final a1 = await onHand(p1, w);
                  final a2 = await onHand(p2, w);
                  expect(a1, o1 + _d(3));
                  expect(a2, o2);
                  return 'folio ${r.count.serial}; P1 $o1 → $a1, P2 $o2 → $a2';
                },
              );

              await step('cancel a confirmed count: 409', () async {
                try {
                  await counts.cancel(id);
                  fail('a confirmed count was cancelled');
                } on AppError catch (e) {
                  expect(_code(e), 'inventory_count.confirmed_cannot_cancel');
                }
                expect((await counts.get(id)).isCompleted, isTrue);
                return null;
              });
            }

            await step(
              'confirm an empty draft is refused; cancel it',
              () async {
                final empty = await counts.create(warehouseId: w, comment: tag);
                created.add(empty.id);
                try {
                  await counts.confirm(empty.id, includeUncounted: false);
                  fail('an empty draft was confirmed');
                } on AppError catch (e) {
                  expect(_code(e), 'inventory_document.no_lines');
                }
                expect((await counts.get(empty.id)).isDraft, isTrue);
                final r = await counts.cancel(empty.id);
                expect(r.status, InventoryDocumentStatus.cancelled);
                expect(r.serial, isNull);
                return '#${empty.id} cancelled';
              },
            );

            await step(
              'two counts of one warehouse: A names B in correctedByOtherCounts',
              () async {
                final a = await counts.create(
                  warehouseId: w,
                  comment: '$tag A',
                );
                created.add(a.id);
                final b = await counts.create(
                  warehouseId: w,
                  comment: '$tag B',
                );
                created.add(b.id);
                await counts.setLines(a.id, [
                  CountLineInput.byProduct(productId: p1, quantity: o1 + _d(5)),
                ]);
                await counts.setLines(b.id, [
                  CountLineInput.byProduct(productId: p1, quantity: o1 + _d(2)),
                ]);
                final rb = await counts.confirm(b.id, includeUncounted: false);
                final ra = await counts.confirm(a.id, includeUncounted: false);
                expect(
                  ra.warnings.correctedByOtherCounts.where(
                    (c) =>
                        c.productId == p1 &&
                        c.otherCountId == b.id &&
                        c.otherCountSerial == rb.count.serial,
                  ),
                  hasLength(1),
                );
                expect(await onHand(p1, w), o1 + _d(5));
                return 'A #${a.id} (folio ${ra.count.serial}) names B #${b.id} '
                    '(folio ${rb.count.serial}) for P1';
              },
            );

            await step('include_uncounted adds 0-quantity lines', () async {
              final u = await counts.create(warehouseId: w, comment: '$tag U');
              created.add(u.id);
              await counts.setLines(u.id, [
                CountLineInput.byProduct(productId: p1, quantity: o1),
              ]);
              final r = await counts.confirm(u.id, includeUncounted: true);
              uncounted = r.count;
              final added = r.count.lines
                  .where((l) => l.productId != p1)
                  .toList();
              expect(added.every((l) => l.quantity == Decimal.zero), isTrue);
              // Every other stocked product of the warehouse got a line (a
              // non-stockable one would not, and the fixture's rows are all
              // stocked products).
              expect(added.map((l) => l.productId), contains(p2));
              final after = await onHandOf(w);
              expect(after.keys, [p1], reason: 'only P1 keeps stock');
              expect(after[p1], o1);
              return '#${u.id}: ${added.length} line(s) added at 0';
            });

            // ---- Reservation warning (its own warehouse, put back) --------
            await step('a product counted below its reservation', () async {
              ({int warehouse, int product, Decimal onHand, Decimal reserved})?
              found;
              final sized = <({int warehouse, int total})>[];
              for (final candidate in listed) {
                final page = (await stock.listStockApiV1StockGet(
                  warehouse: candidate,
                  limit: 1,
                )).data!;
                if (page.total > 0 && page.total <= 1000) {
                  sized.add((warehouse: candidate, total: page.total));
                }
              }
              sized.sort((a, b) => a.total.compareTo(b.total));
              outer:
              for (final c in sized) {
                for (final r in await stockRows(c.warehouse)) {
                  final held = Decimal.parse(r.reserved);
                  final have = Decimal.parse(r.onHand);
                  if (held > Decimal.zero && have >= Decimal.zero) {
                    final p = await products.get(productId: r.product);
                    if (!p.stockable) continue;
                    found = (
                      warehouse: c.warehouse,
                      product: r.product,
                      onHand: have,
                      reserved: held,
                    );
                    break outer;
                  }
                }
              }
              if (found == null) {
                return 'SKIPPED: no product reserved by an open sales order '
                    'in a listed warehouse of up to 1,000 stock rows';
              }
              final f = found;
              final c = await counts.create(
                warehouseId: f.warehouse,
                comment: '$tag R',
              );
              created.add(c.id);
              String note;
              try {
                await counts.setLines(c.id, [
                  CountLineInput.byProduct(
                    productId: f.product,
                    quantity: Decimal.zero,
                  ),
                ]);
                final r = await counts.confirm(c.id, includeUncounted: false);
                final n = r.warnings.negativeAvailable.singleWhere(
                  (x) => x.productId == f.product,
                );
                expect(n.counted, Decimal.zero);
                expect(n.reserved, f.reserved);
                expect(n.available, -f.reserved);
                note =
                    'W${f.warehouse} P${f.product}: counted 0, reserved '
                    '${f.reserved}';
              } finally {
                // Put it back: a final count at its original on hand.
                final back = await counts.create(
                  warehouseId: f.warehouse,
                  comment: '$tag R restore',
                );
                created.add(back.id);
                await counts.setLines(back.id, [
                  CountLineInput.byProduct(
                    productId: f.product,
                    quantity: f.onHand,
                  ),
                ]);
                await counts.confirm(back.id, includeUncounted: false);
              }
              final now = await onHand(f.product, f.warehouse);
              expect(now, f.onHand);
              return '$note; on hand ${f.onHand} → 0 → $now';
            });
          } finally {
            // ---- Restore the counted warehouse ------------------------------
            await step('a final count restores the original on hand', () async {
              final target = <int, Decimal>{
                p1: o1,
                p2: o2,
                for (final l in uncounted?.lines ?? <InventoryCountLine>[])
                  l.productId: original[l.productId] ?? l.quantityOnHand!,
              };
              final f = await counts.create(
                warehouseId: w,
                comment: '$tag restore',
              );
              created.add(f.id);
              await counts.setLines(f.id, [
                for (final e in target.entries)
                  CountLineInput.byProduct(productId: e.key, quantity: e.value),
              ]);
              await counts.confirm(f.id, includeUncounted: false);
              final after = await onHandOf(w);
              expect(after, original);
              return 'W$w before $original, after $after';
            });

            await step('cancel the drafts this run left', () async {
              final left = <int>[];
              for (final id in created) {
                if ((await counts.get(id)).isDraft) {
                  await counts.cancel(id);
                  left.add(id);
                }
              }
              return left.isEmpty ? 'none left' : 'cancelled $left';
            });
          }
        }
      }

      // ---- Report -------------------------------------------------------
      final out = StringBuffer('\n== Conteos físicos live run ==\n');
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
