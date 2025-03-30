import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_attendance/screens/student_dashboard.dart';
import 'package:qr_attendance/screens/student_signup_screen.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  _StudentLoginScreenState createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _loginStudent() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      
      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
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
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Access Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Enter your credentials to log in."),
            SizedBox(height: 20),
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
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text("Forgot your password?", style: TextStyle(color: Colors.blue)),
              ),
            ),
            SizedBox(height: 10),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _loginStudent,
                    child: Text("Log In as Student"),
                  ),
            SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentSignUpScreen()),
                  );
                },
                child: Text("Need an account? Sign Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}