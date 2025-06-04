import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioPage extends StatelessWidget {
  const CalendarioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendário',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat', // Troque para a fonte que preferir
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Color(0xFF7F5AF0),
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat', // Troque para a fonte que preferir
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            weekendTextStyle: TextStyle(
              color: Colors.white70,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          headerStyle: const HeaderStyle(
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            formatButtonVisible: false,
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.white70,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
