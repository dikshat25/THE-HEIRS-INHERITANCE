import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ScanImg extends StatefulWidget {
  const ScanImg({super.key});

  @override
  State<ScanImg> createState() => _ScanImgState();
}

class _ScanImgState extends State<ScanImg> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<String> detectedItems = [];

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Capture image with the camera
  Future<void> _captureImageWithCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Detect labels in the image
  Future<void> _detectItemsInImage(File image) async {
    final stopwatch = Stopwatch()..start();

    final inputImage = InputImage.fromFile(image);

    // Set up ImageLabeler with confidence threshold
    final options = ImageLabelerOptions(confidenceThreshold: 0.5);
    final imageLabeler = ImageLabeler(options: options);

    try {
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
      List<String> items = [];

      for (ImageLabel label in labels) {
        items.add('${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)');
      }

      setState(() {
        detectedItems = items;
      });

      stopwatch.stop();
      print('Label detection took: ${stopwatch.elapsedMilliseconds} ms');
    } catch (e) {
      print('Error during image labeling: $e');
    } finally {
      await imageLabeler.close();
    }
  }

  // Start object detection when the button is pressed
  void _startObjectDetection() {
    if (_image != null) {
      _detectItemsInImage(_image!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture an image first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan to Add', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1b534c),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _image != null
                ? Image.file(
              _image!,
              fit: BoxFit.cover,
            )
                : Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 150,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: _pickImageFromGallery,
                ),
                _buildIconButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onPressed: _captureImageWithCamera,
                ),
                _buildIconButton(
                  icon: Icons.search,
                  label: 'Detect Labels',
                  onPressed: _startObjectDetection,
                ),
              ],
            ),
          ),
          if (detectedItems.isNotEmpty)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detected Items:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Display detected items in bubbles
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: detectedItems.map((item) {
                        return Chip(
                          label: Text(
                            item,
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          backgroundColor: Colors.blueAccent.withOpacity(0.5),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}