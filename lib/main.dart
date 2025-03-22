import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_attendance/screens/splash_screen.dart';
import 'package:qr_attendance/screens/login_screen.dart';
import 'package:qr_attendance/screens/signup_screen.dart';
import 'package:qr_attendance/screens/lecturer_dashboard.dart';
import 'package:qr_attendance/screens/student_dashboard.dart';
import 'package:qr_attendance/screens/course_registration.dart';
import 'package:qr_attendance/screens/attendance_history.dart';
import 'package:qr_attendance/screens/qr_scanning.dart';
import 'package:qr_attendance/screens/monitoring.dart';
import 'package:qr_attendance/screens/qr_generation.dart';
import 'package:qr_attendance/screens/course_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AttendanceApp());
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
      initialRoute: '/splash', // Define the initial screen
      routes: {
        // Common Routes
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),

        // Lecturer Routes
        '/lecturer_dashboard': (context) => LecturerDashboard(),
        '/monitoring': (context) => AttendanceMonitoringScreen(),
        '/qr_generation': (context) => QRCodeGenerationScreen(),
        '/course': (context) => CourseManagementScreen(),

        // Student Routes
        '/student_dashboard': (context) =>  StudentDashboard(),
        '/courses': (context) =>  CourseRegistrationScreen(),
        '/history': (context) =>  AttendanceHistoryScreen(),
        '/qr_scanning': (context) =>  QRScannerScreen(),
      },
    );
  }
}
