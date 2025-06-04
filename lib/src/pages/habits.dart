import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'iconedaia.dart'; // Presumo que este arquivo exista e seja necessário
import 'package:planify/services/gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Removi a importação duplicada de firestore_tasks_service se FirestoreService for o principal
import 'package:planify/services/firestore_service.dart';
import 'package:planify/services/firestore_tasks_service.dart'; // Presumo que este é o seu serviço principal
// import 'package:flutter/services.dart'; // Descomente se usado em algum lugar
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoadingProfileImage = false;
  bool _isCardVisible = false;
  bool _isNotificationsVisible = false;

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
  late AnimationController _circleController;
  late PageController _pageController;
  late AnimationController
      _fadeController; // Adicionado para consistência com o build
  late Animation<double>
      _fadeAnimation; // Adicionado para consistência com o build

  // late FirestoreService _firestoreService; // Você instancia FirestoreService globalmente?
  // Se não for usado nesta tela, pode ser removido.
  // A instância de FirestoreTasksService também sumiu.
  // Se CloseableAiCard precisa de um serviço, ele precisa ser fornecido.
  FirestoreTasksService? _userFirestoreTasksService; // Para o CloseableAiCard

  String _userName = "Carregando...";
  List<Project> _projects = [];
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    // _firestoreService = FirestoreService(); // Se for um serviço global, ok.
    // Senão, pode não ser necessário aqui.

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
          ..repeat();

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
    // _mainScrollController.dispose(); // Se você voltar a usar CustomScrollView
    _profileImageBytes = null; // Limpa a memória da imagem
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop(); // Fecha o drawer primeiro
    }
    Navigator.of(context).pushNamed(routeName);
  }

  // Seus métodos _build... como _buildTopBar, _buildTitle, etc.
  // O método _buildProjectCarousel foi renomeado para _buildProjectCarouselWidget
  // e _buildTasksList espera uma lista.
  // Os cards (_buildProjectCard, _buildTaskCard) usam os objetos Project e Task.

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
      // O body mudou de CustomScrollView para Stack > SafeArea > SingleChildScrollView
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              // Adicionado FadeTransition aqui para o conteúdo principal
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                // Permite scroll se o conteúdo exceder a tela
                // controller: _mainScrollController, // _mainScrollController não é usado com SingleChildScrollView
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    _buildTopBar(),
                    SizedBox(height: screenHeight * 0.02),
                    _buildTitle(context),
                    // const SizedBox(height: 20), // Usar proporção da tela
                    SizedBox(height: screenHeight * 0.025),
                    _buildSectionTitle('PROJETOS'), // Usando seu método
                    // const SizedBox(height: 10),
                    SizedBox(height: screenHeight * 0.015),
                    // Se _projects estiver vazio, PageView.builder com itemCount 0 não mostra nada.
                    // Você pode adicionar um widget de "nenhum projeto" aqui se preferir.
                    _projects.isEmpty
                        ? Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.05),
                                child: (_currentUserId == null ||
                                        _userName ==
                                            "Carregando...") // Checa se ainda está carregando usuário
                                    ? CircularProgressIndicator(
                                        color: kAccentPurple)
                                    : Text("Nenhum projeto encontrado.",
                                        style: TextStyle(
                                            color: kDarkTextSecondary))))
                        : _buildProjectCarouselWidget(_projects),

                    SizedBox(height: screenHeight * 0.025),
                    _buildInProgressHeader(context),
                    SizedBox(height: screenHeight * 0.015),
                    // Se _tasks estiver vazio, ListView.builder com itemCount 0 não mostra nada.
                    // Você pode adicionar um widget de "nenhuma tarefa" aqui.
                    _tasks.isEmpty
                        ? Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.05),
                                child: (_currentUserId == null ||
                                        _userName == "Carregando...")
                                    ? Container() // Não mostra nada se projetos já tem indicador
                                    : Text("Nenhuma tarefa em progresso.",
                                        style: TextStyle(
                                            color: kDarkTextSecondary))))
                        : _buildTasksListWidget(
                            _tasks), // Renomeado para clareza

                    SizedBox(
                        height:
                            screenHeight * 0.12), // Espaço para FAB e BottomNav
                  ],
                ),
              ),
            ),
          ),
          // AI Card - Garanta que _userFirestoreTasksService é passado e não nulo
          if (_userFirestoreTasksService != null &&
              _currentUserId != null) // Adicionado _isCardVisible
            Positioned(
              bottom: -26,
              right:
                  -60, // Ajuste conforme seu layout original para CloseableAiCard
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
                                      style:
                                          TextStyle(color: kDarkTextSecondary)))
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
                                                color:
                                                    notification['read'] == true
                                                        ? kDarkBorder
                                                            .withOpacity(0.3)
                                                        : kAccentPurple
                                                            .withOpacity(0.4))),
                                        child: Column(
                                            /* Conteúdo da Notificação */),
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
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProjectCarouselWidget(List<Project> projects) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (projects.isEmpty && _currentUserId != null) {
      // Adicionado _currentUserId != null para não mostrar antes do load inicial
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
                    color: kDarkTextSecondary,
                    fontSize: screenWidth * 0.035), // Era 0.032 no seu
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
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: kDarkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: kDarkBorder.withOpacity(0.7)), // Era kDarkBorder no seu
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
    );
  }

  // Seus outros métodos _buildTopBar, _buildTitle, etc., como você forneceu
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
          constraints: BoxConstraints(),
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
          constraints: BoxConstraints(),
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
          // Círculos animados (conforme seu código)
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
                  backgroundColor: kAccentPurple.withOpacity(0.2),
                  backgroundImage: _profileImageBytes != null
                      ? MemoryImage(_profileImageBytes!)
                      : null,
                  child: _profileImageBytes == null
                      ? Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                              color: kDarkTextPrimary,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold))
                      : null,
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(_userName,
                    style: TextStyle(
                        color: kDarkTextPrimary,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: TextStyle(
                    color: kDarkTextSecondary,
                    fontSize: screenWidth * 0.03,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
          // Itens removidos: Concluídas, Categorias, Relatórios, Sobre
          const Divider(color: kDarkBorder),
          _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Configurações',
              onTap: () => _navigateToRoute('/settings')),
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
      //height: 60,
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
          size: 24),
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

  // O método _buildAiCardSection não estava sendo chamado no seu build principal,
  // mas se você precisar dele, aqui está um exemplo de como ele poderia ser:
  /*
  Widget _buildAiCardSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Adapte a posição e o conteúdo conforme necessário
    return Positioned(
      bottom: 100, // Exemplo de posição
      right: 20,   // Exemplo de posição
      child: CloseableAiCard(
        firestoreService: _userFirestoreTasksService!, // Certifique-se que não é nulo
        geminiService: widget.geminiService,
        scaleFactor: screenWidth < 360 ? 0.3 : 0.35,
        enableScroll: true,
      ),
    );
  }
  */
}
