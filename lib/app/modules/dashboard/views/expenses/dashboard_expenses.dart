part of '../dashboard_view.dart';

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
      onAdd: () => Navigator.of(context).push(
        buildNestedDashboardRoute(
          settings: const RouteSettings(name: AppRoutes.dashboardExpenseAdd),
          child: const ExpenseAddPage(),
          transitionDuration: const Duration(milliseconds: 280),
          startOffset: const Offset(0.12, 0),
        ),
      ),
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final paidCount = widget.expenses
        .where((item) => expenseShortStatus(item) == 'Paid')
        .length;
    final pendingCount = widget.expenses
        .where((item) => expenseShortStatus(item) == 'Pending')
        .length;
    final partialCount = widget.expenses
        .where((item) => expenseShortStatus(item) == 'Partial')
        .length;
    final repaymentCount = widget.expenses
        .where((item) => item.repaymentPending > 0)
        .length;
    final overdueCount = widget.expenses.where((item) => item.isOverdue).length;
    final filters = [
      _ExpenseFilter('All', widget.expenses.length, Icons.receipt_long_rounded),
      _ExpenseFilter('Paid', paidCount, Icons.check_circle_outline_rounded),
      _ExpenseFilter('Pending', pendingCount, Icons.schedule_rounded),
      _ExpenseFilter('Partial', partialCount, Icons.pie_chart_rounded),
      _ExpenseFilter('Repay', repaymentCount, Icons.assignment_return_rounded),
      _ExpenseFilter('Overdue', overdueCount, Icons.warning_rounded),
    ];
    final filteredExpenses = widget.expenses
        .where((item) => _matchesExpenseFilter(item, _selectedFilter))
        .where((item) => _matchesExpenseQuery(item, _query))
        .toList();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDF4EC), Color(0xFFFFF8F0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ExpensesHero(),
          Transform.translate(
            offset: const Offset(0, -22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _ExpenseSearchPanel(
                filters: filters,
                selectedFilter: _selectedFilter,
                onQueryChanged: (value) => setState(() => _query = value),
                onFilterChanged: (value) => setState(() {
                  _selectedFilter = value;
                }),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _ExpenseListHeader(
              visibleCount: filteredExpenses.length,
              totalCount: widget.expenses.length,
              selectedFilter: _selectedFilter,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: widget.expenses.isEmpty
                ? _ExpenseEmptyLedger(onTap: widget.onAdd)
                : filteredExpenses.isEmpty
                ? _ExpenseEmptyLedger(
                    title: _query.trim().isEmpty
                        ? 'No $_selectedFilter expenses'
                        : 'No matching expenses',
                    subtitle: 'Try another search term or status filter.',
                    onTap: widget.onAdd,
                  )
                : Column(
                    children: filteredExpenses
                        .map((item) => _ExpenseBillCard(item: item))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExpensesHero extends StatelessWidget {
  const _ExpensesHero();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      height: top + 260,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 44, 24, 0),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.25,
          colors: [Color(0xFFC71053), Color(0xFF8F1438), Color(0xFF5A0820)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -120,
            left: 120,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE03A72).withValues(alpha: 0.28),
              ),
            ),
          ),
          Positioned(
            right: -92,
            bottom: -54,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF5B35B).withValues(alpha: 0.22),
                  width: 1.4,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 78,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          Positioned(
            right: 154,
            top: 116,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8B75C), Color(0xFFC95154)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8B75C).withValues(alpha: 0.24),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 44),
              Text(
                'Expenses',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Track every expense, stay on budget',
                style: TextStyle(
                  color: Color(0xFFF7C859),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseSearchPanel extends StatelessWidget {
  const _ExpenseSearchPanel({
    required this.filters,
    required this.selectedFilter,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  final List<_ExpenseFilter> filters;
  final String selectedFilter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoDeep.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          _ExpenseSearchField(onChanged: onQueryChanged),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 12,
              children: filters
                  .map(
                    (filter) => _ExpenseFilterChip(
                      filter: filter,
                      selected: filter.label == selectedFilter,
                      onTap: () => onFilterChanged(filter.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseSearchField extends StatelessWidget {
  const _ExpenseSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      cursorColor: ThemeColors.primary,
      style: const TextStyle(
        color: ThemeColors.logoDeep,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: 'Search by bill, category, payer...',
        hintStyle: TextStyle(
          color: ThemeColors.logoDeep.withValues(alpha: 0.40),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: ThemeColors.primary.withValues(alpha: 0.92),
          size: 30,
        ),
        suffixIcon: Container(
          width: 64,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF2DFDB)),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: ThemeColors.primary.withValues(alpha: 0.96),
            size: 27,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFEFDCD7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFEFDCD7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: ThemeColors.primary.withValues(alpha: 0.42),
          ),
        ),
      ),
    );
  }
}

class _ExpenseFilter {
  const _ExpenseFilter(this.label, this.count, this.icon);

  final String label;
  final int count;
  final IconData icon;
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
    final color = _expenseFilterColor(filter.label);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 48,
          constraints: const BoxConstraints(minWidth: 96),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF9A123A), Color(0xFFC30B4A)],
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFFEFDCD7),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ThemeColors.primary.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  filter.icon,
                  size: 21,
                  color: selected ? Colors.white : color,
                ),
                const SizedBox(width: 8),
                Text(
                  filter.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : ThemeColors.logoDeep,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${filter.count}',
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.86)
                        : ThemeColors.logoDeep.withValues(alpha: 0.45),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _expenseFilterColor(String label) {
  return switch (label) {
    'Paid' => const Color(0xFF159154),
    'Pending' => const Color(0xFFD49A00),
    'Partial' => const Color(0xFFE06012),
    'Repay' => const Color(0xFF9E2ED6),
    'Overdue' => const Color(0xFFE9395C),
    _ => ThemeColors.primary,
  };
}

// ignore: unused_element
class _ExpenseDashboardHero extends StatelessWidget {
  const _ExpenseDashboardHero({
    required this.total,
    required this.pending,
    required this.repayment,
    required this.billCount,
    required this.onAdd,
  });

  final double total;
  final double pending;
  final double repayment;
  final int billCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      padding: const EdgeInsets.all(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7A1230), Color(0xFF9D1740), Color(0xFF3A1117)],
      ),
      borderColor: Colors.white24,
      child: Stack(
        children: [
          const Positioned(
            right: -54,
            top: -64,
            child: _BlurCircle(
              color: Color(0xFFE8B75C),
              size: 170,
              alpha: 0.18,
            ),
          ),
          const Positioned(
            left: -70,
            bottom: -82,
            child: _BlurCircle(
              color: Color(0xFFFFE4B8),
              size: 160,
              alpha: 0.10,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$billCount wedding bills',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.74),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${formatMoney(total)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 0.96,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pending <= 0
                        ? 'Every recorded bill is settled.'
                        : '${moneyOrDash(pending)} pending${repayment > 0 ? ' + ${moneyOrDash(repayment)} repayment' : ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
              final action = FilledButton.icon(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ThemeColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Add expense'),
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 18), action],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 20),
                  action,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExpenseListHeader extends StatelessWidget {
  const _ExpenseListHeader({
    required this.visibleCount,
    required this.totalCount,
    required this.selectedFilter,
  });

  final int visibleCount;
  final int totalCount;
  final String selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            selectedFilter == 'All'
                ? 'Expense ledger'
                : '$selectedFilter bills',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ThemeColors.logoDeep,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$visibleCount of $totalCount',
          style: const TextStyle(
            color: Color(0xFFD17B14),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          CupertinoIcons.chevron_right,
          color: Color(0xFFD17B14),
          size: 18,
        ),
      ],
    );
  }
}

class _ExpenseEmptyLedger extends StatelessWidget {
  const _ExpenseEmptyLedger({
    this.title = 'No expenses added yet',
    this.subtitle = 'Create your first wedding expense to start tracking.',
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: ThemeColors.primary,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ThemeColors.logoDeep,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF78656A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onTap, child: const Text('Add expense')),
        ],
      ),
    );
  }
}

bool _matchesExpenseFilter(ExpenseItem item, String filter) {
  return switch (filter) {
    'All' => true,
    'Repay' => item.repaymentPending > 0,
    'Overdue' => item.isOverdue,
    _ => expenseShortStatus(item) == filter,
  };
}

bool _matchesExpenseQuery(ExpenseItem item, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  final fields = [
    item.name,
    item.category,
    item.paidBy,
    item.repayPerson,
    item.notes,
    item.status,
  ];
  return fields.any((value) => value.toLowerCase().contains(needle));
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
    final status = item.repaymentPending > 0
        ? 'Need to Repay'
        : expenseShortStatus(item);
    final color = _expenseLedgerColor(status);
    final categoryColor = _expenseCategoryColor(item.category);
    final categoryIcon = _expenseCategoryIcon(item.category);
    final repaymentName = item.repayPerson.trim().isEmpty
        ? item.paidBy.trim()
        : item.repayPerson.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openExpenseDetail(context, item.id),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1D9D5)),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.logoDeep.withValues(alpha: 0.07),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFBE7E5),
                    ),
                    child: Icon(categoryIcon, color: color, size: 34),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isEmpty ? 'Untitled bill' : item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 9,
                          children: [
                            _ExpenseLedgerPill(
                              label: status,
                              color: color,
                              filled: true,
                            ),
                            _ExpenseLedgerPill(
                              label: item.category,
                              color: categoryColor,
                            ),
                            if (item.paymentSplit.isNotEmpty)
                              _ExpenseLedgerPill(
                                label:
                                    '${item.paymentSplit.length} payment${item.paymentSplit.length == 1 ? '' : 's'}',
                                color: const Color(0xFF4A3A32),
                                icon: Icons.credit_card_rounded,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: Color(0xFF302328),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        showExpenseDialog(context, item: item);
                      } else if (value == 'delete') {
                        controller.deleteExpense(item);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit bill')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete bill'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: _ExpenseAmountBlock(
                      label: 'Total',
                      value: moneyOrDash(item.totalAmount),
                      color: ThemeColors.primary,
                    ),
                  ),
                  _ExpenseAmountDivider(),
                  Expanded(
                    child: _ExpenseAmountBlock(
                      label: 'Paid',
                      value: moneyOrDash(item.paidAmount),
                      color: ThemeColors.primary,
                    ),
                  ),
                  _ExpenseAmountDivider(),
                  Expanded(
                    child: _ExpenseAmountBlock(
                      label: 'Pending',
                      value: moneyOrDash(item.displayPending),
                      color: const Color(0xFFD18A00),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _PaymentProgressBar(item: item),
              if (item.needsRepayment || item.repaymentPending > 0) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9E5).withValues(alpha: 0.84),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF2D4CE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ThemeColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.assignment_return_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.isRepaymentCompleted
                              ? 'Repayment completed'
                              : 'Repay ${moneyOrDash(item.repayAmount)}${repaymentName.isEmpty ? '' : ' to $repaymentName'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (!item.isRepaymentCompleted &&
                          item.repaymentPending > 0)
                        TextButton.icon(
                          onPressed: () =>
                              controller.markRepaymentCompleted(item),
                          icon: const Icon(CupertinoIcons.check_mark_circled),
                          label: const Text('Done'),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: FilledButton.icon(
                        onPressed: item.pendingForSummary == 0
                            ? null
                            : () => showAddExpensePaymentDialog(
                                context,
                                item: item,
                              ),
                        style: FilledButton.styleFrom(
                          backgroundColor: ThemeColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFEADAD6),
                          disabledForegroundColor: const Color(0xFF9B8884),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(CupertinoIcons.plus, size: 25),
                        label: const Text(
                          'Add payment',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  _ExpenseCircleAction(
                    icon: Icons.history_rounded,
                    label: 'History',
                    onTap: () => _showPaymentActivityDialog(context, item),
                  ),
                  const SizedBox(width: 14),
                  _ExpenseCircleAction(
                    icon: Icons.pie_chart_rounded,
                    label: 'Breakdown',
                    onTap: () => showExpenseDialog(context, item: item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openExpenseDetail(BuildContext context, String expenseId) {
  Navigator.of(context).push(
    buildNestedDashboardRoute(
      settings: RouteSettings(
        name: AppRoutes.dashboardExpenseDetail,
        arguments: expenseId,
      ),
      child: ExpenseDetailPage(expenseId: expenseId),
      transitionDuration: const Duration(milliseconds: 280),
      startOffset: const Offset(0.12, 0),
    ),
  );
}

class _ExpenseLedgerPill extends StatelessWidget {
  const _ExpenseLedgerPill({
    required this.label,
    required this.color,
    this.filled = false,
    this.icon,
  });

  final String label;
  final Color color;
  final bool filled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.13) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: filled ? Colors.transparent : color.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseAmountDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFFEED8D4),
    );
  }
}

class _ExpenseCircleAction extends StatelessWidget {
  const _ExpenseCircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 74,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF5E5),
                border: Border.all(color: const Color(0xFFF2DDBD)),
              ),
              child: Icon(icon, color: const Color(0xFFD18A00), size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF7A5A45),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _expenseLedgerColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('repay')) return const Color(0xFF4422D8);
  if (normalized.contains('paid')) return const Color(0xFF159154);
  if (normalized.contains('partial')) return const Color(0xFF6A38D6);
  if (normalized.contains('overdue')) return const Color(0xFFE9395C);
  return const Color(0xFFD18A00);
}

Color _expenseCategoryColor(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('home') || normalized.contains('work')) {
    return const Color(0xFF6D3A27);
  }
  if (normalized.contains('invite')) return const Color(0xFF6A38D6);
  if (normalized.contains('food')) return const Color(0xFFE06012);
  if (normalized.contains('decor')) return const Color(0xFFD18A00);
  return const Color(0xFF6D3A27);
}

IconData _expenseCategoryIcon(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('invite')) return CupertinoIcons.envelope_fill;
  if (normalized.contains('photo')) return CupertinoIcons.camera_fill;
  if (normalized.contains('food')) return Icons.restaurant_rounded;
  if (normalized.contains('decor')) return Icons.celebration_rounded;
  if (normalized.contains('jewel')) return Icons.diamond_rounded;
  if (normalized.contains('travel')) return CupertinoIcons.airplane;
  if (normalized.contains('venue')) return Icons.storefront_rounded;
  return Icons.storefront_rounded;
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
            minHeight: 10,
            value: progress,
            backgroundColor: const Color(0xFFFFEFD7),
            color: ThemeColors.primary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                '${(progress * 100).round()}% paid',
                style: const TextStyle(
                  color: ThemeColors.logoDeep,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${moneyOrDash(item.pendingForSummary)} remaining',
              style: const TextStyle(
                color: Color(0xFFD18A00),
                fontSize: 15,
                fontWeight: FontWeight.w900,
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
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final valueColor = color ?? Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E6D5D),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
