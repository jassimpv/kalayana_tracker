import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GuestReportActions extends GetView<GuestsController> {
  const GuestReportActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showReportActionSheet(
            context: context,
            title: 'Guest List Report',
            filename: 'guest-list.pdf',
            buildPdf: () => _buildGuestListPdf(controller.guests),
          ),
          icon: const Icon(Icons.list_alt_rounded, size: 18),
          label: const Text('Guest List PDF'),
        ),
        OutlinedButton.icon(
          onPressed: () => _showReportActionSheet(
            context: context,
            title: 'RSVP Summary Report',
            filename: 'rsvp-summary.pdf',
            buildPdf: () => _buildRsvpSummaryPdf(controller),
          ),
          icon: const Icon(Icons.fact_check_rounded, size: 18),
          label: const Text('RSVP Summary PDF'),
        ),
        OutlinedButton.icon(
          onPressed: () => _showReportActionSheet(
            context: context,
            title: 'Event Attendance Report',
            filename: 'event-attendance.pdf',
            buildPdf: () => _buildEventAttendancePdf(controller),
          ),
          icon: const Icon(Icons.event_available_rounded, size: 18),
          label: const Text('Event Attendance PDF'),
        ),
        OutlinedButton.icon(
          onPressed: () => _exportGuestListCsv(context, controller.guests),
          icon: const Icon(Icons.table_view_rounded, size: 18),
          label: const Text('Export Guest List CSV'),
        ),
      ],
    );
  }
}

enum _ReportAction { view, share, download }

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
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
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

Future<pw.ThemeData> _pdfTheme() async {
  final font = await PdfGoogleFonts.notoSansRegular();
  final boldFont = await PdfGoogleFonts.notoSansBold();
  return pw.ThemeData.withFont(base: font, bold: boldFont);
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
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

pw.TableRow _pdfTableHeaderRow(List<String> headers) {
  return pw.TableRow(
    decoration: pw.BoxDecoration(color: _pdfBrandColorLight),
    children: headers
        .map(
          (h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: pw.Text(h, style: _pdfLabelStyle()),
          ),
        )
        .toList(),
  );
}

pw.TableRow _pdfTableRow(List<String> cells) {
  return pw.TableRow(
    children: cells
        .map(
          (c) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: pw.Text(c, style: const pw.TextStyle(fontSize: 9.5)),
          ),
        )
        .toList(),
  );
}

Future<Uint8List> _buildGuestListPdf(List<Guest> guests) async {
  final logo = await _pdfBrandLogo();
  final theme = await _pdfTheme();
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      build: (context) => [
        _pdfReportHeader('Guest List Report', '${guests.length} Guests', logo),
        pw.SizedBox(height: 14),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2.2),
            1: pw.FlexColumnWidth(1.6),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(1.2),
            4: pw.FlexColumnWidth(0.8),
          },
          children: [
            _pdfTableHeaderRow([
              'Name',
              'Phone',
              'Side',
              'Category',
              'Invited',
            ]),
            ...guests.map(
              (g) => _pdfTableRow([
                g.name,
                g.effectiveWhatsapp,
                g.side,
                g.category,
                '${g.numberInvited}',
              ]),
            ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

Future<Uint8List> _buildRsvpSummaryPdf(GuestsController controller) async {
  final logo = await _pdfBrandLogo();
  final theme = await _pdfTheme();
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      build: (context) => [
        _pdfReportHeader(
          'RSVP Summary Report',
          '${controller.totalGuests} Guests',
          logo,
        ),
        pw.SizedBox(height: 14),
        pw.Row(
          children: [
            _pdfSummaryBox('Confirmed', '${controller.confirmedCount}'),
            pw.SizedBox(width: 8),
            _pdfSummaryBox('Declined', '${controller.declinedCount}'),
            pw.SizedBox(width: 8),
            _pdfSummaryBox('Maybe', '${controller.maybeCount}'),
            pw.SizedBox(width: 8),
            _pdfSummaryBox('Pending', '${controller.pendingCount}'),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            _pdfTableHeaderRow(['Guest', 'Event', 'Status', 'Attendees']),
            ...controller.responses.map((response) {
              final guest = controller.guests.firstWhereOrNull(
                (g) => g.id == response.guestId,
              );
              final event = controller.events.firstWhereOrNull(
                (e) => e.id == response.eventId,
              );
              return _pdfTableRow([
                guest?.name ?? response.guestId,
                event?.name ?? response.eventId,
                response.status,
                '${response.attendeeCount}',
              ]);
            }),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

Future<Uint8List> _buildEventAttendancePdf(GuestsController controller) async {
  final logo = await _pdfBrandLogo();
  final theme = await _pdfTheme();
  final doc = pw.Document();
  final summary = controller.eventWiseSummary;
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      build: (context) => [
        _pdfReportHeader(
          'Event Attendance Report',
          '${controller.events.length} Events',
          logo,
        ),
        pw.SizedBox(height: 14),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            _pdfTableHeaderRow([
              'Event',
              'Confirmed',
              'Declined',
              'Maybe',
              'Pending',
              'Expected',
            ]),
            ...summary.map(
              (s) => _pdfTableRow([
                s.event.name,
                '${s.confirmed}',
                '${s.declined}',
                '${s.maybe}',
                '${s.pending}',
                '${s.expectedAttendees}',
              ]),
            ),
          ],
        ),
      ],
    ),
  );
  return doc.save();
}

Future<void> _exportGuestListCsv(
  BuildContext context,
  List<Guest> guests,
) async {
  final buffer = StringBuffer()
    ..writeln('Name,Phone,WhatsApp,Side,Category,Number Invited,Address,Notes');
  for (final guest in guests) {
    buffer.writeln(
      [
        guest.name,
        guest.phone,
        guest.whatsapp,
        guest.side,
        guest.category,
        guest.numberInvited,
        guest.address,
        guest.notes,
      ].map(_csvCell).join(','),
    );
  }
  try {
    final bytes = Uint8List.fromList(buffer.toString().codeUnits);
    final savedPath = await FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(data: bytes, fileName: 'guest-list.csv'),
    );
    if (!context.mounted || savedPath == null) return;
    Get.snackbar(
      'CSV exported',
      'Saved to $savedPath',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (error) {
    if (!context.mounted) return;
    Get.snackbar(
      'CSV export failed',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

String _csvCell(Object? value) {
  final text = value?.toString() ?? '';
  if (text.contains(',') || text.contains('"') || text.contains('\n')) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}
