import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Labeler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ImageLabelingScreen(),
    );
  }
}

class ImageLabelingScreen extends StatefulWidget {
  const ImageLabelingScreen({super.key});

  @override
  _ImageLabelingScreenState createState() => _ImageLabelingScreenState();
}

class _ImageLabelingScreenState extends State<ImageLabelingScreen> {
  XFile? _imageFile;
  List<String> _labels = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      _labelImage(pickedFile.path); // Call image labeling here
    }
  }

  Future<void> _labelImage(String imagePath) async {
    try {
      // Load the image
      final InputImage inputImage = InputImage.fromFilePath(imagePath);

      // Initialize Image Labeler
      final ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();

      // Process the image and get labels
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

      // Update the UI with detected labels
      setState(() {
        _labels = labels.map((label) {
          return '${label.label} (${(label.confidence * 100).toStringAsFixed(2)}%)';
        }).toList();
      });

      // Dispose of resources
      imageLabeler.close();
    } catch (e) {
      setState(() {
        _labels = ['Error labeling image: $e'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Labeler'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _imageFile == null
              ? const Text('No image selected')
              : Image.file(File(_imageFile!.path)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.camera),
            child: const Text('Capture Image'),
          ),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: const Text('Pick from Gallery'),
          ),
          const SizedBox(height: 16),
          const Text('Labels Detected:'),
          ..._labels.map((label) => Text(label)).toList(),
        ],
      ),
    );
  }
}
