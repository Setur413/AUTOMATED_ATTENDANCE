import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom.dart';
import 'course_edit_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  CourseManagementScreenState createState() => CourseManagementScreenState();
}

class CourseManagementScreenState extends State<CourseManagementScreen> {
  TextEditingController courseCodeController = TextEditingController();
  TextEditingController courseTitleController = TextEditingController();
  TextEditingController instructorNameController = TextEditingController();

  void _saveCourseDetails() async {
    if (courseCodeController.text.isEmpty ||
        courseTitleController.text.isEmpty ||
        instructorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('courses').doc(courseCodeController.text).set({
      'courseCode': courseCodeController.text,
      'courseTitle': courseTitleController.text,
      'instructorName': instructorNameController.text,
    }, SetOptions(merge: true));

    setState(() {
      courseCodeController.clear();
      courseTitleController.clear();
      instructorNameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Course details saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course Management"),
        actions: [
          IconButton(
            icon: Icon(Icons.visibility),
            tooltip: "View Courses",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CourseDetailsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter Course Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(controller: courseCodeController, decoration: InputDecoration(labelText: "Course Code*", filled: true)),
              SizedBox(height: 10),
              TextField(controller: courseTitleController, decoration: InputDecoration(labelText: "Title*", filled: true)),
              SizedBox(height: 10),
              TextField(controller: instructorNameController, decoration: InputDecoration(labelText: "Instructor Name*", filled: true)),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(onPressed: _saveCourseDetails, child: Text("Save Course")),
                  SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {
                      courseCodeController.clear();
                      courseTitleController.clear();
                      instructorNameController.clear();
                    },
                    child: Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation logic
        },
      ),
    );
  }
}
