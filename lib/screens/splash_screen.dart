import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_attendance/screens/role_based.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      // Use named route navigation instead of MaterialPageRoute
      Navigator.pushReplacementNamed(context, '/');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Attendance Tracker",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Your Attendance, Secured",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
                );
              },
              child: Text("Proceed to Login or Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
