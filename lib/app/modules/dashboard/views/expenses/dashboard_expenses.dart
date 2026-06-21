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
      onAdd: controller.openExpenseAdd,
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
    final paidCount = widget.expenses.where((item) => item.isCompleted).length;
    final pendingCount = widget.expenses.length - paidCount;
    final filters = [
      _ExpenseFilter('All', widget.expenses.length, Icons.receipt_long_rounded),
      _ExpenseFilter('Paid', paidCount, Icons.check_circle_outline_rounded),
      _ExpenseFilter('Pending', pendingCount, Icons.schedule_rounded),
    ];
    final filteredExpenses = widget.expenses
        .where((item) => _matchesExpenseFilter(item, _selectedFilter))
        .where((item) => _matchesExpenseQuery(item, _query))
        .toList();
    final mobile = isMobile(context);
    final desktop = isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The desktop shell already shows an "Expenses" title bar above
        // this panel, so the mobile-style gradient hero would just repeat
        // it — skip it on desktop instead of stacking two headers.
        if (!desktop) const _ExpensesHero(),
        Transform.translate(
          offset: desktop ? Offset.zero : const Offset(0, -15),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              mobile ? 18 : 24,
              desktop ? 24 : 0,
              mobile ? 18 : 24,
              0,
            ),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 24),
          child: _ExpenseTaskHeader(),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mobile ? 18 : 24),
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
                : ResponsiveCardGrid(
                    desktopCount: 2,
                    spacing: 14,
                    runSpacing: 14,
                    children: filteredExpenses
                        .map((item) => _ExpenseBillCard(item: item))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ExpensesHero extends StatelessWidget {
  const _ExpensesHero();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      height: top + 100,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, top + 18, 22, 0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
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
            top: -76,
            left: 132,
            child: Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE03A72).withValues(alpha: 0.28),
              ),
            ),
          ),
          Positioned(
            right: -66,
            bottom: -72,
            child: Container(
              width: 154,
              height: 154,
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
            right: 92,
            top: 56,
            child: Container(
              width: 14,
              height: 14,
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
              Text(
                'Expenses',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track every expense, stay on budget',
                style: TextStyle(
                  color: Color(0xFFF7C859),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 9,
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
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Search by bill, category, payer...',
        hintStyle: TextStyle(
          color: ThemeColors.logoDeep.withValues(alpha: 0.40),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: ThemeColors.primary.withValues(alpha: 0.92),
          size: 25,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
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

class _ExpenseTaskHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Expense List',
            style: TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 13),
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
                  size: 19,
                  color: selected ? Colors.white : color,
                ),
                const SizedBox(width: 7),
                Text(
                  filter.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : ThemeColors.logoDeep,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  '${filter.count}',
                  style: TextStyle(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.86)
                        : ThemeColors.logoDeep.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppConfig.appCurrency}${formatMoney(total)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 0.96,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pending <= 0
                        ? 'Every recorded bill is settled.'
                        : '${moneyOrDash(pending)} pending${repayment > 0 ? ' + ${moneyOrDash(repayment)} owed' : ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF78656A),
              fontWeight: FontWeight.w500,
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
    'Paid' => item.isCompleted,
    'Pending' => !item.isCompleted,
    _ => true,
  };
}

bool _matchesExpenseQuery(ExpenseItem item, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  final fields = [
    item.name,
    item.category,
    item.displayPaidBy,
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
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Copy CSV or generate a PDF report',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w500,
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
) {
  return _showReportActionSheet(
    context: context,
    title: 'Expenses Report',
    filename: 'kalyana-expenses.pdf',
    buildPdf: () => _buildExpensePdf(expenses, PdfPageFormat.a4),
  );
}

Future<void> _printExpensePaymentsPdf(
  BuildContext context,
  List<ExpenseItem> expenses,
) {
  return _showReportActionSheet(
    context: context,
    title: 'Payment Expenses Report',
    filename: 'kalyana-expense-payments.pdf',
    buildPdf: () => _buildExpensePaymentsPdf(expenses, PdfPageFormat.a4),
  );
}

enum _ReportAction { view, share, download }

/// Lets the user pick how to open a generated report instead of jumping
/// straight into the OS print/share flow.
Future<void> _showReportActionSheet({
  required BuildContext context,
  required String title,
  required String filename,
  required Future<Uint8List> Function() buildPdf,
}) async {
  final action = await showModalBottomSheet<_ReportAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.visibility_outlined),
            title: const Text('View report'),
            onTap: () => Navigator.pop(sheetContext, _ReportAction.view),
          ),
          ListTile(
            leading: const Icon(Icons.ios_share_rounded),
            title: const Text('Share report'),
            onTap: () => Navigator.pop(sheetContext, _ReportAction.share),
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Download report'),
            onTap: () => Navigator.pop(sheetContext, _ReportAction.download),
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  try {
    final bytes = await buildPdf();
    if (!context.mounted) return;
    switch (action) {
      case _ReportAction.view:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _ReportPreviewPage(title: title, bytes: bytes),
          ),
        );
      case _ReportAction.share:
        await Printing.sharePdf(bytes: bytes, filename: filename);
      case _ReportAction.download:
        final savedPath = await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(data: bytes, fileName: filename),
        );
        if (!context.mounted || savedPath == null) return;
        Get.snackbar(
          'Report downloaded',
          'Saved to $savedPath',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  } catch (error) {
    if (!context.mounted) return;
    Get.snackbar(
      'PDF export failed',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _ReportPreviewPage extends StatelessWidget {
  const _ReportPreviewPage({required this.title, required this.bytes});

  final String title;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (format) => bytes,
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: false,
        allowSharing: false,
      ),
    );
  }
}

final PdfColor _pdfBrandColor = PdfColor.fromInt(0xFF8F1438);
final PdfColor _pdfBrandColorLight = PdfColor.fromInt(0xFFFBEAEF);

pw.TextStyle _pdfLabelStyle() => pw.TextStyle(
  color: PdfColors.grey700,
  fontSize: 9,
  fontWeight: pw.FontWeight.bold,
);

Future<pw.MemoryImage> _pdfBrandLogo() async {
  final bytes = await rootBundle.load('assets/logo.png');
  return pw.MemoryImage(bytes.buffer.asUint8List());
}

pw.Widget _pdfSummaryBox(String label, String value) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _pdfBrandColorLight,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border(
          left: pw.BorderSide(color: _pdfBrandColor, width: 3),
          top: const pw.BorderSide(color: PdfColors.grey300),
          right: const pw.BorderSide(color: PdfColors.grey300),
          bottom: const pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: _pdfLabelStyle()),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _pdfBrandColor,
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Widget _pdfReportHeader(
  String title,
  String countLabel,
  pw.MemoryImage logo,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.ClipRRect(
            horizontalRadius: 8,
            verticalRadius: 8,
            child: pw.Image(logo, width: 38, height: 38, fit: pw.BoxFit.cover),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  AppConfig.appName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _pdfBrandColor,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: pw.BoxDecoration(
              color: _pdfBrandColor,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              countLabel,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        'Generated on ${formatDate(DateTime.now())}',
        style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
      ),
      pw.SizedBox(height: 10),
      pw.Container(height: 2, color: _pdfBrandColor),
    ],
  );
}

Future<Uint8List> _buildExpensePdf(
  List<ExpenseItem> expenses,
  PdfPageFormat format,
) async {
  final font = await PdfGoogleFonts.notoSansRegular();
  final boldFont = await PdfGoogleFonts.notoSansBold();
  final logo = await _pdfBrandLogo();
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

  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => [
        _pdfReportHeader(
          'Kalyana Expense Report',
          '${expenses.length} bills',
          logo,
        ),
        pw.SizedBox(height: 18),
        pw.Row(
          children: [
            _pdfSummaryBox('Total', _pdfMoney(total)),
            pw.SizedBox(width: 8),
            _pdfSummaryBox('Paid', _pdfMoney(paid)),
            pw.SizedBox(width: 8),
            _pdfSummaryBox('Pending', _pdfMoney(pending)),
            pw.SizedBox(width: 8),
            _pdfSummaryBox('Owed', _pdfMoney(repayment)),
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
      ],
    ),
  );

  return doc.save();
}

Future<Uint8List> _buildExpensePaymentsPdf(
  List<ExpenseItem> expenses,
  PdfPageFormat format,
) async {
  final font = await PdfGoogleFonts.notoSansRegular();
  final boldFont = await PdfGoogleFonts.notoSansBold();
  final logo = await _pdfBrandLogo();
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
  final paymentCount = expenses.fold<int>(
    0,
    (sum, item) => sum + item.paymentSplit.length,
  );
  final doc = pw.Document(
    title: 'Kalyana Payment Expenses Report',
    theme: pw.ThemeData.withFont(base: font, bold: boldFont),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(28),
      build: (context) => [
        _pdfReportHeader(
          'Kalyana Payment Expenses Report',
          '$paymentCount payments',
          logo,
        ),
        pw.SizedBox(height: 18),
        pw.Row(
          children: [
            _pdfSummaryBox('Paid', _pdfMoney(paid)),
            pw.SizedBox(width: 8),
            _pdfSummaryBox('Pending', _pdfMoney(pending)),
            pw.SizedBox(width: 8),
            _pdfSummaryBox('Owed', _pdfMoney(repayment)),
          ],
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
          payment.displayPaidBy,
          _pdfMoney(remaining),
          payment.notes.trim().isEmpty ? '-' : payment.notes.trim(),
        ];
      }).toList(),
    ),
    pw.SizedBox(height: 12),
  ];
}

String _pdfMoney(double value) =>
    '${AppConfig.appCurrency} ${formatMoney(value)}';

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
      'Owed To',
      'Amount Owed',
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
        item.displayPaidBy,
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppConfig.appCurrency}${formatMoney(total)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'total bill value',
                style: TextStyle(
                  color: scheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              _LegendRow(
                color: ThemeColors.weddingTeal,
                label: 'Paid',
                value: '${AppConfig.appCurrency}${formatMoney(paid)}',
              ),
              const SizedBox(height: 8),
              _LegendRow(
                color: ThemeColors.logoGold,
                label: 'Pending',
                value: '${AppConfig.appCurrency}${formatMoney(pending)}',
              ),
              if (repayment > 0) ...[
                const SizedBox(height: 8),
                _LegendRow(
                  color: const Color(0xFFB85D75),
                  label: 'You owe',
                  value: '${AppConfig.appCurrency}${formatMoney(repayment)}',
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
        value: '${AppConfig.appCurrency}${formatMoney(pending)}',
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
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Upcoming balances and amounts you owe',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w500,
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                moneyOrDash(item.pendingForSummary),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                dueLabel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
class _ExpenseBillCard extends StatelessWidget {
  const _ExpenseBillCard({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final status = item.repaymentPending > 0
        ? 'You Owe'
        : expenseShortStatus(item);
    final statusColor = _expenseLedgerColor(status);
    final categoryIcon = _expenseCategoryIcon(item.category);
    final repaymentName = item.repayPerson.trim().isEmpty
        ? item.displayPaidBy
        : item.repayPerson.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openExpenseDetail(context, item.id),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1D9D5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemeColors.primary.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: ThemeColors.primary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isEmpty ? 'Untitled bill' : item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: _ExpenseCardChip(
                                label: item.category.isEmpty
                                    ? 'General'
                                    : item.category,
                                color: ThemeColors.primary,
                                icon: categoryIcon,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ExpenseCardChip(
                        label: status,
                        color: statusColor,
                        filled: true,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ThemeColors.logoGold.withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
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
              ),
              const SizedBox(height: 10),
              _PaymentProgressBar(item: item),
              if (item.needsRepayment || item.repaymentPending > 0) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_return_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.isRepaymentCompleted
                              ? 'Paid back'
                              : 'You owe ${moneyOrDash(item.repaymentAmount)}${repaymentName.isEmpty ? '' : ' to $repaymentName'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseCardChip extends StatelessWidget {
  const _ExpenseCardChip({
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 128),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: filled ? 0.0 : 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _openExpenseDetail(BuildContext context, String expenseId) {
  Get.find<DashboardController>().openExpenseDetail(expenseId);
}

class _ExpenseAmountDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: const Color(0xFFEED8D4),
    );
  }
}

Color _expenseLedgerColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('owe')) return const Color(0xFF4422D8);
  if (normalized.contains('paid')) return const Color(0xFF159154);
  if (normalized.contains('partial')) return const Color(0xFF6A38D6);
  if (normalized.contains('overdue')) return const Color(0xFFE9395C);
  return const Color(0xFFD18A00);
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
            minHeight: 6,
            value: progress,
            backgroundColor: const Color(0xFFFFEFD7),
            color: ThemeColors.primary,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: Text(
                '${(progress * 100).round()}% paid',
                style: const TextStyle(
                  color: ThemeColors.logoDeep,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${moneyOrDash(item.pendingForSummary)} remaining',
              style: const TextStyle(
                color: Color(0xFFD18A00),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
