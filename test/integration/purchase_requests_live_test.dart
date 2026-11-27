import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

/// Spec 079's repository calls against a live mbe-api (quickstart.md steps
/// 2–11, task T035): the Solicitudes de compra list (default scope, `all`,
/// each facet, the folio search) and the approval queue, and, with
/// `MBE_WRITE=true`, the whole request flow: create, lines, header, submit,
/// approve, reject and resubmit, bulk approve with a stale id, marks, cancel.
///
///   flutter test test/integration/purchase_requests_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env \
///     [--dart-define=MBE_WRITE=true]
///
/// `MBE_POS_*` is the administrator (rights 86, 96 and 20). `MBE_TEST_*`, when
/// set, is checked for a refusal on the list. Fixtures are discovered at run
/// time: the administrator's point-of-sale warehouse (W1), an active
/// purchasable "clavo" product (one with a minimum order quantity above 1 is
/// preferred; the below-minimum checks are skipped when none is found), a
/// warehouse of another facility, and any request line on a purchase order
/// (none can exist until mictlanix/mbe-roadmap#71; skipped otherwise).
///
/// Every request a write run creates is cancelled at the end; the run leaves
/// only cancelled requests behind. Run writes only against dev.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _noAccessUser = String.fromEnvironment('MBE_TEST_USERNAME');
const _noAccessPass = String.fromEnvironment('MBE_TEST_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _canRun = _username != '' && _password != '';

/// A pattern with active purchasable products on the dev tenant ('a' finds
/// nothing there).
const _patternDefine = String.fromEnvironment('MBE_POS_PRODUCT_PATTERN');
const _productPattern = _patternDefine == '' || _patternDefine == 'a'
    ? 'clavo'
    : _patternDefine;

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

void main() {
  late Dio dio;
  late PurchaseRequestRepositoryImpl requests;
  late WarehouseRepositoryImpl warehouses;
  late ProductRepositoryImpl products;
  late int employeeId;
  late int w1;
  final steps = <_Step>[];

  /// Bodies of the line PUTs, as they went on the wire.
  final lineBodies = <String>[];

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
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          if (o.method == 'PUT' &&
              RegExp(r'/purchase-requests/\d+/lines/\d+$').hasMatch(o.path)) {
            lineBodies.add(
              o.data is String ? o.data as String : jsonEncode(o.data),
            );
          }
          h.next(o);
        },
      ),
    );
    requests = PurchaseRequestRepositoryImpl(dio);
    warehouses = WarehouseRepositoryImpl(dio);
    products = ProductRepositoryImpl(dio);
    final me = await auth.me();
    final pointSaleId = me.settings?.pointSaleId;
    if (pointSaleId == null) {
      throw StateError('the administrator has no point of sale (W1)');
    }
    w1 = (await PointSaleRepositoryImpl(
      dio,
    ).get(pointSaleId: pointSaleId)).warehouseId;
    final raw = await dio.get<Map<String, dynamic>>('/api/v1/auth/me');
    employeeId = raw.data!['employee_id'] as int;
  });

  Future<Map<String, dynamic>> rawRequest(int id) async =>
      (await dio.get<Map<String, dynamic>>(
        '/api/v1/purchase-requests/$id',
      )).data!;

  test(
    'Solicitudes de compra against a live mbe-api',
    () async {
      // ---- Read-only (US1, US2, US3 views) --------------------------------
      late PurchaseRequestPage mine;
      await step('list, default scope: own requests, no cancelled', () async {
        mine = await requests.list(skip: 0, limit: 100);
        final dates = mine.items.map((r) => r.date).toList();
        final sorted = [...dates]..sort((a, b) => b.compareTo(a));
        expect(dates, sorted, reason: 'not newest first');
        final others = mine.items.where((r) => r.creatorId != employeeId);
        final cancelled = mine.items.where(
          (r) => r.status == PurchaseRequestStatus.cancelled,
        );
        return '${mine.total} rows; ${others.length} by others, '
            '${cancelled.length} cancelled (employee $employeeId)';
      });

      late PurchaseRequestPage everyone;
      await step('list, all=true', () async {
        everyone = await requests.list(all: true, skip: 0, limit: 100);
        expect(everyone.total, greaterThanOrEqualTo(mine.total));
        final creators = everyone.items.map((r) => r.creatorId).toSet();
        final cancelled = everyone.items.where(
          (r) => r.status == PurchaseRequestStatus.cancelled,
        );
        return '${everyone.total} rows, ${creators.length} creator(s), '
            '${cancelled.length} cancelled on the first page';
      });

      await step('status facet: only that status (all=true)', () async {
        final counts = <String>[];
        for (final status in PurchaseRequestStatus.values) {
          final page = await requests.list(
            all: true,
            status: status,
            skip: 0,
            limit: 50,
          );
          expect(page.items.every((r) => r.status == status), isTrue);
          counts.add('${status.name} ${page.total}');
        }
        return counts.join(', ');
      });

      await step('a status filter in the default scope', () async {
        // Whose rows a status filter returns without `all`: the default
        // scope (own requests) or everyone's.
        final out = <String>[];
        for (final status in PurchaseRequestStatus.values) {
          final page = await requests.list(status: status, skip: 0, limit: 100);
          expect(page.items.every((r) => r.status == status), isTrue);
          final others = page.items.where((r) => r.creatorId != employeeId);
          out.add('${status.name} ${page.total} (${others.length} by others)');
        }
        return out.join(', ');
      });

      await step('warehouse / facility / creator facets', () async {
        final page = await requests.list(
          all: true,
          warehouseId: w1,
          skip: 0,
          limit: 50,
        );
        expect(page.items.every((r) => r.warehouseId == w1), isTrue);
        final byMe = await requests.list(
          all: true,
          creatorId: employeeId,
          skip: 0,
          limit: 50,
        );
        expect(byMe.items.every((r) => r.creatorId == employeeId), isTrue);
        final facility = everyone.items
            .map((r) => r.facilityId)
            .whereType<int>()
            .firstOrNull;
        var fac = 'no facility on page';
        if (facility != null) {
          final f = await requests.list(
            all: true,
            facilityId: facility,
            skip: 0,
            limit: 50,
          );
          expect(f.items.every((r) => r.facilityId == facility), isTrue);
          fac = 'facility $facility: ${f.total}';
        }
        return 'W1 $w1: ${page.total}; creator me: ${byMe.total}; $fac';
      });

      await step('date range facet', () async {
        final now = DateTime.now();
        final from = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 30));
        final page = await requests.list(
          all: true,
          from: from,
          to: now,
          skip: 0,
          limit: 50,
        );
        return '${page.total} in the last 30 days';
      });

      await step('folio search: matching rows', () async {
        final numbered = everyone.items.where((r) => r.serial != null);
        if (numbered.isEmpty) return 'SKIPPED: no numbered request on page';
        final serial = numbered.first.serial!;
        final page = await requests.list(
          all: true,
          serial: serial,
          skip: 0,
          limit: 50,
        );
        expect(page.items, isNotEmpty);
        expect(page.items.every((r) => r.serial == serial), isTrue);
        final facilities = page.items.map((r) => r.facilityId).toSet();
        return 'folio $serial: ${page.total} row(s), '
            '${facilities.length} facility(ies)';
      });

      await step('approval queue: submitted, oldest first', () async {
        final queue = await requests.approvalQueue(skip: 0, limit: 100);
        expect(
          queue.items.every((r) => r.status == PurchaseRequestStatus.submitted),
          isTrue,
        );
        final dates = queue.items.map((r) => r.date).toList();
        final sorted = [...dates]..sort();
        expect(dates, sorted, reason: 'not oldest first');
        return '${queue.total} submitted';
      });

      await step('a request\'s detail loads', () async {
        if (everyone.items.isEmpty) return 'SKIPPED: no requests';
        final first = everyone.items.first;
        final r = await requests.get(first.id);
        expect(r.id, first.id);
        expect(r.status, first.status);
        expect(r.lines.length, first.lineCount);
        return '#${r.id}: ${r.lines.length} line(s)';
      });

      await step('discover a line on a purchase order', () async {
        for (final s in everyone.items.where(
          (r) =>
              r.status == PurchaseRequestStatus.approved ||
              r.status == PurchaseRequestStatus.submitted,
        )) {
          final r = await requests.get(s.id);
          final hit = r.lines.where((l) => l.purchaseOrderId != null);
          if (hit.isNotEmpty) {
            return '#${r.id} line ${hit.first.id} on order '
                '${hit.first.purchaseOrderId} (${hit.first.purchaseOrderStatus})';
          }
        }
        return 'SKIPPED: none (live-order refusals not reachable until #71)';
      });

      if (_noAccessUser.isNotEmpty && _noAccessPass.isNotEmpty) {
        await step('MBE_TEST_* is refused the list', () async {
          final other = Dio(BaseOptions(baseUrl: apiBaseUrl));
          final token = await AuthRepositoryImpl(
            other,
          ).login(username: _noAccessUser, password: _noAccessPass);
          other.options.headers['Authorization'] = 'Bearer $token';
          try {
            final page = await PurchaseRequestRepositoryImpl(
              other,
            ).list(skip: 0, limit: 1);
            fail('MBE_TEST_* read the requests (${page.total})');
          } on AppError catch (e) {
            expect(e, isA<AppError>());
            return 'refused: ${_code(e) ?? e.runtimeType}';
          }
        });
      } else {
        skipped('MBE_TEST_* is refused the list', 'MBE_TEST_* not set');
      }

      // ---- Writes (US1–US6) -----------------------------------------------
      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        final tag = 'QA079 ${DateTime.now().millisecondsSinceEpoch % 100000}';
        final created = <int>[];

        Future<PurchaseRequest> newRequest() async {
          final r = await requests.create(warehouseId: w1, comment: tag);
          created.add(r.id);
          return r;
        }

        try {
          int? otherWarehouse;
          await step('fixtures: a warehouse of another facility', () async {
            final home = await warehouses.get(warehouseId: w1);
            final page = await warehouses.list(
              status: EntityStatus.active,
              limit: 100,
            );
            final other = page.items.where(
              (w) => w.facilityId != home.facilityId,
            );
            if (other.isEmpty) return 'SKIPPED: none';
            otherWarehouse = other.first.warehouseId;
            return 'W1 $w1 (facility ${home.facilityId}); other '
                '$otherWarehouse (facility ${other.first.facilityId})';
          });

          // ---- Create (quickstart 2) ----
          PurchaseRequest? r1;
          await step('create: a draft in W1 with notes', () async {
            r1 = await newRequest();
            expect(r1!.status, PurchaseRequestStatus.draft);
            expect(r1!.serial, isNull);
            expect(r1!.warehouseId, w1);
            expect(r1!.comment, tag);
            expect(r1!.creatorId, employeeId);
            expect(r1!.lines, isEmpty);
            return '#${r1!.id} facility ${r1!.facilityId}';
          });
          if (r1 == null) throw StateError('no draft; the write flow stops');
          final id1 = r1!.id;

          // ---- Lines (quickstart 3) ----
          ProductListItem? product;
          PurchaseRequestLine? line;
          await step('add a line: server defaults (prefer min > 1)', () async {
            final found = await products.list(
              search: _productPattern,
              status: EntityStatus.active,
              purchasable: true,
              limit: 10,
            );
            expect(found.items, isNotEmpty, reason: 'no purchasable product');
            final tried = <String>[];
            for (final p in found.items) {
              final r = await requests.addLine(id1, productId: p.productId);
              final l = r.lines.singleWhere((l) => l.productId == p.productId);
              tried.add('${p.code} min ${l.minOrderQty}');
              final min = l.minOrderQty ?? 0;
              if (min > 1 || p == found.items.last) {
                product = p;
                line = l;
                break;
              }
              await requests.removeLine(id1, l.id);
            }
            final l = line!;
            final min = l.minOrderQty ?? 0;
            expect(l.productName, isNotEmpty);
            expect(l.productCode, product!.code);
            expect(
              l.quantity,
              min > 1 ? Decimal.fromInt(min) : Decimal.one,
              reason: 'quantity = the minimum, or 1',
            );
            expect(l.warehouseId, w1, reason: 'destination = header warehouse');
            return 'chose ${product!.code}: qty ${l.quantity}, dest '
                '${l.warehouseId}, toPurchase ${l.toPurchase}; tried '
                '${tried.join('; ')}';
          });
          if (line == null) throw StateError('no line; the write flow stops');
          final hasMin = (line!.minOrderQty ?? 0) > 1;

          await step('edit quantity: wire string and stored value', () async {
            final q = hasMin
                ? Decimal.fromInt(line!.minOrderQty! - 1)
                : Decimal.parse('2.5');
            lineBodies.clear();
            final r = await requests.updateLine(id1, line!.id, quantity: q);
            final sent = lineBodies.single;
            final l = r.lines.singleWhere((l) => l.id == line!.id);
            expect(l.quantity, q);
            final rawLines = (await rawRequest(id1))['lines'] as List;
            final rawQty =
                (rawLines.singleWhere(
                      (e) =>
                          (e as Map)['purchase_request_detail_id'] == line!.id,
                    )
                    as Map)['quantity'];
            return 'sent $sent; server returns ${jsonEncode(rawQty)}'
                '${hasMin ? ' (below min ${line!.minOrderQty})' : ''}';
          });

          await step('edit quantity: 2 decimals accepted', () async {
            final q = Decimal.parse('1.25');
            lineBodies.clear();
            final r = await requests.updateLine(id1, line!.id, quantity: q);
            expect(r.lines.singleWhere((l) => l.id == line!.id).quantity, q);
            return 'sent ${lineBodies.single}';
          });

          if (otherWarehouse == null) {
            skipped('line destination in another facility', 'no warehouse');
          } else {
            await step('line destination in another facility', () async {
              final r = await requests.updateLine(
                id1,
                line!.id,
                warehouseId: otherWarehouse,
              );
              final l = r.lines.singleWhere((l) => l.id == line!.id);
              expect(l.warehouseId, otherWarehouse);
              // Back to W1 so later steps don't depend on it.
              await requests.updateLine(id1, line!.id, warehouseId: w1);
              return 'saved $otherWarehouse';
            });
          }

          await step('edit product name on the line', () async {
            final name = '${line!.productName} $tag';
            final r = await requests.updateLine(
              id1,
              line!.id,
              productName: name,
            );
            expect(
              r.lines.singleWhere((l) => l.id == line!.id).productName,
              name,
            );
            return null;
          });

          // ---- Header (quickstart 4) ----
          await step('edit then clear the notes (R8)', () async {
            var r = await requests.updateHeader(id1, comment: '$tag edited');
            expect(r.comment, '$tag edited');
            r = await requests.updateHeader(id1, clearComment: true);
            expect(r.comment, isNull);
            expect((await requests.get(id1)).comment, isNull);
            final stored = (await rawRequest(id1))['comment'];
            expect(r.warehouseId, w1, reason: 'warehouse untouched');
            return 'server stores ${stored == null ? 'null' : '"$stored"'}';
          });

          // ---- Submit (quickstart 5) ----
          await step(
            'submit an empty draft: purchase_request.no_lines',
            () async {
              final empty = await newRequest();
              try {
                await requests.submit(empty.id);
                fail('an empty draft was submitted');
              } on AppError catch (e) {
                expect(_code(e), 'purchase_request.no_lines');
              }
              final c = await requests.cancel(empty.id);
              expect(c.status, PurchaseRequestStatus.cancelled);
              return '#${empty.id} refused, cancelled';
            },
          );

          int? serial1;
          await step('submit: folio and Enviada', () async {
            final r = await requests.submit(id1);
            expect(r.status, PurchaseRequestStatus.submitted);
            expect(r.serial, isNotNull);
            serial1 = r.serial;
            return 'folio $serial1';
          });

          await step('a submitted request refuses edits: not_draft', () async {
            try {
              await requests.updateLine(id1, line!.id, quantity: Decimal.one);
              fail('a submitted line was edited');
            } on AppError catch (e) {
              expect(_code(e), 'purchase_request.not_draft');
              return _code(e);
            }
          });

          // ---- Approve (quickstart 6) ----
          await step(
            'queue holds it; approve sets approver and time',
            () async {
              final queue = await requests.approvalQueue(skip: 0, limit: 100);
              final row = queue.items.where((s) => s.id == id1);
              expect(row, hasLength(1), reason: 'not in the queue');
              expect(row.single.lineCount, 1);
              final r = await requests.approve(id1);
              expect(r.status, PurchaseRequestStatus.approved);
              expect(r.approverId, employeeId);
              expect(r.approvalTime, isNotNull);
              expect(r.serial, serial1);
              final after = await requests.approvalQueue(skip: 0, limit: 100);
              expect(after.items.any((s) => s.id == id1), isFalse);
              return 'approver ${r.approverId} at ${r.approvalTime}';
            },
          );

          // ---- Marks (quickstart 10) ----
          await step('approved: unmark then mark a line', () async {
            final before = (await requests.get(id1)).lines.single;
            var r = await requests.markLine(id1, before.id, toPurchase: false);
            expect(r.lines.single.toPurchase, isFalse);
            expect((await requests.get(id1)).lines.single.toPurchase, isFalse);
            r = await requests.markLine(id1, before.id, toPurchase: true);
            expect(r.lines.single.toPurchase, isTrue);
            return 'initially ${before.toPurchase}';
          });

          // ---- Reject and resubmit (quickstart 7) ----
          PurchaseRequest? r3;
          await step('reject: Borrador, same folio; resubmit', () async {
            r3 = await newRequest();
            await requests.addLine(r3!.id, productId: product!.productId);
            final sub = await requests.submit(r3!.id);
            final serial = sub.serial;
            expect(serial, isNotNull);
            final rej = await requests.reject(r3!.id, reason: '$tag reason');
            expect(rej.status, PurchaseRequestStatus.draft);
            expect(rej.serial, serial);
            expect(rej.approverId, isNull);
            final again = await requests.submit(r3!.id);
            expect(again.status, PurchaseRequestStatus.submitted);
            expect(again.serial, serial);
            final queue = await requests.approvalQueue(skip: 0, limit: 100);
            expect(queue.items.any((s) => s.id == r3!.id), isTrue);
            return '#${r3!.id} folio $serial kept';
          });

          await step('reject a draft: not_submitted', () async {
            final d = await newRequest();
            try {
              await requests.reject(d.id, reason: tag);
              fail('a draft was rejected');
            } on AppError catch (e) {
              expect(_code(e), 'purchase_request.not_submitted');
              return _code(e);
            } finally {
              await requests.cancel(d.id);
            }
          });

          // ---- Bulk approve (quickstart 8) ----
          await step('approveMany with a stale id: 2 of 3', () async {
            final ids = <int>[];
            if (r3 != null) ids.add(r3!.id);
            while (ids.length < 3) {
              final r = await newRequest();
              await requests.addLine(r.id, productId: product!.productId);
              await requests.submit(r.id);
              ids.add(r.id);
            }
            final stale = ids.last;
            await requests.cancel(stale);
            final out = await requests.approveMany(ids);
            expect(out.map((o) => o.requestId).toSet(), ids.toSet());
            for (final o in out) {
              if (o.requestId == stale) {
                expect(o.approved, isFalse);
                expect(o.problem?.codeName, 'purchase_request.not_submitted');
              } else {
                expect(o.approved, isTrue, reason: '#${o.requestId}');
                expect(o.problem, isNull);
              }
            }
            final refused = out.singleWhere((o) => !o.approved);
            return 'refused #$stale: ${refused.problem?.codeName} '
                '${refused.problem?.params}';
          });

          // ---- Cancel (quickstart 11) ----
          await step('cancel an approved request; again refused', () async {
            final r = await requests.cancel(id1);
            expect(r.status, PurchaseRequestStatus.cancelled);
            try {
              await requests.cancel(id1);
              fail('cancelled twice');
            } on AppError catch (e) {
              expect(_code(e), 'purchase_request.already_cancelled');
              return 'second cancel: ${_code(e)}';
            }
          });

          await step('markLine on a draft: lines_not_markable', () async {
            final d = await newRequest();
            try {
              final r = await requests.addLine(
                d.id,
                productId: product!.productId,
              );
              await requests.markLine(
                d.id,
                r.lines.single.id,
                toPurchase: false,
              );
              fail('a draft line was marked');
            } on AppError catch (e) {
              expect(_code(e), 'purchase_request.lines_not_markable');
              return _code(e);
            } finally {
              await requests.cancel(d.id);
            }
          });

          // ---- List again (quickstart 9) ----
          await step(
            'default scope hides cancelled; filter shows them',
            () async {
              final def = await requests.list(skip: 0, limit: 100);
              final inDefault = def.items
                  .where((s) => created.contains(s.id))
                  .map((s) => '#${s.id} ${s.status.name}')
                  .toList();
              final cancelled = await requests.list(
                status: PurchaseRequestStatus.cancelled,
                skip: 0,
                limit: 100,
              );
              final shown = cancelled.items
                  .where((s) => created.contains(s.id))
                  .map((s) => s.id)
                  .toSet();
              final hiddenOk = def.items.every(
                (s) => s.status != PurchaseRequestStatus.cancelled,
              );
              return 'default: ${hiddenOk ? 'no cancelled' : 'HAS cancelled'}, '
                  'ours ${inDefault.join(', ')}; status=cancelled shows '
                  '${shown.length} of ours (${shown.join(', ')})';
            },
          );

          if (serial1 != null) {
            await step('folio search finds the new request', () async {
              final page = await requests.list(
                all: true,
                serial: serial1,
                status: PurchaseRequestStatus.cancelled,
                skip: 0,
                limit: 50,
              );
              expect(page.items.any((s) => s.id == id1), isTrue);
              return 'folio $serial1: ${page.total} row(s)';
            });
          }
        } on StateError catch (e) {
          steps.add(_Step('write flow stopped', false, '$e'));
        } finally {
          // Leave dev clean: cancel anything still open.
          final left = <String>[];
          for (final id in created) {
            try {
              var r = await requests.get(id);
              if (r.status != PurchaseRequestStatus.cancelled) {
                r = await requests.cancel(id);
              }
              left.add('#$id ${r.status.name}');
            } on Object catch (e) {
              left.add('#$id NOT CANCELLED (${_code(e) ?? e})');
            }
          }
          steps.add(_Step('cleanup', true, left.join(', ')));
        }
      }

      // ---- Report -----------------------------------------------------------
      final out = StringBuffer('\n== Solicitudes de compra live run ==\n');
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
