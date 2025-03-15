import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooth_tales/reusable_widgets/reusable_widget.dart';
import 'package:tooth_tales/screens/signup.dart';
import 'package:tooth_tales/screens/user/homepage.dart';
import 'package:tooth_tales/screens/doctor/doctorHomePage.dart';

import 'admin/adminhomepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.15, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily:"GoogleSans",
                  ),
                ),
                SizedBox(height:5),
                Text(
                  "Login to your account and",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: "GoogleSans",
                  ),
                ),
                Text(
                  "start your dental health experience.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: "GoogleSans",
                  ),
                ),
                SizedBox(height:20),
                Image.asset(
                  "assets/Images/dentistss.png",
                  width: 500,
                ),
                SizedBox(height: 20),
                ReusableTextField(
                  text: "Enter Email",
                  icon: Icons.email_outlined,
                  isPasswordType: false,
                  controller: _emailTextController,
                ),
                SizedBox(height: 20),
                ReusableTextField(
                  text: "Enter Password",
                  icon: Icons.lock_outlined,
                  isPasswordType: true,
                  controller: _passwordTextController,
                ),
                SizedBox(height: 20),
                signInSignUpButton(context, true, _signInUser),
                signUpOption(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signInUser() async {
    try {
      // Sign in the user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );
      String userId = userCredential.user!.uid;

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        print('User document data: ${userDoc.data()}');

        // Get the 'id' field as a String (to avoid type mismatch)
        String userIdFromFirestore = userDoc.get('id').toString();

        // Check if the user's id is '0' (admin)
        if (userIdFromFirestore == '0') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomePage(adminId: "9zMrY7yPCFfQW3mG88cz47MlZau2"),
            ),
          );
          return;
        }

        // Check if the user is a doctor
        bool isDoctor = userDoc.get('isDoctor');
        _showCustomSnackBar(context, 'Login successful!', Colors.green);

        // Navigate to DoctorHomePage or HomePage based on isDoctor flag
        if (isDoctor) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DoctorHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else {
        print('User document does not exist in Firestore');
        _showCustomSnackBar(context, 'User does not exist!', Colors.red);
      }
    } catch (error) {
      print("Error signing in: $error");
      _showCustomSnackBar(context, 'Incorrect credential', Colors.red);
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
          // Optional dismiss action
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Row signUpOption(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don't have an account?", style: TextStyle(color: Colors.black,fontFamily:"GoogleSans",)),
      GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUpScreen()));
        },
        child: const Text(
          " Sign Up",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,fontFamily:"GoogleSans",),
        ),
      ),
    ],
  );
}