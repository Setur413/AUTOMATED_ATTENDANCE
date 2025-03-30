import 'package:flutter/material.dart';
import 'lecturer_login_screen.dart';
import 'student_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoleButton(
              text: "Login as Lecturer",
              color: Colors.blue.shade600,
              icon: Icons.person_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LecturerLoginScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            RoleButton(
              text: "Login as Student",
              color: Colors.pink.shade400,
              icon: Icons.menu_book_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentLoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const RoleButton({super.key, 
    required this.text,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
