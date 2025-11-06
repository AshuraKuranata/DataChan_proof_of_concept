import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Service for managing scan data storage (barcode/OCR results).
// Handles saving, retrieving, and managing scan results with a maximum size limit of 25 MB.
class ScanDataStorageService {
  static const int maxStorageSizeMB = 25;
  static const int maxStorageSizeBytes = maxStorageSizeMB * 1024 * 1024;
  static const String scanDataDirectoryName = 'scan_data';
  static const String scanDataFileName = 'scans.json';

  // Get the directory where scan data is stored
  static Future<Directory> getScanDataDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final scanDir = Directory(path.join(appDir.path, scanDataDirectoryName));

    // Create directory if it doesn't exist
    if (!await scanDir.exists()) {
      await scanDir.create(recursive: true);
    }

    return scanDir;
  }

  /// Get the scan data file
  static Future<File> _getScanDataFile() async {
    final scanDir = await getScanDataDirectory();
    return File(path.join(scanDir.path, scanDataFileName));
  }

  // Save a scan result to local storage
  // Returns true if save was successful, false otherwise
  static Future<bool> saveScanResult(ScanData scanData) async {
    try {
      final scanFile = await _getScanDataFile();

      // Check current storage usage
      final currentSize = await _getDirectorySize(await getScanDataDirectory());
      final newDataSize = jsonEncode(scanData.toJson()).length;

      if (currentSize + newDataSize > maxStorageSizeBytes) {
        debugPrint('Scan storage limit exceeded. Current: $currentSize, New: $newDataSize, Max: $maxStorageSizeBytes');
        return false;
      }

      // Load existing scans
      List<ScanData> scans = await getSavedScans();

      // Add new scan
      scans.add(scanData);

      // Save all scans
      final jsonData = jsonEncode(scans.map((s) => s.toJson()).toList());
      await scanFile.writeAsString(jsonData);

      debugPrint('Scan saved successfully: ${scanData.id}');
      return true;
    } catch (e) {
      debugPrint('Error saving scan: $e');
      return false;
    }
  }

  // Get all saved scans
  static Future<List<ScanData>> getSavedScans() async {
    try {
      final scanFile = await _getScanDataFile();

      if (!await scanFile.exists()) {
        return [];
      }

      final jsonString = await scanFile.readAsString();
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((item) => ScanData.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading scans: $e');
      return [];
    }
  }

  // Delete a scan by ID
  static Future<bool> deleteScan(String scanId) async {
    try {
      List<ScanData> scans = await getSavedScans();
      scans.removeWhere((scan) => scan.id == scanId);

      final scanFile = await _getScanDataFile();
      final jsonData = jsonEncode(scans.map((s) => s.toJson()).toList());
      await scanFile.writeAsString(jsonData);

      debugPrint('Scan deleted: $scanId');
      return true;
    } catch (e) {
      debugPrint('Error deleting scan: $e');
      return false;
    }
  }

  // Get storage usage in bytes
  static Future<int> getStorageUsage() async {
    return _getDirectorySize(await getScanDataDirectory());
  }

  // Get remaining storage in bytes
  static Future<int> getRemainingStorage() async {
    final used = await getStorageUsage();
    return maxStorageSizeBytes - used;
  }

  // Calculate directory size recursively
  static Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        dir.listSync(recursive: true, followLinks: false).forEach((file) {
          if (file is File) {
            size += file.lengthSync();
          }
        });
      }
    } catch (e) {
      debugPrint('Error calculating directory size: $e');
    }
    return size;
  }
}

// Model for storing scan data
class ScanData {
  final String id;
  final String imagePath;
  final List<String> barcodes;
  final String ocrText;
  final DateTime timestamp;
  final String? notes;

  ScanData({
    required this.id,
    required this.imagePath,
    required this.barcodes,
    required this.ocrText,
    required this.timestamp,
    this.notes,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'barcodes': barcodes,
      'ocrText': ocrText,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from JSON
  factory ScanData.fromJson(Map<String, dynamic> json) {
    return ScanData(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      barcodes: List<String>.from(json['barcodes'] as List),
      ocrText: json['ocrText'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() => 'ScanData(id: $id, barcodes: ${barcodes.length}, timestamp: $timestamp)';
}

