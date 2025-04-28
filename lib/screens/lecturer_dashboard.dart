import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'bottom.dart';
import 'profile_screen.dart';
import 'reportscreen.dart';


class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  _LecturerDashboardState createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  int _currentIndex = 0;
  final CollectionReference _classesCollection =
      FirebaseFirestore.instance.collection('scheduled_classes');
  String? userName;
  String? userEmail;
  String? profileImage;

  Future<void> _fetchUserProfile() async {
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('lecturers')
          .doc('user_id_here') // Replace with actual user ID
          .get();
      if (userSnapshot.exists) {
        setState(() {
          userName = userSnapshot['name'];
          userEmail = userSnapshot['email'];
          profileImage = userSnapshot['profileImage'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User profile not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching profile: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _addUpcomingClass() async {
    final contextRef = context;
    String? selectedCourseCode;
    DateTime? selectedDateTime;

    List<String> courseCodes = [];
    QuerySnapshot courseSnapshot =
        await FirebaseFirestore.instance.collection('courses').get();
    for (var doc in courseSnapshot.docs) {
      courseCodes.add(doc['courseCode']);
    }

    bool? result = await showDialog<bool>(
      context: contextRef,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add Upcoming Class"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCourseCode,
              items: courseCodes.map((code) {
                return DropdownMenuItem(value: code, child: Text(code));
              }).toList(),
              onChanged: (value) {
                selectedCourseCode = value;
              },
              decoration: InputDecoration(labelText: "Select Course Code"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? date = await showDatePicker(
                  context: dialogContext,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  TimeOfDay? time = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    selectedDateTime = DateTime(
                        date.year, date.month, date.day, time.hour, time.minute);
                  }
                }
              },
              child: const Text("Select Date & Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (selectedCourseCode != null && selectedDateTime != null) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (result == true && selectedDateTime != null && selectedCourseCode != null) {
      await _classesCollection.add({
        'courseCode': selectedCourseCode,
        'dateTime': Timestamp.fromDate(selectedDateTime!),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCalendarCard(),
                _buildProfileCard(),
                _buildReportCard(), // New Report Card
              ],
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Upcoming Classes",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: StreamBuilder(
                        stream: _classesCollection
                            .where('dateTime', isGreaterThan: Timestamp.now())
                            .orderBy('dateTime')
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("No upcoming classes"));
                          }
                          return ListView(
                            children: snapshot.data!.docs.map((doc) {
                              Timestamp timestamp = doc["dateTime"];
                              DateTime classDateTime = timestamp.toDate();
                              return _buildClassItem(doc.get("courseCode"), classDateTime);
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Expanded(
      child: InkWell(
        onTap: _addUpcomingClass,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.calendar_today, size: 40, color: Colors.blue),
                SizedBox(height: 5),
                Text("Schedule Class",
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LecturerProfileScreen(),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.account_circle, size: 40, color: Colors.blue),
                SizedBox(height: 5),
                Text("Profile",
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildReportCard() {
  return Expanded(
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>AttendanceReportScreen (), // Navigate to the report screen
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.bar_chart, size: 40, color: Colors.green),
              SizedBox(height: 5),
              Text("Reports",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildClassItem(String code, DateTime dateTime) {
    String formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);
    return Card(
      child: ListTile(
        title: Text(code),
        subtitle: Text(formattedDate),
      ),
    );
  }
}
