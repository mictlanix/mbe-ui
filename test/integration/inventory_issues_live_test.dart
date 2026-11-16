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
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';

/// Spec 068's repository calls against a live mbe-api (quickstart.md, task
/// T028): the Salidas de almacén list, its filters and an issue's detail,
/// and, with `MBE_WRITE=true`, the whole draft flow with a stock check before
/// and after (SC-002) and the insufficient-stock refusal (SC-003).
///
///   flutter test test/integration/inventory_issues_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env \
///     [--dart-define=MBE_WRITE=true]
///
/// `MBE_POS_*` is the administrator (the only account with rights on
/// InventoryIssues, 16; no seeded non-administrator has them, so the
/// non-administrator cases stay manual, research R9). Fixtures are
/// discovered at run time: an active stockable product (two, when the
/// warehouse has them) with available stock in a listed warehouse (mbe-api
/// never lists in-transit warehouses), and any issue with a supplier return
/// (skipped when none).
///
/// **Each write run leaves on the tenant:** cancelled drafts (the empty one,
/// the short-stock one, and the one flowing through confirm), of which the
/// flow one was confirmed first and then cancelled with its stock restored.
/// Run writes only against dev.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _canRun = _username != '' && _password != '';

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

void main() {
  late Dio dio;
  late InventoryIssueRepositoryImpl issues;
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
    issues = InventoryIssueRepositoryImpl(dio);
    warehouses = WarehouseRepositoryImpl(dio);
    products = ProductRepositoryImpl(dio);
    stock = api.StockApi(dio, appSerializers);
  });

  /// On-hand of [product] in [warehouse].
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
    'Salidas de almacén against a live mbe-api',
    () async {
      // ---- Read-only ----------------------------------------------------
      late InventoryIssuePage opening;
      await step('list opens, newest first', () async {
        opening = await issues.list(skip: 0, limit: 20);
        final dates = opening.items.map((r) => r.createdAt).toList();
        final sorted = [...dates]..sort((a, b) => b.compareTo(a));
        expect(dates, sorted, reason: 'not newest first');
        return '${opening.total} issues (administrator: all of them)';
      });

      await step('status filter: only that status', () async {
        for (final status in InventoryDocumentStatus.values) {
          final page = await issues.list(status: status, skip: 0, limit: 50);
          expect(page.items.every((r) => r.status == status), isTrue);
        }
        return null;
      });

      // Listed warehouses (in-transit ones are never listed).
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
        final page = await issues.list(warehouseId: w, skip: 0, limit: 50);
        expect(page.items.every((r) => r.warehouseId == w), isTrue);
        final both = await issues.list(
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

      await step('an issue\'s detail loads', () async {
        if (opening.items.isEmpty) return 'SKIPPED: the tenant has none';
        final first = opening.items.first;
        final detail = await issues.get(first.id);
        expect(detail.id, first.id);
        expect(detail.status, first.status);
        expect(detail.warehouseId, first.warehouseId);
        return '#${detail.id}: ${detail.lines.length} line(s)';
      });

      await step('discover a supplier-return issue', () async {
        final page = await issues.list(skip: 0, limit: 100);
        for (final row in page.items) {
          final detail = await issues.get(row.id);
          if (detail.supplierReturnId != null) {
            return '#${detail.id} (return ${detail.supplierReturnId})';
          }
        }
        return 'SKIPPED: none among the newest ${page.items.length}';
      });

      // ---- Writes -------------------------------------------------------
      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        final tag = 'QA068 ${DateTime.now().millisecondsSinceEpoch % 100000}';
        late int w;
        late int p1;
        int? p2;
        late Decimal available1;

        await step(
          'fixtures: stocked products in a listed warehouse',
          () async {
            for (final candidate in listed) {
              final rows = <({int product, Decimal available})>[];
              for (var skip = 0; ; skip += 100) {
                final page = (await stock.listStockApiV1StockGet(
                  warehouse: candidate,
                  skip: skip,
                  limit: 100,
                )).data!;
                for (final r in page.items) {
                  final available = Decimal.parse(r.available);
                  if (available >= Decimal.fromInt(5)) {
                    rows.add((product: r.product, available: available));
                  }
                }
                if (page.items.length < 100 || rows.length >= 20) break;
              }
              final ok = <({int product, Decimal available})>[];
              for (final r in rows) {
                final p = await products.get(productId: r.product);
                if (p.stockable && p.status.name == 'active') ok.add(r);
                if (ok.length == 2) break;
              }
              if (ok.isEmpty) continue;
              w = candidate;
              p1 = ok[0].product;
              available1 = ok[0].available;
              p2 = ok.length > 1 ? ok[1].product : null;
              return 'W$w, P1 $p1 (available $available1), P2 $p2';
            }
            fail(
              'no active stockable product with stock >= 5 in any warehouse',
            );
          },
        );

        // The write steps depend on the fixtures; stop here when missing.
        if (steps.last.ok) {
          InventoryIssue? draft;
          await step('create a draft with notes', () async {
            draft = await issues.create(warehouseId: w, comment: tag);
            expect(draft!.status, InventoryDocumentStatus.draft);
            expect(draft!.serial, isNull);
            expect(draft!.comment, tag);
            expect(draft!.warehouseId, w);
            return '#${draft!.id}';
          });

          if (draft != null) {
            final id = draft!.id;
            late Decimal before;

            await step('header: clear the notes, set them again', () async {
              final cleared = await issues.updateHeader(id, clearComment: true);
              expect(cleared.comment, isNull);
              expect((await issues.get(id)).comment, isNull);
              await issues.updateHeader(id, comment: '$tag again');
              expect((await issues.get(id)).comment, '$tag again');
              return null;
            });

            await step('header: change the warehouse and back', () async {
              final other = listed.where((x) => x != w).firstOrNull;
              if (other == null) return 'SKIPPED: only one warehouse listed';
              final moved = await issues.updateHeader(id, warehouseId: other);
              expect(moved.warehouseId, other);
              final back = await issues.updateHeader(id, warehouseId: w);
              expect(back.warehouseId, w);
              return 'W$w → W$other → W$w';
            });

            await step('add P1 × 2 then × 1: one line of 3', () async {
              await issues.addLine(
                id,
                productId: p1,
                quantity: Decimal.fromInt(2),
              );
              final r = await issues.addLine(
                id,
                productId: p1,
                quantity: Decimal.one,
              );
              final lines = r.lines.where((l) => l.productId == p1);
              expect(lines, hasLength(1));
              expect(lines.single.quantity, Decimal.fromInt(3));
              return null;
            });

            await step('edit the P1 line to 2', () async {
              final r0 = await issues.get(id);
              final line = r0.lines.singleWhere((l) => l.productId == p1);
              final r = await issues.updateLine(
                id,
                line.id,
                quantity: Decimal.fromInt(2),
              );
              expect(
                r.lines.singleWhere((l) => l.id == line.id).quantity,
                Decimal.fromInt(2),
              );
              return null;
            });

            if (p2 == null) {
              skipped('add P2 × 1, remove it', 'only one stocked product');
            } else {
              await step('add P2 × 1, remove it', () async {
                var r = await issues.addLine(
                  id,
                  productId: p2!,
                  quantity: Decimal.one,
                );
                final line = r.lines.singleWhere((l) => l.productId == p2);
                r = await issues.removeLine(id, line.id);
                expect(r.lines.map((l) => l.productId), [p1]);
                return null;
              });
            }

            await step(
              'confirm: folio assigned and P1 stock -2 (SC-002)',
              () async {
                before = await onHand(p1, w);
                final r = await issues.confirm(id);
                expect(r.status, InventoryDocumentStatus.completed);
                expect(r.serial, isNotNull);
                final after = await onHand(p1, w);
                expect(after, before - Decimal.fromInt(2));
                return 'folio ${r.serial}; on hand $before → $after';
              },
            );

            await step('cancel the confirmed issue: stock restored', () async {
              final r = await issues.cancel(id);
              expect(r.status, InventoryDocumentStatus.cancelled);
              expect(await onHand(p1, w), before);
              return null;
            });
          }

          await step(
            'confirm an empty draft is refused; cancel the draft',
            () async {
              final empty = await issues.create(warehouseId: w, comment: tag);
              try {
                await issues.confirm(empty.id);
                fail('an empty draft was confirmed');
              } on AppError catch (e) {
                expect(_code(e), 'inventory_document.no_lines');
              }
              final r = await issues.cancel(empty.id);
              expect(r.status, InventoryDocumentStatus.cancelled);
              return '#${empty.id} cancelled';
            },
          );

          await step(
            'confirm refused for insufficient stock (SC-003)',
            () async {
              final r = await issues.create(warehouseId: w, comment: tag);
              try {
                await issues.addLine(
                  r.id,
                  productId: p1,
                  quantity: available1 + Decimal.one,
                );
                try {
                  await issues.confirm(r.id);
                  fail('the confirm went through');
                } on AppError catch (e) {
                  expect(_code(e), 'inventory_document.insufficient_stock');
                  expect(e.problem!.params['product_id'], p1);
                }
                expect(
                  (await issues.get(r.id)).status,
                  InventoryDocumentStatus.draft,
                );
                return '#${r.id} (product $p1, ${available1 + Decimal.one} > '
                    '$available1) stays Borrador';
              } finally {
                await issues.cancel(r.id);
              }
            },
          );
        }
      }

      // ---- Report -------------------------------------------------------
      final out = StringBuffer('\n== Salidas de almacén live run ==\n');
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
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
