import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<String> labels;

  const CameraScreen({super.key, required this.cameras, required this.labels});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  Interpreter? _interpreter;
  FlutterTts flutterTts = FlutterTts();
  bool _isDetecting = false;
  String _selectedLabel = '';
  Offset? _eyePosition;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
    _configureTTS();
  }

  void _initializeCamera() async {
    CameraDescription frontCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras[0],
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _cameraController.initialize();
    await _initializeControllerFuture;

    _cameraController.startImageStream((CameraImage frame) {
      if (_interpreter != null) {
        processFrame(frame);
      }
    });

    setState(() {});
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/gaze_estimation_model_optimized.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      print("Model loaded");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  void _configureTTS() {
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(1.0);
  }

  void processFrame(CameraImage frame) async {
    if (_isDetecting || _interpreter == null) return;

    _isDetecting = true;

    img.Image image = await _convertYUV420ToImage(frame);
    img.Image resizedImage = img.copyResize(image, width: 64, height: 64);
    Uint8List byteList = Uint8List.fromList(resizedImage.getBytes());

    var input = [byteList];
    var output = List.filled(2, 0.0).reshape([1, 2]);

    _interpreter!.run(input, output);

    final gazePrediction =
        output[0][0] > output[0][1] ? widget.labels[0] : widget.labels[1];

    updateUI(gazePrediction, output[0]);

    _isDetecting = false;
  }

  Future<img.Image> _convertYUV420ToImage(CameraImage frame) async {
    final Plane plane = frame.planes[0];
    final Uint8List bytes = plane.bytes;
    final int width = frame.width;
    final int height = frame.height;

    img.Image image = img.Image(width, height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = bytes[y * width + x];
        int gray = ((pixel & 0xFF) * 0.3 +
                ((pixel >> 8) & 0xFF) * 0.59 +
                ((pixel >> 16) & 0xFF) * 0.11)
            .toInt();
        image.setPixel(x, y, img.getColor(gray, gray, gray));
      }
    }
    return image;
  }

  void updateUI(String gazePrediction, List<double> output) {
    setState(() {
      _selectedLabel = gazePrediction;
      _eyePosition = _mapGazeToScreen(output);
    });
  }

  Offset _mapGazeToScreen(List<double> output) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Offset(output[0] * screenWidth, output[1] * screenHeight);
  }

  void _speak(String message) async {
    await flutterTts.stop();
    await flutterTts.speak(message);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _interpreter?.close();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection Screen')),
      body: Column(
        children: [
          // Buttons at the top
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildDetectionBox(0), _buildDetectionBox(1)],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildDetectionBox(2), _buildDetectionBox(3)],
                ),
              ],
            ),
          ),

          // Adjusted camera preview height and moved up by 18px
          SizedBox(
            height:
                MediaQuery.of(context).size.height / 3 - 10, // Reduced by 10px
            child: Padding(
              padding: const EdgeInsets.only(top: 18), // Moved up by 18px
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(
                        _cameraController); // Camera preview at the bottom
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),

          // Eye position indicator on top of the camera preview
          if (_eyePosition != null)
            Positioned(
              left: _eyePosition!.dx - 10,
              top: _eyePosition!.dy - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetectionBox(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLabel = widget.labels[index];
        });
        _speak(widget.labels[index]);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedLabel == widget.labels[index]
              ? Colors.green
              : Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        width: 150,
        height: 150,
        margin: const EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            widget.labels[index],
            style: const TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
