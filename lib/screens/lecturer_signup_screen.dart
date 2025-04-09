import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attendance/screens/lecturer_login_screen.dart';

class LecturerSignUpScreen extends StatefulWidget {
  const LecturerSignUpScreen({super.key});

  @override
  _LecturerSignUpScreenState createState() => _LecturerSignUpScreenState();
}

class _LecturerSignUpScreenState extends State<LecturerSignUpScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController staffIdController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isPasswordVisible = false; // Variable to control password visibility

  Future<void> _signUpLecturer() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        staffIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot lecturerDoc =
            await _firestore.collection('lecturers').doc(user.uid).get();

        if (!lecturerDoc.exists) {
          // Save lecturer details in Firestore
          await _firestore.collection('lecturers').doc(user.uid).set({
            'fullName': fullNameController.text.trim(),
            'email': user.email,
            'staffId': staffIdController.text.trim(),
            'uid': user.uid, // Store user UID for reference
            'createdAt': FieldValue.serverTimestamp(),
          });

          print("User created and saved: ${user.uid}");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sign-up successful! You can now log in.")),
          );

          // Navigate to Lecturer Login Screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LecturerLoginScreen()),
          );
        } else {
          print("Lecturer already exists in Firestore.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account already exists! Please log in.")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Sign-up failed. Please try again.";

      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password must be at least 6 characters.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      }

      print("Sign-up error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print("Unexpected error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Enter your details to continue"),
            SizedBox(height: 15),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible, // Toggle visibility based on the boolean
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: staffIdController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Staff ID",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUpLecturer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                      ),
                      child: Text("Sign Up as Lecturer"),
                    ),
                  ),
            SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LecturerLoginScreen()),
                  );
                },
                child: Text("Already have an account? Log In"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
