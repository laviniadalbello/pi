import 'package:flutter/material.dart';
import 'dart:math';
import 'configuracoes.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _circleController;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _circleController.dispose();

    super.dispose();
  }

  Widget _buildMenuCard(BuildContext context) {
    double bottomPadding = 60.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: 40, right: 40),
      child: Material(
        color: const Color.fromARGB(223, 17, 24, 39),
        elevation: 8,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          // Padding inside the card
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
                onPressed: () => Navigator.of(context).pop(), //
                child: const Icon(Icons.close, size: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      extendBody: true,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Stack(
                children: [
                  _animatedCircle(20, 150, 6, [
                    Colors.lightBlueAccent,
                    const Color.fromARGB(255, 243, 33, 208),
                  ], 0),
                  _animatedCircle(350, 130, 4, [
                    Color.fromARGB(164, 180, 34, 238),
                    Colors.deepPurpleAccent,
                  ], 1),
                  _animatedCircle(180, 150, 5, [
                    Colors.amberAccent,
                    Colors.orange,
                  ], 2),
                  _animatedCircle(40, 115, 5, [
                    Colors.pinkAccent,
                    const Color.fromARGB(255, 149, 226, 4),
                  ], 3),
                  _animatedCircle(370, 150, 8, [
                    Color.fromARGB(173, 36, 17, 204),
                    const Color.fromARGB(255, 218, 20, 20),
                  ], 4),
                  _animatedCircle(100, 120, 6, [
                    Color.fromARGB(255, 222, 87, 240),
                    const Color.fromARGB(255, 27, 112, 1),
                  ], 5),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),

                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.image,
                          color: Color(0xFF8875FF),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'USER',
                        style: TextStyle(
                          color: Color(0xFF8875FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '@nomedousuario',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // ação do botão Edit
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color.fromARGB(137, 130, 11, 241),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Botão My Projects
                  _fixedButton(text: 'My Projects'),

                  const SizedBox(height: 20),

                  // Botão Settings
                  _fixedButton(text: 'Settings'),
                ],
              ),
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
          showModalBottomSheet(
            context: context,
            builder: _buildMenuCard,
            backgroundColor: Colors.transparent,
            elevation: 0,
          );
        },

        child: const Icon(Icons.add, size: 28, color: Colors.white),
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

  Widget _fixedButton({required String text}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(text, style: const TextStyle(color: Colors.black)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (text == 'Settings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsApp()),
            );
          } else {}
        },
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
}
