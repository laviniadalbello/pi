import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Today Task',
      theme: ThemeData.dark(useMaterial3: true),
      home: const TodayTaskPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodayTaskPage extends StatelessWidget {
  const TodayTaskPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final dates = [
      {'day': '19', 'week': 'Sat'},
      {'day': '20', 'week': 'Sun'},
      {'day': '21', 'week': 'Mon'},
      {'day': '22', 'week': 'Tue'},
      {'day': '23', 'week': 'Wed'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
   appBar: AppBar(
  backgroundColor: Colors.black,
  title: const Text(
    'Today Task',
    style: TextStyle(
      fontSize: 24,
      color: Colors.white,
    ),
  ),
  centerTitle: true,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
    onPressed: () {},
  ),
  actions: [
    Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 20),
    ),
    Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.edit, color: Colors.white, size: 20),
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              const SizedBox(height: 27),
Text(
  '${DateFormat('MMMM, d').format(DateTime.now())} ✍️',
  style: const TextStyle(
    fontSize: 28, // Aumentado
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
     const Text(
              '15 task today',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final item = dates[index];
                  final isSelected = index == 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.purple : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item['day']!,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black)),
                          const SizedBox(height: 4),
                          Text(item['week']!,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: const [
                  TaskItem(
                    time: '10 am',
                    title: 'Wareframe elements 😌',
                    color: Colors.lightBlue,
                    participants: ['👨‍💼', '👩‍💻'],
                    duration: '10am - 11am',
                  ),
                  TaskItem(
                    time: '11 am',
                    title: 'Mobile app Design 😍',
                    color: Colors.greenAccent,
                    participants: ['👨🏿‍💻', '👩🏻‍💼', '👨🏽‍💻'],
                    duration: '11:40am - 12:40pm',
                  ),
                  TaskItem(
                    time: '01 pm',
                    title: 'Design Team call 😎',
                    color: Colors.deepOrangeAccent,
                    participants: ['👩‍💼', '👨‍💼', '+5'],
                    duration: '01:20pm - 02:20pm',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.chat_bubble_outline, color: Colors.white),
              SizedBox(width: 40), // espaço para o botão flutuante
              Icon(Icons.more_horiz, color: Colors.white),
              Icon(Icons.person_outline, color: Colors.white),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class TaskItem extends StatelessWidget {
  final String time;
  final String title;
  final Color color;
  final List<String> participants;
  final String duration;

  const TaskItem({
    super.key,
    required this.time,
    required this.title,
    required this.color,
    required this.participants,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 60,
              child: Text(time,
                  style: const TextStyle(color: Colors.white, fontSize: 16))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...participants
                          .map((p) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(p, style: const TextStyle(fontSize: 12)),
                                  radius: 14,
                                ),
                              ))
                          .toList(),
                      const Spacer(),
                      Text(duration,
                          style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
