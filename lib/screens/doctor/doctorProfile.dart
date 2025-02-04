import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'doctorHomePage.dart';

class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}
class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _gender = 'Male';
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  File? _imageFile;
  List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  Map<String, List<DateTime>> _availability = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };
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
        _specialityController.text = userData['speciality'] ?? '';
        _locationController.text = userData['location'] ?? '';
        _descriptionController.text = userData['description'] ?? '';
        _gender = userData['gender'] ?? 'Male';
        _imageUrl = userData['imageUrl'];
        if (userData['availability'] != null) {
          Map<String, dynamic> availabilityMap = userData['availability'];
          _availability = {};
          availabilityMap.forEach((day, timeslots) {
            if (timeslots is List) {
              List<Timestamp> timestampList = List<Timestamp>.from(timeslots);
              _availability[day] = timestampList.map((e) => e.toDate()).toList();
            } else {
              print('Expected List but got: $timeslots');
            }
          });
        } else {
          _availability = {
            'Monday': [],
            'Tuesday': [],
            'Wednesday': [],
            'Thursday': [],
            'Friday': [],
            'Saturday': [],
            'Sunday': [],
          };
        }
      });
    }
  }

  Future<void> _updateProfile() async {
    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'userName': _userNameController.text,
        'speciality': _specialityController.text,
        'location': _locationController.text,
        'gender': _gender,
        'imageUrl': imageUrl,
        'description': _descriptionController.text,
        'availability': _availability,
      });

      _showCustomSnackBar(context, 'Profile updated successfully', Colors.green);
    } catch (e) {
      print('Error updating profile: $e');
      _showCustomSnackBar(context, 'Failed to update profile', Colors.red);
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

  void _selectTimeSlots(BuildContext context, String day) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        final dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        setState(() {
          _availability[day]?.add(dateTime);
        });
      }
    }
  }

  void _deleteTimeSlot(String day, DateTime dateTime) {
    setState(() {
      _availability[day]?.remove(dateTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Profile Page', style: const TextStyle(
          color: Colors.white,
          fontFamily: "GoogleSans",
          fontSize: 18,
          // fontWeight: FontWeight.bold,
        ),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        : AssetImage('assets/Images/avatar.png')
                    as ImageProvider,
                    child: _imageFile == null && _imageUrl == null
                        ? Icon(Icons.camera_alt,
                        size: 40, color: Colors.white.withOpacity(0.7))
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
                style: TextStyle(fontFamily: "GoogleSans"),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _specialityController,
                decoration: InputDecoration(
                  labelText: 'Speciality',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                style: TextStyle(fontFamily: "GoogleSans"),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                style: TextStyle(fontFamily: "GoogleSans"),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Male', 'Female', 'Other']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
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
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                maxLines: 4,
                style: TextStyle(fontFamily: "GoogleSans"),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Availability',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ..._availability.keys.map((day) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _availability[day]!
                                  .map(
                                    (slot) => Chip(
                                  label: Text(
                                    "${slot.toLocal()}".split(' ')[0] + " " + slot.toString().split(' ')[1],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.blue,
                                  deleteIcon: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  onDeleted: () => _deleteTimeSlot(day, slot),
                                ),
                              )
                                  .toList(),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _selectTimeSlots(context, day),
                                icon: Icon(Icons.add, color: Colors.blue),
                                label: Text(
                                  'Add Slot',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              SizedBox(height: 10.0),
              Center( child: ElevatedButton(
                onPressed: () {
                  _updateProfile();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorHomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Update Profile', style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: "GoogleSans",
                ),),
              ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
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
