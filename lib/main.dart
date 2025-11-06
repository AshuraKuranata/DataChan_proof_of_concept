// Main entry point for the DataChan Proof of Concept application.
//
// This application demonstrates a Flutter-based camera and gallery system with
// image storage capabilities. It provides:
// - Camera functionality to capture images
// - Local storage management with 25MB limit
// - Gallery view to display saved images
// - QR/Barcode scanning and OCR capabilities (placeholder)

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:proof_of_concept_v1/views/homepage.dart';
import 'package:proof_of_concept_v1/views/cameraview.dart';
import 'package:proof_of_concept_v1/views/gallery.dart';
import 'package:proof_of_concept_v1/views/scanlist.dart';

// Global list of available cameras on the device.
// Initialized during app startup to ensure camera availability.
late List<CameraDescription> cameras;

// Application entry point.
//
// Initializes Flutter bindings and retrieves available cameras before
// launching the app. This ensures the camera is ready when needed.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

// Root widget of the application.
//
// Configures the MaterialApp with theme and home page.
// Uses a deep purple color scheme for the application theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataChan Proof of Concept',
      theme: ThemeData(
        // Apply a deep purple color scheme throughout the app
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'DataChan Proof of Concept'),
    );
  }
}

// Main home page widget that manages navigation between different views.
//
// This is a stateful widget that maintains the selected navigation index
// and displays the appropriate view based on user selection.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State for MyHomePage.
//
// Manages the navigation rail and displays different views:
// - Home: Welcome screen with quick actions
// - Camera: Camera view for capturing images
// - Gallery: Gallery view for viewing saved images
// - Scan List: View of all saved barcode/OCR scan results
class _MyHomePageState extends State<MyHomePage> {
  // Currently selected navigation index (0=Home, 1=Camera, 2=Gallery, 3=ScanList)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          // Left navigation rail with four destinations
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.camera),
                  label: Text("Snap Picture"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.image),
                  label: Text("Gallery"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.qr_code_scanner),
                  label: Text("Scans"),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
            ),
          ),
          // Main content area that displays the selected view
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: _buildView(_selectedIndex),
            ),
          )
        ],
      ),
    );
  }

  // Build the appropriate view based on the selected index.
  //
  // Returns:
  // - HomePage for index 0
  // - CameraView for index 1
  // - GalleryView for index 2
  // - ScanListView for index 3
  Widget _buildView(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return CameraView(camera: cameras.first);
      case 2:
        return const GalleryView();
      case 3:
        return const ScanListView();
      default:
        return const HomePage();
    }
  }
}