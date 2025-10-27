import 'package:tflite_flutter/tflite_flutter.dart';

class GazeEstimator {
  late Interpreter _interpreter;

  GazeEstimator() {
    _loadModel();
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset(
        'assets/models/gaze_estimation_model.tflite');
  }

  // Estimate gaze based on the input data
  List<double> estimateGaze(List<double> inputData) {
    // Create input tensor with the correct shape
    var input = List.generate(inputData.length, (index) => inputData[index]);

    // Prepare an output tensor with 2 values (representing gaze coordinates or results)
    var output = List.filled(2, 0.0);

    // Run inference with the input tensor and get the output
    _interpreter.run(input, output);

    // Return the output as a list of doubles
    return output;
  }
}
