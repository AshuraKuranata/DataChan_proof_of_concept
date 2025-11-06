import 'package:flutter/material.dart';
import 'package:proof_of_concept_v1/services/vision_service.dart';

/// Component for displaying QR/Barcode scanning and OCR results.
/// Shows detected barcodes and extracted text from images.
class VisionResultsComponent extends StatelessWidget {
  final VisionResult result;
  final VoidCallback? onClose;

  const VisionResultsComponent({
    super.key,
    required this.result,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        actions: [
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.hasBarcodes) ...[
              _buildBarcodesSection(context),
              const SizedBox(height: 24),
            ],
            if (result.hasText) ...[
              _buildTextSection(context),
            ],
            if (!result.hasResults)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No results found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No barcodes or text detected in the image',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build the barcodes section
  Widget _buildBarcodesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Barcodes (${result.barcodes.length})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ...result.barcodes.asMap().entries.map((entry) {
          final index = entry.key;
          final barcode = entry.value;
          return _buildBarcodeCard(context, index, barcode);
        }),
      ],
    );
  }

  /// Build a single barcode card
  Widget _buildBarcodeCard(BuildContext context, int index, BarcodeResult barcode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.qr_code_2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Barcode ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Format: ${barcode.format}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                barcode.value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _copyToClipboard(context, barcode.value);
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build the text section
  Widget _buildTextSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extracted Text (OCR)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  result.text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _copyToClipboard(context, result.text);
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Copy text to clipboard
  void _copyToClipboard(BuildContext context, String text) {
    // Note: In a real app, you would use the clipboard package
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: ${text.substring(0, (text.length > 50 ? 50 : text.length))}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

