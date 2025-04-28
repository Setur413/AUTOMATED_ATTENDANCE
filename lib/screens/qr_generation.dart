import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'bottom.dart';

class QRCodeGenerationScreen extends StatefulWidget {
  const QRCodeGenerationScreen({super.key});

  @override
  _QRCodeGenerationScreenState createState() => _QRCodeGenerationScreenState();
}

class _QRCodeGenerationScreenState extends State<QRCodeGenerationScreen> {
  int expiryTime = 10; // Expiry time in minutes
  TextEditingController sessionTitleController = TextEditingController();
  TextEditingController sessionDescriptionController = TextEditingController();
  TimeOfDay? selectedTime;
  String? qrData;
  bool isLoading = false;
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
    String title = sessionTitleController.text.trim();
    String description = sessionDescriptionController.text.trim();

    if (selectedTime != null) {
      final now = DateTime.now();
      final sessionDateTime = DateTime(now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute);
      String time = "${sessionDateTime.hour}:${sessionDateTime.minute.toString().padLeft(2, '0')}";

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
        // Store the session details and expiration time in Firestore
        DocumentReference docRef = await FirebaseFirestore.instance.collection('sessions').add({
          'title': title,
          'description': description,
          'time': sessionDateTime,
          'expiryTime': expiryTime,
          'createdAt': FieldValue.serverTimestamp(),
          'expirationTimestamp': Timestamp.fromDate(sessionDateTime.add(Duration(minutes: expiryTime))), // Add expiration timestamp
        });

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

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _downloadQRCode() async {
    Uint8List? pngBytes = await _capturePng();
    if (pngBytes == null) return;

    final directory = await getExternalStorageDirectory();
    final path = "${directory!.path}/qr_code.png";
    final file = File(path);
    await file.writeAsBytes(pngBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("QR Code saved to: $path")),
    );
  }

  Future<void> _shareQRCode() async {
    Uint8List? pngBytes = await _capturePng();
    if (pngBytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/qr_code.png').create();
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Here is the class QR code.');
  }

  // Check if QR code has expired
  void _checkQRCodeExpiration(String sessionId) async {
    DocumentSnapshot sessionDoc = await FirebaseFirestore.instance.collection('sessions').doc(sessionId).get();

    if (sessionDoc.exists) {
      final expirationTime = sessionDoc['expirationTimestamp'] as Timestamp;
      final currentTime = Timestamp.now();

      if (currentTime.compareTo(expirationTime) > 0) {
        // QR code has expired
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This QR code has expired.")),
        );
      } else {
        // Proceed with attendance
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("QR code is valid!")),
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
      body: SingleChildScrollView(
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
              items: [5, 10, 15, 20, 30].map((int value) {
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
            if (qrData != null) ...[
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _downloadQRCode,
                    icon: Icon(Icons.download),
                    label: Text("Download"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _shareQRCode,
                    icon: Icon(Icons.share),
                    label: Text("Share"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (qrData != null) {
                    // Check if the QR code has expired
                    String sessionId = qrData!.split("\n")[0].split(": ")[1];
                    _checkQRCodeExpiration(sessionId);
                  }
                },
                child: Text("Check QR Code Expiration"),
              ),
            ]
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3, onTap: (index) {}),
    );
  }
}
