import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  String _selectedLabel = '';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/gaze_estimation_model.tflite',
      );
      setState(() {
        _isModelLoaded = true;
      });
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  // Process the gaze data (dummy implementation for now)
  void _processGaze(String label) {
    setState(() {
      _selectedLabel = label;
    });

    // In real implementation, use the model's inference to select the label
    // Example: based on gaze prediction, update the selected label
    print('$label selected');
  }

  @override
  void dispose() {
    _interpreter.close(); // Close the interpreter to release resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two buttons per row
            crossAxisSpacing: 16, // Space between columns
            mainAxisSpacing: 16, // Space between rows
          ),
          itemCount: 4, // Now 4 items only
          itemBuilder: (context, index) {
            final labels = [
              'Food',
              'Medicine',
              'Toilet',
              'Water',
            ];

            return GestureDetector(
              onTap: () {
                // Process gaze prediction and select the appropriate label
                _processGaze(labels[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedLabel == labels[index]
                      ? Colors.green
                      : Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
