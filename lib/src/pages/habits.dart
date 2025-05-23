import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';
import 'iconedaia.dart';
import 'package:planify/services/gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class HabitsPage extends StatefulWidget {
  final GeminiService geminiService;
  const HabitsPage({super.key, required this.geminiService});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _cardKey = GlobalKey();

  final ScrollController _mainScrollController = ScrollController();

  bool _isDrawerOpen = false;
  bool _isCardVisible = false;
  bool _isHovered = false;
  bool _isNotificationsVisible = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Nova mensagem',
      'message': 'Você recebeu uma nova mensagem',
      'time': '2 min atrás',
      'read': false,
    },
    {
      'title': 'Lembrete',
      'message': 'Reunião em 30 minutos',
      'time': '10 min atrás',
      'read': false,
    },
    {
      'title': 'Atualização',
      'message': 'Seu projeto foi atualizado',
      'time': '1 hora atrás',
      'read': true,
    },
    {
      'title': 'Novo seguidor',
      'message': 'Alguém começou a seguir seu perfil',
      'time': '3 horas atrás',
      'read': true,
    },
  ];

  int get _unreadNotificationsCount =>
      _notifications.where((n) => !n['read']).length;

  late AnimationController _fadeController;
  late AnimationController _circleController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;
  late AnimationController _notificationsController;
  late Animation<Offset> _notificationsAnimation;

  String _userName = "Carregando...";

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Adicione esta linha
    _pageController = PageController(viewportFraction: 0.7);
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

    _notificationsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _notificationsAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _notificationsController, curve: Curves.easeOut),
    );

    _loadUserData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _circleController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _notificationsController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    // Fecha o drawer se estiver aberto
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushNamed(routeName);
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _userName = doc['name'] ?? 'Usuário';
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() {
        _userName = 'Usuário';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      backgroundColor: Colors.black,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: CustomScrollView(
        controller: _mainScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isCardVisible) {
                      if (mounted) {
                        setState(() {
                          _isCardVisible = false;
                          _slideController.reverse();
                        });
                      }
                    }
                    if (_isNotificationsVisible) {
                      setState(() {
                        _isNotificationsVisible = false;
                        _notificationsController.reverse();
                      });
                    }
                    FocusScope.of(context).unfocus();
                  },
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            _buildTopBar(),
                            SizedBox(height: screenHeight * 0.02),
                            _buildTitle(context),
                            SizedBox(height: screenHeight * 0.01),
                            _buildProjectCarousel(context),
                            SizedBox(height: screenHeight * 0.02),
                            _buildInProgressHeader(context),
                            SizedBox(height: screenHeight * 0.015),
                            _buildTaskCard(
                              context: context,
                              title: "Criar Detalhes",
                              subtitle: "Produtividade",
                              time: "2 min atras",
                              progress: 0.6,
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            _buildTaskCard(
                              context: context,
                              title: "Revisar a  Home Page",
                              subtitle: "App de banco",
                              time: "5 min atras",
                              progress: 0.7,
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            _buildTaskCard(
                              context: context,
                              title: "Trabalhar na  Landing Page",
                              subtitle: "Curso online",
                              time: "7 min atras",
                              progress: 0.8,
                            ),
                            SizedBox(height: screenHeight * 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 42,
                  right: -60,
                  child: CloseableAiCard(
                    geminiService: widget.geminiService,
                    scaleFactor: screenWidth < 360 ? 0.35 : 0.4,
                    enableScroll: true,
                  ),
                ),
                if (_isCardVisible) _buildDimOverlay(),
                if (_isCardVisible) _buildSlidingMenu(),
                // Painel de notificações
                if (_isNotificationsVisible)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isNotificationsVisible = false;
                          _notificationsController.reverse();
                        });
                      },
                      child: Container(color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                if (_isNotificationsVisible)
                  Positioned(
                    top: screenHeight * 0.08,
                    right: 0,
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.7,
                    child: SlideTransition(
                      position: _notificationsAnimation,
                      child: Material(
                        color: Colors.transparent,
                        elevation: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(223, 17, 24, 39),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(-6, 0),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Notificações',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isNotificationsVisible = false;
                                        _notificationsController.reverse();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _notifications.length,
                                  itemBuilder: (context, index) {
                                    final notification = _notifications[index];
                                    return Dismissible(
                                      key: Key(
                                        'notification_${index}_${notification['title']}',
                                      ),
                                      // Direção para arrastar (direita)
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        setState(() {
                                          // Remove a notificação da lista
                                          _notifications.removeAt(index);
                                        });
                                      },
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: screenWidth * 0.06,
                                        ),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          bottom: screenHeight * 0.015,
                                        ),
                                        padding: EdgeInsets.all(
                                          screenWidth * 0.03,
                                        ),
                                        decoration: BoxDecoration(
                                          color: notification['read']
                                              ? Colors.white.withOpacity(
                                                  0.05,
                                                )
                                              : Colors.blueAccent
                                                  .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  notification['title'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  notification['time'],
                                                  style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize:
                                                        screenWidth * 0.03,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: screenHeight * 0.01,
                                            ),
                                            Text(
                                              notification['message'],
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                            SizedBox(
                                              height: screenHeight * 0.01,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _notifications[index]
                                                          ['read'] = true;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Marcar como lida',
                                                    style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize:
                                                          screenWidth * 0.03,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
          ),
        ],
      ),
    );
  }

  Widget _buildAiCardSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Transform.translate(
      offset: Offset(screenWidth * 0.15, -25),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.02),
          child: CloseableAiCard(
            geminiService: widget.geminiService,
            scaleFactor: screenWidth < 360 ? 0.3 : 0.35,
            enableScroll: true,
          ),
        ),
      ),
    );
  }

  Widget _buildDimOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isCardVisible = false;
            _slideController.reverse();
          });
        },
        child: Container(color: Colors.black.withOpacity(0.6)),
      ),
    );
  }

  Widget _buildSlidingMenu() {
    return Positioned(
      bottom: 80,
      left: 30,
      right: 30,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          elevation: 8,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: kDarkElementBg,
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
                InkWell(
                  onTap: () {
                    setState(() {
                      _isCardVisible = false;
                      _slideController.reverse();
                    });
                    _navigateToRoute('/adicionartarefa');
                  },
                  child: _menuItem(Icons.edit_outlined, 'Criar Tarefa'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isCardVisible = false;
                      _slideController.reverse();
                    });
                    _navigateToRoute('/criarprojeto');
                  },
                  child: _menuItem(Icons.add_circle_outline, 'Criar Projeto'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isCardVisible = false;
                      _slideController.reverse();
                    });
                    _navigateToRoute('/criarevento');
                  },
                  child: _menuItem(Icons.schedule_outlined, 'Criar Evento'),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: kAccentPurple,
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
                    color: kDarkTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: kDarkBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
        color: kDarkSurface.withOpacity(0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: kDarkTextSecondary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: kDarkTextSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Transform.translate(
      offset: const Offset(0, 0),
      child: FloatingActionButton(
        backgroundColor: kAccentPurple,
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
        child: const Icon(Icons.add, size: 28, color: kDarkTextPrimary),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: kDarkSurface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {},
              child: _bottomBarIcon(Icons.home_rounded, isActive: true),
            ),
            InkWell(
              onTap: () {
                _navigateToRoute('/settings');
              },
              child: _bottomBarIcon(Icons.settings_outlined),
            ),
            const SizedBox(width: 40),
            InkWell(
              onTap: () {
                _navigateToRoute('/planner');
              },
              child: _bottomBarIcon(Icons.book_outlined),
            ),
            InkWell(
              onTap: () {
                _navigateToRoute('/perfil');
              },
              child: _bottomBarIcon(Icons.person_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBarIcon(IconData icon, {bool isActive = false}) {
    return Icon(
      icon,
      color: isActive ? kAccentPurple : kDarkTextSecondary.withOpacity(0.6),
      size: 24,
    );
  }

  Widget _buildTopBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.035;
    final iconSize = screenWidth * 0.06;

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
          child: Icon(Icons.menu_rounded, color: Colors.white, size: iconSize),
        ),
        Text(
          formattedDate,
          style: TextStyle(
            color: Colors.white70,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
                size: iconSize,
              ),
              onPressed: () {
                setState(() {
                  _isNotificationsVisible = !_isNotificationsVisible;
                  if (_isNotificationsVisible) {
                    _notificationsController.forward();
                  } else {
                    _notificationsController.reverse();
                  }
                });
              },
            ),
            if (_unreadNotificationsCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: screenWidth * 0.04,
                    minHeight: screenWidth * 0.04,
                  ),
                  child: Text(
                    _unreadNotificationsCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final titleFontSize = screenWidth * 0.07;

    return SizedBox(
      height: screenHeight * 0.16,
      child: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.04,
            left: 0,
            right: 0,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Vamos construir bons\n",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: "habitos juntos🙌",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.start,
            ),
          ),
          _animatedCircleResponsive(
              context,
              0.05,
              0.01,
              0.015,
              [
                Colors.lightBlueAccent,
                const Color.fromARGB(255, 243, 33, 208),
              ],
              0),
          _animatedCircleResponsive(
              context,
              0.85,
              0.02,
              0.01,
              [
                const Color.fromARGB(164, 180, 34, 238),
                Colors.deepPurpleAccent,
              ],
              1),
          _animatedCircleResponsive(
              context,
              0.45,
              0.045,
              0.012,
              [
                Colors.amberAccent,
                Colors.orange,
              ],
              2),
          _animatedCircleResponsive(
              context,
              0.1,
              0.08,
              0.012,
              [
                Colors.pinkAccent,
                const Color.fromARGB(255, 149, 226, 4),
              ],
              3),
          _animatedCircleResponsive(
              context,
              0.9,
              0.09,
              0.02,
              [
                const Color.fromARGB(173, 36, 17, 204),
                const Color.fromARGB(255, 218, 20, 20),
              ],
              4),
          _animatedCircleResponsive(
              context,
              0.25,
              0.03,
              0.015,
              [
                const Color.fromARGB(255, 222, 87, 240),
                const Color.fromARGB(255, 27, 112, 1),
              ],
              5),
        ],
      ),
    );
  }

  Widget _animatedCircleResponsive(
    BuildContext context,
    double xFactor,
    double yFactor,
    double sizeFactor,
    List<Color> colors,
    int index,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final x = screenWidth * xFactor;
    final y = screenHeight * yFactor;
    final size = screenWidth * sizeFactor;

    return AnimatedBuilder(
      animation: _circleController,
      builder: (context, child) {
        final t = (_circleController.value + (index * 0.1)) % 1.0;
        final offset = 2 * sin(t * 2 * pi);

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

  Widget _buildProjectCarousel(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.22; // Altura responsiva

    return SizedBox(
      height: carouselHeight,
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
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.02,
                    vertical: MediaQuery.of(context).size.height * 0.015,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.22;
    final cardWidth = screenWidth * 0.4;
    final titleFontSize = screenWidth * 0.032;
    final descFontSize = screenWidth * 0.04;
    final dateFontSize = screenWidth * 0.032;
    final iconSize = screenWidth * 0.045;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: EdgeInsets.all(screenWidth * 0.04),
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: titleFontSize,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: iconSize,
                ),
                color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  // Ação de exclusão
                  if (value == 'delete') {
                    // Lógica para excluir o card
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                        const SnackBar(content: Text('Card excluído')));
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Excluir',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Flexible(
            child: Text(
              desc,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: descFontSize,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            date,
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: dateFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.055;

    return Text(
      'Em Progresso',
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required double progress,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final titleFontSize = screenWidth * 0.035;
    final subtitleFontSize = screenWidth * 0.03;
    final timeFontSize = screenWidth * 0.028;
    final progressFontSize = screenWidth * 0.025;
    final progressSize = screenWidth * 0.1;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: timeFontSize,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: progressSize,
                  width: progressSize,
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: progressFontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    // Chama _loadUserData() quando o drawer é construído para garantir dados atualizados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final avatarSize = screenWidth * 0.12;
    final titleFontSize = screenWidth * 0.045;
    final menuFontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.055;

    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: Padding(
        padding: EdgeInsets.only(
          top: screenHeight * 0.08,
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
          bottom: screenHeight * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info section
            Row(
              children: [
                CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundImage: const NetworkImage(
                    "https://i.pravatar.cc/150?img=11",
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                _userName == "Carregando..."
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04),
            const Divider(color: Colors.white24),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: _drawerItemResponsive(
                      context,
                      Icons.home_outlined,
                      "Início",
                      true,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _isNotificationsVisible = true;
                        _notificationsController.forward();
                      });
                    },
                    child: _drawerItemResponsive(
                      context,
                      Icons.notifications_outlined,
                      "Notificações",
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/perfil');
                    },
                    child: _drawerItemResponsive(
                      context,
                      Icons.person_outline,
                      "Perfil",
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute('/planner');
                    },
                    child: _drawerItemResponsive(
                      context,
                      Icons.book_outlined,
                      "Planner Diário",
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _navigateToRoute('/settings');
              },
              child: _drawerItemResponsive(
                context,
                Icons.settings_outlined,
                "Configurações",
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: _drawerItemResponsive(context, Icons.logout, "Sair"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItemResponsive(
    BuildContext context,
    IconData icon,
    String label, [
    bool isActive = false,
  ]) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenWidth * 0.04;
    final iconSize = screenWidth * 0.055;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white60,
            size: iconSize,
          ),
          SizedBox(width: screenWidth * 0.03),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontSize: fontSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isActive) ...[
            const Spacer(),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
