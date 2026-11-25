import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

/// Spec 078's repository calls against a live mbe-api (quickstart.md, task
/// T034): the months list, a month with and without an agent, agents, labels,
/// participations, rates and product labels; with `MBE_WRITE=true`, a
/// throwaway round trip through the settings; with
/// `MBE_COMMISSIONS_PERIODS=true` as well, one close and reopen.
///
///   flutter test test/integration/commissions_live_test.dart \
///     --dart-define-from-file=.env.settings --dart-define-from-file=.env \
///     [--dart-define=MBE_WRITE=true] \
///     [--dart-define=MBE_COMMISSIONS_PERIODS=true]
///
/// `MBE_POS_*` is the administrator (rights on CommissionsBySalesPerson, 112).
/// Fixtures are discovered at run time: an existing agent and an active
/// product that has no commission label (the write pass is skipped, with the
/// reason, when there is none).
///
/// **Reads** always run. They also fail, listing the offending values, when a
/// label rate, an agent share or a line's rate has more than four fraction
/// digits: read-only display rounds to two percent decimals (research R12).
///
/// **Writes** (`MBE_WRITE=true`) create a label `ZZ-TEST-078-<timestamp>`, a
/// temporary participation type and a rate for an existing agent, label a
/// product that has none, check that deleting the label is refused with
/// `resource.still_referenced`, then remove everything in reverse order (in a
/// `finally`, so a failure still cleans up). Run writes only against dev.
///
/// **Close and reopen** (`MBE_COMMISSIONS_PERIODS=true`, with `MBE_WRITE`)
/// close the month after the latest closed or paid one, when it has ended,
/// and reopen it at once. Skipped when no month is closed (the first close
/// starts the chain, research R14) or when the next month has not ended.
///
/// **Pay is never automated** (research R14): it is final, for everyone.
///
/// A run without credentials is skipped, like the other live tests.
const _username = String.fromEnvironment('MBE_POS_USERNAME');
const _password = String.fromEnvironment('MBE_POS_PASSWORD');
const _write = bool.fromEnvironment('MBE_WRITE');
const _periods = bool.fromEnvironment('MBE_COMMISSIONS_PERIODS');
const _canRun = _username != '' && _password != '';

class _Step {
  _Step(this.name, this.ok, this.detail);
  final String name;
  final bool ok;
  final String detail;
}

String? _code(Object e) => e is AppError ? e.problem?.codeName : null;

/// The values of [offenders] shown for a failure message.
String _show(List<String> offenders) => offenders.take(20).join('; ');

void main() {
  late Dio dio;
  late CommissionRepositoryImpl commissions;
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
    commissions = CommissionRepositoryImpl(dio);
    products = ProductRepositoryImpl(dio);
  });

  test(
    'Comisiones against a live mbe-api',
    () async {
      // ---- Reads --------------------------------------------------------
      late List<CommissionPeriodSummary> months;
      await step('months list, newest first', () async {
        months = await commissions.listPeriods();
        final sorted = [...months]..sort((a, b) => b.month.compareTo(a.month));
        expect(
          months.map((m) => m.month),
          sorted.map((m) => m.month),
          reason: 'not newest first',
        );
        return '${months.length} month(s)';
      });

      late List<CommissionLabel> labels;
      await step('labels', () async {
        labels = await commissions.listLabels();
        final bad = [
          for (final l in labels)
            if (l.rate.scale > 6) '${l.name}: ${l.rate}',
        ];
        expect(bad, isEmpty, reason: 'more than 6 fraction digits');
        return '${labels.length} label(s)';
      });

      late List<CommissionAgent> agents;
      await step('agents', () async {
        agents = await commissions.listAgents();
        return '${agents.length} agent(s)';
      });

      await step('participation types', () async {
        final all = await commissions.listParticipations();
        return '${all.length} type(s)';
      });

      await step('agent rates: list, per agent and per label', () async {
        final all = await commissions.listAgentRates();
        if (agents.isNotEmpty) {
          final one = await commissions.listAgentRates(
            agentId: agents.first.employeeId,
          );
          expect(
            one.every((r) => r.agentId == agents.first.employeeId),
            isTrue,
          );
        }
        if (labels.isNotEmpty) {
          final one = await commissions.listAgentRates(
            labelId: labels.first.id,
          );
          expect(one.every((r) => r.labelId == labels.first.id), isTrue);
        }
        return '${all.length} rate(s)';
      });

      // R12: read-only display rounds to two percent decimals, so no rate may
      // need more than four fraction digits (two percent decimals).
      await step('no label rate or agent share past four digits', () async {
        final bad = <String>[
          for (final l in labels)
            if (l.rate.scale > 4) 'label ${l.id} ${l.name} rate ${l.rate}',
          for (final r in await commissions.listAgentRates())
            if (r.share.scale > 4) 'agent rate ${r.id} share ${r.share}',
        ];
        expect(bad, isEmpty, reason: _show(bad));
        return null;
      });

      await step('product labels: page, by label, by product', () async {
        final page = await commissions.listProductLabels(skip: 0, limit: 50);
        if (page.items.isNotEmpty) {
          final first = page.items.first;
          final byLabel = await commissions.listProductLabels(
            labelId: first.labelId,
            skip: 0,
            limit: 50,
          );
          expect(
            byLabel.items.every((p) => p.labelId == first.labelId),
            isTrue,
          );
          final byProduct = await commissions.listProductLabels(
            productId: first.productId,
            skip: 0,
            limit: 50,
          );
          expect(byProduct.total, 1);
          expect(byProduct.items.single.labelId, first.labelId);
        }
        return '${page.total} labelled product(s)';
      });

      // The last six calendar months before this one, plus any closed month
      // the list knows: a database with no close yet still has live months
      // with sales (an open month is computed live).
      Future<CommissionPeriod?> monthWithLines() async {
        final now = DateTime.now();
        var m = CommissionMonth(year: now.year, month: now.month).previous;
        final candidates = <CommissionMonth>[
          for (var i = 0; i < 6; i++, m = m.previous) m,
          for (final s in months.take(6)) s.month,
        ];
        for (final c in candidates) {
          final p = await commissions.getPeriod(c);
          if (p.lines.isNotEmpty) return p;
        }
        return null;
      }

      await step('a month, with and without an agent', () async {
        final whole = await commissions.getPeriod(
          months.isEmpty
              ? CommissionMonth(
                  year: DateTime.now().year,
                  month: DateTime.now().month,
                ).previous
              : months.first.month,
        );
        expect(whole.grandTotal, isNotNull);
        final withLines = await monthWithLines() ?? whole;
        if (withLines.lines.isEmpty) {
          return 'SKIPPED agent filter: no month has lines';
        }
        final agent = withLines.totalsByAgent.first.agentId;
        final one = await commissions.getPeriod(
          withLines.month,
          agentId: agent,
        );
        expect(one.lines.every((l) => l.agentId == agent), isTrue);
        expect(one.totals.every((t) => t.agentId == agent), isTrue);
        final expected = withLines.totals
            .where((t) => t.agentId == agent)
            .fold(Decimal.zero, (s, t) => s + t.commission);
        expect(one.grandTotal, expected);
        return '${withLines.month.year}-${withLines.month.month}: '
            '${withLines.lines.length} line(s), agent $agent '
            '${one.lines.length}';
      });

      await step('no line rate or share past four digits', () async {
        final bad = <String>[];
        for (final m in months.take(6)) {
          final p = await commissions.getPeriod(m.month);
          for (final l in p.lines) {
            final at =
                '${m.month.year}-${m.month.month} detail '
                '${l.salesOrderDetailId}';
            if (l.rate.scale > 4) bad.add('$at rate ${l.rate}');
            if (l.labelRate.scale > 4) bad.add('$at label rate ${l.labelRate}');
            final share = l.share;
            if (share != null && share.scale > 4) {
              bad.add('$at share $share');
            }
          }
        }
        expect(bad, isEmpty, reason: _show(bad));
        return null;
      });

      // ---- Writes -------------------------------------------------------
      if (!_write) {
        skipped('write flow', 'MBE_WRITE=true not set (read-only run)');
      } else {
        final tag = 'ZZ-TEST-078-${DateTime.now().millisecondsSinceEpoch}';
        // Reverse-order cleanup, run in a finally.
        final cleanup = <String, Future<void> Function()>{};

        await step('settings round trip on throwaway rows', () async {
          if (agents.isEmpty) {
            return 'SKIPPED: the tenant has no commission agent';
          }
          // An active product that has no label yet.
          int? productId;
          for (var skip = 0; productId == null; skip += 50) {
            final page = await products.list(
              status: EntityStatus.active,
              skip: skip,
              limit: 50,
            );
            for (final item in page.items) {
              final has = await commissions.listProductLabels(
                productId: item.productId,
                skip: 0,
                limit: 1,
              );
              if (has.total == 0) {
                productId = item.productId;
                break;
              }
            }
            if (page.items.length < 50) break;
          }
          if (productId == null) return 'SKIPPED: every product has a label';
          final product = productId;
          final agent = agents.first.employeeId;
          try {
            final label = await commissions.createLabel(
              name: tag,
              rate: Decimal.parse('0.01'),
              comment: 'throwaway, spec 078 live test',
            );
            cleanup['label ${label.id}'] = () =>
                commissions.deleteLabel(label.id);
            expect(label.name, tag);
            expect(label.rate, Decimal.parse('0.01'));

            final participation = await commissions.createParticipation(tag);
            cleanup['participation ${participation.id}'] = () =>
                commissions.deleteParticipation(participation.id);

            final rate = await commissions.createAgentRate(
              agentId: agent,
              labelId: label.id,
              participationId: participation.id,
              share: Decimal.parse('0.5'),
            );
            cleanup['rate ${rate.id}'] = () =>
                commissions.deleteAgentRate(rate.id);
            final updated = await commissions.updateAgentRate(
              rate.id,
              Decimal.parse('0.25'),
            );
            expect(updated.share, Decimal.parse('0.25'));
            final listed = await commissions.listAgentRates(
              agentId: agent,
              labelId: label.id,
            );
            expect(listed.map((r) => r.id), contains(rate.id));

            final labelled = await commissions.setProductLabel(
              product,
              label.id,
            );
            cleanup['product label $product'] = () =>
                commissions.removeProductLabel(product);
            expect(labelled.labelId, label.id);
            final byLabel = await commissions.listProductLabels(
              labelId: label.id,
              skip: 0,
              limit: 10,
            );
            expect(byLabel.items.map((p) => p.productId), contains(product));

            try {
              await commissions.deleteLabel(label.id);
              fail('a label in use was deleted');
            } on AppError catch (e) {
              expect(_code(e), 'resource.still_referenced');
            }
            return 'label ${label.id}, rate ${rate.id}, product $product';
          } finally {
            for (final entry in cleanup.entries.toList().reversed) {
              try {
                await entry.value();
              } on Object catch (e) {
                // ignore: avoid_print
                print('CLEANUP FAILED ${entry.key}: $e');
                rethrow;
              }
            }
          }
        });

        await step('throwaway rows are gone', () async {
          expect(
            (await commissions.listLabels()).map((l) => l.name),
            isNot(contains(tag)),
          );
          expect(
            (await commissions.listParticipations()).map((p) => p.name),
            isNot(contains(tag)),
          );
          return null;
        });

        // ---- Close and reopen -------------------------------------------
        if (!_periods) {
          skipped(
            'close and reopen',
            'MBE_COMMISSIONS_PERIODS=true not set (R14)',
          );
        } else {
          await step('close and reopen the next month', () async {
            final latest = [
              for (final m in months)
                if (m.status != CommissionPeriodStatus.open) m.month,
            ]..sort();
            if (latest.isEmpty) {
              return 'SKIPPED: no month is closed (the first close starts '
                  'the chain)';
            }
            final target = latest.last.next;
            final now = DateTime.now();
            if (target.isAfterCurrent(now) ||
                (target.year == now.year && target.month == now.month)) {
              return 'SKIPPED: ${target.year}-${target.month} has not ended';
            }
            var closed = false;
            try {
              final done = await commissions.closePeriod(target);
              closed = true;
              expect(done.status, CommissionPeriodStatus.closed);
              expect(done.month, target);
            } finally {
              if (closed) {
                final back = await commissions.reopenPeriod(target);
                expect(back.status, CommissionPeriodStatus.open);
              }
            }
            return 'closed and reopened ${target.year}-${target.month}';
          });
        }
      }

      // ---- Report -------------------------------------------------------
      final out = StringBuffer('\n== Comisiones live run ==\n');
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
