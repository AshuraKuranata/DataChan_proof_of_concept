/* Main Build */

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'components/camera/camera.dart';

void main() async {
  // Camera functionality
  
  // Ensures plugin services are initialized for 'avaliableCameras()' to be called
  // before 'runApp()' 
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain list of available cameras in device
  final cameras = await availableCameras();
  // Select specific camera from list of available cameras
  final firstCamera = cameras.first;

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: Center(

      ),

    );
  }
}
