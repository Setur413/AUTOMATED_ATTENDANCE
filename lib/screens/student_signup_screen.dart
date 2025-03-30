import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attendance/screens/student_login_screen.dart';

class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  _StudentSignUpScreenState createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController studentRegNoController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _signUpStudent() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        studentRegNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection("students").doc(user.uid).set({
          "fullName": fullNameController.text.trim(),
          "email": emailController.text.trim(),
          "registrationNumber": studentRegNoController.text.trim(),
          "uid": user.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-up successful! Please log in.")),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentLoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Sign-up failed. Please try again.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak. Use a stronger password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
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
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Create an Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Enter your details to create a student account."),
            SizedBox(height: 20),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: studentRegNoController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.badge),
                labelText: "Student Registration Number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _signUpStudent,
                    child: Text("Sign Up as Student"),
                  ),
            SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentLoginScreen()),
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