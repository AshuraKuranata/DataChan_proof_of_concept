import 'package:flutter/material.dart';
import 'package:proof_of_concept_v1/components/scanlist/scanlist_component.dart';

/// Scan list view that displays all saved barcode/OCR scan results.
/// 
/// This view provides:
/// - List of all scans with timestamps
/// - View details of individual scans
/// - Delete scans
/// - Refresh scan list
class ScanListView extends StatelessWidget {
  const ScanListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScanListComponent();
  }
}

