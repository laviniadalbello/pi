import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _cardKey = GlobalKey();

  bool _isDrawerOpen = false;
  bool _isCardVisible = false;

  late AnimationController _fadeController;
  late AnimationController _circleController;
  late Animation<double> _fadeAnimation;
  

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null).then((_) => setState(() {}));

    // Controller para a animação de entrada
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Controller separado para os círculos decorativos
  _circleController = AnimationController(
  duration: const Duration(seconds: 6),
  vsync: this,
)..repeat(); // Animação contínua
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      backgroundColor: Colors.black,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isCardVisible) {
                setState(() {
                  _isCardVisible = false;
                });
              }
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      _buildTopBar(),
                      const SizedBox(height: 20),
                      _buildTitle(), // Agora usa o _circleController
                      const SizedBox(height: 30),
                      _buildProjectCarousel(),
                      const SizedBox(height: 30),
                      _buildInProgressHeader(),
                      const SizedBox(height: 10),
                      _buildTaskCard(
                        title: "Create Detail Booking",
                        subtitle: "Productivity Mobile App",
                        time: "2 min ago",
                        progress: 0.6,
                      ),
                      const SizedBox(height: 10),
                      _buildTaskCard(
                        title: "Revision Home Page",
                        subtitle: "Banking Mobile App",
                        time: "5 min ago",
                        progress: 0.7,
                      ),
                      const SizedBox(height: 10),
                      _buildTaskCard(
                        title: "Working On Landing Page",
                        subtitle: "Online Course",
                        time: "7 min ago",
                        progress: 0.8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isCardVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isCardVisible = false;
                  });
                },
                child: Container(
                  color: Colors.black54.withOpacity(0),
                ),
              ),
            ),
          if (_isCardVisible)
            Positioned(
              bottom: 5,
              left: 30,
              right: 30,
              child: Material(
                color: const Color.fromARGB(0, 36, 36, 36),
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  key: _cardKey,
                  constraints: const BoxConstraints(minHeight: 150),
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 36),
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
                      _menuItem(Icons.task, 'Create Task'),
                      const SizedBox(height: 12),
                      _menuItem(Icons.work, 'Create Project'),
                      const SizedBox(height: 12),
                      _menuItem(Icons.group, 'Create Team'),
                      const SizedBox(height: 12),
                      _menuItem(Icons.event, 'Create Event'),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
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

  Widget _buildTopBar() {
    String formattedDate =
        DateFormat('EEEE, dd MMMM', 'pt_BR').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _isDrawerOpen = !_isDrawerOpen);
            if (_isDrawerOpen) {
              _scaffoldKey.currentState?.openDrawer();
            } else {
              _scaffoldKey.currentState?.closeDrawer();
            }
          },
          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        ),
        Text(
          formattedDate,
          style: const TextStyle(
              color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(
            "https://i.pravatar.cc/150?img=11",
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return SizedBox(
      height: 130,
      child: Stack(
        children: [
          // Texto central
          const Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Let's build goods\n",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: "habits together 🙌",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.start,
            ),
          ),

          // Círculos decorativos com leve animação
        _animatedCircle(20, 10, 6, [Colors.lightBlueAccent, const Color.fromARGB(255, 243, 33, 208)], 0),
        _animatedCircle(350, 20, 4, [Color.fromARGB(164, 180, 34, 238), Colors.deepPurpleAccent], 1),
        _animatedCircle(180, 45, 5, [Colors.amberAccent, Colors.orange], 2),
        _animatedCircle(40, 80, 5, [Colors.pinkAccent, const Color.fromARGB(255, 149, 226, 4)], 3),
        _animatedCircle(370, 90, 8, [Color.fromARGB(173, 36, 17, 204), const Color.fromARGB(255, 218, 20, 20)], 4),
        _animatedCircle(100, 30, 6, [Color.fromARGB(255, 222, 87, 240), const Color.fromARGB(255, 27, 112, 1)], 5),

        ],
      ),
    );
  }

Widget _animatedCircle(double x, double y, double size, List<Color> colors, int index) {
  return AnimatedBuilder(
    animation: _circleController,
    builder: (context, child) {
      final t = (_circleController.value + (index * 0.1)) % 1.0;
      final offset = 2 * sin(t * 2 * pi);

      // Interpolação de cor
      final colorTween = ColorTween(
        begin: colors[0],
        end: colors[1],
      );
      final animatedColor = colorTween.transform(t) ?? colors[0];

      // Escala e opacidade pulsantes
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
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProjectCarousel() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildProjectCard("Projeto 1", "Front-End\nDevelopment", "20/10/2020"),
          const SizedBox(width: 12),
          _buildProjectCard("Projeto 2", "Back-End\nDevelopment", "24/10/2020"),
        ],
      ),
    );
  }

  Widget _buildProjectCard(String title, String desc, String date) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF9E62FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(desc,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInProgressHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("In Progress",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white38),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required String time,
    required double progress,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 6),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(time, style: const TextStyle(color: Colors.white30, fontSize: 11)),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 38,
                width: 38,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8A5CFF)),
                ),
              ),
              Text("${(progress * 100).round()}%",
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Menu",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _drawerItem(Icons.home, "Início"),
            _drawerItem(Icons.topic, "Tópicos"),
            _drawerItem(Icons.message, "Mensagens"),
            _drawerItem(Icons.notifications, "Notificações"),
            _drawerItem(Icons.bookmark, "Favoritos"),
            _drawerItem(Icons.person, "Perfil"),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
