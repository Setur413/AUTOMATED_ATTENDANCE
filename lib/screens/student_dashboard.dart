import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attendance/screens/class_calendar.dart';
import 'package:qr_attendance/screens/navigation.dart';
import 'package:qr_attendance/screens/student_profile.dart';

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        title: Text(
          "Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentProfileScreen(userData: widget.userData),
                ),
              );
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Title
            Center(
              child: Text(
                "Attendify",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            Center(
              child: Text(
                "Your attendance app",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            // Upcoming Classes Section
            Text(
              "Upcoming Classes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)))
                    : ClassCalendar(upcomingClasses: _upcomingClasses),
            SizedBox(height: 20),
            // Recent Attendance Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 6,
              shadowColor: Colors.grey[500],
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.blueAccent),
                title: Text("Recent Attendance Records", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Last marked attendance on 12th March 2025"),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                onTap: () {
                  // Handle tap (navigate to the attendance history screen if needed)
                },
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
