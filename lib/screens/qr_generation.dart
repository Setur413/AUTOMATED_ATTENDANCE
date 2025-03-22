import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:gallery_saver/gallery_saver.dart';
import 'bottom.dart';

class QRCodeGenerationScreen extends StatefulWidget {
  const QRCodeGenerationScreen({super.key});

  @override
  _QRCodeGenerationScreenState createState() => _QRCodeGenerationScreenState();
}

class _QRCodeGenerationScreenState extends State<QRCodeGenerationScreen> {
  int expiryTime = 10;
  String? selectedCourseCode;
  TextEditingController sessionDescriptionController = TextEditingController();
  TimeOfDay? selectedTime;
  String? qrData;
  bool isLoading = false;

  // Global Key for capturing QR image
  GlobalKey globalKey = GlobalKey();

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

  void _generateQRCode() async {
    String description = sessionDescriptionController.text.trim();
    String time = selectedTime != null ? selectedTime!.format(context) : "No Time Selected";

    if (selectedCourseCode == null || description.isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a course and enter all session details.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('sessions').add({
        'courseCode': selectedCourseCode,
        'description': description,
        'time': time,
        'expiryTime': expiryTime,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        qrData = "Session ID: ${docRef.id}\nCourse Code: $selectedCourseCode\nTime: $time\nExpiry: $expiryTime min";
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

  // Function to capture and save QR code as image
  Future<void> _saveQRCode() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/qr_code.png';
      final File imgFile = File(filePath);
      await imgFile.writeAsBytes(pngBytes);

      // Save to Gallery
      await GallerySaver.saveImage(imgFile.path, albumName: "QR Codes");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("QR Code saved to Gallery!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving QR Code!")),
      );
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
                  : RepaintBoundary(
                      key: globalKey,
                      child: QrImageView(
                        data: qrData!,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var courseDocs = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: selectedCourseCode,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCourseCode = newValue;
                    });
                  },
                  items: courseDocs.map<DropdownMenuItem<String>>((doc) {
                    return DropdownMenuItem<String>(
                      value: doc['courseCode'],
                      child: Text(doc['courseCode']),
                    );
                  }).toList(),
                  hint: Text("Select Course Code"),
                );
              },
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
            SizedBox(height: 10),
            if (qrData != null) // Show download button only when QR is generated
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveQRCode,
                  icon: Icon(Icons.download),
                  label: Text("Download QR Code"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3, onTap: (index) {}),
    );
  }
}
