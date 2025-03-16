import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_attendance/screens/splash_screen.dart'; // Ensure correct import
import 'package:qr_attendance/screens/login_screen.dart';
import 'package:qr_attendance/screens/signup_screen.dart';
import 'package:qr_attendance/screens/lecturer_dashboard.dart';
import 'package:qr_attendance/screens/monitoring.dart';
import 'package:qr_attendance/screens/qr_generation.dart';
import 'package:qr_attendance/screens/course_details.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash', // Define initial screen
      routes: {
        '/splash': (context) => SplashScreen(), // Splash screen loads first
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/dashboard': (context) => LecturerDashboard(),
        '/monitoring': (context) => AttendanceMonitoringScreen(),
        '/qr_generation': (context) =>  QRCodeGenerationScreen(),
        '/course': (context) => CourseManagementScreen(),
      },
    );
  }
}
