import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';
import 'iconedaia.dart';
import 'package:planify/services/gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/services/firestore_tasks_service.dart';

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

  // Adicione a instância do FirestoreTasksService aqui
  final FirestoreTasksService _firestoreService = FirestoreTasksService(userId: 'userId');

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
                    // Passando a instância do firestoreService
                    firestoreService: _firestoreService,
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
                                                              ['read'] =
                                                          true;
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
            firestoreService: _firestoreService,
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

  // Métodos restantes (buildProjectCarousel, buildInProgressHeader, buildTaskCard, buildDrawer, buildDrawerItem, animatedCircleResponsive)
  // que não foram incluídos no erro, mas são necessários para o código funcionar.

  Widget _buildProjectCarousel(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.15,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 3, // Exemplo de 3 projetos
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildProjectCard(context, index),
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: kDarkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkBorder),
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Projeto ${index + 1}',
                style: TextStyle(
                  color: kDarkTextPrimary,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.more_vert,
                color: kDarkTextSecondary,
                size: screenWidth * 0.05,
              ),
            ],
          ),
          Text(
            'Descrição do projeto ${index + 1}',
            style: TextStyle(
              color: kDarkTextSecondary,
              fontSize: screenWidth * 0.035,
            ),
          ),
          LinearProgressIndicator(
            value: (index + 1) * 0.25,
            backgroundColor: kDarkBorder,
            color: kAccentSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Em progresso',
          style: TextStyle(
            color: kDarkTextPrimary,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Ver todos',
          style: TextStyle(
            color: kAccentPurple,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ],
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
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: kDarkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: kDarkTextPrimary,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.more_vert,
                color: kDarkTextSecondary,
                size: screenWidth * 0.05,
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            subtitle,
            style: TextStyle(
              color: kDarkTextSecondary,
              fontSize: screenWidth * 0.035,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: kDarkBorder,
            color: kAccentSecondary,
          ),
          SizedBox(height: screenWidth * 0.01),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              time,
              style: TextStyle(
                color: kDarkTextSecondary,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      backgroundColor: kDarkPrimaryBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: kDarkSurface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.08,
                  backgroundColor: kAccentPurple,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: kDarkTextPrimary,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  _userName,
                  style: TextStyle(
                    color: kDarkTextPrimary,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home_outlined,
            title: 'Início',
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              // Adicione a navegação para a página inicial, se houver
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today_outlined,
            title: 'Calendário',
            onTap: () {
              Navigator.pop(context);
              _navigateToRoute('/calendario');
            },
          ),
          _buildDrawerItem(
            icon: Icons.check_circle_outline,
            title: 'Concluídas',
            onTap: () {
              Navigator.pop(context);
              _navigateToRoute('/concluidas');
            },
          ),
          _buildDrawerItem(
            icon: Icons.category_outlined,
            title: 'Categorias',
            onTap: () {
              Navigator.pop(context);
              _navigateToRoute('/categorias');
            },
          ),
          _buildDrawerItem(
            icon: Icons.pie_chart_outline,
            title: 'Relatórios',
            onTap: () {
              Navigator.pop(context);
              _navigateToRoute('/relatorios');
            },
          ),
          const Divider(color: kDarkBorder),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Configurações',
            onTap: () {
              Navigator.pop(context);
              _navigateToRoute('/settings');
            },
          ),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'Sobre',
            onTap: () {
              Navigator.pop(context);
              _navigateToRoute('/sobre');
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Sair',
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListTile(
      leading: Icon(icon, color: kDarkTextSecondary, size: screenWidth * 0.06),
      title: Text(
        title,
        style: TextStyle(
          color: kDarkTextPrimary,
          fontSize: screenWidth * 0.045,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _animatedCircleResponsive(
    BuildContext context,
    double right,
    double top,
    double sizeFactor,
    List<Color> colors,
    int delayMultiplier,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      right: screenWidth * right,
      top: screenHeight * top,
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _circleController,
            curve: Interval(
              delayMultiplier * 0.1,
              1.0,
              curve: Curves.linear,
            ),
          ),
        ),
        child: Container(
          width: screenWidth * sizeFactor,
          height: screenWidth * sizeFactor,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}