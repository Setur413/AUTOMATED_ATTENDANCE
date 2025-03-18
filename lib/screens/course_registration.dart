import 'package:flutter/material.dart';
import 'package:qr_attendance/screens/navigation.dart'; // Import bottom navigation

class CourseRegistrationScreen extends StatefulWidget {
  @override
  _CourseRegistrationScreenState createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  int _currentIndex = 1; // Set default tab to "Courses"

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Map<String, String>> courses = [
    {
      "title": "Intro to AI",
      "code": "CS101: Basics of AI",
      "description": "Explore the fundamentals of artificial intelligence.",
      "buttonText": "Register"
    },
    {
      "title": "Data Science",
      "code": "DS201: Data Analysis",
      "description": "Learn techniques for data analysis and visualization.",
      "buttonText": "More Info"
    },
    {
      "title": "Web Development",
      "code": "WD301: Build Websites",
      "description": "Design and develop responsive websites.",
      "buttonText": "Register"
    },
    {
      "title": "Machine Learning",
      "code": "ML401: Algorithms",
      "description": "Understand machine learning algorithms and applications.",
      "buttonText": "More Info"
    },
    {
      "title": "Network Security",
      "code": "NS501: Protect Networks",
      "description": "Learn to secure and protect network systems.",
      "buttonText": "Register"
    },
  ];

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
        child: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];

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
                      course["title"]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course["code"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course["description"]!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle register or more info actions
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(course["buttonText"]!),
                      ),
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
