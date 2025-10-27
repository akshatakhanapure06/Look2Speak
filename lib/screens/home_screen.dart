import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({super.key, required this.cameras});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> labels = [
    'Food',
    'Medicine',
    'Toilet',
    'Water',
  ];

  // Show dialog to change the label name
  Future<void> _showChangeLabelDialog(int index) async {
    TextEditingController controller =
        TextEditingController(text: labels[index]);

    return showDialog<void>(
      // Display the dialog
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Label Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Label Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  labels[index] = controller.text; // Update the label
                });
                Navigator.of(context).pop();
              },
              child: const Text('Change'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Look2Speak'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Look2Speak',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(
                      cameras: widget.cameras,
                      labels: labels, // Pass updated labels here
                    ),
                  ),
                );
              },
              child: const Text('Start Detection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Open the dialog for each label
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Change Detection Box Names'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(labels.length, (index) {
                          return ListTile(
                            title: Text(labels[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showChangeLabelDialog(index),
                            ),
                          );
                        }),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Change Detection Box Names'),
            ),
          ],
        ),
      ),
    );
  }
}
