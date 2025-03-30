import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ClassCalendar extends StatefulWidget {
  final List<Map<String, dynamic>> upcomingClasses;

  const ClassCalendar({super.key, required this.upcomingClasses});

  @override
  _ClassCalendarState createState() => _ClassCalendarState();
}

class _ClassCalendarState extends State<ClassCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _prepareEvents();
  }

  /// Normalize DateTime by removing time (set hour, minute, second to 0)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _prepareEvents() {
    Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (var classData in widget.upcomingClasses) {
      DateTime classDate = _normalizeDate(classData['dateTime']); // Normalize date

      if (!events.containsKey(classDate)) {
        events[classDate] = [];
      }
      events[classDate]!.add(classData);
    }

    setState(() {
      _events = events;
    });

    // Debugging output
    print("Events map: $_events");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            print("Selected date: $_selectedDay");
            print("Classes on selected date: ${_events[_normalizeDate(_selectedDay!)] ?? "None"}");
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          eventLoader: (day) {
            DateTime normalizedDate = _normalizeDate(day);
            return _events[normalizedDate] ?? [];
          },
        ),
        const SizedBox(height: 10),
        if (_selectedDay != null && _events.containsKey(_normalizeDate(_selectedDay!)))
          Column(
            children: _events[_normalizeDate(_selectedDay!)]!.map((classData) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(classData['courseCode']),
                  subtitle: Text("${classData['dateTime']}"), // Format if needed
                  leading: const Icon(Icons.class_, color: Colors.blue),
                ),
              );
            }).toList(),
          )
        else
          const Text("No classes today"),
      ],
    );
  }
}
