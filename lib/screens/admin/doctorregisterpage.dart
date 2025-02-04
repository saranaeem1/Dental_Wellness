import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooth_tales/models/userModel.dart';
import '../../services/firestore_service.dart';

class DoctorRegisterPage extends StatefulWidget {
  const DoctorRegisterPage({Key? key}) : super(key: key);

  @override
  _DoctorRegisterPageState createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends State<DoctorRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // To toggle password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Dentist Registration",
          style: TextStyle(fontFamily: "GoogleSans", fontSize: 16, color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Register Dentist!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "GoogleSans",
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Create a Dentist account to enable them to provide treatment to users.",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "GoogleSans",
                    ),
                    textAlign: TextAlign.center, // Center align the text
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Image.asset(
                    "assets/Images/dentistss.png",
                    width: 500,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  labelText: "Full Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  labelText: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  labelText: "Password",
                  obscureText: !_isPasswordVisible,
                  isPassword: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _registerDoctor,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "GoogleSans",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    bool isPassword = false,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontFamily: "GoogleSans"),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: Icon(icon, color: Colors.blue),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.blue,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        )
            : null,
      ),
      style: const TextStyle(fontFamily: "GoogleSans"),
    );
  }

  void _registerDoctor() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String doctorId = userCredential.user!.uid;

      UserAccounts doctorAccount = UserAccounts(
        id: doctorId,
        userName: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        isDoctor: true,
      );

      await FirestoreService<UserAccounts>('users').addItemWithId(doctorAccount, doctorId);

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Doctor registered successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
