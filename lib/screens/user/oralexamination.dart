import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OralExaminationScreen extends StatefulWidget {
  @override
  _OralExaminationScreenState createState() => _OralExaminationScreenState();
}

class _OralExaminationScreenState extends State<OralExaminationScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // Method to pick an image from the camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Method to upload the image (with basic snackbar for success/failure)
  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      // Upload logic here (Firebase or other backend)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please take a picture first!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oral Examination', style: TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.w500)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,  // Set the background color to white
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Oral Examination Steps',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'GoogleSans'),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Follow these steps to take a picture of your oral cavity for examination:',
                  style: TextStyle(fontSize: 16, fontFamily: 'GoogleSans', color: Colors.blue),
                ),
                SizedBox(height: 12),
                _buildStep('1. Open your mouth wide to expose your teeth and gums.'),
                _buildStep('2. Ensure the light is sufficient to capture a clear image.'),
                _buildStep('3. Hold the camera steady for a clear picture.'),
                _buildStep('4. Take a picture and check the image for clarity.'),
                SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade50,
                      child: _imageFile == null
                          ? Icon(Icons.camera_alt, size: 50, color: Colors.blue)
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _imageFile!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: TextStyle(fontSize: 16, fontFamily: 'GoogleSans'),
                    ),
                    child: Text('Upload Picture', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          // Footer
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Text(
              '© 2025 Oral Care App. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontFamily: 'GoogleSans', color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to display steps
  Widget _buildStep(String stepText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              stepText,
              style: TextStyle(fontSize: 16, fontFamily: 'GoogleSans'),
            ),
          ),
        ],
      ),
    );
  }
}
