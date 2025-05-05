import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';
import 'chatdaia.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _cardKey = GlobalKey();

  bool _isDrawerOpen = false;
  bool _isCardVisible = false;

  late AnimationController _fadeController;
  late AnimationController _circleController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.55);
    initializeDateFormatting('pt_BR', null).then((_) => setState(() {}));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    _circleController = AnimationController(
      duration: const Duration(seconds: 3),
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
    _fadeController.dispose();
    _circleController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
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
              // Fecha o card flutuante se estiver visível
              if (_isCardVisible) {
                if (mounted) {
                  setState(() {
                    _isCardVisible = false;
                    _slideController.reverse();
                  });
                }
              }
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        _buildTopBar(),
                        const SizedBox(height: 15),
                        _buildTitle(),
                        const SizedBox(height: 5),
                        _buildProjectCarousel(),
                        const SizedBox(height: 10),
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
                          // The last task card
                          title: "Working On Landing Page",
                          subtitle: "Online Course",
                          time: "7 min ago",
                          progress: 0.8,
                        ),
                        Transform.translate(
                          offset: const Offset(65, -25),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: CloseableAiCard(scaleFactor: 0.35),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Card flutuante (menu de criação)
          if (_isCardVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      _isCardVisible = false;
                      _slideController.reverse();
                    });
                  }
                },
                // Usa uma cor semi-transparente para o fundo, evitando problemas
                child: Container(color: Colors.black.withOpacity(0.5)),
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
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildTopBar() {
    String formattedDate = DateFormat(
      'EEEE, dd MMMM',
      'pt_BR',
    ).format(DateTime.now());

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
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            // Lógica de notificação aqui
          },
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

          _animatedCircle(20, 10, 6, [
            Colors.lightBlueAccent,
            const Color.fromARGB(255, 243, 33, 208),
          ], 0),
          _animatedCircle(350, 20, 4, [
            Color.fromARGB(164, 180, 34, 238),
            Colors.deepPurpleAccent,
          ], 1),
          _animatedCircle(180, 45, 5, [Colors.amberAccent, Colors.orange], 2),
          _animatedCircle(40, 80, 5, [
            Colors.pinkAccent,
            const Color.fromARGB(255, 149, 226, 4),
          ], 3),
          _animatedCircle(370, 90, 8, [
            Color.fromARGB(173, 36, 17, 204),
            const Color.fromARGB(255, 218, 20, 20),
          ], 4),
          _animatedCircle(100, 30, 6, [
            Color.fromARGB(255, 222, 87, 240),
            const Color.fromARGB(255, 27, 112, 1),
          ], 5),
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
        final offset = 2 * sin(t * 2 * pi);

        // Interpolação de cor
        final colorTween = ColorTween(begin: colors[0], end: colors[1]);
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildProjectCarousel() {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 3,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page =
                  _pageController.hasClients && _pageController.page != null
                      ? _pageController.page!
                      : index.toDouble();

              double scaleFactor = 0.9;
              double position = index.toDouble() - page;
              double scale = (1 - (position.abs() * 0.1)).clamp(
                scaleFactor,
                1.0,
              );

              return Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: _buildProjectCard(
                    context,
                    "Projeto ${index + 1}",
                    index == 0
                        ? "Front-End\nDevelopment"
                        : index == 1
                        ? "Back-End\nDevelopment"
                        : "Mobile App\nDesign",
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.now().add(Duration(days: index * 3))),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    String title,
    String desc,
    String date,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.22;

    return Container(
      width: 160,
      height: cardHeight,
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 18,
                ),
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  // Ações dos botões
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'Editar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Excluir',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'view',
                        child: Text(
                          'Visualizar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              desc,
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // Limitar o número de linhas para evitar o overflow
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressHeader() {
    return const Text(
      'In Progress',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required String time,
    required double progress,
  }) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          // Remove o efeito quando o mouse sai
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
          boxShadow:
              _isHovered
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                  : [],
        ),

        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.white30, fontSize: 11),
                  ),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF8A5CFF),
                    ),
                  ),
                ),
                Text(
                  "${(progress * 100).round()}%",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isHovered = false;

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 60,
          left: 16,
          right: 16,
          bottom: 20,
        ), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info section
            Row(
              children: [
                const CircleAvatar(
                  radius: 25, // Slightly larger avatar
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?img=11",
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Nome do Usuário",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white24), // Lighter divider

            Expanded(
              //
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(Icons.home_outlined, "Início", true),
                  _drawerItem(Icons.topic_outlined, "Tópicos"),
                  _drawerItem(Icons.message_outlined, "Mensagens"),
                  _drawerItem(Icons.notifications_outlined, "Notificações"),
                  _drawerItem(Icons.bookmark_border, "Favoritos"),
                  _drawerItem(Icons.person_outline, "Perfil"),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            // Settings or Logout (optional)
            _drawerItem(Icons.settings_outlined, "Configurações"),
            _drawerItem(Icons.logout, "Sair"),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, [bool isActive = false]) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blueAccent : Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.blueAccent : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context);

        print("$title tapped");
      },
      dense: true, // Reduce vertical padding
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.white.withOpacity(0.1), // Subtle hover effect
    );
  }
}
