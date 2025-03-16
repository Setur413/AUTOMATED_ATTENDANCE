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
  String? selectedDate;

  List<String> courses = ["Class 101", "Math 201", "CS 305"];
  List<String> dates = ["2024-03-01", "2024-03-02", "2024-03-03"];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lecturer Attendance Monitoring"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Course", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedCourse,
              hint: Text("Choose a Course"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourse = newValue;
                });
              },
              items: courses.map<DropdownMenuItem<String>>((String course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedDate,
              hint: Text("Choose a Date"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDate = newValue;
                });
              },
              items: dates.map<DropdownMenuItem<String>>((String date) {
                return DropdownMenuItem<String>(
                  value: date,
                  child: Text(date),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text("Attendance List", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('attendance')
                    .where('course', isEqualTo: selectedCourse)
                    .where('date', isEqualTo: selectedDate)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var students = snapshot.data!.docs;

                  if (students.isEmpty) {
                    return Center(child: Text("No students found for this course and date."));
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      var student = students[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: ListTile(
                            title: Text(
                              "${student['name']}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "ID: ${student['id']}\nCourse: ${student['course']}\nDate: ${student['date']}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            trailing: Icon(Icons.circle, color: _getStatusColor(student['status']), size: 16),
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
