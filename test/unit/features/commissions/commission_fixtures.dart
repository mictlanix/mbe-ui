import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

Decimal d(String value) => Decimal.parse(value);

/// A period summary for tests; override what the case is about.
CommissionPeriodSummary aPeriodSummary({
  CommissionMonth month = const CommissionMonth(year: 2026, month: 10),
  CommissionPeriodStatus status = CommissionPeriodStatus.open,
  String total = '0.00',
}) => CommissionPeriodSummary(month: month, status: status, total: d(total));

CommissionTotal aTotal({
  int agentId = 7,
  int? labelId = 3,
  String? labelName = 'Premium',
  int lines = 2,
  String commission = '100.00',
}) => CommissionTotal(
  agentId: agentId,
  labelId: labelId,
  labelName: labelName,
  lines: lines,
  commission: d(commission),
);

CommissionLine aLine({
  CommissionMovement movement = CommissionMovement.sale,
  int agentId = 7,
  int? labelId = 3,
  String commission = '50.00',
}) => CommissionLine(
  movement: movement,
  scheme: CommissionScheme.fullyPaid,
  salesOrderId: 61,
  salesOrderDetailId: 610,
  orderDate: DateTime(2026, 10, 3),
  paidDate: DateTime(2026, 10, 5),
  customerId: 11,
  customerName: 'Cliente',
  productId: 5,
  productName: 'Tornillo',
  labelId: labelId,
  labelName: 'Premium',
  labelRate: d('0.050000'),
  agentId: agentId,
  orderSalespersonId: agentId,
  customerSalespersonId: agentId,
  participationId: 2,
  participationName: 'CLIENTE VITALICIO',
  participationRate: d('0.500000'),
  rate: d('0.025000'),
  price: d('100.00'),
  quantity: d('2'),
  total: d('200.00'),
  fullCommission: d('10.00'),
  commission: d(commission),
);

CommissionPeriod aPeriod({
  CommissionPeriodStatus status = CommissionPeriodStatus.open,
  List<CommissionTotal>? totals,
  List<CommissionLine>? lines,
  int? agentId,
}) => CommissionPeriod(
  month: const CommissionMonth(year: 2026, month: 10),
  status: status,
  isFinal: status != CommissionPeriodStatus.open,
  totals: totals ?? [aTotal()],
  lines: lines ?? [aLine()],
  agentId: agentId,
);

CommissionLabel aLabel({int id = 3, String rate = '0.050000'}) =>
    CommissionLabel(id: id, name: 'Premium', rate: d(rate));

CommissionAgent anAgent({int employeeId = 7}) => CommissionAgent(
  employeeId: employeeId,
  name: 'Ana Ruiz',
  scheme: CommissionScheme.fullyPaid,
);

/// A JSON body per endpoint, as mbe-api serves it.
Map<String, Object?> periodSummaryJson({
  int year = 2026,
  int month = 10,
  String status = 'closed',
  String total = '1234.50',
}) => {
  'year': year,
  'month': month,
  'status': status,
  'closed_by': 4,
  'closed_at': '2026-11-02T09:00:00.000',
  'reopened_by': null,
  'reopened_at': null,
  'paid_by': null,
  'paid_at': null,
  'total': total,
};

Map<String, Object?> periodResponseJson({String status = 'closed'}) => {
  'year': 2026,
  'month': 10,
  'status': status,
  'closed_by': 4,
  'closed_at': '2026-11-02T09:00:00.000',
  'reopened_by': 5,
  'reopened_at': '2026-11-03T09:00:00.000',
  'paid_by': 6,
  'paid_at': '2026-11-04T09:00:00.000',
};

Map<String, Object?> totalJson({int agent = 7, int? label = 3}) => {
  'salesperson': agent,
  'label': label,
  'label_name': label == null ? null : 'Premium',
  'lines': 2,
  'commission': '100.00',
};

Map<String, Object?> lineJson({
  String movement = 'sale',
  int scheme = 1,
  String? share,
  int? label = 3,
}) => {
  'scheme': scheme,
  'movement': movement,
  'sales_order': 61,
  'sales_order_detail': 610,
  'customer_refund_detail': movement == 'refund' ? 8 : null,
  'order_date': '2026-10-03T10:00:00.000',
  'paid_date': '2026-10-05T10:00:00.000',
  'customer': 11,
  'customer_name': 'Cliente',
  'product': 5,
  'product_name': 'Tornillo',
  'label': label,
  'label_name': label == null ? null : 'Premium',
  'label_rate': '0.050000',
  'salesperson': 7,
  'order_salesperson': 7,
  'customer_salesperson': 8,
  'participation': 2,
  'participation_name': 'CLIENTE VITALICIO',
  'participation_rate': '0.500000',
  'rate': '0.025000',
  'price': '100.00',
  'quantity': '2.500',
  'total': '250.00',
  'full_commission': '12.50',
  'share': share,
  'commission': '6.25',
};

Map<String, Object?> periodDetailJson({
  String status = 'open',
  List<Object?>? lines,
}) => {
  ...periodResponseJson(status: status),
  'final': status != 'open',
  'totals': [totalJson(), totalJson(agent: 8, label: null)],
  'lines': lines ?? [lineJson()],
};

Map<String, Object?> labelJson({String rate = '0.025000'}) => {
  'commission_id': 3,
  'name': 'Premium',
  'commission_rate': rate,
  'comment': 'Nota',
};

Map<String, Object?> participationJson() => {
  'commission_participation_id': 2,
  'name': 'CANALIZACION',
};

Map<String, Object?> agentJson({int scheme = 2}) => {
  'employee': 7,
  'name': 'Ana Ruiz',
  'scheme': scheme,
};

Map<String, Object?> agentRateJson() => {
  'commission_salesperson_id': 41,
  'salesperson': 7,
  'commission': 3,
  'commission_participation': 2,
  'participation_rate': '0.025000',
};

Map<String, Object?> productLabelJson() => {
  'product': 5,
  'product_code': 'A-100',
  'product_name': 'Tornillo',
  'commission': 3,
};
