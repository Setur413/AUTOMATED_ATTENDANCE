import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom.dart'; // Import your BottomNavBar widget

class QRCodeGenerationScreen extends StatefulWidget {
  const QRCodeGenerationScreen({super.key});

  @override
  _QRCodeGenerationScreenState createState() => _QRCodeGenerationScreenState();
}

class _QRCodeGenerationScreenState extends State<QRCodeGenerationScreen> {
  int expiryTime = 10;
  TextEditingController sessionTitleController = TextEditingController();
  TextEditingController sessionDescriptionController = TextEditingController();
  TimeOfDay? selectedTime;
  String? qrData;
  bool isLoading = false; // Track loading state

  // Function to select the time for the session
  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Function to generate QR code with session details
  void _generateQRCode() async {
    String title = sessionTitleController.text.trim();
    String description = sessionDescriptionController.text.trim();

    // Ensure the current date and selected time are combined into a DateTime
    if (selectedTime != null) {
      final now = DateTime.now();
      final sessionDateTime = DateTime(now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute);

      // Format the DateTime into a string for display in QR code
      String time = "${sessionDateTime.hour}:${sessionDateTime.minute.toString().padLeft(2, '0')}";

      // Validate input fields
      if (title.isEmpty || description.isEmpty || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter all session details.")),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        // Store the session with DateTime in Firestore as Timestamp
        DocumentReference docRef = await FirebaseFirestore.instance.collection('sessions').add({
          'title': title,
          'description': description,
          'time': sessionDateTime, // Store DateTime here
          'expiryTime': expiryTime,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Set the QR code data with formatted time
        setState(() {
          qrData = "Session ID: ${docRef.id}\nTitle: $title\nTime: $time\nExpiry: $expiryTime min";
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error generating QR code. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Generation"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: qrData == null
                  ? Image.asset('assets/download.png', height: 150)
                  : QrImageView(
                      data: qrData!,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: sessionTitleController,
              decoration: InputDecoration(labelText: "Session Title"),
            ),
            TextField(
              controller: sessionDescriptionController,
              decoration: InputDecoration(labelText: "Session Description"),
            ),
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: InputDecoration(labelText: "Pick a Time"),
                child: Text(selectedTime?.format(context) ?? "Select Time"),
              ),
            ),
            SizedBox(height: 10),
            DropdownButton<int>(
              value: expiryTime,
              onChanged: (int? newValue) {
                setState(() {
                  expiryTime = newValue!;
                });
              },
              items: [5, 10, 15, 20, 30].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value min"),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : _generateQRCode,
                child: isLoading ? CircularProgressIndicator() : Text("Generate QR Code"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3, onTap: (index) {}),
    );
  }
}
