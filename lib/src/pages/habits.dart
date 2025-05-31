import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'dart:math'; // Removido se não usado diretamente pela HabitsPage
import 'iconedaia.dart'; // Mantenha se CloseableAiCard e outros dependem disso
import 'package:planify/services/gemini_service.dart'; // Mantenha sua importação
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/services/firestore_tasks_service.dart'; // Mantenha sua importação

// Importe seus modelos REAIS aqui
import 'package:planify/models/task.dart'; // Substitua pelo caminho correto
import 'package:planify/models/project_model.dart'; // Substitua pelo caminho correto

// Suas constantes de cor
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
  final ScrollController _mainScrollController = ScrollController();

  bool _isDrawerOpen = false;
  bool _isCardVisible = false;
  bool _isNotificationsVisible = false;

  FirestoreTasksService? _firestoreService;
  String? _currentUserId;

  // Lista mockada de notificações (você pode querer buscar do Firestore também)
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
    _pageController = PageController(viewportFraction: 0.75);
    initializeDateFormatting('pt_BR', null).then((_) {
      if (mounted) setState(() {});
    });

    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this)
      ..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _circleController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat();
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _notificationsController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _notificationsAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _notificationsController, curve: Curves.easeOut));

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

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUserId = user.uid;
        _firestoreService = FirestoreTasksService(userId: user.uid);
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (mounted) {
          setState(() {
            _userName =
                doc.exists ? (doc.data()?['name'] ?? 'Usuário') : 'Usuário';
          });
        }
      } else {
        if (mounted) setState(() => _userName = 'Visitante');
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      if (mounted) setState(() => _userName = 'Erro');
    }
    if (mounted) setState(() {});
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false)
      Navigator.of(context).pop();
    Navigator.of(context).pushNamed(routeName);
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
      backgroundColor: kDarkPrimaryBg,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: CustomScrollView(
        controller: _mainScrollController,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isCardVisible)
                      setState(() {
                        _isCardVisible = false;
                        _slideController.reverse();
                      });
                    if (_isNotificationsVisible)
                      setState(() {
                        _isNotificationsVisible = false;
                        _notificationsController.reverse();
                      });
                    FocusScope.of(context).unfocus();
                  },
                  child: SafeArea(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                            SizedBox(height: screenHeight * 0.025),
                            _buildInProgressHeader(context),
                            SizedBox(height: screenHeight * 0.015),
                            Expanded(child: _buildTasksList(context)),
                            SizedBox(height: screenHeight * 0.12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_firestoreService != null && _currentUserId != null)
                  Positioned(
                    bottom: 42,
                    right: -60,
                    child: CloseableAiCard(
                      firestoreService: _firestoreService!,
                      geminiService: widget.geminiService,
                      scaleFactor: screenWidth < 360 ? 0.35 : 0.4,
                      enableScroll: true,
                    ),
                  ),
                if (_isCardVisible) _buildDimOverlay(),
                if (_isCardVisible) _buildSlidingMenu(),

                // ------------- PAINEL DE NOTIFICAÇÕES COMPLETO -------------
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
                    top: screenHeight * 0.08, // Posição a partir do topo
                    right: 0, // Alinhado à direita
                    width: screenWidth * 0.85, // Largura do painel
                    height: screenHeight * 0.75, // Altura do painel
                    child: SlideTransition(
                      position: _notificationsAnimation,
                      child: Material(
                        color: Colors
                            .transparent, // Para não cobrir a sombra do Container interno
                        elevation: 0, // Sombra será do Container interno
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(235, 22, 33,
                                62), // Cor similar a kDarkSurface com opacidade
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(-5, 5), // Sombra sutil
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
                                      color: kDarkTextPrimary,
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: kDarkTextPrimary),
                                    onPressed: () {
                                      setState(() {
                                        _isNotificationsVisible = false;
                                        _notificationsController.reverse();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: screenHeight * 0.015), // Espaçamento
                              Expanded(
                                child: _notifications.isEmpty
                                    ? Center(
                                        child: Text("Nenhuma notificação",
                                            style: TextStyle(
                                                color: kDarkTextSecondary)))
                                    : ListView.builder(
                                        itemCount: _notifications.length,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          final notification =
                                              _notifications[index];
                                          // Gera uma chave única mais robusta para o Dismissible
                                          final String uniqueKey =
                                              'notification_${notification['title']}_${notification['time']}_$index';
                                          return Dismissible(
                                            key: Key(uniqueKey),
                                            direction:
                                                DismissDirection.endToStart,
                                            onDismissed: (direction) {
                                              setState(() {
                                                _notifications.removeAt(index);
                                                // Aqui você pode adicionar lógica para remover do backend também, se necessário
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "${notification['title']} dispensada"),
                                                      duration: Duration(
                                                          seconds: 2)));
                                            },
                                            background: Container(
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.only(
                                                  right: 20.0),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                  Icons.delete_sweep_outlined,
                                                  color: Colors.white,
                                                  size: screenWidth * 0.06),
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  bottom: screenHeight * 0.015),
                                              padding: EdgeInsets.all(
                                                  screenWidth * 0.035),
                                              decoration: BoxDecoration(
                                                  color: notification['read'] ==
                                                          true
                                                      ? kDarkSurface.withOpacity(
                                                          0.5) // Cor para lida
                                                      : kAccentPurple.withOpacity(
                                                          0.15), // Cor para não lida
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: notification[
                                                                  'read'] ==
                                                              true
                                                          ? kDarkBorder
                                                              .withOpacity(0.3)
                                                          : kAccentPurple
                                                              .withOpacity(
                                                                  0.4))),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          notification['title'],
                                                          style: TextStyle(
                                                              color:
                                                                  kDarkTextPrimary,
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        notification['time'],
                                                        style: TextStyle(
                                                            color:
                                                                kDarkTextSecondary
                                                                    .withOpacity(
                                                                        0.8),
                                                            fontSize:
                                                                screenWidth *
                                                                    0.03),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.008),
                                                  Text(
                                                    notification['message'],
                                                    style: TextStyle(
                                                        color:
                                                            kDarkTextSecondary,
                                                        fontSize:
                                                            screenWidth * 0.035,
                                                        height: 1.3),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (notification['read'] ==
                                                      false) ...[
                                                    // Só mostra se não estiver lida
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.01),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _notifications[
                                                                    index]
                                                                ['read'] = true;
                                                          });
                                                        },
                                                        child: Text(
                                                            'Marcar como lida',
                                                            style: TextStyle(
                                                                color:
                                                                    kAccentSecondary,
                                                                fontSize:
                                                                    screenWidth *
                                                                        0.03)),
                                                      ),
                                                    ),
                                                  ]
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
                // ------------- FIM DO PAINEL DE NOTIFICAÇÕES -------------
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (Restante dos seus métodos _buildProjectCarousel, _buildProjectCard, etc., conforme a resposta anterior)
  // COLE AQUI OS MÉTODOS _buildProjectCarousel, _buildProjectCard, _buildTasksList, _buildTaskCard,
  // _buildTopBar, _buildTitle, _buildInProgressHeader, _buildDrawer, _buildDrawerItem,
  // _animatedCircleResponsive, _buildFloatingActionButton, _buildBottomBar, _bottomBarIcon,
  // _buildDimOverlay, _buildSlidingMenu, _menuItem
  // DA MINHA RESPOSTA ANTERIOR (A GRANDE COM TUDO INTEGRADO)
  // Vou repetir abaixo para garantir que está completo.

  Widget _buildProjectCarousel(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (_currentUserId == null) {
      return SizedBox(
          height: screenHeight * 0.16,
          child: const Center(
              child: CircularProgressIndicator(color: kAccentPurple)));
    }
    return SizedBox(
      height: screenHeight * 0.16,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .where('userId', isEqualTo: _currentUserId)
            .where('status', isNotEqualTo: 'arquivado')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kAccentPurple));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro: ${snapshot.error}',
                    style: TextStyle(color: kDarkTextSecondary)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('Nenhum projeto ativo.',
                    style: TextStyle(color: kDarkTextSecondary)));
          }
          final projects = snapshot.data!.docs
              .map((doc) => Project.fromFirestore(doc))
              .toList();
          return PageView.builder(
            controller: _pageController,
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildProjectCard(context, projects[index]));
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final screenWidth = MediaQuery.of(context).size.width;
    double? progressValue;
    if (project.progressPercentage != null) {
      progressValue = project.progressPercentage! / 100.0;
      progressValue = progressValue.clamp(0.0, 1.0);
    } else if (project.status == 'concluído' || project.status == 'completed') {
      // Adicionado 'completed'
      progressValue = 1.0;
    }

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: kDarkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkBorder.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(project.name,
                    style: TextStyle(
                        color: kDarkTextPrimary,
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.more_vert,
                  color: kDarkTextSecondary, size: screenWidth * 0.05),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
              child: Text(project.description,
                  style: TextStyle(
                      color: kDarkTextSecondary, fontSize: screenWidth * 0.032),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          if (progressValue != null)
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: kDarkBorder,
              color: kAccentSecondary,
              minHeight: 5,
              borderRadius: BorderRadius.circular(5),
            )
          else
            const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(
          child: CircularProgressIndicator(color: kAccentPurple));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'pending')
          .orderBy('dueDate')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: kAccentPurple));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Erro: ${snapshot.error}',
                  style: TextStyle(color: kDarkTextSecondary)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Nenhuma tarefa pendente!',
                      style: TextStyle(color: kDarkTextSecondary))));
        }
        final tasks =
            snapshot.data!.docs.map((doc) => Task.fromFirestore(doc)).toList();
        return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.015),
                child: _buildTaskCard(context: context, task: tasks[index]),
              );
            });
      },
    );
  }

  Widget _buildTaskCard({required BuildContext context, required Task task}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double? progressValue;
    if (task.progressPercentage != null) {
      progressValue = task.progressPercentage! / 100.0;
      progressValue = progressValue.clamp(0.0, 1.0);
    } else if (task.isCompleted) {
      progressValue = 1.0;
    }

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: kDarkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkBorder.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(task.title,
                      style: TextStyle(
                          color: kDarkTextPrimary,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
              Icon(Icons.more_vert,
                  color: kDarkTextSecondary, size: screenWidth * 0.05),
            ],
          ),
          SizedBox(height: screenWidth * 0.01),
          if (task.description != null && task.description!.isNotEmpty)
            Text(task.description!,
                style: TextStyle(
                    color: kDarkTextSecondary, fontSize: screenWidth * 0.035),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          SizedBox(height: screenWidth * 0.02),
          if (progressValue != null)
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: kDarkBorder,
              color: kAccentSecondary,
              minHeight: 5,
              borderRadius: BorderRadius.circular(5),
            )
          else
            const SizedBox(height: 5),
          SizedBox(height: screenWidth * 0.01),
          Align(
              alignment: Alignment.bottomRight,
              child: Text(task.displayTime,
                  style: TextStyle(
                      color: kDarkTextSecondary,
                      fontSize: screenWidth * 0.03))),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.035;
    final iconSize = screenWidth * 0.06;
    String formattedDate = "Carregando data...";
    if (Localizations.localeOf(context).languageCode == 'pt') {
      // Garante que a formatação pt_BR só ocorre se o locale estiver pronto
      try {
        formattedDate =
            DateFormat('EEEE, dd MMMM', 'pt_BR').format(DateTime.now());
      } catch (e) {
        // fallback se pt_BR não estiver disponível, embora initializeDateFormatting deva cuidar disso
        formattedDate = DateFormat('EEEE, dd MMMM').format(DateTime.now());
      }
    } else {
      formattedDate = DateFormat('EEEE, dd MMMM').format(DateTime.now());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.menu_rounded, color: Colors.white, size: iconSize),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        Text(formattedDate,
            style: TextStyle(
                color: Colors.white70,
                fontSize: fontSize,
                fontWeight: FontWeight.w500)),
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none_outlined,
                  color: Colors.white, size: iconSize),
              onPressed: () => setState(() {
                _isNotificationsVisible = !_isNotificationsVisible;
                if (_isNotificationsVisible)
                  _notificationsController.forward();
                else
                  _notificationsController.reverse();
              }),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            if (_unreadNotificationsCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding:
                      EdgeInsets.all(_unreadNotificationsCount > 9 ? 3 : 4),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: kDarkPrimaryBg, width: 1.5)),
                  constraints: BoxConstraints(
                      minWidth: screenWidth * 0.04,
                      minHeight: screenWidth * 0.04),
                  child: Text(
                    _unreadNotificationsCount > 9
                        ? "9+"
                        : _unreadNotificationsCount.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.022,
                        fontWeight: FontWeight.bold),
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
    final titleFontSize = screenWidth * 0.065;

    return SizedBox(
      height: screenHeight * 0.13,
      child: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.015,
            left: 0,
            right: 0,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: "Vamos construir bons\n",
                    style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25)),
                TextSpan(
                    text: "hábitos juntos 🙌",
                    style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25)),
              ]),
              textAlign: TextAlign.start,
            ),
          ),
          _animatedCircleResponsive(
              context,
              0.85,
              0.01,
              0.015,
              [
                kAccentPurple.withOpacity(0.3),
                kAccentSecondary.withOpacity(0.3)
              ],
              0),
          _animatedCircleResponsive(
              context,
              0.05,
              0.02,
              0.01,
              [
                kAccentSecondary.withOpacity(0.3),
                kAccentPurple.withOpacity(0.3)
              ],
              1),
        ],
      ),
    );
  }

  Widget _buildInProgressHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Em progresso',
              style: TextStyle(
                  color: kDarkTextPrimary,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => _navigateToRoute('/tasks'),
            child: Text('Ver todos',
                style: TextStyle(
                    color: kAccentPurple,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500)),
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
            decoration: const BoxDecoration(color: kDarkSurface),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.07,
                  backgroundColor: kAccentPurple,
                  child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                          color: kDarkTextPrimary,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(_userName,
                    style: TextStyle(
                        color: kDarkTextPrimary,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          _buildDrawerItem(
              icon: Icons.home_outlined,
              title: 'Início',
              onTap: () => Navigator.pop(context)),
          _buildDrawerItem(
              icon: Icons.calendar_today_outlined,
              title: 'Calendário',
              onTap: () => _navigateToRoute('/calendario')),
          _buildDrawerItem(
              icon: Icons.check_circle_outline,
              title: 'Concluídas',
              onTap: () => _navigateToRoute('/concluidas')),
          _buildDrawerItem(
              icon: Icons.category_outlined,
              title: 'Categorias',
              onTap: () => _navigateToRoute('/categorias')),
          _buildDrawerItem(
              icon: Icons.pie_chart_outline,
              title: 'Relatórios',
              onTap: () => _navigateToRoute('/relatorios')),
          const Divider(color: kDarkBorder),
          _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Configurações',
              onTap: () => _navigateToRoute('/settings')),
          _buildDrawerItem(
              icon: Icons.info_outline,
              title: 'Sobre',
              onTap: () => _navigateToRoute('/sobre')),
          _buildDrawerItem(
              icon: Icons.logout,
              title: 'Sair',
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                if (mounted)
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false);
              }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListTile(
      leading: Icon(icon, color: kDarkTextSecondary, size: screenWidth * 0.055),
      title: Text(title,
          style: TextStyle(
              color: kDarkTextPrimary.withOpacity(0.9),
              fontSize: screenWidth * 0.04)),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _animatedCircleResponsive(
      BuildContext context,
      double rightPercent,
      double topPercent,
      double sizeFactor,
      List<Color> colors,
      int delayMultiplier) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      right: screenWidth * rightPercent,
      top: screenHeight * topPercent,
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _circleController,
            curve: Interval(delayMultiplier * 0.1, 1.0, curve: Curves.linear))),
        child: Container(
          width: screenWidth * sizeFactor,
          height: screenWidth * sizeFactor,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            boxShadow: [
              BoxShadow(
                  color: colors[0].withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 0.5)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: kAccentPurple,
      elevation: 6,
      shape: const CircleBorder(),
      onPressed: () => setState(() {
        _isCardVisible = !_isCardVisible;
        if (_isCardVisible)
          _slideController.forward();
        else
          _slideController.reverse();
      }),
      child: const Icon(Icons.add, size: 28, color: kDarkTextPrimary),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      height: 60,
      color: kDarkSurface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomBarIcon(Icons.home_rounded, isActive: true, onTap: () {}),
          _bottomBarIcon(Icons.settings_outlined,
              onTap: () => _navigateToRoute('/settings')),
          const SizedBox(width: 40),
          _bottomBarIcon(Icons.book_outlined,
              onTap: () => _navigateToRoute('/planner')),
          _bottomBarIcon(Icons.person_outline,
              onTap: () => _navigateToRoute('/perfil')),
        ],
      ),
    );
  }

  Widget _bottomBarIcon(IconData icon,
      {bool isActive = false, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(icon,
          color: isActive ? kAccentPurple : kDarkTextSecondary.withOpacity(0.6),
          size: 26),
      onPressed: onTap,
      padding: const EdgeInsets.all(12),
    );
  }

  Widget _buildDimOverlay() {
    return Positioned.fill(
        child: GestureDetector(
            onTap: () => setState(() {
                  _isCardVisible = false;
                  _slideController.reverse();
                }),
            child: Container(color: Colors.black.withOpacity(0.6))));
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                        color: kDarkElementBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6))
                        ]),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              _isCardVisible = false;
                              _slideController.reverse();
                            });
                            _navigateToRoute('/adicionartarefa');
                          },
                          child:
                              _menuItem(Icons.edit_outlined, 'Criar Tarefa')),
                      const SizedBox(height: 12),
                      InkWell(
                          onTap: () {
                            setState(() {
                              _isCardVisible = false;
                              _slideController.reverse();
                            });
                            _navigateToRoute('/criarprojeto');
                          },
                          child: _menuItem(
                              Icons.add_circle_outline, 'Criar Projeto')),
                      const SizedBox(height: 12),
                      InkWell(
                          onTap: () {
                            setState(() {
                              _isCardVisible = false;
                              _slideController.reverse();
                            });
                            _navigateToRoute('/criarevento');
                          },
                          child: _menuItem(
                              Icons.schedule_outlined, 'Criar Evento')),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                          mini: true,
                          backgroundColor: kAccentPurple,
                          elevation: 0,
                          shape: const CircleBorder(),
                          onPressed: () => setState(() {
                                _isCardVisible = false;
                                _slideController.reverse();
                              }),
                          child: const Icon(Icons.close,
                              size: 20, color: kDarkTextPrimary))
                    ])))));
  }

  Widget _menuItem(IconData icon, String label) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
            border: Border.all(color: kDarkBorder.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(16),
            color: kDarkSurface.withOpacity(0.5)),
        child: Row(children: [
          Icon(icon, color: kDarkTextSecondary, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: kDarkTextSecondary, fontSize: 14))
        ]));
  }
}
