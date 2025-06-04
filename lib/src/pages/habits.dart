import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'iconedaia.dart'; // Presumo que este arquivo exista e seja necessário
import 'package:planify/services/gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/src/pages/iconedaia.dart';
// Removi a importação duplicada de firestore_tasks_service se FirestoreService for o principal
import 'package:planify/services/firestore_service.dart';
import 'package:planify/services/firestore_tasks_service.dart'; // Presumo que este é o seu serviço principal
// import 'package:flutter/services.dart'; // Descomente se usado em algum lugar
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

// Modelos - Certifique-se que os caminhos estão corretos e as classes são 'Project' e 'Task'
import 'package:planify/models/project_model.dart'; // Contém a classe Project
import 'package:planify/models/task.dart'; // Contém a classe Task

// Suas constantes de cor
const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class HabitsScreen extends StatefulWidget {
  final GeminiService geminiService;

  const HabitsScreen({Key? key, required this.geminiService}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // bool _isDrawerOpen = false; // Não parece estar sendo usado para controlar o estado diretamente
  Uint8List? _profileImageBytes; // Para armazenar a foto do perfil
  bool _isLoadingProfileImage = false; // Estado para carregamento da imagem
  bool _isCardVisible = false;
  bool _isNotificationsVisible = false;
  bool _isHovered = false; // Adicionado para a animação de hover do TaskCard

  String? _currentUserId; // UID do usuário logado

  // Lista mockada de notificações
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

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _notificationsController;
  late Animation<Offset> _notificationsAnimation;
  late AnimationController _circleController; // Controlador para os círculos animados
  late PageController _pageController;
  late AnimationController _fadeController; // Adicionado para consistência com o build
  late Animation<double> _fadeAnimation; // Adicionado para consistência com o build

  FirestoreTasksService? _userFirestoreTasksService; // Para o CloseableAiCard

  String _userName = "Carregando...";
  List<Project> _projects = [];
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController(viewportFraction: 0.8); // Ajustado de 0.75 ou 0.85

    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this)
      ..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _notificationsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _notificationsAnimation = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero) // Ajustado de (0,-1) para vir da direita
        .animate(CurvedAnimation(
            parent: _notificationsController, curve: Curves.easeOut));

    _circleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(); // Repete a animação dos círculos

    initializeDateFormatting('pt_BR', null).then((_) {
      if (mounted) setState(() {});
    });

    _loadUserAndInitialData();

    // Listener para atualizações do perfil
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        _loadUserName(); // Recarrega os dados do usuário quando o auth state muda
      }
    });
  }

  Future<void> _loadUserAndInitialData() async {
    await _loadUserName(); // Espera o nome e UID do usuário
    if (_currentUserId != null) {
      _userFirestoreTasksService = FirestoreTasksService(
          userId: _currentUserId!); // Inicializa o serviço para o Card AI
      _loadData(); // Carrega os dados de projetos e tarefas
    } else {
      // Usuário não está logado, ou UID não pôde ser obtido
      print("Usuário não logado. Não carregando projetos/tarefas.");
      if (mounted) {
        setState(() {
          _projects = [];
          _tasks = [];
        });
      }
    }
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      try {
        // No carregamento
        final prefs = await SharedPreferences.getInstance();
        final cachedImage = prefs.getString('profileImage_$_currentUserId');
        if (cachedImage != null) {
          setState(() => _profileImageBytes = base64Decode(cachedImage));
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (mounted) {
          setState(() {
            if (userDoc.exists) {
              _userName = userDoc.get('name') ??
                  user.displayName ??
                  user.email ??
                  'Usuário';

              // Carrega a imagem se existir
              if (userDoc.get('profileImage') != null) {
                _profileImageBytes = base64Decode(userDoc.get('profileImage'));
              }
            } else {
              _userName =
                  user.displayName ?? user.email ?? 'Usuário (doc não existe)';
            }
          });
        }
      } catch (e) {
        print("Erro ao buscar dados do usuário: $e");
        if (mounted) {
          setState(() {
            _userName =
                user.displayName ?? user.email ?? 'Usuário (erro Firestore)';
          });
        }
      }
    } else {
      _currentUserId = null;
      if (mounted) setState(() => _userName = 'Visitante');
    }
  }

  void _loadData() async {
    if (_currentUserId == null) {
      print("Erro fatal: _loadData chamado sem _currentUserId.");
      if (mounted)
        setState(() {
          _projects = [];
          _tasks = [];
        });
      return;
    }

    // Carregar projetos
    try {
      final projectSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('userId', isEqualTo: _currentUserId!) // FILTRO ESSENCIAL
          .where('status', isNotEqualTo: 'arquivado') // Filtro adicional
          .orderBy('createdAt', descending: true) // Ordenação
          .get();
      if (mounted) {
        setState(() {
          _projects = projectSnapshot.docs
              .map((doc) => Project.fromFirestore(doc))
              .toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar projetos: $e');
      if (mounted) setState(() => _projects = []);
      // TODO: Mostrar erro para o usuário na UI de projetos
    }

    // Carregar tarefas
    try {
      final taskSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: _currentUserId!) // FILTRO ESSENCIAL
          .where('status', isEqualTo: 'pending') // Filtro adicional
          .orderBy('dueDate') // Ordenação
          .get();
      if (mounted) {
        setState(() {
          _tasks =
              taskSnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
      if (mounted) setState(() => _tasks = []);
      // TODO: Mostrar erro para o usuário na UI de tarefas
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _notificationsController.dispose();
    _circleController.dispose();
    _pageController.dispose();
    _fadeController.dispose(); // Dispose do fade controller
    _profileImageBytes = null; // Limpa a memória da imagem
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop(); // Fecha o drawer primeiro
    }
    Navigator.of(context).pushNamed(routeName);
  }

  // Adicionei um _buildSectionTitle como no seu código
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70, // kDarkTextSecondary.withOpacity(0.7)
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height; // Útil para alturas relativas
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kDarkPrimaryBg,
      drawer: _buildDrawer(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: [
          // Círculos animados de fundo
          _animatedCircleResponsive(context, 0.05, 0.01, 0.015, [
            Colors.lightBlueAccent,
            const Color.fromARGB(255, 243, 33, 208),
          ], 0),
          _animatedCircleResponsive(context, 0.85, 0.02, 0.01, [
            const Color.fromARGB(164, 180, 34, 238),
            Colors.deepPurpleAccent,
          ], 1),
          _animatedCircleResponsive(context, 0.45, 0.045, 0.012, [
            Colors.amberAccent,
            Colors.orange,
          ], 2),
          _animatedCircleResponsive(context, 0.1, 0.08, 0.012, [
            Colors.pinkAccent,
            const Color.fromARGB(255, 149, 226, 4),
          ], 3),
          _animatedCircleResponsive(context, 0.9, 0.09, 0.02, [
            const Color.fromARGB(173, 36, 17, 204),
            const Color.fromARGB(255, 218, 20, 20),
          ], 4),
          _animatedCircleResponsive(context, 0.25, 0.03, 0.015, [
            const Color.fromARGB(255, 222, 87, 240),
            const Color.fromARGB(255, 27, 112, 1),
          ], 5),

          SafeArea(
            child: FadeTransition(
              // Adicionado FadeTransition aqui para o conteúdo principal
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    _buildTopBar(),
                    SizedBox(height: screenHeight * 0.02),
                    _buildTitle(context),
                    SizedBox(height: screenHeight * 0.025),
                    _buildSectionTitle('PROJETOS'), // Usando seu método
                    SizedBox(height: screenHeight * 0.015),
                    _projects.isEmpty
                        ? Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.05),
                                child: (_currentUserId == null ||
                                        _userName ==
                                            "Carregando...") // Checa se ainda está carregando usuário
                                    ? const CircularProgressIndicator(
                                        color: kAccentPurple)
                                    : const Text("Nenhum projeto encontrado.",
                                        style: TextStyle(
                                            color: kDarkTextSecondary))))
                        : _buildProjectCarouselWidget(_projects),

                    SizedBox(height: screenHeight * 0.025),
                    _buildInProgressHeader(context),
                    SizedBox(height: screenHeight * 0.015),
                    _tasks.isEmpty
                        ? Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.05),
                                child: (_currentUserId == null ||
                                        _userName == "Carregando...")
                                    ? Container() // Não mostra nada se projetos já tem indicador
                                    : const Text("Nenhuma tarefa em progresso.",
                                        style: TextStyle(
                                            color: kDarkTextSecondary))))
                        : _buildTasksListWidget(_tasks),

                    SizedBox(
                        height:
                            screenHeight * 0.12), // Espaço para FAB e BottomNav
                  ],
                ),
              ),
            ),
          ),
          // AI Card - Garanta que _userFirestoreTasksService é passado e não nulo
          if (_userFirestoreTasksService != null && _currentUserId != null)
            Positioned(
              bottom: -26, // Posição consistente
              right: -60, // Ajuste a posição conforme o layout desejado
              child: CloseableAiCard(
                firestoreService: _userFirestoreTasksService!,
                geminiService: widget.geminiService,
                scaleFactor: screenWidth < 360 ? 0.35 : 0.4,
                enableScroll: true,
              ),
            ),
          if (_isCardVisible)
            _buildDimOverlay(), // Controla visibilidade do DimOverlay
          if (_isCardVisible)
            _buildSlidingMenu(), // Controla visibilidade do SlidingMenu (seu _buildSlidingMenu já tem Positioned)

          // Painel de Notificações (conforme código anterior)
          if (_isNotificationsVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() {
                  _isNotificationsVisible = false;
                  _notificationsController.reverse();
                }),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          if (_isNotificationsVisible)
            Positioned(
              top: screenHeight * 0.08,
              right: 0,
              width: screenWidth * 0.85,
              height: screenHeight * 0.75,
              child: SlideTransition(
                position: _notificationsAnimation,
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24)),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(235, 22, 33, 62),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(-5, 5))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Notificações',
                                style: TextStyle(
                                    color: kDarkTextPrimary,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: kDarkTextPrimary),
                              onPressed: () => setState(() {
                                _isNotificationsVisible = false;
                                _notificationsController.reverse();
                              }),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
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
                                    final notification = _notifications[index];
                                    final String uniqueKey =
                                        'notification_${notification['title']}_${notification['time']}_$index';
                                    return Dismissible(
                                      key: Key(uniqueKey),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) => setState(
                                          () => _notifications.removeAt(index)),
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Icon(Icons.delete_sweep_outlined,
                                            color: Colors.white,
                                            size: screenWidth * 0.06),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: screenHeight * 0.015),
                                        padding:
                                            EdgeInsets.all(screenWidth * 0.035),
                                        decoration: BoxDecoration(
                                            color: notification['read'] == true
                                                ? kDarkSurface.withOpacity(0.5)
                                                : kAccentPurple
                                                    .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: notification['read'] == true
                                                    ? kDarkBorder
                                                        .withOpacity(0.3)
                                                    : kAccentPurple
                                                        .withOpacity(0.4))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
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
                                                      _notifications[index]['read'] =
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
    );
  }

  // --- Métodos de construção de Widgets ---

  Widget _buildTopBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.035;
    // final iconSize = screenWidth * 0.06; // Não precisa mais do sino
    String formattedDate = "Carregando data...";
    try {
      formattedDate =
          DateFormat('EEEE, dd MMMM', 'pt_BR').format(DateTime.now());
    } catch (e) {
      formattedDate =
          DateFormat('EEEE, dd MMMM').format(DateTime.now()); // Fallback
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.menu_rounded,
              color: Colors.white, size: screenWidth * 0.06),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(formattedDate,
            style: TextStyle(
                color: Colors.white70,
                fontSize: fontSize,
                fontWeight: FontWeight.w500)),
        // Removido o sino de notificação
        IconButton(
          icon: Icon(Icons.mail_outline,
              color: Colors.white, size: screenWidth * 0.06),
          onPressed: () {
            Navigator.of(context).pushNamed('/convites');
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
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
        ],
      ),
    );
  }

  // Método para os círculos animados de fundo
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

  // Método para o círculo decorativo (usado por _animatedCircleResponsive)
  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildProjectCarouselWidget(List<Project> projects) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (projects.isEmpty && _currentUserId != null) {
      return Center(
          child: Text('Nenhum projeto para exibir.',
              style: TextStyle(color: kDarkTextSecondary)));
    }
    return SizedBox(
      height: screenHeight * 0.16, // Ajustado para bater com o seu código
      child: PageView.builder(
        controller: _pageController,
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0), // Era 6.0 no seu
            child: _buildProjectCard(context, projects[index]),
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
      progressValue = 1.0;
    }

    return Container(
      decoration: BoxDecoration(
        color: kDarkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: kDarkBorder.withOpacity(0.7)), // Era kDarkBorder no seu
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, // Adicionado no seu
            children: [
              Expanded(
                // Adicionado para evitar overflow no nome do projeto
                child: Text(
                  project.name,
                  style: TextStyle(
                    color: kDarkTextPrimary,
                    fontSize: screenWidth * 0.045, // Era 0.042 no seu
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1, // Adicionado
                  overflow: TextOverflow.ellipsis, // Adicionado
                ),
              ),
              Icon(Icons.more_vert,
                  color: kDarkTextSecondary, size: screenWidth * 0.05),
            ],
          ),
          Expanded(
            // Adicionado para melhor layout da descrição
            child: Padding(
              // Adicionado no seu
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
              child: Text(
                project.description,
                style: TextStyle(
                    color: kDarkTextSecondary, fontSize: screenWidth * 0.035), // Era 0.032 no seu
                maxLines: 2, // Adicionado
                overflow: TextOverflow.ellipsis, // Adicionado
              ),
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
            const SizedBox(height: 5), // Placeholder para manter alinhamento
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

  // Renomeei para _buildTasksListWidget para diferenciar da sua versão anterior que usava StreamBuilder
  Widget _buildTasksListWidget(List<Task> tasks) {
    // A lógica com shrinkWrap e NeverScrollableScrollPhysics é boa para SingleChildScrollView
    if (tasks.isEmpty && _currentUserId != null) {
      // Adicionado _currentUserId != null
      return Center(
          child: Text('Nenhuma tarefa em progresso.',
              style: TextStyle(color: kDarkTextSecondary)));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      padding: EdgeInsets.zero, // Removido padding padrão do ListView
      itemBuilder: (context, index) {
        final task = tasks[index];
        // Seu _buildTaskCard original recebia campos individuais,
        // vamos adaptar para passar o objeto Task inteiro ou manter assim se preferir
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.015),
          // Chamando o _buildTaskCard que você já tem, passando os campos da task
          child: _buildTaskCardFromObject(context: context, task: task),
        );
      },
    );
  }

  // Criei este para receber o objeto Task, o seu _buildTaskCard original recebia parâmetros separados
  Widget _buildTaskCardFromObject(
      {required BuildContext context, required Task task}) {
    return _buildTaskCard(
      // Chama o seu _buildTaskCard original
      context: context,
      title: task.title,
      subtitle: task.description ?? 'Sem descrição',
      time: task.displayTime,
      progress: task.progressPercentage != null
          ? (task.progressPercentage! / 100.0).clamp(0.0, 1.0)
          : (task.isCompleted ? 1.0 : 0.0),
    );
  }

  // Seu _buildTaskCard original que recebe parâmetros individuais (mantido)
  Widget _buildTaskCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required double progress,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return MouseRegion( // Re-adicionado para o efeito de hover
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
      child: AnimatedContainer( // Re-adicionado para a animação de hover
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: kDarkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: kDarkBorder.withOpacity(0.7)), // Era kDarkBorder no seu
          boxShadow: _isHovered // Efeito de sombra ao passar o mouse
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // Adicionado
                  child: Text(
                    title,
                    style: TextStyle(
                        color: kDarkTextPrimary,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold),
                    maxLines: 1, // Adicionado
                    overflow: TextOverflow.ellipsis, // Adicionado
                  ),
                ),
                Icon(Icons.more_vert,
                    color: kDarkTextSecondary, size: screenWidth * 0.05),
              ],
            ),
            SizedBox(height: screenWidth * 0.01),
            if (subtitle.isNotEmpty) // Checa se subtítulo não é vazio
              Text(
                subtitle,
                style: TextStyle(
                    color: kDarkTextSecondary, fontSize: screenWidth * 0.035),
                maxLines: 2, // Adicionado
                overflow: TextOverflow.ellipsis, // Adicionado
              ),
            SizedBox(height: screenWidth * 0.02),
            if (progress >= 0 &&
                progress <= 1) // Só mostra se progresso for válido
              LinearProgressIndicator(
                value: progress,
                backgroundColor: kDarkBorder,
                color: kAccentSecondary, // Cor do progresso da tarefa
                minHeight: 5,
                borderRadius: BorderRadius.circular(5),
              )
            else
              const SizedBox(height: 5), // Placeholder
            SizedBox(height: screenWidth * 0.01),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(time,
                  style: TextStyle(
                      color: kDarkTextSecondary, fontSize: screenWidth * 0.03)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
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
                  // Correção: Garante que a expressão condicional retorne um ImageProvider
                  backgroundImage: _profileImageBytes != null
                      ? MemoryImage(_profileImageBytes!) as ImageProvider<Object>
                      : const NetworkImage(
                          "https://i.pravatar.cc/150?img=11"), // Fallback
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  _userName, // Usando o nome do usuário carregado
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
                      true, // Ativo
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
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                _navigateToRoute('/'); // Redireciona para a tela de login/inicial
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
    final String _currentPageRoute = '/habitos'; // Ou '/' se for a Home

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
              onTap: () {
                _navigateToRoute('/habitos'); // Navega para a própria página de hábitos
              },
              child: _bottomBarIcon(Icons.home_rounded, isActive: _currentPageRoute == '/habitos'),
            ),
            InkWell(
              onTap: () {
                _navigateToRoute('/settings');
              },
              child: _bottomBarIcon(Icons.settings_outlined, isActive: _currentPageRoute == '/settings'),
            ),
            const SizedBox(width: 40),
            InkWell(
              onTap: () {
                _navigateToRoute('/planner');
              },
              child: _bottomBarIcon(Icons.book_outlined, isActive: _currentPageRoute == '/planner'),
            ),
            InkWell(
              onTap: () {
                _navigateToRoute('/perfil');
              },
              child: _bottomBarIcon(Icons.person_outline, isActive: _currentPageRoute == '/perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBarIcon(IconData icon, {bool isActive = false, VoidCallback? onTap}) {
    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? kAccentPurple : kDarkTextSecondary.withOpacity(0.6),
        size: 26,
      ),
      onPressed: onTap,
      padding: EdgeInsets.zero, // Removido padding padrão do IconButton
      constraints: const BoxConstraints(), // Removido constraints padrão do IconButton
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
}
