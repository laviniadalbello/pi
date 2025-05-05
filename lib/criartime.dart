import 'package:flutter/material.dart';
import 'dart:math';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _cardKey = GlobalKey();

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
    super.dispose();
    _slideController.dispose();
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
            // Círculos animados
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
                  const SizedBox(height: 30),
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
                        'Create Team',
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
                      const CircleAvatar(
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
                        'Upload logo file',
                        style: TextStyle(
                          color: Color(0xFF8875FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Your logo will publish always',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Team Name',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 55,
                    child: TextFormField(
                      initialValue: 'Team Align',
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Team Member',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _avatar('assets/jeny.png', 'Jeny'),
                      _avatar('assets/mehrin.png', 'Mehrin'),
                      _avatar('assets/avishek.png', 'Avishek'),
                      _avatar('assets/jafor.png', 'Jafor'),
                      _addMemberButton(),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Color.fromARGB(239, 255, 255, 255)),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 13),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Type',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _typeButton('Private', selected: true),
                      const SizedBox(width: 10),
                      _typeButton('Public'),
                      const SizedBox(width: 10),
                      _typeButton('Secret'),
                    ],
                  ),
                  const SizedBox(height: 66),
                  SizedBox(
                    width: 195,
                    height: 43,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8875FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Create Team',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            if (_isCardVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCardVisible = false;
                      _slideController.reverse();
                    });
                  },
                  child: Container(color: Colors.black54.withOpacity(0)),
                ),
              ),
            if (_isCardVisible)
              Positioned(
                bottom: 20,
                left: 30,
                right: 30,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      key: _cardKey,
                      constraints: const BoxConstraints(minHeight: 130),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
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
                          // Add the close button matching the reference image style
                          FloatingActionButton(
                            mini: true, // Make it smaller
                            backgroundColor:
                                Colors.blueAccent, // Match FAB color
                            elevation: 0, // Lower elevation for inner button
                            shape: const CircleBorder(),
                            onPressed: () {
                              setState(() {
                                _isCardVisible = false;
                                _slideController.reverse();
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ), // White icon
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _avatar(String assetPath, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          CircleAvatar(backgroundImage: AssetImage(assetPath), radius: 18),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 10)),
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

  Widget _addMemberButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF8875FF), width: 2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Icon(Icons.add, color: Color(0xFF8875FF)),
            ),
          ),
          const SizedBox(height: 4),
          const Text('', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _typeButton(
    String text, {
    bool selected = false,
    double leftPadding = 14,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Container(
        width: 90,
        height: 38,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8875FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
