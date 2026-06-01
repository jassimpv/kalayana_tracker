part of 'dashboard_view.dart';

class ExpensesPanel extends GetView<DashboardController> {
  const ExpensesPanel({super.key, required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  Widget build(BuildContext context) {
    final sorted = [...expenses]
      ..sort((a, b) {
        if (a.repaymentPending > 0 && b.repaymentPending == 0) return -1;
        if (b.repaymentPending > 0 && a.repaymentPending == 0) return 1;
        if (a.pendingForSummary != b.pendingForSummary) {
          return b.pendingForSummary.compareTo(a.pendingForSummary);
        }
        return b.updatedDate.compareTo(a.updatedDate);
      });
    return _ExpenseListMockup(
      expenses: sorted,
      onAdd: () => showExpenseDialog(context),
    );
  }
}

class _ExpenseListMockup extends StatefulWidget {
  const _ExpenseListMockup({required this.expenses, required this.onAdd});

  final List<ExpenseItem> expenses;
  final VoidCallback onAdd;

  @override
  State<_ExpenseListMockup> createState() => _ExpenseListMockupState();
}

class _ExpenseListMockupState extends State<_ExpenseListMockup> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filters = [
      const _ExpenseFilter('All'),
      const _ExpenseFilter('Paid'),
      const _ExpenseFilter('Pending'),
      const _ExpenseFilter('Partial'),
    ];
    final filteredExpenses = widget.expenses
        .where(
          (item) => _selectedFilter == 'All'
              ? true
              : expenseShortStatus(item) == _selectedFilter,
        )
        .toList();

    return Column(
      children: [
        const _ExpenseSearchField(),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: filters
                .map(
                  (filter) => _ExpenseFilterChip(
                    filter: filter,
                    selected: filter.label == _selectedFilter,
                    onTap: () => setState(() {
                      _selectedFilter = filter.label;
                    }),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        if (widget.expenses.isEmpty)
          const PremiumEmptyState(
            icon: Icons.payments_rounded,
            title: 'No expenses added yet',
            subtitle: 'Create your first wedding expense to start tracking.',
          )
        else if (filteredExpenses.isEmpty)
          PremiumEmptyState(
            icon: Icons.filter_alt_off_rounded,
            title: 'No $_selectedFilter expenses',
            subtitle: 'Try another status filter to view more expenses.',
          )
        else
          ...filteredExpenses.map((item) => _ExpenseListTileCard(item: item)),
      ],
    );
  }
}

class _ExpenseSearchField extends StatelessWidget {
  const _ExpenseSearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        hintText: 'Search expenses...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.74),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: ThemeColors.logoGold.withValues(alpha: 0.22),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: ThemeColors.logoGold.withValues(alpha: 0.22),
          ),
        ),
      ),
    );
  }
}

class _ExpenseFilter {
  const _ExpenseFilter(this.label);

  final String label;
}

class _ExpenseFilterChip extends StatelessWidget {
  const _ExpenseFilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final _ExpenseFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 48, minWidth: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? ThemeColors.primary : const Color(0xFFFFEED7),
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ThemeColors.primary.withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Text(
            filter.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : ThemeColors.logoDeep,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseListTileCard extends GetView<DashboardController> {
  const _ExpenseListTileCard({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final status = expenseShortStatus(item);
    final statusColor = expenseStatusColor(item);
    final payer = item.paidBy.trim().isEmpty ? 'Self' : item.paidBy.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white.withValues(alpha: 224),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            buildNestedDashboardRoute(
              settings: RouteSettings(
                name: AppRoutes.dashboardExpenseDetail,
                arguments: item.id,
              ),
              child: ExpenseDetailPage(expenseId: item.id),
              transitionDuration: const Duration(milliseconds: 320),
              startOffset: const Offset(0.08, 0),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 250),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ThemeColors.logoGold.withValues(alpha: 46),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.isEmpty ? 'Untitled expense' : item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ThemeColors.logoDeep,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _ExpenseTag(label: status, color: statusColor),
                              _ExpenseTag(label: item.category),
                              _ExpenseTag(label: payer),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          moneyOrDash(item.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.dueDate == null
                              ? 'No due date'
                              : formatDate(item.dueDate!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ExpenseListAmount(
                        label: 'Paid',
                        value: moneyOrDash(item.paidForSummary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ExpenseListAmount(
                        label: 'Pending',
                        value: moneyOrDash(item.pendingForSummary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseTag extends StatelessWidget {
  const _ExpenseTag({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? ThemeColors.logoDeep.withValues(alpha: 20)).withValues(
          alpha: 242,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ExpenseListAmount extends StatelessWidget {
  const _ExpenseListAmount({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: ThemeColors.logoDeep,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _ExpenseExportCard extends StatelessWidget {
  const _ExpenseExportCard({required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final details = Row(
            children: [
              SoftIcon(
                icon: Icons.ios_share_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export expenses',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Copy CSV or generate a PDF report',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: expenses.isEmpty
                    ? null
                    : () => _copyExpenseCsv(context, expenses),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('CSV'),
              ),
              FilledButton.icon(
                onPressed: expenses.isEmpty
                    ? null
                    : () => _printExpensePdf(context, expenses),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('PDF'),
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [details, const SizedBox(height: 14), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: details),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );
  }
}

Future<void> _printExpensePdf(
  BuildContext context,
  List<ExpenseItem> expenses,
) async {
  try {
    await Printing.layoutPdf(
      name: 'kalyana-expenses.pdf',
      onLayout: (format) => _buildExpensePdf(expenses, format),
    );
  } catch (error) {
    if (!context.mounted) return;
    Get.snackbar(
      'PDF export failed',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

Future<Uint8List> _buildExpensePdf(
  List<ExpenseItem> expenses,
  PdfPageFormat format,
) async {
  final font = await PdfGoogleFonts.notoSansRegular();
  final boldFont = await PdfGoogleFonts.notoSansBold();
  final total = expenses.fold<double>(0, (sum, item) => sum + item.totalAmount);
  final paid = expenses.fold<double>(
    0,
    (sum, item) => sum + item.paidForSummary,
  );
  final pending = expenses.fold<double>(
    0,
    (sum, item) => sum + item.pendingForSummary,
  );
  final repayment = expenses.fold<double>(
    0,
    (sum, item) => sum + item.repaymentPending,
  );
  final doc = pw.Document(
    title: 'Kalyana Expense Report',
    theme: pw.ThemeData.withFont(base: font, bold: boldFont),
  );

  pw.TextStyle labelStyle() => pw.TextStyle(
    color: PdfColors.grey700,
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
  );

  pw.Widget summaryBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: labelStyle()),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Kalyana Expense Report',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generated on ${formatDate(DateTime.now())}',
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.Text(
              '${expenses.length} bills',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Row(
          children: [
            summaryBox('Total', _pdfMoney(total)),
            pw.SizedBox(width: 8),
            summaryBox('Paid', _pdfMoney(paid)),
            pw.SizedBox(width: 8),
            summaryBox('Pending', _pdfMoney(pending)),
            pw.SizedBox(width: 8),
            summaryBox('Repay', _pdfMoney(repayment)),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Text(
          'Expenses',
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 8,
          ),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellAlignment: pw.Alignment.centerLeft,
          headerAlignment: pw.Alignment.centerLeft,
          columnWidths: const {
            0: pw.FlexColumnWidth(2.2),
            1: pw.FlexColumnWidth(1.25),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(1.1),
            4: pw.FlexColumnWidth(1.1),
            5: pw.FlexColumnWidth(1.1),
            6: pw.FlexColumnWidth(1.2),
          },
          headers: const [
            'Item',
            'Category',
            'Status',
            'Total',
            'Paid',
            'Pending',
            'Due',
          ],
          data: expenses
              .map(
                (item) => [
                  item.name.isEmpty ? 'Untitled bill' : item.name,
                  item.category,
                  item.status,
                  _pdfMoney(item.totalAmount),
                  _pdfMoney(item.paidForSummary),
                  _pdfMoney(item.pendingForSummary),
                  item.dueDate == null ? '-' : formatDate(item.dueDate!),
                ],
              )
              .toList(),
        ),
        pw.SizedBox(height: 18),
        pw.Text(
          'Payment History',
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        ...expenses.expand(_paymentHistoryWidgets),
      ],
    ),
  );

  return doc.save();
}

List<pw.Widget> _paymentHistoryWidgets(ExpenseItem item) {
  final payments = [...item.paymentSplit]
    ..sort((a, b) => a.date.compareTo(b.date));
  if (payments.isEmpty) {
    return [
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Text(
          '${item.name.isEmpty ? 'Untitled bill' : item.name}: No payments recorded',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ),
    ];
  }
  var runningPaid = 0.0;
  return [
    pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Text(
        item.name.isEmpty ? 'Untitled bill' : item.name,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    ),
    pw.TableHelper.fromTextArray(
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      columnWidths: const {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(1.1),
        2: pw.FlexColumnWidth(1.25),
        3: pw.FlexColumnWidth(1.25),
        4: pw.FlexColumnWidth(2),
      },
      headers: const ['Date', 'Amount', 'Paid by', 'Pending', 'Notes'],
      data: payments.map((payment) {
        runningPaid += payment.amount;
        final remaining = (item.totalAmount - runningPaid)
            .clamp(0, double.infinity)
            .toDouble();
        return [
          formatDate(payment.date),
          _pdfMoney(payment.amount),
          payment.paidBy.trim().isEmpty ? 'Self' : payment.paidBy.trim(),
          _pdfMoney(remaining),
          payment.notes.trim().isEmpty ? '-' : payment.notes.trim(),
        ];
      }).toList(),
    ),
    pw.SizedBox(height: 12),
  ];
}

String _pdfMoney(double value) => '\u20B9 ${formatMoney(value)}';

Future<void> _copyExpenseCsv(
  BuildContext context,
  List<ExpenseItem> expenses,
) async {
  final rows = [
    [
      'Name',
      'Category',
      'Status',
      'Total',
      'Paid',
      'Pending',
      'Paid By',
      'Repay Person',
      'Repay Amount',
      'Due Date',
      'Notes',
    ],
    ...expenses.map(
      (item) => [
        item.name,
        item.category,
        item.status,
        item.totalAmount.toStringAsFixed(0),
        item.paidAmount.toStringAsFixed(0),
        item.pendingForSummary.toStringAsFixed(0),
        item.paidBy,
        item.repayPerson,
        item.repaymentPending.toStringAsFixed(0),
        item.dueDate == null ? '' : formatDate(item.dueDate!),
        item.notes,
      ],
    ),
  ];
  final csv = rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  await Clipboard.setData(ClipboardData(text: csv));
  if (!context.mounted) return;
  Get.snackbar(
    'Expenses exported',
    'CSV copied to clipboard.',
    snackPosition: SnackPosition.BOTTOM,
  );
}

String _csvCell(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

// ignore: unused_element
class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({
    required this.total,
    required this.paid,
    required this.pending,
    required this.repayment,
    required this.progress,
  });

  final double total;
  final double paid;
  final double pending;
  final double repayment;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PremiumSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final ring = _ProgressRing(
            progress: progress,
            color: scheme.primary,
            size: compact ? 92 : 104,
            stroke: 10,
            center: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹${formatMoney(total)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'total bill value',
                style: TextStyle(
                  color: scheme.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _LegendRow(
                color: ThemeColors.weddingTeal,
                label: 'Paid',
                value: '₹${formatMoney(paid)}',
              ),
              const SizedBox(height: 8),
              _LegendRow(
                color: ThemeColors.logoGold,
                label: 'Pending',
                value: '₹${formatMoney(pending)}',
              ),
              if (repayment > 0) ...[
                const SizedBox(height: 8),
                _LegendRow(
                  color: const Color(0xFFB85D75),
                  label: 'Need to repay',
                  value: '₹${formatMoney(repayment)}',
                ),
              ],
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: ring),
                const SizedBox(height: 16),
                details,
              ],
            );
          }
          return Row(
            children: [
              ring,
              const SizedBox(width: 18),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

// ignore: unused_element
class _ExpenseStatusStrip extends StatelessWidget {
  const _ExpenseStatusStrip({
    required this.billCount,
    required this.overdueCount,
    required this.pending,
    required this.splitPaymentCount,
  });

  final int billCount;
  final int overdueCount;
  final double pending;
  final int splitPaymentCount;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MiniExpenseMetric(
        icon: Icons.receipt_long_rounded,
        label: 'Bills',
        value: '$billCount',
        color: ThemeColors.weddingTeal,
      ),
      _MiniExpenseMetric(
        icon: Icons.schedule_rounded,
        label: 'Pending',
        value: '₹${formatMoney(pending)}',
        color: ThemeColors.logoGold,
      ),
      _MiniExpenseMetric(
        icon: Icons.call_split_rounded,
        label: 'Split bills',
        value: '$splitPaymentCount',
        color: const Color(0xFFB85D75),
      ),
      _MiniExpenseMetric(
        icon: Icons.warning_rounded,
        label: 'Overdue',
        value: '$overdueCount',
        color: const Color(0xFFE45D52),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4
                ? 2.8
                : columns == 2
                ? 2.35
                : 3.6,
          ),
          itemBuilder: (context, index) => metrics[index],
        );
      },
    );
  }
}

// ignore: unused_element
class _PendingPaymentReminderCard extends StatelessWidget {
  const _PendingPaymentReminderCard({required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  Widget build(BuildContext context) {
    final visible = expenses.take(3).toList();
    return _PremiumSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SoftIcon(
                icon: Icons.notification_important_rounded,
                color: ThemeColors.logoGold,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending payment reminders',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Upcoming balances and repayment deadlines',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...visible.map((item) => _PendingPaymentRow(item: item)),
        ],
      ),
    );
  }
}

class _PendingPaymentRow extends StatelessWidget {
  const _PendingPaymentRow({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final days = daysUntilDate(item.dueDate);
    final dueLabel = item.dueDate == null
        ? 'No due date'
        : days == null
        ? formatDate(item.dueDate!)
        : days < 0
        ? '${days.abs()} days overdue'
        : days == 0
        ? 'Due today'
        : 'Due in $days days';
    final color = days != null && days < 0
        ? const Color(0xFFE45D52)
        : ThemeColors.logoGold;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name.isEmpty ? 'Untitled bill' : item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                moneyOrDash(item.pendingForSummary),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                dueLabel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniExpenseMetric extends StatelessWidget {
  const _MiniExpenseMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      padding: const EdgeInsets.all(14),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0.12), Colors.white],
      ),
      child: Row(
        children: [
          SoftIcon(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _ExpenseBillCard extends GetView<DashboardController> {
  const _ExpenseBillCard({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final color = _premiumStatusColor(item.status);
    final repaymentName = item.repayPerson.trim().isEmpty
        ? item.paidBy.trim()
        : item.repayPerson.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PremiumSurface(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftIcon(icon: Icons.storefront_rounded, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.isEmpty ? 'Untitled bill' : item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusPill(label: item.status),
                          LabelPill(label: item.category),
                          if (item.hasSplitPayments)
                            LabelPill(
                              label: '${item.paymentSplit.length} payments',
                            ),
                          if (item.dueDate != null)
                            LabelPill(
                              label: 'Due ${formatDate(item.dueDate!)}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (value) {
                    if (value == 'edit') {
                      showExpenseDialog(context, item: item);
                    } else if (value == 'delete') {
                      controller.deleteExpense(item);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit bill')),
                    PopupMenuItem(value: 'delete', child: Text('Delete bill')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ExpenseAmountBlock(
                    label: 'Total',
                    value: moneyOrDash(item.totalAmount),
                  ),
                ),
                Expanded(
                  child: _ExpenseAmountBlock(
                    label: 'Paid',
                    value: moneyOrDash(item.paidAmount),
                  ),
                ),
                Expanded(
                  child: _ExpenseAmountBlock(
                    label: 'Pending',
                    value: moneyOrDash(item.displayPending),
                    emphasize: item.displayPending > 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PaymentProgressBar(item: item),
            if (item.needsRepayment || item.repaymentPending > 0) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB85D75).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFB85D75).withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assignment_return_rounded,
                      color: Color(0xFFB85D75),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.isRepaymentCompleted
                            ? 'Repayment completed'
                            : 'Repay ${moneyOrDash(item.repayAmount)}${repaymentName.isEmpty ? '' : ' to $repaymentName'}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (!item.isRepaymentCompleted && item.repaymentPending > 0)
                      TextButton(
                        onPressed: () =>
                            controller.markRepaymentCompleted(item),
                        child: const Text('Done'),
                      ),
                  ],
                ),
              ),
            ],
            if (item.notes.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                item.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: item.pendingForSummary == 0
                        ? null
                        : () =>
                              showAddExpensePaymentDialog(context, item: item),
                    icon: const Icon(Icons.add_card_rounded),
                    label: const Text('Add payment'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: () => _showPaymentActivityDialog(context, item),
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'Payment activity',
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: () => showExpenseDialog(context, item: item),
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Edit',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPaymentActivityDialog(
  BuildContext context,
  ExpenseItem item,
) async {
  await showDialog<void>(
    context: context,
    builder: (context) => _PaymentActivityDialog(item: item),
  );
}

class _PaymentActivityDialog extends StatelessWidget {
  const _PaymentActivityDialog({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: ThemeColors.surfaceGradient is LinearGradient
                ? ThemeColors.surfaceGradient as LinearGradient
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.surface, ThemeColors.inputBackground],
                  ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: ThemeColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment activity',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.name.isEmpty ? 'Untitled bill' : item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PaymentProgressBar(item: item),
                      const SizedBox(height: 14),
                      if (item.paymentSplit.isEmpty)
                        const PremiumEmptyState(
                          icon: Icons.history_rounded,
                          title: 'No payment activity yet',
                          subtitle:
                              'Add a partial payment and the transaction history will appear here.',
                        )
                      else
                        _ExpensePaymentActivity(item: item),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentProgressBar extends StatelessWidget {
  const _PaymentProgressBar({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final progress = item.totalAmount == 0
        ? 0.0
        : (item.paidForSummary / item.totalAmount).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: ThemeColors.logoGold.withValues(alpha: 0.16),
            color: ThemeColors.weddingTeal,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                '${(progress * 100).round()}% paid',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${moneyOrDash(item.pendingForSummary)} remaining',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExpensePaymentActivity extends StatelessWidget {
  const _ExpensePaymentActivity({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final payments = [...item.paymentSplit]
      ..sort((a, b) => a.date.compareTo(b.date));
    var runningPaid = 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Payment activity',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${payments.length}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...payments.map((payment) {
            runningPaid += payment.amount;
            final remaining = (item.totalAmount - runningPaid)
                .clamp(0, double.infinity)
                .toDouble();
            return _PaymentTimelineRow(payment: payment, remaining: remaining);
          }),
        ],
      ),
    );
  }
}

class _PaymentTimelineRow extends StatelessWidget {
  const _PaymentTimelineRow({required this.payment, required this.remaining});

  final PaymentSplit payment;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final payer = payment.paidBy.trim().isEmpty
        ? 'Self'
        : payment.paidBy.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              color: ThemeColors.weddingTeal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${moneyOrDash(payment.amount)} paid by $payer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDate(payment.date)} | ${moneyOrDash(remaining)} pending',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (payment.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    payment.notes.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseAmountBlock extends StatelessWidget {
  const _ExpenseAmountBlock({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final color = emphasize
        ? ThemeColors.logoGold
        : Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
