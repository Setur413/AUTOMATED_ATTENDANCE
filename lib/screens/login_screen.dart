import 'package:flutter/material.dart';
import 'package:qr_attendance/screens/signup_screen.dart'; // Update with actual signup screen
import 'package:qr_attendance/screens/student_dashboard.dart'; // Student dashboard screen
import 'package:qr_attendance/screens/lecturer_dashboard.dart'; // Lecturer dashboard screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentRegNoController = TextEditingController();
  String _selectedRole = "Student";

  void _loginUser() {
    // Mock authentication logic
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      if (_selectedRole == "Student") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LecturerDashboard()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Access Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Enter your credentials to access your dashboard and manage your teaching activities."),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: ["Student", "Lecturer"].map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Select Role",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: "Your email address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: "Enter your password",
                border: OutlineInputBorder(),
              ),
            ),
            if (_selectedRole == "Student") ...[
              SizedBox(height: 10),
              TextField(
                controller: studentIdController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: "Student ID",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: studentRegNoController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.badge),
                  hintText: "Student Registration Number",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text("Forgot your password?", style: TextStyle(color: Colors.blue)),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loginUser,
                child: Text("Log In as $_selectedRole"),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Need to create an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
