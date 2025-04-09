import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  _AttendanceReportScreenState createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  String? selectedCourse; // The selected course for the report
  List<String> courses = []; // List of courses fetched from Firestore
  Map<String, double> studentAttendancePercentage = {}; // Student attendance percentages
  bool isLoading = false; // To track loading state for report generation
  double averageAttendance = 0.0; // To store the average attendance percentage

  @override
  void initState() {
    super.initState();
    _fetchCourses(); // Fetch courses from Firestore on initialization
  }

  // Fetch courses from Firestore (assuming courses are stored in 'courses' collection)
  void _fetchCourses() async {
    var snapshot = await FirebaseFirestore.instance.collection('courses').get();
    setState(() {
      courses = snapshot.docs.map((doc) => doc['courseCode'] as String).toList();
    });
  }

  // Function to calculate average attendance percentage for students
  Future<void> _generateAttendanceReport() async {
    if (selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a course")),
      );
      return;
    }

    // Prompt for total number of classes
    int? totalClasses = await _showTotalClassesDialog();

    if (totalClasses == null || totalClasses <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid number of classes")),
      );
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });

    // Fetch all attendance records for the selected course
    var attendanceSnapshot = await FirebaseFirestore.instance
        .collection('session_attendance')
        .where('sessionTitle', isEqualTo: selectedCourse)
        .get();

    if (attendanceSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No attendance records found for this course")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    Map<String, int> studentAttendances = {}; // Map to track student attendance

    for (var doc in attendanceSnapshot.docs) {
      String studentName = doc['fullName'];
      String status = doc['attendanceStatus'].toLowerCase(); // "present" or "absent"

      if (status == 'present') {
        studentAttendances[studentName] = (studentAttendances[studentName] ?? 0) + 1;
      }
    }

    // Calculate the attendance percentage for each student
    studentAttendances.forEach((student, attendedClasses) {
      double attendancePercentage = (attendedClasses / totalClasses) * 100;
      studentAttendancePercentage[student] = attendancePercentage;
    });

    // Calculate the average attendance percentage
    double totalPercentage = 0;
    studentAttendancePercentage.forEach((student, percentage) {
      totalPercentage += percentage;
    });

    if (studentAttendancePercentage.isNotEmpty) {
      averageAttendance = totalPercentage / studentAttendancePercentage.length;
    }

    setState(() {
      isLoading = false; // Stop loading once data is fetched and processed
    });
  }

  // Dialog for entering the total number of classes
  Future<int?> _showTotalClassesDialog() async {
    int? totalClasses = 0;
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Total Number of Classes"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter number of classes"),
            onChanged: (value) {
              totalClasses = int.tryParse(value); // Try parsing the input to an integer
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Cancel if no number is entered
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(totalClasses); // Return the entered value
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Report"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Dropdown
            Text("Select Course", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (courses.isEmpty)
              Text("No courses available", style: TextStyle(color: Colors.red))
            else
              DropdownButton<String>(
                value: selectedCourse,
                hint: Text("Choose a Course"),
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
            SizedBox(height: 20),

            // Generate Report Button
            ElevatedButton(
              onPressed: _generateAttendanceReport,
              child: Text("Generate Report"),
            ),
            SizedBox(height: 20),

            // Display Loading Indicator
            if (isLoading)
              Center(child: CircularProgressIndicator()),

            // Display Report
            if (!isLoading && studentAttendancePercentage.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Student Attendance Report", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: studentAttendancePercentage.length,
                      itemBuilder: (context, index) {
                        String student = studentAttendancePercentage.keys.elementAt(index);
                        double percentage = studentAttendancePercentage[student]!;
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: ListTile(
                              title: Text(student, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              trailing: Text("${percentage.toStringAsFixed(2)}%"),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Average Attendance: ${averageAttendance.toStringAsFixed(2)}%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),

            // Message when no report data is available
            if (!isLoading && studentAttendancePercentage.isEmpty && selectedCourse != null)
              Center(child: Text("No attendance data found for the selected course.")),
          ],
        ),
      ),
    );
  }
}
