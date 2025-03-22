import 'package:flutter/material.dart';
import 'package:qr_attendance/screens/navigation.dart'; // Import bottom navigation

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  int _currentIndex = 2; // Set default tab to "History"

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Map<String, String>> attendanceRecords = [
    {
      "class": "Math Class",
      "date": "Sep 25, 2023",
      "percentage": "85%",
    },
    {
      "class": "Science Class",
      "date": "Sep 26, 2023",
      "percentage": "90%",
    },
    {
      "class": "History Class",
      "date": "Sep 27, 2023",
      "percentage": "88%",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.bar_chart, color: Colors.black), // Analytics (future)
          SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: NetworkImage("https://via.placeholder.com/150"),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: attendanceRecords.length,
          itemBuilder: (context, index) {
            final record = attendanceRecords[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                title: Text(
                  record["class"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date: ${record["date"]}"),
                    Text("Percentage: ${record["percentage"]}"),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        // Handle file upload for absence justification
                      },
                      child: const Text("Justify Absence"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
