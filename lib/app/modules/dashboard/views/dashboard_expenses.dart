part of 'dashboard_view.dart';

class ExpensesPanel extends GetView<DashboardController> {
  const ExpensesPanel({super.key, required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold<double>(
      0,
      (sum, item) => sum + item.knownTotal,
    );
    final paid = expenses.fold<double>(
      0,
      (sum, item) => sum + item.paidForSummary,
    );
    final pending = expenses.fold<double>(
      0,
      (sum, item) => sum + item.pendingForSummary,
    );
    final progress = total == 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);
    final overdue = expenses
        .where((item) => item.status == expenseStatusOverdue)
        .length;
    final repaymentTotal = expenses.fold<double>(
      0,
      (sum, item) => sum + item.repaymentPending,
    );
    final splitPaymentCount = expenses
        .where((item) => item.hasSplitPayments || item.hasPartialPayment)
        .length;
    final duePayments =
        expenses.where((item) => item.pendingForSummary > 0).toList()
          ..sort((a, b) {
            final aDate = a.dueDate ?? DateTime(9999);
            final bDate = b.dueDate ?? DateTime(9999);
            return aDate.compareTo(bDate);
          });
    final sorted = [...expenses]
      ..sort((a, b) {
        if (a.repaymentPending > 0 && b.repaymentPending == 0) return -1;
        if (b.repaymentPending > 0 && a.repaymentPending == 0) return 1;
        if (a.pendingForSummary != b.pendingForSummary) {
          return b.pendingForSummary.compareTo(a.pendingForSummary);
        }
        return b.updatedDate.compareTo(a.updatedDate);
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScreenHero(
          eyebrow: 'Bills & repayments',
          title: 'Expense tracker',
          subtitle:
              '${expenses.length} bills | ₹${formatMoney(pending)} pending | ₹${formatMoney(repaymentTotal)} to repay',
          icon: Icons.payments_rounded,
          actionLabel: 'Add expense',
          onAction: () => showExpenseDialog(context),
        ),
        const SizedBox(height: 18),
        _ExpenseSummaryCard(
          total: total,
          paid: paid,
          pending: pending,
          repayment: repaymentTotal,
          progress: progress,
        ),
        const SizedBox(height: 18),
        _ExpenseStatusStrip(
          billCount: expenses.length,
          overdueCount: overdue,
          pending: pending,
          splitPaymentCount: splitPaymentCount,
        ),
        const SizedBox(height: 18),
        if (duePayments.isNotEmpty) ...[
          _PendingPaymentReminderCard(expenses: duePayments),
          const SizedBox(height: 18),
        ],
        _ExpenseExportCard(expenses: sorted),
        const SizedBox(height: 18),
        expenses.isEmpty
            ? const _PremiumEmptyState(
                icon: Icons.payments_rounded,
                title: 'No expenses added yet',
                subtitle:
                    'Create a vendor card and your payment command center appears here.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'Bills', action: 'Review'),
                  const SizedBox(height: 12),
                  ...sorted.map((item) => _ExpenseBillCard(item: item)),
                ],
              ),
      ],
    );
  }
}

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
              _SoftIcon(
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
      child: Row(
        children: [
          _ProgressRing(
            progress: progress,
            color: scheme.primary,
            size: 104,
            stroke: 10,
            center: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
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
                  color: const Color(0xFF0F8B7D),
                  label: 'Paid',
                  value: '₹${formatMoney(paid)}',
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  color: const Color(0xFFD4A373),
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
            ),
          ),
        ],
      ),
    );
  }
}

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
        color: const Color(0xFF0F8B7D),
      ),
      _MiniExpenseMetric(
        icon: Icons.schedule_rounded,
        label: 'Pending',
        value: '₹${formatMoney(pending)}',
        color: const Color(0xFFD4A373),
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
        final columns = constraints.maxWidth >= 680 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4 ? 1.35 : 1.55,
          ),
          itemBuilder: (context, index) => metrics[index],
        );
      },
    );
  }
}

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
              _SoftIcon(
                icon: Icons.notification_important_rounded,
                color: const Color(0xFFD4A373),
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
        : const Color(0xFFD4A373);
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
      padding: const EdgeInsets.all(12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withValues(alpha: 0.12), Colors.white],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
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
    );
  }
}

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
                _SoftIcon(icon: Icons.storefront_rounded, color: color),
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
                        const _PremiumEmptyState(
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
            backgroundColor: const Color(0xFFD4A373).withValues(alpha: 0.16),
            color: const Color(0xFF0F8B7D),
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
              color: Color(0xFF0F8B7D),
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
        ? const Color(0xFFD4A373)
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
