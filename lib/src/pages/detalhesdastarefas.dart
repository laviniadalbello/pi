import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() => runApp(const DetailsTaskPage());

class DetailsTaskPage extends StatelessWidget {
  const DetailsTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Today Task',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: TodayTaskPage(),
    );
  }
}

class TodayTaskPage extends StatefulWidget {
  const TodayTaskPage({super.key});

  @override
  State<TodayTaskPage> createState() => _TodayTaskPageState();
}

class _TodayTaskPageState extends State<TodayTaskPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isCardVisible = false;

  late AnimationController _circleController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _circleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

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
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      extendBody: true,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Today Task',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {},
            ),
            actions: [
              _iconCircle(Icons.calendar_today_outlined),
              _iconCircle(Icons.edit),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                _animatedCircle(20, 50, 6, [
                  Colors.lightBlueAccent,
                  const Color.fromARGB(255, 243, 33, 208),
                ], 0),
                _animatedCircle(300, 60, 4, [
                  Color.fromARGB(164, 180, 34, 238),
                  Colors.deepPurpleAccent,
                ], 1),
                _animatedCircle(180, 50, 5, [
                  Colors.amberAccent,
                  Colors.orange,
                ], 2),
                _animatedCircle(40, 45, 5, [
                  Colors.pinkAccent,
                  const Color.fromARGB(255, 149, 226, 4),
                ], 3),
                _animatedCircle(310, 50, 8, [
                  Color.fromARGB(173, 36, 17, 204),
                  const Color.fromARGB(255, 218, 20, 20),
                ], 4),
                _animatedCircle(100, 30, 3, [
                  Color.fromARGB(255, 222, 87, 240),
                  const Color.fromARGB(255, 27, 112, 1),
                ], 5),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  '${DateFormat('MMMM, d').format(DateTime.now())} ✍️',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  '15 task today',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                _buildDateSelector(dates),
                const SizedBox(height: 24),
                Expanded(child: _buildTaskArea()),
              ],
            ),
          ),
          if (_isCardVisible)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCardVisible = false;
                  _slideController.reverse();
                });
              },
              child: Container(color: Colors.black54),
            ),
          if (_isCardVisible)
            Positioned(
              bottom: 20,
              left: 30,
              right: 30,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildFloatingCard(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _animatedCircle(
    double x,
    double y,
    double size,
    List<Color> colors,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _circleController,
      builder: (context, child) {
        final t = (_circleController.value + (index * 0.1)) % 1.0;
        final offset = 20 * sin(t * 2 * pi);
        final colorTween = ColorTween(begin: colors[0], end: colors[1]);
        final animatedColor = colorTween.transform(t) ?? colors[0];
        final pulse = 0.5 + 0.5 * sin(t * 2 * pi);
        final scale = 1.0 + 0.05 * pulse;
        final opacity = 0.8 + 0.2 * pulse;

        return Positioned(
          top: y + offset,
          left: x,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: _decorativeCircle(size, animatedColor),
            ),
          ),
        );
      },
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildDateSelector(List<Map<String, String>> dates) {
    return SizedBox(
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
                  Text(
                    item['day']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['week']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskArea() {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: List.generate(
              12,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.20),
                ),
              ),
            ),
          ),
        ),
        ListView(
          padding: EdgeInsets.zero,
          children: const [
            TaskItem(
              time: '10 am',
              title: 'Wareframe elements 😌',
              color: Color(0xFF63B4FF),
              participants: ['👨‍💼', '👩‍💻'],
              duration: '10am - 11am',
            ),
            TaskItem(
              time: '11 am',
              title: 'Mobile app Design 😍',
              color: Color(0xFFB1D199),
              participants: ['👨🏿‍💻', '👩🏻‍💼', '👨🏽‍💻'],
              duration: '11:40am - 12:40pm',
            ),
            TaskItem(
              time: '01 pm',
              title: 'Design Team call 😎',
              color: Color(0xFFFFB35A),
              participants: ['👩‍💼', '👨‍💼', '+5'],
              duration: '01:20pm - 02:20pm',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingCard() {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color.fromARGB(223, 17, 24, 39),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(Icons.edit_outlined, 'Create Task'),
            const SizedBox(height: 12),
            _menuItem(Icons.add_circle_outline, 'Create Project'),
            const SizedBox(height: 12),
            _menuItem(Icons.group_outlined, 'Create Team'),
            const SizedBox(height: 12),
            _menuItem(Icons.schedule_outlined, 'Create Event'),
            const SizedBox(height: 16),
            FloatingActionButton(
              mini: true,
              backgroundColor: Colors.blueAccent,
              elevation: 0,
              shape: const CircleBorder(),
              onPressed: () {
                setState(() {
                  _isCardVisible = false;
                  _slideController.reverse();
                });
              },
              child: const Icon(Icons.close, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Transform.translate(
      offset: const Offset(0, 30),
      child: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () {
          setState(() {
            _isCardVisible = !_isCardVisible;
            if (_isCardVisible) {
              _slideController.forward();
            } else {
              _slideController.reverse();
            }
          });
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.black,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home_rounded),
                  color: Colors.blueAccent,
                  onPressed: () {},
                ),
                const SizedBox(width: 28),
                IconButton(
                  icon: const Icon(Icons.folder_rounded),
                  color: Colors.white30,
                  onPressed: () {},
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: Colors.white30,
                  onPressed: () {},
                ),
                const SizedBox(width: 28),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  color: Colors.white30,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...participants.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              p,
                              style: const TextStyle(fontSize: 12),
                            ),
                            radius: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
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
