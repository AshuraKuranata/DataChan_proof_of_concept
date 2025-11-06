import 'package:flutter/material.dart';
import 'package:proof_of_concept_v1/services/scan_data_storage_service.dart';

// Component that displays a list of saved scan results (barcodes and OCR data).
// Shows scan history with options to view details and delete scans.
class ScanListComponent extends StatefulWidget {
  const ScanListComponent({super.key});

  @override
  State<ScanListComponent> createState() => _ScanListComponentState();
}

// State for ScanListComponent.
// 
// Manages loading and displaying scan history from local storage.
class _ScanListComponentState extends State<ScanListComponent> {
  late Future<List<ScanData>> _scansFuture;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  // Load scans from local storage
  void _loadScans() {
    _scansFuture = ScanDataStorageService.getSavedScans();
  }

  // Refresh the scan list by reloading scans
  Future<void> _refreshScans() async {
    setState(() {
      _loadScans();
    });
  }

  // Delete a scan and refresh the list
  Future<void> _deleteScan(String scanId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scan'),
        content: const Text('Are you sure you want to delete this scan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ScanDataStorageService.deleteScan(scanId);
      _refreshScans();
    }
  }

  // Show details of a scan
  void _showScanDetails(ScanData scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${scan.timestamp.toString().split('.')[0]}'),
              const SizedBox(height: 12),
              if (scan.barcodes.isNotEmpty) ...[
                const Text('Barcodes:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...scan.barcodes.map((barcode) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('• $barcode'),
                )),
                const SizedBox(height: 12),
              ],
              if (scan.ocrText.isNotEmpty) ...[
                const Text('OCR Text:', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(scan.ocrText, maxLines: 5, overflow: TextOverflow.ellipsis),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        elevation: 0,
      ),
      body: FutureBuilder<List<ScanData>>(
        future: _scansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading scans: ${snapshot.error}'),
            );
          }

          final scans = snapshot.data ?? [];

          if (scans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scans yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan images to see results here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshScans,
            child: ListView.builder(
              itemCount: scans.length,
              itemBuilder: (context, index) {
                final scan = scans[scans.length - 1 - index]; // Reverse order (newest first)
                return ScanListTile(
                  scan: scan,
                  onTap: () => _showScanDetails(scan),
                  onDelete: () => _deleteScan(scan.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Individual scan list tile widget
class ScanListTile extends StatelessWidget {
  final ScanData scan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ScanListTile({
    super.key,
    required this.scan,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          scan.barcodes.isNotEmpty ? Icons.qr_code : Icons.text_fields,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          scan.barcodes.isNotEmpty
              ? 'Barcode: ${scan.barcodes.first}'
              : 'OCR Scan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scan.timestamp.toString().split('.')[0],
              style: const TextStyle(fontSize: 12),
            ),
            if (scan.ocrText.isNotEmpty)
              Text(
                scan.ocrText.split('\n').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onTap,
              child: const Text('View Details'),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Text('Delete'),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

