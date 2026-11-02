import 'package:kalayanaexpresstracker/app/core/localization/translation_service.dart';
import 'package:kalayanaexpresstracker/app/core/localization/localized_widgets.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/planning_entry.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/planning/workspace_backup.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

const _titles = {
  PlanningKind.vendor: 'Vendors',
  PlanningKind.task: 'Checklist',
  PlanningKind.gift: 'Gift money received',
  PlanningKind.contribution: 'Family contributions',
  PlanningKind.document: 'Documents',
  PlanningKind.categoryBudget: 'Category budgets',
  PlanningKind.repayment: 'Repayment history',
};
const _icons = {
  PlanningKind.vendor: Icons.storefront_outlined,
  PlanningKind.task: Icons.checklist_rounded,
  PlanningKind.gift: Icons.card_giftcard,
  PlanningKind.contribution: Icons.savings_outlined,
  PlanningKind.document: Icons.attach_file,
  PlanningKind.categoryBudget: Icons.pie_chart_outline,
  PlanningKind.repayment: Icons.currency_exchange,
};
String _money(double value) => '${AppConfig.appCurrency}${formatMoney(value)}';

/// Additional planning tools use the existing workspace and its access controls.
class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key, this.initialKind});
  final PlanningKind? initialKind;

  @override
  Widget build(BuildContext context) {
    if (initialKind != null) return _PlanningList(kind: initialKind!);
    return Scaffold(
      appBar: AppBar(title: const LocalizedText('Wedding planning')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(() {
            final data = Get.find<DashboardController>().data.value;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedText(
                      'Money received',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    LocalizedText('Gifts: ${_money(data.giftsReceived)}'),
                    LocalizedText(
                      'Family contributions: ${_money(data.contributionsReceived)}',
                    ),
                    LocalizedText(
                      'Total received: ${_money(data.fundsReceived)}',
                    ),
                    LocalizedText(
                      'Received less recorded payments: ${_money(data.fundsReceived - data.paid)}',
                    ),
                    const SizedBox(height: 8),
                    const LocalizedText(
                      'Received money is tracked separately from your spending budget.',
                    ),
                  ],
                ),
              ),
            );
          }),
          ...PlanningKind.values.map(
            (kind) => Card(
              child: ListTile(
                leading: Icon(_icons[kind]),
                title: LocalizedText(_titles[kind]!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _PlanningList(kind: kind),
                  ),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.show_chart),
              title: const LocalizedText('Spending trends'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _SpendingInsights(),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const LocalizedText('Backup & restore'),
              subtitle: const LocalizedText(
                'Export or merge a workspace backup',
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const WorkspaceBackupPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanningList extends StatefulWidget {
  const _PlanningList({required this.kind});
  final PlanningKind kind;
  @override
  State<_PlanningList> createState() => _PlanningListState();
}

class _PlanningListState extends State<_PlanningList> {
  final controller = Get.find<DashboardController>();
  String query = '';
  bool openOnly = false;
  bool exporting = false;
  bool templateBusy = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: LocalizedText(_titles[widget.kind]!),
      actions: [
        PopupMenuButton<String>(
          enabled: !exporting,
          onSelected: _export,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'csv', child: LocalizedText('Copy CSV')),
            PopupMenuItem(value: 'pdf', child: LocalizedText('Share PDF')),
          ],
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(),
      icon: const Icon(Icons.add),
      label: const LocalizedText('Add'),
    ),
    body: Obx(() {
      final data = controller.data.value;
      final all = data.entries(widget.kind);
      final entries =
          all
              .where(
                (entry) =>
                    (!openOnly || !entry.isDone) &&
                    '${entry.name} ${entry.category} ${entry.contact} ${entry.notes} ${entry.assignee}'
                        .toLowerCase()
                        .contains(query.toLowerCase()),
              )
              .toList()
            ..sort(
              (a, b) => (b.date ?? DateTime(1970)).compareTo(
                a.date ?? DateTime(1970),
              ),
            );
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          TextField(
            decoration: const LocalizedInputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search',
            ),
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 12),
          _summary(data, all),
          if (widget.kind == PlanningKind.task)
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const LocalizedText('Open tasks'),
                  selected: openOnly,
                  onSelected: (value) => setState(() => openOnly = value),
                ),
                ActionChip(
                  label: const LocalizedText('Add wedding checklist template'),
                  onPressed: templateBusy ? null : _template,
                ),
              ],
            ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: LocalizedText('No records yet. Tap Add to get started.'),
            ),
          ...entries.map(
            (entry) => Card(
              child: ListTile(
                leading: Icon(_icons[entry.kind]),
                title: Text(entry.name),
                subtitle: LocalizedText(_description(entry, data)),
                isThreeLine: true,
                onTap: () => _edit(entry),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'delete') _delete(entry);
                    if (action == 'open') _open(entry.url);
                  },
                  itemBuilder: (_) => [
                    if (entry.url.isNotEmpty)
                      const PopupMenuItem(
                        value: 'open',
                        child: LocalizedText('Open document'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: LocalizedText('Delete'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }),
  );

  Widget _summary(WeddingData data, List<PlanningEntry> entries) {
    String text;
    switch (widget.kind) {
      case PlanningKind.gift:
        text =
            '${entries.length} gifts · Total received ${_money(data.giftsReceived)}';
      case PlanningKind.contribution:
        final pledged = entries.fold<double>(
          0,
          (sum, entry) => sum + entry.amount,
        );
        text =
            'Pledged ${_money(pledged)} · Received ${_money(data.contributionsReceived)} · Outstanding ${_money(pledged - data.contributionsReceived)}';
      case PlanningKind.repayment:
        text =
            'Recorded repayments ${_money(entries.fold<double>(0, (sum, entry) => sum + entry.amount))}\nRemaining owed ${_money(data.repaymentPending)}';
      case PlanningKind.task:
        text =
            '${entries.where((entry) => entry.status == 'Completed').length} of ${entries.length} tasks completed';
      case PlanningKind.categoryBudget:
        text =
            'Allocated ${_money(entries.fold<double>(0, (sum, entry) => sum + entry.amount))} · Overall budget ${_money(data.effectiveBudget)}';
      default:
        text = '${entries.length} records';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LocalizedText(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  String _description(
    PlanningEntry entry,
    WeddingData data, {
    bool localize = true,
  }) {
    String label(String value) =>
        localize ? TranslationService.translate(value) : value;
    final date = entry.date == null
        ? ''
        : localize
        ? formatDisplayDate(entry.date!)
        : formatDate(entry.date!);
    switch (entry.kind) {
      case PlanningKind.gift:
        return '${_money(entry.amount)} · $date\n${entry.category} ${entry.notes}';
      case PlanningKind.contribution:
        return 'Pledged ${_money(entry.amount)} · Received ${_money(entry.received)}\n$date ${entry.notes}';
      case PlanningKind.vendor:
        final expenses = data.expenses.where(
          (expense) => expense.vendorId == entry.id,
        );
        final total = expenses.fold<double>(
          0,
          (sum, expense) => sum + expense.totalAmount,
        );
        final paid = expenses.fold<double>(
          0,
          (sum, expense) => sum + expense.paidForSummary,
        );
        return '${label(entry.category)} · ${label(entry.status)} · ${entry.phone}\nBills ${_money(total)} · Paid ${_money(paid)} · Due ${_money(total - paid)}';
      case PlanningKind.categoryBudget:
        final spent = data.categoryTotals[entry.category] ?? 0;
        return 'Allocated ${_money(entry.amount)} · Committed ${_money(spent)}\n${label(spent > entry.amount ? 'Over budget' : 'Remaining')} ${_money((entry.amount - spent).abs())}';
      case PlanningKind.repayment:
        final expense = data.expenses.firstWhereOrNull(
          (item) => item.id == entry.linkedId,
        );
        return '${_money(entry.amount)} · $date\n${expense?.name ?? 'Expense unavailable'} · ${entry.notes}';
      case PlanningKind.task:
        return '${label(entry.status)} · ${label(entry.priority)} · $date\n${entry.assignee} · ${entry.stage}';
      case PlanningKind.document:
        return '${entry.category} · ${entry.contact}\n${entry.url}';
    }
  }

  Future<void> _edit([PlanningEntry? entry]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _PlanningEditor(kind: widget.kind, entry: entry),
      ),
    );
  }

  Future<void> _delete(PlanningEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LocalizedText('Delete ${entry.name}?'),
        content: const LocalizedText(
          'This will remove the record from your shared workspace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const LocalizedText('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const LocalizedText('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await controller.deletePlanning(entry);
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _template() async {
    if (templateBusy) return;
    setState(() => templateBusy = true);
    final existing = controller.data.value
        .entries(PlanningKind.task)
        .map((entry) => entry.name)
        .toSet();
    try {
      for (final item in const [
        ('Set wedding budget', 'Getting started'),
        ('Confirm guest list', 'Getting started'),
        ('Book venue', 'Bookings'),
        ('Book catering', 'Bookings'),
        ('Book photography', 'Bookings'),
        ('Send invitations', 'Invitations'),
        ('Buy wedding outfits', 'Shopping'),
        ('Prepare marriage documents', 'Documents'),
        ('Confirm final vendor payments', 'Final preparations'),
        ('Confirm guest attendance', 'Final preparations'),
      ]) {
        if (existing.contains(item.$1)) continue;
        await controller.savePlanning(
          PlanningEntry(
            id: newId(),
            kind: PlanningKind.task,
            name: item.$1,
            stage: item.$2,
            status: 'Pending',
          ),
        );
      }
      _message('Checklist template added. Existing tasks were preserved.');
    } catch (error) {
      _message(error.toString());
    } finally {
      if (mounted) setState(() => templateBusy = false);
    }
  }

  Future<void> _export(String format) async {
    setState(() => exporting = true);
    try {
      final entries = controller.data.value.entries(widget.kind);
      final rows = <List<String>>[
        [
          'Name',
          'Amount',
          'Received',
          'Date',
          'Status',
          'Category',
          'Contact',
          'Phone',
          'Email',
          'Notes',
          'Assignee',
          'Priority',
          'Stage',
          'Linked ID',
          'Document URL',
        ],
        ...entries.map(
          (entry) => [
            entry.name,
            entry.amount.toStringAsFixed(2),
            entry.received.toStringAsFixed(2),
            entry.date?.toIso8601String() ?? '',
            entry.status,
            entry.category,
            entry.contact,
            entry.phone,
            entry.email,
            entry.notes,
            entry.assignee,
            entry.priority,
            entry.stage,
            entry.linkedId,
            entry.url,
          ],
        ),
      ];
      if (format == 'csv') {
        String escape(String value) {
          final safe = RegExp(r'^[\s]*[=+@-]').hasMatch(value)
              ? "'$value"
              : value;
          return '"${safe.replaceAll('"', '""')}"';
        }

        await Clipboard.setData(
          ClipboardData(
            text: rows.map((row) => row.map(escape).join(',')).join('\r\n'),
          ),
        );
        _message('CSV copied. Paste into your spreadsheet.');
      } else {
        final font = await PdfGoogleFonts.notoSansRegular();
        final pdf = pw.Document(theme: pw.ThemeData.withFont(base: font));
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (_) => [
              pw.Text(
                _titles[widget.kind]!,
                style: const pw.TextStyle(fontSize: 22),
              ),
              pw.Text('Currency: ${AppConfig.appCurrency}'),
              ...entries.map(
                (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(entry.name),
                      pw.Text(
                        _description(
                          entry,
                          controller.data.value,
                          localize: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: '${widget.kind.name}-report.pdf',
        );
      }
    } catch (error) {
      _message('Export failed: $error');
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  Future<void> _open(String url) async {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'https' ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Unable to open document.');
      }
    } catch (error) {
      _message(error.toString());
    }
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: LocalizedText(text)));
    }
  }
}

class _PlanningEditor extends StatefulWidget {
  const _PlanningEditor({required this.kind, this.entry});
  final PlanningKind kind;
  final PlanningEntry? entry;
  @override
  State<_PlanningEditor> createState() => _PlanningEditorState();
}

class _PlanningEditorState extends State<_PlanningEditor> {
  final controller = Get.find<DashboardController>();
  final form = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  final dependencies = <String>{};
  DateTime? date;
  String status = '';
  String category = '';
  String priority = 'Normal';
  String linkedId = '';
  bool saving = false;
  String? editingWorkspaceId;
  bool get monetary => [
    PlanningKind.gift,
    PlanningKind.contribution,
    PlanningKind.categoryBudget,
    PlanningKind.repayment,
  ].contains(widget.kind);

  @override
  void initState() {
    super.initState();
    editingWorkspaceId = controller.workspaceId.value;
    final entry = widget.entry;
    final json = entry?.toJson() ?? <String, dynamic>{};
    for (final key in [
      'name',
      'contact',
      'phone',
      'email',
      'notes',
      'assignee',
      'stage',
      'url',
    ]) {
      fields[key] = TextEditingController(text: json[key] as String? ?? '');
    }
    fields['amount'] = TextEditingController(
      text: entry == null ? '' : entry.amount.toStringAsFixed(2),
    );
    fields['received'] = TextEditingController(
      text: entry == null ? '' : entry.received.toStringAsFixed(2),
    );
    date =
        entry?.date ??
        (monetary && widget.kind != PlanningKind.categoryBudget
            ? DateTime.now()
            : null);
    status =
        entry?.status ??
        switch (widget.kind) {
          PlanningKind.vendor => 'Researching',
          PlanningKind.task => 'Pending',
          PlanningKind.gift => 'Received',
          PlanningKind.contribution => 'Pledged',
          PlanningKind.document => 'Saved',
          PlanningKind.categoryBudget => 'Active',
          PlanningKind.repayment => 'Paid',
        };
    category =
        entry?.category ??
        (widget.kind == PlanningKind.categoryBudget
            ? expenseCategories.first
            : '');
    priority = entry?.priority ?? 'Normal';
    linkedId = entry?.linkedId ?? '';
    dependencies.addAll(entry?.dependencies ?? []);
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Widget _text(
    String key,
    String label, {
    bool required = false,
    bool money = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: fields[key],
      decoration: LocalizedInputDecoration(labelText: label),
      maxLines: lines,
      maxLength: key == 'notes'
          ? 2000
          : key == 'url'
          ? 2000
          : 200,
      keyboardType: money
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (value) {
        final text = money
            ? normalizeNumberInput(value?.trim() ?? '')
            : value?.trim() ?? '';
        if (required && text.isEmpty) {
          return TranslationService.translate('Required');
        }
        if (money &&
            text.isNotEmpty &&
            (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text) ||
                double.tryParse(text)?.isFinite != true ||
                (double.tryParse(text) ?? 0) > 9999999999.99)) {
          return TranslationService.translate(
            'Enter a positive amount with up to 2 decimal places',
          );
        }
        if (key == 'url' && text.isNotEmpty) {
          final uri = Uri.tryParse(text);
          if (uri == null ||
              uri.scheme != 'https' ||
              uri.host.isEmpty ||
              uri.userInfo.isNotEmpty) {
            return TranslationService.translate('Enter an HTTPS document link');
          }
        }
        if (key == 'email' &&
            text.isNotEmpty &&
            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
          return TranslationService.translate('Enter a valid email');
        }
        return null;
      },
    ),
  );

  Widget _choice(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> changed,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : options.first,
      decoration: LocalizedInputDecoration(labelText: label),
      items: options
          .map(
            (option) =>
                DropdownMenuItem(value: option, child: LocalizedText(option)),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => changed(value));
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final data = controller.data.value;
    final kind = widget.kind;
    final links = <String, String>{
      if (kind != PlanningKind.repayment) '': 'None',
      if (kind == PlanningKind.document)
        for (final vendor in data.entries(PlanningKind.vendor))
          vendor.id: 'Vendor: ${vendor.name}',
      if (kind == PlanningKind.document || kind == PlanningKind.repayment)
        for (final expense in data.expenses.where(
          (item) => kind != PlanningKind.repayment || item.needsRepayment,
        ))
          expense.id: 'Expense: ${expense.name}',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${TranslationService.translate(widget.entry == null ? 'Add' : 'Edit')} ${TranslationService.translate(_titles[kind]!)}',
        ),
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _text('name', switch (kind) {
              PlanningKind.gift => 'Gift giver name',
              PlanningKind.contribution => 'Contributor name',
              PlanningKind.repayment => 'Paid to',
              _ => 'Name / title',
            }, required: true),
            if (monetary)
              _text(
                'amount',
                kind == PlanningKind.contribution
                    ? 'Pledged amount (${AppConfig.appCurrency})'
                    : 'Amount (${AppConfig.appCurrency})',
                required: true,
                money: true,
              ),
            if (kind == PlanningKind.contribution)
              _text(
                'received',
                'Received amount (${AppConfig.appCurrency})',
                required: true,
                money: true,
              ),
            if (kind == PlanningKind.categoryBudget)
              _choice(
                'Expense category',
                category,
                expenseCategories,
                (value) => category = value,
              )
            else if (kind != PlanningKind.repayment)
              _textCategory(),
            if (kind == PlanningKind.vendor) ...[
              _text('contact', 'Contact person'),
              _text('phone', 'Phone'),
              _text('email', 'Email'),
              _choice('Booking status', status, [
                'Researching',
                'Contacted',
                'Quoted',
                'Booked',
                'Completed',
                'Cancelled',
              ], (value) => status = value),
              const LocalizedText(
                'Link expenses to this vendor from Add/Edit Expense to track bills and payments.',
              ),
              ...data.expenses
                  .where((expense) => expense.vendorId == widget.entry?.id)
                  .map(
                    (expense) => Card(
                      child: ListTile(
                        title: Text(expense.name),
                        subtitle: LocalizedText(
                          'Paid ${_money(expense.paidForSummary)} · Due ${_money(expense.pendingForSummary)}',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          controller.openExpenseDetail(expense.id);
                        },
                      ),
                    ),
                  ),
            ],
            if (kind == PlanningKind.task) ...[
              _choice('Status', status, [
                'Pending',
                'In progress',
                'Completed',
                'Cancelled',
              ], (value) => status = value),
              _choice('Priority', priority, [
                'Low',
                'Normal',
                'High',
              ], (value) => priority = value),
              _text('assignee', 'Task owner'),
              _text('stage', 'Preparation stage'),
              const LocalizedText('Complete these tasks first:'),
              ...data
                  .entries(PlanningKind.task)
                  .where((entry) => entry.id != widget.entry?.id)
                  .map(
                    (entry) => CheckboxListTile(
                      title: Text(entry.name),
                      value: dependencies.contains(entry.id),
                      onChanged: (value) => setState(() {
                        value == true
                            ? dependencies.add(entry.id)
                            : dependencies.remove(entry.id);
                      }),
                    ),
                  ),
            ],
            if (kind == PlanningKind.document || kind == PlanningKind.repayment)
              DropdownButtonFormField<String>(
                initialValue: links.containsKey(linkedId) ? linkedId : null,
                decoration: const LocalizedInputDecoration(
                  labelText: 'Linked record',
                ),
                items: links.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => linkedId = value ?? '',
                validator: (_) =>
                    kind == PlanningKind.repayment &&
                        !links.containsKey(linkedId)
                    ? TranslationService.translate('Select an expense')
                    : null,
              ),
            if (kind == PlanningKind.document) ...[
              const SizedBox(height: 14),
              _text('url', 'Receipt or contract HTTPS link', required: true),
              const LocalizedText(
                'Use a document link your family can access. Files remain with your chosen storage provider.',
              ),
            ],
            if (kind != PlanningKind.categoryBudget) ...[
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: LocalizedText(
                  date == null ? 'Choose date' : formatDisplayDate(date!),
                ),
                trailing: date == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => date = null),
                      ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && mounted) setState(() => date = picked);
                },
              ),
            ],
            _text('notes', 'Notes / payment method / reference', lines: 3),
            FilledButton.icon(
              onPressed: saving ? null : _save,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: LocalizedText(saving ? 'Saving…' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textCategory() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      initialValue: category,
      decoration: const LocalizedInputDecoration(
        labelText: 'Category / occasion',
      ),
      onChanged: (value) => category = value.trim(),
    ),
  );

  Future<void> _save() async {
    if (controller.workspaceId.value != editingWorkspaceId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LocalizedText('Workspace changed. Reopen this form.'),
        ),
      );
      return;
    }
    if (!form.currentState!.validate()) return;
    final kind = widget.kind;
    int minor(String key) =>
        ((double.tryParse(normalizeNumberInput(fields[key]!.text.trim())) ??
                    0) *
                100)
            .round();
    final amount = minor('amount');
    final received = minor('received');
    final data = controller.data.value;
    String? error;
    if (monetary && amount <= 0) error = 'Amount must be greater than zero.';
    if (kind == PlanningKind.contribution && received > amount) {
      error = 'Received amount cannot exceed the pledge.';
    }
    if ([
          PlanningKind.gift,
          PlanningKind.contribution,
          PlanningKind.repayment,
        ].contains(kind) &&
        date == null) {
      error = 'Choose a date.';
    }
    if ([PlanningKind.gift, PlanningKind.repayment].contains(kind) &&
        date != null &&
        date!.isAfter(DateTime.now())) {
      error = 'Received money and repayments cannot have a future date.';
    }
    if (kind == PlanningKind.categoryBudget &&
        data
            .entries(kind)
            .any(
              (entry) =>
                  entry.id != widget.entry?.id && entry.category == category,
            )) {
      error =
          'This category already has a budget. Edit the existing allocation.';
    }
    if (kind == PlanningKind.task) {
      final tasks = {for (final entry in data.entries(kind)) entry.id: entry};
      bool reachesSelf(String id, Set<String> visited) {
        if (id == widget.entry?.id) return true;
        if (!visited.add(id)) return false;
        return tasks[id]?.dependencies.any(
              (next) => reachesSelf(next, visited),
            ) ??
            false;
      }

      if (dependencies.any((id) => reachesSelf(id, {}))) {
        error = 'Task dependencies cannot form a cycle.';
      }
      if (status == 'Completed' &&
          dependencies.any((id) => tasks[id]?.status != 'Completed')) {
        error = 'Complete prerequisite tasks first.';
      }
    }
    if (widget.entry?.kind == PlanningKind.repayment &&
        linkedId != widget.entry!.linkedId) {
      error = 'Delete and recreate a repayment to change its expense.';
    }
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => saving = true);
    try {
      await controller.savePlanning(
        PlanningEntry(
          id: widget.entry?.id ?? newId(),
          kind: kind,
          name: fields['name']!.text.trim(),
          amountMinor: amount,
          receivedMinor: received,
          date: date,
          status: kind == PlanningKind.contribution
              ? (received == amount
                    ? 'Received'
                    : received > 0
                    ? 'Partially received'
                    : 'Pledged')
              : status,
          category: category,
          contact: fields['contact']!.text.trim(),
          phone: fields['phone']!.text.trim(),
          email: fields['email']!.text.trim(),
          notes: fields['notes']!.text.trim(),
          assignee: fields['assignee']!.text.trim(),
          priority: priority,
          stage: fields['stage']!.text.trim(),
          linkedId: linkedId,
          url: fields['url']!.text.trim(),
          dependencies: dependencies.toList(),
        ),
        expected: widget.entry,
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: LocalizedText(error.toString())));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

class _SpendingInsights extends StatefulWidget {
  const _SpendingInsights();
  @override
  State<_SpendingInsights> createState() => _SpendingInsightsState();
}

class _SpendingInsightsState extends State<_SpendingInsights> {
  bool weekly = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const LocalizedText('Spending trends')),
    body: Obx(() {
      final data = Get.find<DashboardController>().data.value;
      final now = DateTime.now();
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      final starts = List.generate(
        6,
        (index) => weekly
            ? startOfWeek.subtract(Duration(days: (5 - index) * 7))
            : DateTime(now.year, now.month - (5 - index)),
      );
      final totals = List<double>.filled(6, 0);
      for (final expense in data.expenses) {
        if (expense.paymentSplit.isEmpty) {
          _add(
            totals,
            starts,
            expense.createdDate,
            expense.paidForSummary,
            weekly,
          );
        } else {
          for (final payment in expense.paymentSplit) {
            _add(totals, starts, payment.date, payment.amount, weekly);
          }
        }
      }
      final maxTotal = math.max(1.0, totals.reduce(math.max));
      final previous = totals[4];
      final difference = totals[5] - previous;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: LocalizedText('Monthly')),
              ButtonSegment(value: true, label: LocalizedText('Weekly')),
            ],
            selected: {weekly},
            onSelectionChanged: (values) =>
                setState(() => weekly = values.first),
          ),
          const SizedBox(height: 20),
          const LocalizedText(
            'Actual payments by payment date. The current period is still in progress.',
          ),
          LocalizedText(
            'Current period ${_money(totals[5])} · Previous ${_money(previous)}',
          ),
          LocalizedText(
            'Change ${difference >= 0 ? '+' : '-'}${_money(difference.abs())}${previous == 0 ? '' : ' (${(difference / previous * 100).toStringAsFixed(1)}%)'}',
          ),
          const SizedBox(height: 20),
          ...List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weekly ? formatDisplayDate(starts[index]) : '${starts[index].year}-${starts[index].month.toString().padLeft(2, '0')}'} · ${_money(totals[index])}',
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: totals[index] / maxTotal,
                    minHeight: 14,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          LocalizedText('Received gifts ${_money(data.giftsReceived)}'),
          LocalizedText(
            'Received contributions ${_money(data.contributionsReceived)}',
          ),
          LocalizedText('Committed expenses ${_money(data.totalBudget)}'),
          LocalizedText('Recorded payments ${_money(data.paid)}'),
        ],
      );
    }),
  );
  void _add(
    List<double> totals,
    List<DateTime> starts,
    DateTime date,
    double amount,
    bool weekly,
  ) {
    if (date.isAfter(DateTime.now())) return;
    for (var index = 0; index < starts.length; index++) {
      final end = weekly
          ? starts[index].add(const Duration(days: 7))
          : DateTime(starts[index].year, starts[index].month + 1);
      if (!date.isBefore(starts[index]) && date.isBefore(end)) {
        totals[index] += amount;
        return;
      }
    }
  }
}
