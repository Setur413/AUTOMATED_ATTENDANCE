import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/dashboard');
            break;
          case 1:
            Navigator.pushNamed(context, '/course_details');
            break;
          case 2:
            Navigator.pushNamed(context, '/monitoring');
            break;
          case 3:
            Navigator.pushNamed(context, '/qr_generation');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "Courses"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Attendance"),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "QR Code"),
      ],
    );
  }
}
