import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // Get available cameras
  await loadModel(); // Load the model at startup
  runApp(Look2SpeakApp());
}

// Load the TensorFlow Lite model using tflite_flutter
Future<void> loadModel() async {
  try {
    final interpreterOptions = InterpreterOptions()..threads = 4;
    await Interpreter.fromAsset(
      'assets/models/gaze_estimation_model.tflite',
      options: interpreterOptions,
    );
    print('Model loaded successfully');
  } catch (e) {
    print('Error loading model: $e');
  }
}

class Look2SpeakApp extends StatelessWidget {
  const Look2SpeakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Look2Speak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(cameras: cameras),
    );
  }
}
