import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom.dart';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  _LecturerDashboardState createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  int _currentIndex = 0;
  final CollectionReference _classesCollection =
      FirebaseFirestore.instance.collection('scheduled_classes');

  void _addUpcomingClass() async {
    final contextRef = context;
    String? selectedCourseCode;
    DateTime? selectedDateTime;

    // Fetch course codes from Firestore
    List<String> courseCodes = [];
    QuerySnapshot courseSnapshot = await FirebaseFirestore.instance.collection('courses').get();
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
                    selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
                _buildInfoCard("80.8%", "Avg. attendance rate"),
              ],
            ),
            SizedBox(height: 20),
            Text("Upcoming Classes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: _classesCollection.where('dateTime', isGreaterThan: Timestamp.now()).snapshots(),
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
                Text("Schedule Class", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassItem(String code, DateTime dateTime) {
    return Card(
      child: ListTile(
        title: Text(code),
        subtitle: Text("${dateTime.month}/${dateTime.day} at ${dateTime.hour}:${dateTime.minute}"),
      ),
    );
  }
}