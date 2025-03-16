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
  final CollectionReference _classesCollection = FirebaseFirestore.instance.collection('scheduled_classes');

  void _addUpcomingClass() async {
    final contextRef = context; // Capture context before async calls
    TextEditingController courseTitleController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    bool? result = await showDialog<bool>(
      context: contextRef,
      builder: (dialogContext) => AlertDialog(
        title: Text("Add Upcoming Class"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courseTitleController,
              decoration: InputDecoration(labelText: "Course Title"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: dialogContext,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  selectedTime = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.now(),
                  );
                }
              },
              child: Text("Select Date & Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (courseTitleController.text.isNotEmpty && selectedDate != null && selectedTime != null) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );

    if (result == true && selectedDate != null && selectedTime != null) {
      await _classesCollection.add({
        'courseTitle': courseTitleController.text,
        'date': "${selectedDate!.month}/${selectedDate!.day}",
        'time': selectedTime!.format(contextRef),
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
                stream: _classesCollection.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No upcoming classes"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return _buildClassItem(doc["courseTitle"], doc["date"], doc["time"]);
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

  Widget _buildClassItem(String title, String date, String time) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text("$date at $time"),
      ),
    );
  }
}