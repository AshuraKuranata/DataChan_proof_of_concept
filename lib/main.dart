/* Main Build */

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:proof_of_concept_v1/views/homepage.dart';
import 'package:proof_of_concept_v1/views/cameraview.dart';
import 'package:proof_of_concept_v1/views/gallery.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataChan Proof of Concept',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'DataChan Proof of Concept'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
            ),
          ),
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

  Widget _buildView(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return CameraView(camera: cameras.first);
      case 2:
        return const GalleryView();
      default:
        return const HomePage();
    }
  }
}