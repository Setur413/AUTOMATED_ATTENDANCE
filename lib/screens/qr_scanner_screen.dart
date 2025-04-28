import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_success_screen.dart'; // Import the new screen

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String scanStatus = "Scanning...";
  bool isScanning = true;
  int _currentIndex = 3;
  String? fullName;
  String? registrationNumber;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch student details from Firestore
  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .get();

        if (studentDoc.exists) {
          setState(() {
            fullName = studentDoc['fullName'] ?? "Unknown";
            registrationNumber = studentDoc['registrationNumber'] ?? "N/A";
          });
        } else {
          setState(() => scanStatus = "Student details not found!");
        }
      } catch (e) {
        setState(() => scanStatus = "Error loading student details.");
      }
    } else {
      setState(() => scanStatus = "No authenticated user.");
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isScanning && capture.barcodes.isNotEmpty) {
      final qrData = capture.barcodes.first.rawValue ?? "";
      if (qrData.isNotEmpty) {
        setState(() {
          scanStatus = "QR Code Detected!";
          isScanning = false;
        });

        await _storeAttendance(qrData);
      } else {
        setState(() => scanStatus = "Invalid QR Code. Try again.");
      }
    }
  }

  // Function to store attendance in Firestore
  Future<void> _storeAttendance(String qrData) async {
    if (fullName == null || registrationNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student details not loaded. Try again.")),
      );
      return;
    }

    // Extract Session ID and Title from the QR data
    List<String> dataParts = qrData.split("\n");
    String sessionId = "";
    String sessionTitle = "";

    for (String part in dataParts) {
      if (part.startsWith("Session ID:")) {
        sessionId = part.replaceFirst("Session ID: ", "").trim();
      } else if (part.startsWith("Title:")) {
        sessionTitle = part.replaceFirst("Title: ", "").trim();
      }
    }

    if (sessionId.isEmpty || sessionTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid QR Code format.")),
      );
      return;
    }

    // Check if the user has already scanned this session
    bool alreadyScanned = await _checkIfAlreadyScanned(sessionId, registrationNumber!);
    if (alreadyScanned) {
      setState(() => scanStatus = "Attendance already recorded for this session!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have already scanned this session's QR code!")),
      );
      return;
    }

    // Save attendance with "Present" status
    try {
      await FirebaseFirestore.instance.collection('session_attendance').add({
        'sessionId': sessionId,
        'sessionTitle': sessionTitle,
        'scannedAt': FieldValue.serverTimestamp(),
        'fullName': fullName,
        'registrationNumber': registrationNumber,
        'status': "Present", // Add status field
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attendance recorded successfully!")),
      );

      // Navigate to the success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AttendanceSuccessScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error storing attendance. Try again.")),
      );
    }
  }

  // Function to check if the student has already scanned for the session
  Future<bool> _checkIfAlreadyScanned(String sessionId, String registrationNumber) async {
    QuerySnapshot attendanceQuery = await FirebaseFirestore.instance
        .collection('session_attendance')
        .where('sessionId', isEqualTo: sessionId)
        .where('registrationNumber', isEqualTo: registrationNumber)
        .get();

    return attendanceQuery.docs.isNotEmpty;
  }

  // Navigation when tapping on bottom navigation bar
  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/dashboard');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/courses');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/history');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/qr_scanning');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        title: const Text(
          "Attendance",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.bar_chart, color: Colors.black),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.grey,
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: MobileScanner(
                  onDetect: _onDetect,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              scanStatus,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR Scan',
          ),
        ],
      ),
    );
  }
}
