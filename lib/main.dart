import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_attendance/screens/splash_screen.dart';
import 'package:qr_attendance/screens/lecturer_dashboard.dart';
import 'package:qr_attendance/screens/student_dashboard.dart';
import 'package:qr_attendance/screens/course_registration.dart';
import 'package:qr_attendance/screens/attendance_history.dart';
import 'package:qr_attendance/screens/qr_scanning.dart';
import 'package:qr_attendance/screens/monitoring.dart';
import 'package:qr_attendance/screens/qr_generation.dart';
import 'package:qr_attendance/screens/course_details.dart';
import 'package:qr_attendance/screens/role_based.dart';
import 'package:qr_attendance/screens/student_profile.dart';

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
      initialRoute: '/splash',
      
      // Define static routes
      routes: {
        '/splash': (context) => SplashScreen(),
        '/role': (context) => RoleSelectionScreen(),
        //lecturer's route
        '/lecturer_dashboard': (context) => LecturerDashboard(),
        '/monitoring': (context) => AttendanceMonitoringScreen(),
        '/qr_generation': (context) => QRCodeGenerationScreen(),
        '/course': (context) => CourseManagementScreen(),
        //student's route
        '/courses': (context) => CourseRegistrationScreen(),
        '/history': (context) => AttendanceHistoryScreen(),
        '/qr_scanning': (context) => QRScannerScreen(),
      },
      
      // Handle dynamic routes (e.g., passing user data)
      onGenerateRoute: (settings) {
        if (settings.name == '/student_dashboard') {
          final userData = settings.arguments as Map<String, dynamic>?; 
          return MaterialPageRoute(
            builder: (context) => StudentDashboard(userData: userData ?? {}),
          );
        }

        if (settings.name == '/profile') {
          final userData = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => StudentProfileScreen(userData: userData ?? {}),
          );
        }

        return null; // Default case
      },
    );
  }
}
