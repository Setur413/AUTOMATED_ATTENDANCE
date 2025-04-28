import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  _AttendanceReportScreenState createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  String? selectedCourse;
  List<String> courses = [];
  List<DateTime> sessionDates = [];
  List<Map<String, dynamic>> allAttendanceRecords = [];
  int presentCount = 0;
  double attendancePercentage = 0.0;
  bool isLoading = true;
  bool loadingDates = false;
  int totalExpectedAttendance = 0;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      var courseSnapshot = await FirebaseFirestore.instance.collection('courses').get();
      List<String> courseList = courseSnapshot.docs.map((doc) => doc['courseCode'] as String).toList();
      setState(() {
        courses = courseList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching courses: $e")),
      );
    }
  }

  Future<void> _fetchSessions(String course) async {
    setState(() {
      loadingDates = true;
      sessionDates.clear();
      allAttendanceRecords.clear();
    });

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('session_attendance')
          .where('sessionTitle', isEqualTo: course)
          .get();

      Set<DateTime> uniqueDates = {};
      List<Map<String, dynamic>> tempList = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = Map<String, dynamic>.from(doc.data());
        Timestamp timestamp = data['scannedAt'];
        DateTime date = timestamp.toDate();
        DateTime pureDate = DateTime(date.year, date.month, date.day);

        data['scannedDate'] = pureDate;
        tempList.add(data);
        uniqueDates.add(pureDate);
      }

      setState(() {
        allAttendanceRecords = tempList;
        sessionDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));
        loadingDates = false;
      });

      var registrationSnapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .where('courseCode', isEqualTo: course)
          .get();

      setState(() {
        totalExpectedAttendance = registrationSnapshot.docs.length;
      });
    } catch (e) {
      setState(() {
        loadingDates = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching sessions: $e")),
      );
    }
  }

  void _calculateAttendanceByDate(DateTime date) {
    List<Map<String, dynamic>> filteredRecords = allAttendanceRecords
        .where((record) => record['scannedDate'] == date && (record['status']?.toLowerCase() == 'present'))
        .toList();

    setState(() {
      presentCount = filteredRecords.length;
      attendancePercentage = totalExpectedAttendance > 0
          ? (presentCount / totalExpectedAttendance) * 100
          : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Attendance Report"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Course",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : DropdownButton<String>(
                    value: selectedCourse,
                    hint: const Text("Choose a Course"),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCourse = newValue;
                        presentCount = 0;
                        attendancePercentage = 0.0;
                      });
                      _fetchSessions(newValue!);
                    },
                    items: courses.map<DropdownMenuItem<String>>((String course) {
                      return DropdownMenuItem<String>(
                        value: course,
                        child: Text(course),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),
            if (loadingDates) const Center(child: CircularProgressIndicator()),
            if (sessionDates.isNotEmpty) ...[
              const Text(
                "Select Date",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: sessionDates.length,
                  itemBuilder: (context, index) {
                    DateTime date = sessionDates[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      child: ListTile(
                        title: Text("${date.toLocal()}".split(' ')[0]),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          _calculateAttendanceByDate(date);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (totalExpectedAttendance > 0) ...[
              Center(
                child: Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15.0),
                        title: Text(
                          "Attendance Percentage: ${attendancePercentage.toStringAsFixed(2)}%",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                        subtitle: LinearProgressIndicator(
                          value: attendancePercentage / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15.0),
                        title: Text(
                          "Present: $presentCount",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Total Registered: $totalExpectedAttendance",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
