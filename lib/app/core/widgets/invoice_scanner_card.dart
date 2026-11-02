import 'package:kalayanaexpresstracker/app/core/localization/localized_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kalayanaexpresstracker/app/core/services/zai_invoice_service.dart';
import 'package:kalayanaexpresstracker/app/data/models/invoice_bill_data.dart';

class InvoiceScannerCard extends StatefulWidget {
  const InvoiceScannerCard({
    super.key,
    required this.onScanned,
    required this.onBusyChanged,
    this.enabled = true,
  });
  final ValueChanged<InvoiceBillData> onScanned;
  final ValueChanged<bool> onBusyChanged;
  final bool enabled;
  @override
  State<InvoiceScannerCard> createState() => _InvoiceScannerCardState();
}

class _InvoiceScannerCardState extends State<InvoiceScannerCard> {
  bool busy = false;
  Future<void> _scan(ImageSource source) async {
    if (busy || !widget.enabled) return;
    setState(() => busy = true);
    widget.onBusyChanged(true);
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (image == null || !mounted) return;
      final invoice = await ZaiInvoiceService().extractInvoice(
        await image.readAsBytes(),
      );
      if (!mounted) return;
      if (!invoice.isInvoice) {
        throw const InvoiceScanException(
          'The selected image does not look like a bill or receipt.',
        );
      }
      widget.onScanned(invoice);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LocalizedText(
            'Invoice scanned. Review the details before saving.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: LocalizedText(
              error is InvoiceScanException
                  ? error.message
                  : 'Unable to scan this image. Check your connection, image permissions, then try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
        widget.onBusyChanged(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.document_scanner_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: LocalizedText(
                  busy
                      ? 'Reading invoice with Z.ai…'
                      : 'Scan invoice to fill bill',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const LocalizedText(
            'Use a photo or receipt image to fill expense details.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: busy || !widget.enabled
                    ? null
                    : () => _scan(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const LocalizedText('Camera'),
              ),
              OutlinedButton.icon(
                onPressed: busy || !widget.enabled
                    ? null
                    : () => _scan(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const LocalizedText('Choose image'),
              ),
            ],
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    ),
  );
}
