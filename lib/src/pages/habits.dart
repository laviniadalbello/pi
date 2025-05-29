import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';
import 'iconedaia.dart';
import 'package:planify/services/gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/services/firestore_tasks_service.dart';
import 'package:flutter/services.dart';
import 'package:planify/models/task.dart';

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
  final bool _isHovered = false;
  bool _isNotificationsVisible = false;
  bool _isLoading = true;

  // Lista de tarefas do usuário
  List<Task> _userTasks = [];

  // Instância do FirestoreTasksService
  late FirestoreTasksService _firestoreService;

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
  String _userId = "";

  @override
  void initState() {
    super.initState();
    _initializeUser();
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

  // Inicializa o usuário e carrega seus dados
  Future<void> _initializeUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _userId = user.uid;
          // Inicializa o serviço com o ID do usuário autenticado
          _firestoreService = FirestoreTasksService(userId: user.uid);
        });
        
        await _loadUserData();
        await _loadUserTasks();
      } else {
        print('Usuário não autenticado');
        // Redirecionar para tela de login se necessário
      }
    } catch (e) {
      print('Erro ao inicializar usuário: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRoute(String routeName) {
    // Fecha o drawer se estiver aberto
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushNamed(routeName);
  }

  // Carrega os dados do perfil do usuário
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

  // Carrega as tarefas do usuário do Firestore
  Future<void> _loadUserTasks() async {
    try {
      if (_userId.isEmpty) return;
      
      final tasks = await _firestoreService.listUserTasks();
      setState(() {
        _userTasks = tasks;
      });
      print('Carregadas ${tasks.length} tarefas para o usuário $_userId');
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
      // Mostrar mensagem de erro se necessário
    }
  }

  // Cria uma nova tarefa
  Future<void> _createTask(String title, String subtitle) async {
    try {
      if (_userId.isEmpty) return;
      
      await _firestoreService.createUserTask(
        title: title,
        description: subtitle,
        priority: 'medium',
      );
      
      // Recarrega as tarefas após criar uma nova
      await _loadUserTasks();
      
      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa criada com sucesso!')),
      );
    } catch (e) {
      print('Erro ao criar tarefa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar tarefa: $e')),
      );
    }
  }

  // Deleta uma tarefa
  Future<void> _deleteTask(String taskId) async {
    try {
      if (_userId.isEmpty) return;
      
      await _firestoreService.deleteTask(taskId: taskId);
      
      // Recarrega as tarefas após deletar
      await _loadUserTasks();
      
      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa removida com sucesso!')),
      );
    } catch (e) {
      print('Erro ao deletar tarefa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover tarefa: $e')),
      );
    }
  }

  // Mostra diálogo para criar nova tarefa
  void _showCreateTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkElementBg,
        title: const Text(
          'Nova Tarefa',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kAccentPurple),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kAccentPurple),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Descrição',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kAccentPurple),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kAccentPurple),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentPurple,
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _createTask(
                  titleController.text,
                  descriptionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccentPurple,
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kAccentPurple),
              ),
            )
          : CustomScrollView(
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
                                  // Exibe as tarefas do usuário
                                  ..._buildUserTasksList(context),
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
                                child: _buildNotificationsPanel(screenWidth, screenHeight),
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

  // Constrói a lista de tarefas do usuário
  List<Widget> _buildUserTasksList(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    
    if (_userTasks.isEmpty) {
      return [
        SizedBox(
          height: screenHeight * 0.2,
          child: const Center(
            child: Text(
              "Você não tem tarefas. Crie uma nova!",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ];
    }
    
    return _userTasks.map((task) {
      // Calcula um valor de progresso aleatório para demonstração
      // Em um app real, você usaria task.progressPercentage
      final progress = task.progressPercentage != null 
          ? task.progressPercentage! / 100 
          : Random().nextDouble() * 0.8 + 0.1;
      
      return Column(
        children: [
          _buildTaskCard(
            context: context,
            title: task.title,
            subtitle: task.description ?? "Sem descrição",
            time: _formatTaskTime(task.createdAt),
            progress: progress,
            taskId: task.id,
          ),
          SizedBox(height: screenHeight * 0.015),
        ],
      );
    }).toList();
  }

  // Formata o tempo da tarefa para exibição
  String _formatTaskTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return "Agora mesmo";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min atrás";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} h atrás";
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required double progress,
    required String taskId,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Dismissible(
      key: Key(taskId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        _deleteTask(taskId);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: kDarkElementBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: kDarkTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: kDarkTextSecondary,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(progress),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return kAccentSecondary;
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        Row(
          children: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNotificationsVisible = true;
                      _notificationsController.forward();
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
                      child: Text(
                        _unreadNotificationsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/perfil');
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kAccentPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kAccentPurple,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty
                        ? _userName[0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Olá, $_userName",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Vamos organizar seu dia!",
          style: TextStyle(
            color: kDarkTextSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCarousel(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    final projects = [
      {
        'title': 'Projeto App',
        'tasks': 5,
        'completed': 2,
        'color': const Color(0xFF7F5AF0),
      },
      {
        'title': 'Website',
        'tasks': 8,
        'completed': 3,
        'color': const Color(0xFF2CB67D),
      },
      {
        'title': 'Design UI',
        'tasks': 3,
        'completed': 1,
        'color': const Color(0xFFF25F4C),
      },
    ];

    return SizedBox(
      height: screenWidth * 0.4,
      child: PageView.builder(
        controller: _pageController,
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (_pageController.page! - index).abs();
                value = (1 - (value * 0.3)).clamp(0.7, 1.0);
              }
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: project['color'] as Color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (project['color'] as Color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${project['completed']}/${project['tasks']} tarefas",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (project['completed'] as int) /
                              (project['tasks'] as int),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 6,
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
    );
  }

  Widget _buildInProgressHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Tarefas em Progresso",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // Navegar para a tela de todas as tarefas
          },
          child: const Text(
            "Ver Todas",
            style: TextStyle(
              color: kAccentPurple,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsPanel(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  setState(() {
                    _notifications.removeAt(index);
                  });
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
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
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: notification['read']
                        ? Colors.white.withOpacity(0.05)
                        : Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification['title'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            notification['time'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        notification['message'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                      if (!notification['read'])
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                notification['read'] = true;
                              });
                            },
                            child: Text(
                              'Marcar como lida',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
        child: Container(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildSlidingMenu() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: screenHeight * 0.6,
          decoration: const BoxDecoration(
            color: kDarkElementBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Criar Novo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                  ),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildMenuOption(
                      icon: Icons.task_alt,
                      title: "Tarefa",
                      color: kAccentPurple,
                      onTap: () {
                        setState(() {
                          _isCardVisible = false;
                          _slideController.reverse();
                        });
                        _showCreateTaskDialog();
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.folder,
                      title: "Projeto",
                      color: const Color(0xFF2CB67D),
                      onTap: () {
                        setState(() {
                          _isCardVisible = false;
                          _slideController.reverse();
                        });
                        Navigator.of(context).pushNamed('/criarprojeto');
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.event,
                      title: "Evento",
                      color: const Color(0xFFF25F4C),
                      onTap: () {
                        setState(() {
                          _isCardVisible = false;
                          _slideController.reverse();
                        });
                        Navigator.of(context).pushNamed('/criarevento');
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.people,
                      title: "Time",
                      color: const Color(0xFF3DA9FC),
                      onTap: () {
                        setState(() {
                          _isCardVisible = false;
                          _slideController.reverse();
                        });
                        Navigator.of(context).pushNamed('/criartime');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kDarkSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      height: 64,
      width: 64,
      margin: const EdgeInsets.only(bottom: 16),
      child: FloatingActionButton(
        backgroundColor: kAccentPurple,
        elevation: 4,
        onPressed: () {
          setState(() {
            _isCardVisible = true;
            _slideController.forward();
          });
        },
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: kDarkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: "Home",
            isActive: true,
            onTap: () {},
          ),
          _buildNavItem(
            icon: Icons.calendar_today,
            label: "Planner",
            isActive: false,
            onTap: () {
              Navigator.of(context).pushNamed('/planner');
            },
          ),
          const SizedBox(width: 64), // Espaço para o FAB
          _buildNavItem(
            icon: Icons.chat_bubble_outline,
            label: "Chat",
            isActive: false,
            onTap: () {
              Navigator.of(context).pushNamed('/chatdaia');
            },
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: "Config",
            isActive: false,
            onTap: () {
              Navigator.of(context).pushNamed('/configuracoes');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? kAccentPurple : kDarkTextSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? kAccentPurple : kDarkTextSecondary,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: kDarkSurface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: kDarkPrimaryBg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: kAccentPurple.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kAccentPurple,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _userName.isNotEmpty
                          ? _userName[0].toUpperCase()
                          : "U",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Usuário Premium",
                  style: TextStyle(
                    color: kDarkTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            title: "Home",
            onTap: () => _navigateToRoute('/habitos'),
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            title: "Planner Diário",
            onTap: () => _navigateToRoute('/planner'),
          ),
          _buildDrawerItem(
            icon: Icons.folder,
            title: "Projetos",
            onTap: () => _navigateToRoute('/projetos'),
          ),
          _buildDrawerItem(
            icon: Icons.task_alt,
            title: "Tarefas",
            onTap: () => _navigateToRoute('/tarefas'),
          ),
          _buildDrawerItem(
            icon: Icons.event,
            title: "Eventos",
            onTap: () => _navigateToRoute('/eventos'),
          ),
          _buildDrawerItem(
            icon: Icons.people,
            title: "Times",
            onTap: () => _navigateToRoute('/times'),
          ),
          const Divider(
            color: kDarkBorder,
            thickness: 1,
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: "Configurações",
            onTap: () => _navigateToRoute('/configuracoes'),
          ),
          _buildDrawerItem(
            icon: Icons.help_outline,
            title: "Ajuda",
            onTap: () => _navigateToRoute('/ajuda'),
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: "Sair",
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
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
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}

class CloseableAiCard extends StatefulWidget {
  final FirestoreTasksService firestoreService;
  final GeminiService geminiService;
  final double scaleFactor;
  final bool enableScroll;

  const CloseableAiCard({
    super.key,
    required this.firestoreService,
    required this.geminiService,
    this.scaleFactor = 0.4,
    this.enableScroll = false,
  });

  @override
  State<CloseableAiCard> createState() => _CloseableAiCardState();
}

class _CloseableAiCardState extends State<CloseableAiCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isLoading = false;
  String _aiResponse = "";
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.scaleFactor,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getAiResponse() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.geminiService.getGeminiResponse(
        _promptController.text,
      );
      setState(() {
        _aiResponse = response;
        _isLoading = false;
      });

      // Limpa o campo de texto
      _promptController.clear();

      // Rola para o final da resposta
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Erro ao obter resposta: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _isExpanded ? 0 : _rotationAnimation.value,
          child: Transform.scale(
            scale: _isExpanded ? 1.0 : _scaleAnimation.value,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _controller.stop();
                  } else {
                    _controller.forward();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isExpanded ? screenWidth * 0.9 : 180,
                height: _isExpanded ? screenSize.height * 0.7 : 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6735B1),
                      Color(0xFF9C6DFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6735B1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isExpanded
                    ? _buildExpandedContent(context)
                    : _buildCollapsedContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedContent(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: BubblesPainter(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                "DAIA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Seu assistente de produtividade",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Toque para abrir",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "DAIA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = false;
                    _controller.forward();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: widget.enableScroll
                      ? SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_aiResponse.isEmpty)
                                const Text(
                                  "Olá! Sou a DAIA, sua assistente de produtividade. Como posso ajudar você hoje?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                )
                              else
                                Text(
                                  _aiResponse,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_aiResponse.isEmpty)
                              const Text(
                                "Olá! Sou a DAIA, sua assistente de produtividade. Como posso ajudar você hoje?",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              )
                            else
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    _aiResponse,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        decoration: InputDecoration(
                          hintText: "Digite sua pergunta...",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _getAiResponse(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: kAccentPurple,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                        onPressed: _isLoading ? null : _getAiResponse,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Desenha bolhas decorativas
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.15,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      size.width * 0.1,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.8),
      size.width * 0.08,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
