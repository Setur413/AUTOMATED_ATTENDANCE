import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attendance/screens/navigation.dart';

class CourseRegistrationScreen extends StatefulWidget {
  const CourseRegistrationScreen({super.key});

  @override
  _CourseRegistrationScreenState createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  int _currentIndex = 1; // Default tab to "Courses"
  String? _studentId;
  List<String> _registeredCourses = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentIdAndRegistrations();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Fetch the authenticated student's ID and their registered courses
  Future<void> _fetchStudentIdAndRegistrations() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _studentId = user.uid;
      });

      // Fetch all courses the student has registered for
      var registeredDocs = await FirebaseFirestore.instance
          .collection('registrations')
          .where('studentId', isEqualTo: user.uid)
          .get();

      setState(() {
        _registeredCourses = registeredDocs.docs.map((doc) => doc['courseCode'] as String).toList();
      });
    }
  }

  // Register for a course if not already registered
  void _registerForCourse(String courseCode, String courseTitle) async {
    if (_studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Student not logged in.")),
      );
      return;
    }

    if (_registeredCourses.contains(courseCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are already registered for $courseTitle.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('registrations')
          .doc("${_studentId}_$courseCode")
          .set({
        'studentId': _studentId,
        'courseCode': courseCode,
        'courseTitle': courseTitle,
        'registrationDate': Timestamp.now(),
      });

      setState(() {
        _registeredCourses.add(courseCode);
      });

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
        elevation: 4,
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
                String description = "Learn more about $title taught by $instructor.";
                bool isRegistered = _registeredCourses.contains(code);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  margin: const EdgeInsets.only(bottom: 20), // Larger margin between cards
                  elevation: 5,
                  shadowColor: Colors.grey[300],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // More padding inside the card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
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
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: isRegistered
                                ? null
                                : () => _registerForCourse(code, title),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRegistered ? Colors.grey : Colors.blueAccent,
                              foregroundColor: isRegistered ? Colors.black : Colors.white,
                              side: BorderSide(
                                  color: isRegistered ? Colors.grey : Colors.blueAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Rounded button
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                            ),
                            child: Text(
                              isRegistered ? "Registered" : "Register",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
