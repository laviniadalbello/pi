import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'dart:math'; // Removido se não usado diretamente pela HabitsPage
import 'iconedaia.dart'; // Mantenha se CloseableAiCard e outros dependem disso
import 'package:planify/services/gemini_service.dart'; // Mantenha sua importação
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/services/firestore_tasks_service.dart';
import 'package:planify/services/firestore_service.dart';
import 'package:flutter/services.dart';
import 'package:planify/models/project_model.dart'; // Ajuste o caminho se necessário
import 'package:planify/models/task.dart'; // Você fará o mesmo para Task

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

class HabitsScreen extends StatefulWidget {
  final GeminiService
      geminiService; // Adicione este parâmetro se a classe AI Card precisar dele

  const HabitsScreen({Key? key, required this.geminiService}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with TickerProviderStateMixin {
  // Variáveis de estado
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  bool _isCardVisible = false;
  bool _isNotificationsVisible = false;
  int _unreadNotificationsCount = 2; // Exemplo
  String _userName =
      'Usuário'; // Exemplo, você pode carregar isso do Firebase Auth/Firestore

  // Controladores de animação
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _notificationsController;
  late Animation<Offset> _notificationsAnimation;
  late AnimationController _circleController; // Para os círculos animados
  late PageController _pageController; // Para o PageView dos projetos

  // Serviços
  late FirestoreService _firestoreService;

  // Listas de dados (serão preenchidas do Firestore)
  List<Project> _projects = [];
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _isCardVisible = false; // Inicializa o serviço Firestore

    // Inicialização dos controladores de animação
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _notificationsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _notificationsAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notificationsController,
      curve: Curves.easeOut,
    ));

    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); // Repetir a animação dos círculos

    _pageController = PageController(
        viewportFraction: 0.85); // Ajuste para o carousel de projetos

    // Carregar dados ao iniciar a tela
    _loadData();
    _loadUserName(); // Carregar nome do usuário
  }

  Future<void> _loadUserName() async {
    // Exemplo: carregar nome do usuário logado
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Você pode carregar o nome do display name ou de um documento no Firestore
      setState(() {
        _userName = user.displayName ?? user.email ?? 'Usuário';
      });
      // Se o nome for carregado do Firestore, use algo como:
      // DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      // if (userDoc.exists) {
      //   setState(() {
      //     _userName = userDoc['name'] ?? 'Usuário';
      //   });
      // }
    }
  }

  void _loadData() async {
    // Carregar projetos do Firestore
    try {
      final projectSnapshot =
          await FirebaseFirestore.instance.collection('projects').get();
      setState(() {
        _projects = projectSnapshot.docs
            .map((doc) => Project.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Erro ao carregar projetos: $e');
      // Tratar o erro, talvez mostrar uma mensagem para o usuário
    }

    // Carregar tarefas do Firestore (se você tiver uma coleção de tarefas)
    try {
      final taskSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .get(); // Ou a coleção de tarefas em progresso
      setState(() {
        _tasks =
            taskSnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Erro ao carregar tarefas: $e');
      // Tratar o erro
    }
  }

  void _navigateToRoute(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _notificationsController.dispose();
    _circleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12, // Tamanho da fonte conforme a imagem
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Adiciona a chave para o Scaffold
      backgroundColor: kDarkPrimaryBg, // Cor de fundo principal
      drawer: _buildDrawer(), // Adiciona o Drawer
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(), // Barra superior com menu e notificações
                    _buildTitle(
                        context), // Título "Vamos construir bons hábitos juntos"
                    const SizedBox(height: 20),
                    _buildSectionTitle('PROJETOS'),
                    const SizedBox(height: 10),
                    _buildProjectCarouselWidget(
                        _projects), // Passa a lista de projetos
                    const SizedBox(height: 20),
                    _buildInProgressHeader(context),
                    const SizedBox(height: 10),
                    _buildTasksList(_tasks), // Passa a lista de tarefas
                    const SizedBox(height: 80), // Espaço para o FAB
                  ],
                ),
              ),
            ),
          ),
          // AI Card
          if (_isCardVisible) _buildAiCardSection(context),
          // Dim Overlay e Sliding Menu
          if (_isCardVisible) _buildDimOverlay(),
          _buildSlidingMenu(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
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
              color:
                  kDarkElementBg, // Substituí para kDarkElementBg (presumi que você tem essa constante)
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

  // Renomeado de _buildProjectCarousel para evitar conflito com o PageView
  Widget _buildProjectCarouselWidget(List<Project> projects) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.15,
      child: PageView.builder(
        controller: _pageController,
        itemCount: projects.length, // Usa o número real de projetos
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildProjectCard(
                context, projects[index]), // Passa o objeto Project
          );
        },
      ),
    );
  }

  // Alterado para receber um objeto Project
  Widget _buildProjectCard(BuildContext context, Project project) {
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
                project.name, // Usando project.name
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
            project.description, // Usando project.description
            style: TextStyle(
              color: kDarkTextSecondary,
              fontSize: screenWidth * 0.035,
            ),
          ),
          LinearProgressIndicator(
            value: project.progressPercentage != null
                ? project.progressPercentage! / 100
                : 0.0, // Usando progressPercentage
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

  Widget _buildTasksList(List<Task> tasks) {
    // Este é um exemplo, você precisará adaptar isso para suas tarefas reais.
    return ListView.builder(
      shrinkWrap:
          true, // Para o ListView funcionar dentro de um SingleChildScrollView
      physics:
          const NeverScrollableScrollPhysics(), // Desabilita o scroll próprio do ListView
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(
              bottom: 10), // Adicionado para espaçamento entre os cards
          child: _buildTaskCard(
            // Reutiliza o _buildTaskCard existente
            context: context,
            title: task
                .title, // Assumindo que sua classe Task terá um campo 'title'
            subtitle: task.description ?? 'Sem descrição',
            time: task.displayTime,
            progress: task.progressPercentage != null
                ? task.progressPercentage! / 100
                : 0.0, // Assumindo campo de progresso
          ),
        );
      },
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
