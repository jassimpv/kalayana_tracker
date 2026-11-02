import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

enum PlanningKind {
  vendor,
  task,
  gift,
  contribution,
  document,
  categoryBudget,
  repayment,
}

/// A workspace planning record. Money is stored as integer minor units.
class PlanningEntry {
  const PlanningEntry({
    required this.id,
    required this.kind,
    required this.name,
    this.amountMinor = 0,
    this.receivedMinor = 0,
    this.date,
    this.status = '',
    this.category = '',
    this.contact = '',
    this.phone = '',
    this.email = '',
    this.notes = '',
    this.assignee = '',
    this.priority = 'Normal',
    this.stage = '',
    this.linkedId = '',
    this.url = '',
    this.dependencies = const [],
  });

  final String id;
  final PlanningKind kind;
  final String name;
  final int amountMinor;
  final int receivedMinor;
  final DateTime? date;
  final String status;
  final String category;
  final String contact;
  final String phone;
  final String email;
  final String notes;
  final String assignee;
  final String priority;
  final String stage;
  final String linkedId;
  final String url;
  final List<String> dependencies;

  double get amount => amountMinor / 100;
  double get received => receivedMinor / 100;
  bool get isDone => status == 'Completed' || status == 'Cancelled';

  factory PlanningEntry.fromJson(Map<String, dynamic> json) => PlanningEntry(
    id: json['id'] as String,
    kind: PlanningKind.values.byName(json['kind'] as String),
    name: json['name'] as String,
    amountMinor: (json['amountMinor'] as num? ?? 0).toInt(),
    receivedMinor: (json['receivedMinor'] as num? ?? 0).toInt(),
    date: dateFromJson(json['date']),
    status: json['status'] as String? ?? '',
    category: json['category'] as String? ?? '',
    contact: json['contact'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    assignee: json['assignee'] as String? ?? '',
    priority: json['priority'] as String? ?? 'Normal',
    stage: json['stage'] as String? ?? '',
    linkedId: json['linkedId'] as String? ?? '',
    url: json['url'] as String? ?? '',
    dependencies: (json['dependencies'] as List<dynamic>? ?? [])
        .map((value) => value as String)
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'name': name,
    'amountMinor': amountMinor,
    'receivedMinor': receivedMinor,
    'date': date?.toIso8601String(),
    'status': status,
    'category': category,
    'contact': contact,
    'phone': phone,
    'email': email,
    'notes': notes,
    'assignee': assignee,
    'priority': priority,
    'stage': stage,
    'linkedId': linkedId,
    'url': url,
    'dependencies': dependencies,
  };
}
