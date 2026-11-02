import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

class InvoiceBillData {
  const InvoiceBillData({
    required this.isInvoice,
    required this.confidenceScore,
    required this.vendorName,
    required this.invoiceNumber,
    required this.category,
    required this.totalAmount,
    required this.paidAmount,
    required this.invoiceDate,
    required this.dueDate,
    required this.notes,
  });

  factory InvoiceBillData.fromJson(Map<String, dynamic> json) {
    return InvoiceBillData(
      isInvoice: json['is_invoice'] == true,
      confidenceScore: numberFromJson(json['confidence_score']) ?? 0,
      vendorName: json['vendor_name']?.toString().trim() ?? '',
      invoiceNumber: json['invoice_number']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? 'General',
      totalAmount: numberFromJson(json['total_amount']) ?? 0,
      paidAmount: numberFromJson(json['paid_amount']) ?? 0,
      invoiceDate: dateFromJson(json['invoice_date']),
      dueDate: dateFromJson(json['due_date']),
      notes: json['notes']?.toString().trim() ?? '',
    );
  }

  final bool isInvoice;
  final double confidenceScore;
  final String vendorName;
  final String invoiceNumber;
  final String category;
  final double totalAmount;
  final double paidAmount;
  final DateTime? invoiceDate;
  final DateTime? dueDate;
  final String notes;

  Map<String, dynamic> toJson() => {
    'is_invoice': isInvoice,
    'confidence_score': confidenceScore,
    'vendor_name': vendorName,
    'invoice_number': invoiceNumber,
    'category': category,
    'total_amount': totalAmount,
    'paid_amount': paidAmount,
    'invoice_date': invoiceDate?.toIso8601String(),
    'due_date': dueDate?.toIso8601String(),
    'notes': notes,
  };

  String get expenseName {
    if (vendorName.isNotEmpty) return vendorName;
    if (invoiceNumber.isNotEmpty) return 'Invoice $invoiceNumber';
    return 'Scanned invoice';
  }

  String get billNotes {
    final parts = <String>[
      if (invoiceNumber.isNotEmpty) 'Invoice: $invoiceNumber',
      if (invoiceDate != null) 'Invoice date: ${formatDate(invoiceDate!)}',
      if (notes.isNotEmpty) notes,
    ];
    return parts.join('\n');
  }
}
