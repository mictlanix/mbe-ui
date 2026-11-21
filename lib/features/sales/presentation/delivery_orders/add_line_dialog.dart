import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/design/design.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/core/widgets/list_state_views.dart';
import 'package:mbe_ui/core/widgets/record_id_text.dart';
import 'package:mbe_ui/core/widgets/responsive_dialog.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/deliverable_lines.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/open_sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_actions.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_dialogs.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// How many sales step 1 asks for at a time (contracts C7).
const _salesPageSize = 20;

/// Adds lines to draft [order] from one of its customer's completed sales at
/// the order's facility (spec 061 C7, FR-014, research R8), in two steps:
/// pick the sale, then type a quantity on each of its lines that still has
/// something left to deliver.
///
/// "Agregar" sends one add per filled row, in sequence, and stops at the
/// first refusal, which shows inline: the rows before it are already on the
/// order and leave the table. Answers how many lines were added, so the
/// screen can say so; each add has already reloaded the order.
Future<int> showAddDeliveryOrderLineDialog(
  BuildContext context,
  DeliveryOrder order,
) async =>
    await showResponsiveDialog<int>(
      context,
      builder: (context) => _AddLineDialog(order: order),
    ) ??
    0;

class _AddLineDialog extends ConsumerStatefulWidget {
  const _AddLineDialog({required this.order});

  final DeliveryOrder order;

  @override
  ConsumerState<_AddLineDialog> createState() => _AddLineDialogState();
}

class _AddLineDialogState extends ConsumerState<_AddLineDialog> {
  // Step 1: the sales.
  final _search = TextEditingController();
  Timer? _debounce;
  int _salesRequest = 0;
  List<OpenSale>? _sales;
  int _salesTotal = 0;
  bool _loadingMore = false;
  AppError? _salesError;

  // Step 2: the chosen sale's lines. [_sale] non-null means step 2.
  OpenSale? _sale;
  int _linesRequest = 0;
  List<DeliverableLine>? _lines;
  AppError? _linesError;
  final _quantities = <int, TextEditingController>{};

  bool _busy = false;
  AppError? _refusal;
  int _added = 0;

  DeliveryOrder get _order => widget.order;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSales());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _disposeQuantities();
    super.dispose();
  }

  void _disposeQuantities() {
    for (final controller in _quantities.values) {
      controller.dispose();
    }
    _quantities.clear();
  }

  // -- Step 1 ---------------------------------------------------------------

  Future<void> _loadSales({bool more = false}) async {
    final request = ++_salesRequest;
    setState(() {
      _salesError = null;
      if (more) {
        _loadingMore = true;
      } else {
        _sales = null;
      }
    });
    final search = _search.text.trim();
    try {
      final page = await ref
          .read(salesOrderRepositoryProvider)
          .listOrders(
            customer: _order.customerId,
            status: SaleStatus.completed,
            facility: _order.facilityId,
            search: search.isEmpty ? null : search,
            skip: more ? _sales?.length ?? 0 : 0,
            limit: _salesPageSize,
          );
      if (!mounted || request != _salesRequest) return;
      setState(() {
        _sales = [if (more) ...?_sales, ...page.items];
        _salesTotal = page.total;
        _loadingMore = false;
      });
    } on AppError catch (e) {
      if (!mounted || request != _salesRequest) return;
      setState(() {
        _salesError = e;
        _loadingMore = false;
      });
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(ref.read(inputDebounceProvider), _loadSales);
  }

  // -- Step 2 ---------------------------------------------------------------

  void _choose(OpenSale sale) {
    setState(() {
      _sale = sale;
      _refusal = null;
    });
    unawaited(_loadLines());
  }

  void _backToSales() {
    _linesRequest++;
    setState(() {
      _sale = null;
      _lines = null;
      _linesError = null;
      _refusal = null;
      _disposeQuantities();
    });
  }

  /// The sale's lines with something left to deliver, as the server counts
  /// it (mbe-api#313), less the ones already on this order.
  Future<void> _loadLines() async {
    final saleId = _sale!.id;
    final request = ++_linesRequest;
    setState(() {
      _lines = null;
      _linesError = null;
    });
    try {
      final deliverable = await ref
          .read(deliveryOrderAdminRepositoryProvider)
          .deliverableLines(customer: _order.customerId, salesOrder: saleId);
      if (!mounted || request != _linesRequest) return;
      final onOrder = {
        for (final line in _order.lines)
          if (line.salesOrderDetailId != null) line.salesOrderDetailId!,
      };
      final lines = [
        for (final line in deliverable)
          if (!onOrder.contains(line.salesOrderDetailId)) line,
      ];
      setState(() {
        _disposeQuantities();
        for (final line in lines) {
          _quantities[line.salesOrderDetailId] = TextEditingController();
        }
        _lines = lines;
      });
    } on AppError catch (e) {
      if (!mounted || request != _linesRequest) return;
      setState(() => _linesError = e);
    }
  }

  /// The quantity typed for [line]: `null` when blank (skip it), otherwise
  /// the value, or a negative sentinel when it isn't a valid quantity.
  Decimal? _quantityOf(DeliverableLine line) {
    final text = _quantities[line.salesOrderDetailId]?.text.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = ref.read(formattersProvider).field.parseQuantity(text);
    return parsed == null ? Decimal.fromInt(-1) : Decimal.parse(parsed);
  }

  bool _isInvalid(DeliverableLine line) {
    final quantity = _quantityOf(line);
    return quantity != null &&
        (quantity <= Decimal.zero || quantity > line.remaining);
  }

  bool get _canSubmit {
    final lines = _lines;
    if (_busy || lines == null) return false;
    var filled = false;
    for (final line in lines) {
      if (_isInvalid(line)) return false;
      if (_quantityOf(line) != null) filled = true;
    }
    return filled;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final navigator = Navigator.of(context);
    final rows = [
      for (final line in _lines!)
        if (_quantityOf(line) case final quantity?) (line, quantity),
    ];
    setState(() {
      _busy = true;
      _refusal = null;
    });
    final actions = ref.read(deliveryOrderActionsProvider.notifier);
    for (final (line, quantity) in rows) {
      final error = await actions.addLine(
        _order.id,
        salesOrderDetail: line.salesOrderDetailId,
        quantity: quantity,
      );
      if (!mounted) return;
      if (error != null) {
        setState(() {
          _busy = false;
          _refusal = error;
        });
        return;
      }
      // Added: it leaves the table, so a retry can't send it twice.
      setState(() {
        _added++;
        _lines = [..._lines!]..remove(line);
        _quantities.remove(line.salesOrderDetailId)?.dispose();
      });
    }
    navigator.pop(_added);
  }

  // -- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sale = _sale;

    return ResponsiveDialog(
      key: const Key('delivery_order_add_line_dialog'),
      title: sale == null
          ? l10n.deliveryOrderAddLineStep1Title
          : l10n.deliveryOrderAddLineStep2Title(
              '${sale.serial ?? '#${sale.id}'}',
            ),
      maxWidth: 720,
      dismissible: !_busy,
      body: sale == null ? _salesStep(context) : _linesStep(context),
      secondaryAction: ResponsiveDialogAction(
        label: l10n.cancelButton,
        onPressed: _busy ? null : () => Navigator.of(context).pop(_added),
      ),
      primaryAction: ResponsiveDialogAction(
        key: const Key('delivery_order_add_line_submit'),
        label: l10n.deliveryOrderAddLineSubmit,
        busy: _busy,
        onPressed: _canSubmit ? _submit : null,
      ),
    );
  }

  Widget _salesStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final customer =
        ref.watch(customerDisplayNameProvider(_order.customerId)).value ??
        '#${_order.customerId}';
    final facility =
        ref.watch(facilityDisplayNameProvider(_order.facilityId)).value ??
        '#${_order.facilityId}';
    final sales = _sales;

    final Widget list;
    if (_salesError != null) {
      list = ListFailedView(
        error: _salesError!,
        retryLabel: l10n.retryButton,
        onRetry: _loadSales,
      );
    } else if (sales == null) {
      list = const Center(child: CircularProgressIndicator());
    } else if (sales.isEmpty) {
      list = KeyedSubtree(
        key: const Key('delivery_order_add_line_no_sales'),
        child: ListEmptyView(message: l10n.deliveryOrderAddLineEmptySales),
      );
    } else {
      Widget row(List<Widget> cells, {TextStyle? style}) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.sm,
        ),
        child: DefaultTextStyle.merge(
          style: style,
          child: Row(
            spacing: spacing.md,
            children: [
              Expanded(child: cells[0]),
              Expanded(child: cells[1]),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: cells[2],
                ),
              ),
              SizedBox(
                width: spacing.lg,
                child: cells.length > 3 ? cells[3] : null,
              ),
            ],
          ),
        ),
      );
      list = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row([
            Text(l10n.deliveryOrderAddLineSaleColumnSerial),
            Text(l10n.deliveryOrderAddLineSaleColumnDate),
            Text(l10n.deliveryOrderAddLineSaleColumnTotal),
          ], style: theme.textTheme.labelMedium),
          const Divider(height: 1),
          for (final sale in sales)
            InkWell(
              key: Key('delivery_order_add_line_sale_${sale.id}'),
              onTap: () => _choose(sale),
              child: row([
                RecordIdText('${sale.serial ?? '#${sale.id}'}'),
                Text(fmt.display.date(sale.date)),
                Text(fmt.display.currency(sale.total)),
                const Icon(Icons.chevron_right),
              ]),
            ),
          if (sales.length < _salesTotal)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('delivery_order_add_line_load_more'),
                onPressed: _loadingMore ? null : () => _loadSales(more: true),
                child: Text(l10n.deliveryOrderAddLineLoadMore),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        Text(l10n.deliveryOrderAddLineStep1Intro(customer, facility)),
        TextField(
          key: const Key('delivery_order_add_line_search'),
          controller: _search,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: l10n.deliveryOrderAddLineSearchHint,
          ),
          onChanged: _searchChanged,
          onSubmitted: (_) {
            _debounce?.cancel();
            unawaited(_loadSales());
          },
        ),
        list,
      ],
    );
  }

  Widget _linesStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final fmt = ref.watch(formattersProvider);
    final lines = _lines;

    final Widget table;
    if (_linesError != null) {
      table = ListFailedView(
        error: _linesError!,
        retryLabel: l10n.retryButton,
        onRetry: _loadLines,
      );
    } else if (lines == null) {
      table = const Center(child: CircularProgressIndicator());
    } else if (lines.isEmpty) {
      table = KeyedSubtree(
        key: const Key('delivery_order_add_line_no_lines'),
        child: ListEmptyView(message: l10n.deliveryOrderAddLineEmptyLines),
      );
    } else {
      Widget row(List<Widget> cells, {TextStyle? style}) => Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: DefaultTextStyle.merge(
          style: style,
          child: Row(
            spacing: spacing.md,
            children: [
              Expanded(child: cells[0]),
              Expanded(flex: 3, child: cells[1]),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: cells[2],
                ),
              ),
              Expanded(flex: 2, child: cells[3]),
            ],
          ),
        ),
      );
      table = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row([
            Text(l10n.deliveryOrderLineColumnCode),
            Text(l10n.deliveryOrderLineColumnProduct),
            Text(l10n.deliveryOrderAddLineColumnRemaining),
            Text(l10n.deliveryOrderAddLineColumnQuantity),
          ], style: theme.textTheme.labelMedium),
          const Divider(height: 1),
          for (final line in lines)
            KeyedSubtree(
              key: Key(
                'delivery_order_add_line_row_${line.salesOrderDetailId}',
              ),
              child: row([
                Text(line.productCode),
                Text(line.productName),
                Text(fmt.display.quantity(line.remaining.toString())),
                TextField(
                  key: Key(
                    'delivery_order_add_line_quantity_${line.salesOrderDetailId}',
                  ),
                  controller: _quantities[line.salesOrderDetailId],
                  enabled: !_busy,
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    errorText: _isInvalid(line)
                        ? l10n.deliveryOrderAddLineQuantityInvalid(
                            fmt.display.quantity(line.remaining.toString()),
                          )
                        : null,
                    errorMaxLines: 3,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ]),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: spacing.fieldGapVertical,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const Key('delivery_order_add_line_another_sale'),
            onPressed: _busy ? null : _backToSales,
            icon: const Icon(Icons.chevron_left),
            label: Text(l10n.deliveryOrderAddLineAnotherSale),
          ),
        ),
        table,
        if (_refusal != null) DeliveryOrderRefusal(error: _refusal!),
      ],
    );
  }
}
