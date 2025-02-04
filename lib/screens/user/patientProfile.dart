import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _gender = 'Male';
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  File? _imageFile;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _userNameController.text = userData['userName'] ?? '';
        _dobController.text = userData['dateOfBirth'] ?? '';
        _gender = userData['gender'] ?? 'Male';
        _imageUrl = userData['imageUrl'];
      });
    }
  }
  Future<void> _updateProfile() async {
    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
        'userName': _userNameController.text,
        'dateOfBirth': _dobController.text,
        'gender': _gender,
        'imageUrl': imageUrl,
      });
      _showCustomSnackBar(context, 'Profile updated successfully!', Colors.green);
    } catch (e) {
      print('Error updating profile: $e');
      _showCustomSnackBar(context, 'Error updating profile: $e', Colors.red);
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('$userId.jpg');

      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page', style: TextStyle(color: Colors.white, fontFamily: 'GoogleSans')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : _imageUrl != null
                      ? NetworkImage(_imageUrl!)
                      : AssetImage('assets/Images/avatar.png') as ImageProvider,
                  child: _imageFile == null && _imageUrl == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white.withOpacity(0.7))
                      : null,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              style: TextStyle(fontFamily: 'GoogleSans-Regular'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle(fontFamily: 'GoogleSans-Regular'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(
                child: Text(label, style: TextStyle(fontFamily: 'GoogleSans-Regular'),),
                value: label,
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  textStyle: TextStyle(fontSize: 18, fontFamily: 'GoogleSans'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Update Profile', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showCustomSnackBar(BuildContext context, String message, Color color) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    action: SnackBarAction(
      label: 'Dismiss',
      textColor: Colors.white,
      onPressed: () {
        // Handle dismiss action if needed
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
