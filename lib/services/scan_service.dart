import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Service for handling barcode scanning and OCR (Optical Character Recognition).
// Provides methods to scan barcodes (UPC, EAN, QR codes) and extract text from images.
//
// For Developer Review:
// - Uses Google ML Kit for actual barcode scanning (supports UPC, EAN, QR codes, etc.)
// - Uses Google ML Kit for actual OCR (text recognition)
// - Supports multiple barcode formats: UPC-A, UPC-E, EAN-13, EAN-8, Code 128, Code 39, Code 93, Codabar, ITF, etc.
class ScanService {
  // Scan an image for barcodes and QR codes
  // Returns a list of detected barcodes with their values
  //
  // - Uses Google ML Kit for actual barcode scanning
  // - Supports UPC-A, UPC-E, EAN-13, EAN-8, Code 128, Code 39, Code 93, Codabar, ITF, and QR codes
  static Future<List<BarcodeResult>> scanBarcodes(String imagePath) async {
    try {
      debugPrint('Scanning barcodes from: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return [];
      }

      // Create barcode scanner instance with options for UPC and EAN formats
      final barcodeScanner = BarcodeScanner(
        formats: [
          BarcodeFormat.upca,
          BarcodeFormat.upce,
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.codabar,
          BarcodeFormat.itf,
          BarcodeFormat.qrCode,
        ],
      );

      try {
        // Create input image from file
        final inputImage = InputImage.fromFilePath(imagePath);

        // Scan for barcodes
        final barcodes = await barcodeScanner.processImage(inputImage);

        // Convert ML Kit barcodes to our BarcodeResult model
        final results = barcodes.map((barcode) {
          return BarcodeResult(
            value: barcode.displayValue ?? barcode.rawValue ?? '',
            format: _getBarcodeFormatName(barcode.format),
            rawValue: barcode.rawValue,
          );
        }).toList();

        debugPrint('Found ${results.length} barcodes');
        return results;
      } finally {
        await barcodeScanner.close();
      }
    } catch (e) {
      debugPrint('Error scanning barcodes: $e');
      return [];
    }
  }

  // Helper method to convert ML Kit barcode format to readable string
  static String _getBarcodeFormatName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.unknown:
        return 'Unknown';
      case BarcodeFormat.all:
        return 'All';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.code93:
        return 'Code 93';
      case BarcodeFormat.codabar:
        return 'Codabar';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.itf:
        return 'ITF';
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.upca:
        return 'UPC-A';
      case BarcodeFormat.upce:
        return 'UPC-E';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.aztec:
        return 'Aztec';
    }
  }

  // Perform OCR (Optical Character Recognition) on an image
  // Returns extracted text from the image
  //
  // - Uses Google ML Kit Text Recognition for actual OCR
  // - Extracts all text from the image
  static Future<String> performOCR(String imagePath) async {
    try {
      debugPrint('Performing OCR on: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return '';
      }

      // Create text recognizer instance
      final textRecognizer = TextRecognizer();

      try {
        // Create input image from file
        final inputImage = InputImage.fromFilePath(imagePath);

        // Recognize text in the image
        final recognizedText = await textRecognizer.processImage(inputImage);

        // Extract all text from the recognized text object
        final extractedText = recognizedText.text;

        debugPrint('OCR completed. Text length: ${extractedText.length}');
        return extractedText;
      } finally {
        await textRecognizer.close();
      }
    } catch (e) {
      debugPrint('Error performing OCR: $e');
      return '';
    }
  }

  // Scan an image for both barcodes and text
  // Returns a combined result with barcodes and extracted text
  //
  // - Performs barcode scanning and OCR in parallel for efficiency
  // - Returns combined ScanResult with both barcodes and text
  static Future<ScanResult> scanImage(String imagePath) async {
    try {
      debugPrint('Scanning image for barcodes and text: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return ScanResult(barcodes: [], text: '');
      }

      // Scan for barcodes and text in parallel for better performance
      final barcodesFuture = scanBarcodes(imagePath);
      final textFuture = performOCR(imagePath);

      final barcodes = await barcodesFuture;
      final text = await textFuture;

      return ScanResult(barcodes: barcodes, text: text);
    } catch (e) {
      debugPrint('Error scanning image: $e');
      return ScanResult(barcodes: [], text: '');
    }
  }

  // Recognize store type from image (Safeway/Albertsons or Costco)
  // For Developer Review:
  // - Analyzes image to identify store tags/labels
  // - Uses OCR to detect store-specific text patterns
  // - Returns "Safeway/Albertsons", "Costco", or null if unable to determine
  // - This is a placeholder implementation that uses OCR text analysis
  // - In production, this could use image classification ML models
  static Future<String?> recognizeStoreType(String imagePath) async {
    try {
      debugPrint('Recognizing store type from: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return null;
      }

      // Perform OCR to extract text from image
      final extractedText = await performOCR(imagePath);

      // Analyze text for store-specific keywords
      final lowerText = extractedText.toLowerCase();

      // Check for Costco indicators
      if (lowerText.contains('costco') ||
          lowerText.contains('warehouse') ||
          lowerText.contains('member')) {
        debugPrint('Detected Costco store type');
        return 'Costco';
      }

      // Check for Safeway/Albertsons indicators
      if (lowerText.contains('safeway') ||
          lowerText.contains('albertsons') ||
          lowerText.contains('albertson')) {
        debugPrint('Detected Safeway/Albertsons store type');
        return 'Safeway/Albertsons';
      }

      // If no specific store indicators found, return null
      debugPrint('Unable to determine store type from image');
      return null;
    } catch (e) {
      debugPrint('Error recognizing store type: $e');
      return null;
    }
  }

  // Extract product information from OCR text
  // For Developer Review:
  // - Extracts product name from the first line of OCR text
  // - Attempts to extract price and unit price from OCR text
  // - Looks for common price patterns like "$X.XX" or "X.XX"
  // - Returns ProductInfo with extracted data
  static Future<ProductInfo> extractProductInfo(String ocrText) async {
    try {
      debugPrint('Extracting product information from OCR text');

      final lines = ocrText.split('\n');
      String? productName;
      double? price;
      double? unitPrice;

      // Extract product name from first non-empty line
      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          productName = line.trim();
          break;
        }
      }

      // Extract prices from OCR text using regex patterns
      final pricePattern = RegExp(r'\$?\s*(\d+\.\d{2}|\d+)');
      final matches = pricePattern.allMatches(ocrText);

      if (matches.isNotEmpty) {
        // First price found is typically the total price
        final firstMatch = matches.first.group(1);
        if (firstMatch != null) {
          price = double.tryParse(firstMatch);
        }

        // If there are multiple prices, second one might be unit price
        if (matches.length > 1) {
          final secondMatch = matches.elementAt(1).group(1);
          if (secondMatch != null) {
            unitPrice = double.tryParse(secondMatch);
          }
        }
      }

      debugPrint('Extracted product info: name=$productName, price=$price, unitPrice=$unitPrice');
      return ProductInfo(
        productName: productName,
        price: price,
        unitPrice: unitPrice,
      );
    } catch (e) {
      debugPrint('Error extracting product information: $e');
      return ProductInfo(productName: null, price: null, unitPrice: null);
    }
  }
}

// Result model for barcode scanning
class BarcodeResult {
  final String value;
  final String format;
  final String? rawValue;

  BarcodeResult({
    required this.value,
    required this.format,
    this.rawValue,
  });

  @override
  String toString() => 'BarcodeResult(value: $value, format: $format)';
}

// Combined barcode and OCR scanning result
class ScanResult {
  final List<BarcodeResult> barcodes;
  final String text;

  ScanResult({
    required this.barcodes,
    required this.text,
  });

  bool get hasBarcodes => barcodes.isNotEmpty;
  bool get hasText => text.isNotEmpty;
  bool get hasResults => hasBarcodes || hasText;

  @override
  String toString() =>
      'Scan Result(barcodes: ${barcodes.length}, text length: ${text.length})';
}

// Product information extracted from OCR text
class ProductInfo {
  final String? productName;
  final double? price;
  final double? unitPrice;

  ProductInfo({
    required this.productName,
    required this.price,
    required this.unitPrice,
  });

  @override
  String toString() => 'ProductInfo(name: $productName, price: $price, unitPrice: $unitPrice)';
}

