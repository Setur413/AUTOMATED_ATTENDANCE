import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _selectedRole = "Student";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create an Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Select your role to continue"),
            SizedBox(height: 10),
            ToggleButtons(
              isSelected: [
                _selectedRole == "Student",
                _selectedRole == "Lecturer"
              ],
              onPressed: (index) {
                setState(() {
                  _selectedRole = index == 0 ? "Student" : "Lecturer";
                });
              },
              borderRadius: BorderRadius.circular(10),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Student"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Lecturer"),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: _selectedRole == "Student" ? "Student ID" : "Staff ID",
                border: OutlineInputBorder(),
              ),
            ),
            if (_selectedRole == "Student") ...[
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "Student Registration Number",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle signup logic
                },
                child: Text("Sign Up as $_selectedRole"),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
