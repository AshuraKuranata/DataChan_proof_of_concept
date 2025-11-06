import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:proof_of_concept_v1/services/image_storage_service.dart';
import 'package:proof_of_concept_v1/services/vision_service.dart';
import 'package:proof_of_concept_v1/services/scan_data_storage_service.dart';
import 'package:proof_of_concept_v1/components/vision/vision_results_component.dart';

// Camera view widget that allows users to capture images.
//
// Displays a live camera preview and provides functionality to:
// - Take pictures
// - Save images to local storage
// - Scan for QR/Barcodes and perform OCR
class CameraView extends StatefulWidget {
  const CameraView({super.key, required this.camera});

  final CameraDescription camera;

  @override
  CameraViewState createState() => CameraViewState();
}

// State for CameraView.
//
// Manages the camera controller and handles image capture.
// Initializes the camera on startup and properly disposes of resources.
class CameraViewState extends State<CameraView> {
  // Controller for managing camera operations
  late CameraController _controller;

  // Future that completes when the camera is initialized
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller with the provided camera
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium, // Use medium resolution for balance between quality and performance
    );

    // Initialize the controller asynchronously
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Camera is initialized, display the live preview
            return CameraPreview(_controller);
          } else {
            // Camera is still initializing, show loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        tooltip: 'Take Picture',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  // Capture an image from the camera and navigate to the display screen
  Future<void> _takePicture() async {
    try {
      // Ensure the camera is initialized before taking a picture
      await _initializeControllerFuture;

      // Capture the image
      final image = await _controller.takePicture();

      if (!context.mounted) return;

      // Navigate to the display screen to show the captured image
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }
}

// Widget that displays a captured image and provides options to save or scan it.
//
// Allows users to:
// - View the captured image in full screen
// - Save the image to local storage
// - Scan the image for QR/Barcodes and perform OCR
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

// State for DisplayPictureScreen.
//
// Manages the image display and handles save/scan operations.
class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  // Flag indicating if the image is being saved
  bool _isSaving = false;

  // Flag indicating if the image is being scanned
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(widget.imagePath)),
      floatingActionButton: _isSaving || _isScanning
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'scan_btn',
                  onPressed: _scanImage,
                  tooltip: 'Scan for QR/Barcode and OCR',
                  child: const Icon(Icons.qr_code_scanner),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'save_btn',
                  onPressed: _saveImage,
                  tooltip: 'Save Image',
                  child: const Icon(Icons.save),
                ),
              ],
            ),
    );
  }

  // Save the image to local storage using ImageStorageService.
  //
  // Shows a success message and navigates back if successful,
  // or shows an error message if the save fails (e.g., storage limit exceeded).
  Future<void> _saveImage() async {
    setState(() {
      _isSaving = true;
    });

    // Attempt to save the image to local storage
    final savedPath = await ImageStorageService.saveImage(widget.imagePath);

    if (!context.mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (savedPath != null) {
      // Image saved successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to camera view
      Navigator.of(context).pop();
    } else {
      // Save failed (likely due to storage limit)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save image. Storage limit may be exceeded.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Scan the image for QR/Barcodes and perform OCR.
  //
  // Uses VisionService to detect barcodes and extract text from the image.
  // Saves the scan results to local storage and navigates to VisionResultsComponent.
  //
  // For Developer Review:
  // - Scans image using VisionService
  // - Saves results to ScanDataStorageService
  // - Displays results in VisionResultsComponent
  Future<void> _scanImage() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Scan the image for barcodes and text
      final result = await VisionService.scanImage(widget.imagePath);

      if (!context.mounted) return;

      // Save scan results to local storage
      final scanData = ScanData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: widget.imagePath,
        barcodes: result.barcodes.map((b) => b.value).toList(),
        ocrText: result.text,
        timestamp: DateTime.now(),
      );

      await ScanDataStorageService.saveScanResult(scanData);

      setState(() {
        _isScanning = false;
      });

      // Navigate to results screen to display scan results
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VisionResultsComponent(
            result: result,
            onClose: () => Navigator.pop(context),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      setState(() {
        _isScanning = false;
      });

      // Show error message if scanning fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning image: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
