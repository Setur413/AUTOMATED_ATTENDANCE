import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  CourseManagementScreenState createState() => CourseManagementScreenState();
}

class CourseManagementScreenState extends State<CourseManagementScreen> {
  TextEditingController courseCodeController = TextEditingController(text: "IT01");
  TextEditingController courseTitleController = TextEditingController(text: "Introduction to Information Technology");
  TextEditingController instructorNameController = TextEditingController(text: "Dr. Smith");

  List<String> students = [];

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  // Load Course from Firestore
  void _loadCourseDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('courses').doc(courseCodeController.text).get();
      if (!mounted) return;
      if (doc.exists) {
        setState(() {
          courseTitleController.text = doc['courseTitle'];
          instructorNameController.text = doc['instructorName'];
          students = List<String>.from(doc['students']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Course not found!")));
      }
    } catch (e) {
      print("Error loading course: $e");
    }
  }

  // Save or Update Course
  void _saveCourseDetails() async {
    await FirebaseFirestore.instance.collection('courses').doc(courseCodeController.text).set({
      'courseCode': courseCodeController.text,
      'courseTitle': courseTitleController.text,
      'instructorName': instructorNameController.text,
      'students': students,
    }, SetOptions(merge: true)); // Prevents overwriting existing data
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Course details saved successfully!")),
    );
  }

  // Delete Course
  void _deleteCourse() async {
    await FirebaseFirestore.instance.collection('courses').doc(courseCodeController.text).delete();
    setState(() {
      courseTitleController.clear();
      instructorNameController.clear();
      students.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Course deleted successfully!")));
  }

  // Add a Student
  void _addStudent() async {
    TextEditingController studentNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Student"),
        content: TextField(
          controller: studentNameController,
          decoration: InputDecoration(labelText: "Student Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (studentNameController.text.isNotEmpty) {
                setState(() {
                  students.add(studentNameController.text);
                });
                _saveCourseDetails();
              }
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  // Edit Student
  void _editStudent(int index) async {
    TextEditingController studentNameController = TextEditingController(text: students[index]);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Student"),
        content: TextField(
          controller: studentNameController,
          decoration: InputDecoration(labelText: "Student Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (studentNameController.text.isNotEmpty) {
                setState(() {
                  students[index] = studentNameController.text;
                });
                _saveCourseDetails();
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // Remove Student
  void _removeStudent(int index) {
    setState(() {
      students.removeAt(index);
    });
    _saveCourseDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course Details"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.bar_chart))],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Course Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(controller: courseCodeController, decoration: InputDecoration(labelText: "Course Code*", filled: true)),
            SizedBox(height: 10),
            TextField(controller: courseTitleController, decoration: InputDecoration(labelText: "Title*", filled: true)),
            SizedBox(height: 10),
            TextField(controller: instructorNameController, decoration: InputDecoration(labelText: "Instructor Name*", filled: true)),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(onPressed: _saveCourseDetails, child: Text("Save Changes")),
                SizedBox(width: 10),
                OutlinedButton(onPressed: () {}, child: Text("Cancel")),
              ],
            ),
            SizedBox(height: 20),
            Text("Enrolled Students (${students.length})", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _addStudent, child: Text("Add Student")),
            SizedBox(height: 10),
            Expanded(
              child: students.isEmpty
                  ? Center(child: Text("No students enrolled yet"))
                  : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(students[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () => _editStudent(index), icon: Icon(Icons.edit)),
                                IconButton(onPressed: () => _removeStudent(index), icon: Icon(Icons.delete, color: Colors.red)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteCourse,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete Course", style: TextStyle(color: Colors.white)),
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
