import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

class GeminiInovieAppData {
  GeminiInovieAppData({String? apiKey, String? endpoint})
    : apiKey =
          apiKey ??
          const String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''),
      geminiEndpoint =
          endpoint ??
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent';

  final String apiKey;
  final String geminiEndpoint;

  Future<InvoiceBillData> extractInvoice(Uint8List imageBytes) async {
    final payload = {
      'contents': [
        {
          'parts': [
            {'text': _invoicePrompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
    };

    final response = await http.post(
      Uri.parse(geminiEndpoint),
      headers: {'Content-Type': 'application/json', 'X-goog-api-key': apiKey},
      body: jsonEncode(payload),
    );
    if (response.statusCode >= 400) {
      throw StateError('Gemini HTTP ${response.statusCode}: ${response.body}');
    }

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _unwrapCandidateText(decodedResponse);
    return InvoiceBillData.fromJson(_extractJson(text));
  }

  Future<Map<String, dynamic>> estimate(Uint8List imageBytes) async {
    return (await extractInvoice(imageBytes)).toJson();
  }

  String _unwrapCandidateText(Map<String, dynamic> response) {
    final candidates = response['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      for (final candidate in candidates) {
        if (candidate is Map<String, dynamic>) {
          final content = candidate['content'];
          if (content is Map<String, dynamic>) {
            final parts = content['parts'];
            if (parts is List) {
              for (final part in parts) {
                if (part is Map<String, dynamic> && part['text'] is String) {
                  return part['text'] as String;
                }
              }
            }
          }
          if (candidate['text'] is String) {
            return candidate['text'] as String;
          }
        }
      }
    }
    throw StateError('Gemini response missing text output.');
  }

  Map<String, dynamic> _extractJson(String candidate) {
    final start = candidate.indexOf('{');
    final end = candidate.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('Gemini response was not valid JSON.');
    }
    final decoded = jsonDecode(candidate.substring(start, end + 1));
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Decoded payload was not a JSON object.');
  }
}

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

const _invoicePrompt = '''
Act as an invoice and receipt extraction specialist for a wedding expense tracker.
Analyze the attached image and respond with ONLY a valid JSON object. Do not include markdown or explanations.

Rules:
- Set "is_invoice" to true only when the image is a bill, invoice, receipt, quote, or payment receipt.
- Extract values exactly when visible. If a value is missing, use an empty string for text, 0 for numbers, and null for dates.
- Dates must be ISO-8601 format YYYY-MM-DD when visible.
- Numbers must be plain numeric values without currency symbols or commas.
- "paid_amount" should be the amount already paid/advance/deposit. If not visible, use 0.
- Choose "category" from this list only: General, Loan, Venue, Photography, Makeup, Home Work, Dress, Invitation, Travel, Food, Jewelry, Decor.

Return exactly this JSON shape:
{
  "is_invoice": boolean,
  "confidence_score": number,
  "vendor_name": "string",
  "invoice_number": "string",
  "category": "string",
  "total_amount": number,
  "paid_amount": number,
  "invoice_date": "YYYY-MM-DD or null",
  "due_date": "YYYY-MM-DD or null",
  "notes": "string"
}
''';
