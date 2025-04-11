import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom.dart';

class AttendanceMonitoringScreen extends StatefulWidget {
  const AttendanceMonitoringScreen({super.key});

  @override
  _AttendanceMonitoringScreenState createState() => _AttendanceMonitoringScreenState();
}

class _AttendanceMonitoringScreenState extends State<AttendanceMonitoringScreen> {
  String? selectedCourse;
  List<String> courses = [];
  bool isLoading = true;

  // Fetch courses from Firestore
  Future<void> _fetchCourses() async {
    try {
      var courseSnapshot = await FirebaseFirestore.instance.collection('courses').get();
      List<String> courseList = [];
      for (var doc in courseSnapshot.docs) {
        courseList.add(doc['courseCode']);
      }
      setState(() {
        courses = courseList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching courses: $e")),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCourses(); // Fetch courses when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer Attendance Monitoring"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Dropdown
            Text("Select Course", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                : DropdownButton<String>(
                    value: selectedCourse,
                    hint: const Text("Choose a Course"),
                    onChanged: (String? newValue) {
                      setState(() => selectedCourse = newValue);
                    },
                    items: courses.map<DropdownMenuItem<String>>((String course) {
                      return DropdownMenuItem<String>(
                        value: course,
                        child: Text(course),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),

            // Attendance List Header
            const Text("Attendance List", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Attendance Data Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedCourse == null
                    ? null
                    : FirebaseFirestore.instance
                        .collection('session_attendance')
                        .where('sessionTitle', isEqualTo: selectedCourse)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No attendance records found."));
                  }

                  final attendanceRecords = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: attendanceRecords.length,
                    itemBuilder: (context, index) {
                      var record = attendanceRecords[index];

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ListTile(
                            title: Text(
                              record['fullName'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("📌 Registration Number: ${record['registrationNumber']}"),
                                Text("📚 Course: ${record['sessionTitle']}"),
                                Text("📅 Date: ${(record['scannedAt'] as Timestamp).toDate()}"),
                              ],
                            ),
                            trailing: Icon(Icons.circle, color: _getStatusColor("present"), size: 16),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    );
  }
}
