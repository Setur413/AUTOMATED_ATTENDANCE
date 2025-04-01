import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attendance/screens/class_calendar.dart';
import 'package:qr_attendance/screens/navigation.dart';
import 'package:qr_attendance/screens/student_profile.dart'; // Import profile screen

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> userData; // Accepts user data for profile screen

  const StudentDashboard({super.key, required this.userData});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _upcomingClasses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUpcomingClasses();
  }

  Future<void> _fetchUpcomingClasses() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scheduled_classes')
          .where('dateTime', isGreaterThan: Timestamp.now())
          .orderBy('dateTime')
          .get();

      List<Map<String, dynamic>> classes = snapshot.docs.map((doc) {
        return {
          'courseCode': doc['courseCode'],
          'dateTime': (doc['dateTime'] as Timestamp).toDate(),
        };
      }).toList();

      setState(() {
        _upcomingClasses = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load upcoming classes';
        _isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve student's full name and registration number
    String fullName = widget.userData['fullName'] ?? 'Student';
    String regNumber = widget.userData['registrationNumber'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentProfileScreen(userData: widget.userData),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display welcome message and registration number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Welcome, $fullName", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Reg No: $regNumber",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Attendify",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                "Your attendance app ",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Upcoming classes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
                    : ClassCalendar(upcomingClasses: _upcomingClasses),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              child: const ListTile(
                leading: Icon(Icons.history, color: Colors.blue),
                title: Text("Recent Attendance Records"),
                subtitle: Text("Last marked attendance on 12th March 2025"),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
