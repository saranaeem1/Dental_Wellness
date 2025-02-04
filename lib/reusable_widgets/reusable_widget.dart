import 'package:flutter/material.dart';

// Reusable text field for input with icons and password visibility toggle
TextField reusableTextField(String text, IconData icon, bool isPasswordType, TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.black.withOpacity(0.9),fontFamily:"GoogleSans",),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.blue,
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.black,fontFamily:"GoogleSans"),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black, width: 1),  // Black border
      ),
    ),
    keyboardType: isPasswordType ? TextInputType.visiblePassword : TextInputType.text,
  );
}

// Sign Up/Sign In button with padding and a fixed height and reduced width
Container signInSignUpButton(BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.5, // Reduced width to 50% of screen width
    height: 60, // Fixed height for the button
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30), // Round corners for the container
    ),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'LOGIN' : 'SIGNUP',
        style: const TextStyle(
          color: Colors.white,
          // fontWeight: FontWeight.bold,
          fontFamily: "GoogleSans",
          fontSize: 20,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.blueAccent;  // Change to blueAccent on press
            }
            return Colors.blue; // Default color
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Matching rounded corners
          ),
        ),
      ),
    ),
  );
}
