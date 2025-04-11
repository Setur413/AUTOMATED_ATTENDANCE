import 'package:flutter/material.dart';

class AttendanceSuccessScreen extends StatelessWidget {
  const AttendanceSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Success"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                "Your attendance is successfully marked.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the dashboard
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text("Go to Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
