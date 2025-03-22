import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attendance/screens/navigation.dart';

class CourseRegistrationScreen extends StatefulWidget {
  const CourseRegistrationScreen({super.key});

  @override
  _CourseRegistrationScreenState createState() =>
      _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  int _currentIndex = 1; // Default tab to "Courses"
  final String studentId = "student123"; // TODO: Replace with authenticated user ID

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _isCourseRegistered(String courseCode) async {
    var doc = await FirebaseFirestore.instance
        .collection('registrations')
        .doc("${studentId}_$courseCode")
        .get();
    return doc.exists;
  }

  void _registerForCourse(String courseCode, String courseTitle) async {
    bool alreadyRegistered = await _isCourseRegistered(courseCode);

    if (alreadyRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are already registered for $courseTitle.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('registrations')
          .doc("${studentId}_$courseCode")
          .set({
        'studentId': studentId,
        'courseCode': courseCode,
        'courseTitle': courseTitle,
        'registrationDate': Timestamp.now(),
      });

      setState(() {}); // Refresh UI to disable the button

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully registered for $courseTitle!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error registering: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Course Registration",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.bar_chart, color: Colors.black),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.grey, // Placeholder for user image
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('courses').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No courses available."));
            }

            var courses = snapshot.data!.docs;

            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                var course = courses[index];
                String title = course['courseTitle'] ?? "No Title";
                String code = course['courseCode'] ?? "No Code";
                String instructor = course['instructorName'] ?? "Instructor";
                String description =
                    "Learn more about $title taught by $instructor.";

                return FutureBuilder<bool>(
                  future: _isCourseRegistered(code),
                  builder: (context, snapshot) {
                    bool isRegistered = snapshot.data ?? false;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$code: $instructor",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                onPressed: isRegistered
                                    ? null
                                    : () => _registerForCourse(code, title),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isRegistered
                                      ? Colors.grey
                                      : Colors.white,
                                  foregroundColor: isRegistered
                                      ? Colors.black
                                      : Colors.blue,
                                  side: BorderSide(
                                      color: isRegistered
                                          ? Colors.grey
                                          : Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                    isRegistered ? "Registered" : "Register"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
