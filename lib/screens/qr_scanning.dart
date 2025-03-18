import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_attendance/screens/navigation.dart';  // Import the navigation bar

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String scanStatus = "Scanning...";
  bool isScanning = true;
  int _currentIndex = 3; // Set active index for QR Scanner

  void _onDetect(BarcodeCapture capture) {
    if (isScanning && capture.barcodes.isNotEmpty) {
      setState(() {
        scanStatus = "QR Code Detected: ${capture.barcodes.first.rawValue}";
        isScanning = false;
      });

      // Simulate a short delay before navigating
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard'); // Navigate to Dashboard
        }
      });
    }
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
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
            backgroundColor: Colors.grey, // Placeholder for profile image
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isScanning
                  ? null
                  : () {
                      setState(() {
                        scanStatus = "Scanning...";
                        isScanning = true;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Scan Again"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
