import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  CourseManagementScreenState createState() => CourseManagementScreenState();
}

class CourseManagementScreenState extends State<CourseManagementScreen> {
  TextEditingController courseCodeController = TextEditingController();
  TextEditingController courseTitleController = TextEditingController();
  TextEditingController instructorNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Save or Update Course
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
    }, SetOptions(merge: true)); // Prevents overwriting existing data

    setState(() {
      courseCodeController.clear();
      courseTitleController.clear();
      instructorNameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Course details saved successfully!")),
    );
  }

  // Delete Course
  void _deleteCourse(String courseId) async {
    await FirebaseFirestore.instance.collection('courses').doc(courseId).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Course deleted successfully!")));
  }

  // Edit Course Details
  void _editCourse(DocumentSnapshot doc) {
    TextEditingController editTitleController = TextEditingController(text: doc['courseTitle']);
    TextEditingController editInstructorController = TextEditingController(text: doc['instructorName']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Course"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: editTitleController, decoration: InputDecoration(labelText: "Course Title")),
              SizedBox(height: 10),
              TextField(controller: editInstructorController, decoration: InputDecoration(labelText: "Instructor Name")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('courses').doc(doc.id).update({
                  'courseTitle': editTitleController.text,
                  'instructorName': editInstructorController.text,
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
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
        title: Text("Course Management"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                OutlinedButton(onPressed: () {}, child: Text("Cancel")),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            Text("Courses Created", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('courses').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No courses available"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(doc['courseTitle']),
                          subtitle: Text("Instructor: ${doc['instructorName']}"),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editCourse(doc);
                              } else if (value == 'delete') {
                                _deleteCourse(doc.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
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
