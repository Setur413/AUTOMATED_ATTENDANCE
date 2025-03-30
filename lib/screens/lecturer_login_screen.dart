import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_attendance/screens/lecturer_dashboard.dart';
import 'package:qr_attendance/screens/lecturer_signup_screen.dart';

class LecturerLoginScreen extends StatefulWidget {
  const LecturerLoginScreen({super.key});

  @override
  _LecturerLoginScreenState createState() => _LecturerLoginScreenState();
}

class _LecturerLoginScreenState extends State<LecturerLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _loginLecturer() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.")),
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

      User? user = userCredential.user;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LecturerDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";

      if (e.code == 'user-not-found') {
        errorMessage = "No account found for this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Please enter a valid email address.";
      }

      print("Login error: ${e.message}");
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
        title: Text("Log In"),
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
            Text("Access Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Enter your credentials to access your dashboard."),
            SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email Address",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, // Implement forgot password later
                child: Text("Forgot your password?", style: TextStyle(color: Colors.blue)),
              ),
            ),
            SizedBox(height: 10),
            _isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading spinner
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                      ),
                      onPressed: _isLoading ? null : _loginLecturer,
                      child: Text("Log In as Lecturer"),
                    ),
                  ),
            SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LecturerSignUpScreen()),
                  );
                },
                child: Text("Need to create an account? Sign Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
