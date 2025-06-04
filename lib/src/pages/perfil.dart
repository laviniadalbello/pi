import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart'; // Para formatação de data
import 'package:planify/services/gemini_service.dart';
import 'package:planify/services/firestore_tasks_service.dart';
import 'configuracoes.dart'; // Certifique-se que este import é necessário
import 'iconedaia.dart'; // Certifique-se que este import é necessário
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:universal_html/html.dart' as html;
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Seus modelos - Certifique-se que os caminhos estão corretos
// e que as classes são 'Project' e 'Task'
import 'package:planify/models/project_model.dart'; // Deve conter a classe Project
import 'package:planify/models/task.dart'; // Deve conter a classe Task

// Suas constantes de cor (kDarkPrimaryBg, etc.)
const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _circleController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  late GeminiService _geminiService;
  FirestoreTasksService?
      _firestoreTasksService; // Modificado para ser nullable e usar o nome que passamos para o card

  bool _isCardVisible = false;
  String? _currentUserId;
  String? _currentUserEmail;

  // Dados do perfil - serão carregados do Firestore
  String _userName = "Carregando...";
  String _userHandle = "@usuario";
  String _userBio = "Buscando informações...";
  List<Map<String, dynamic>> _userStats = [
    {"label": "Projetos", "value": 0},
    {"label": "Tarefas", "value": 0},
    {"label": "Equipes", "value": 0}, // Será atualizado
  ];
  List<Map<String, dynamic>> _recentActivities = [];

  Uint8List? _profileImageBytes;

  void _navigateToRoute(String routeName) {
    // Primeiro, fecha o drawer se estiver aberto
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    // Então, navega para a nova rota
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(apiKey: 'SUA_API_KEY_GEMINI_AQUI');

    _circleController =
        AnimationController(duration: const Duration(seconds: 6), vsync: this)
          ..repeat();
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Carrega os dados e verifica se há foto salva
    _loadAllDataForProfile().then((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        _loadUserProfileFromFirestore(user);
      }
    });
  }

  Future<void> _loadAllDataForProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _userName = "Visitante";
          _userHandle = "@convidado";
          _userBio = "Faça login para ver seu perfil.";
          _userStats = [
            {"label": "Projetos", "value": 0},
            {"label": "Tarefas", "value": 0},
            {"label": "Equipes", "value": 0},
          ];
          _recentActivities = [];
        });
      }
      return;
    }

    _currentUserId = user.uid;
    _currentUserEmail = user.email; // Guardar o email para a query de 'members'
    _firestoreTasksService = FirestoreTasksService(userId: _currentUserId!);

    // Carrega todos os dados em paralelo quando possível
    try {
      await Future.wait([
        _loadUserProfileFromFirestore(user), // Carrega nome, bio, handle
        _loadUserStatsFromFirestore(
            _currentUserId!, _currentUserEmail), // Carrega contagens
        _loadRecentActivitiesFromFirestore(
            _currentUserId!), // Carrega atividades
      ]);
    } catch (e) {
      print("Erro ao carregar todos os dados do perfil: $e");
      // Você pode querer definir um estado de erro mais geral aqui
    }
  }

  Future<void> _loadUserProfileFromFirestore(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;

          // Carrega dados básicos
          final nameFromDoc = data?['name'] ?? data?['nome'];
          setState(() {
            _userName = nameFromDoc?.toString() ??
                user.displayName ??
                user.email ??
                'Usuário';
            _userHandle = '@${user.email?.split('@').first ?? 'usuario'}';
            _userBio = data?['bio']?.toString() ?? 'Bio não informada';

            // Carrega a imagem se existir
            if (data?['profileImage'] != null) {
              _profileImageBytes =
                  base64Decode(data!['profileImage'] as String);
            } else {
              _profileImageBytes = null;
            }
          });
        } else {
          // Cria novo usuário se não existir
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': user.displayName ?? 'Novo Usuário',
            'email': user.email,
            'profileComplete': false,
            'createdAt': FieldValue.serverTimestamp(),
            'bio': 'Hey there! I am using Planify',
          });

          if (mounted) {
            await _loadUserProfileFromFirestore(user);
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar perfil: $e');
      if (mounted) {
        setState(() {
          _userName = 'Erro ao carregar';
          _userHandle = '@erro';
          _userBio = 'Não foi possível carregar os dados.';
        });
      }
    }
  }

  Future<void> _loadUserStatsFromFirestore(
      String userId, String? userEmail) async {
    try {
      // Contar Projetos do usuário
      final projectCountQuery = FirebaseFirestore.instance
          .collection('projects')
          .where('userId', isEqualTo: userId);
      final projectCountSnapshot = await projectCountQuery.count().get();
      final int projectCount = projectCountSnapshot.count ?? 0;

      // Contar Tarefas do usuário
      final taskCountQuery = FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId);
      final taskCountSnapshot = await taskCountQuery.count().get();
      final int taskCount = taskCountSnapshot.count ?? 0;

      // Contar "Equipes" - Projetos onde o usuário é membro (pelo email)
      // ATENÇÃO: Ajuste esta lógica se 'equipes' tiver uma definição diferente para você.
      int teamCount = 0;
      if (userEmail != null && userEmail.isNotEmpty) {
        final teamQuery = FirebaseFirestore.instance
            .collection('projects')
            .where('members',
                arrayContains:
                    userEmail); // Assume que 'members' é um array de emails
        // .where('userId', isNotEqualTo: userId); // Opcional: para não contar projetos que ele já possui
        final teamSnapshot = await teamQuery.count().get();
        teamCount = teamSnapshot.count ?? 0;
      }

      if (mounted) {
        setState(() {
          _userStats = [
            {"label": "Projetos", "value": projectCount},
            {"label": "Tarefas", "value": taskCount},
            {"label": "Equipes", "value": projectCount},
          ];
        });
      }
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
      if (mounted) {
        setState(() {
          _userStats = [
            {"label": "Projetos", "value": 0},
            {"label": "Tarefas", "value": 0},
            {"label": "Equipes", "value": 0},
          ];
        });
      }
    }
  }

  Future<void> _loadRecentActivitiesFromFirestore(String userId) async {
    List<Map<String, dynamic>> activities = [];
    try {
      // Buscar os 2 projetos mais recentes
      QuerySnapshot recentProjects = await FirebaseFirestore.instance
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      for (var doc in recentProjects.docs) {
        Project project = Project.fromFirestore(doc); // Usa seu modelo Project
        Color activityColor = kAccentPurple; // Cor padrão
        try {
          if (project.color.isNotEmpty) {
            String colorString = project.color.replaceAll('#', '');
            if (colorString.length == 6) colorString = 'FF$colorString';
            activityColor = Color(int.parse("0x$colorString"));
          }
        } catch (_) {}

        activities.add({
          "type": "project",
          "title": project.name,
          "date": DateFormat('dd/MM/yy, HH:mm', 'pt_BR')
              .format(project.createdAt.toDate()),
          "status": project.status,
          "color": activityColor,
        });
      }

      // Buscar as 2 tarefas mais recentes (ou com prazo mais próximo, etc.)
      QuerySnapshot recentTasks = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true) // ou 'dueDate'
          .limit(2)
          .get();

      for (var doc in recentTasks.docs) {
        Task task = Task.fromFirestore(doc); // Usa seu modelo Task
        activities.add({
          "type": "task",
          "title": task.title,
          "date": DateFormat('dd/MM/yy, HH:mm', 'pt_BR')
              .format(task.createdAt), // Ou task.dueDate
          "status": task.status,
          "color": kAccentSecondary, // Cor de exemplo para tarefas
        });
      }

      // Ordenar todas as atividades combinadas pela data (mais recentes primeiro)
      // Isso assume que 'date' é uma String formatada que pode ser comparada ou um DateTime.
      // Para comparação de datas reais, seria melhor converter 'date' para DateTime antes de ordenar.
      // Por simplicidade, se as datas formatadas já ordenam bem:
      // activities.sort((a, b) => b['date'].compareTo(a['date']));

      if (mounted) {
        setState(() {
          _recentActivities = activities;
        });
      }
    } catch (e) {
      print('Erro ao carregar atividades recentes: $e');
      if (mounted) setState(() => _recentActivities = []);
    }
  }

  // Seu método testFirestore, dispose, _navigateToRoute, e todos os _build... methods
  // (como _buildFloatingActionButton, _buildDimOverlay, _buildSlidingMenu, _menuItem,
  // _buildBottomBar, _buildBottomBarIcon, _animatedCircle, _buildHeader, _buildProfileSection,
  // _buildStatsSection, _buildRecentActivitiesSection, _buildActivityItem, _buildActionButtons,
  // _buildAiCardSection, _showEditProfileDialog, _showEditAvatarOptions, _showOptionsMenu)
  // permanecem aqui como você os definiu no código que me enviou.
  // Apenas garanta que _buildAiCardSection use _firestoreTasksService se precisar do userId.

  // ... (COLE AQUI O RESTANTE DOS SEUS MÉTODOS _build... E OUTROS MÉTODOS HELPER) ...
  // Exemplo do _buildAiCardSection ajustado para usar o serviço correto:
  Widget _buildAiCardSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_firestoreTasksService == null)
      return SizedBox.shrink(); // Não mostra se o serviço não está pronto

    return Transform.translate(
      offset: Offset(screenWidth * 0.15, -25),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.02),
          child: CloseableAiCard(
            geminiService: _geminiService,
            firestoreService:
                _firestoreTasksService!, // Usa a instância correta com userId
            scaleFactor: screenWidth < 360 ? 0.3 : 0.35,
            enableScroll: true,
          ),
        ),
      ),
    );
  }

  // Cole todos os seus outros métodos _build... aqui para o código ficar completo.
  // ...
  // Exemplo:
  Widget _buildBottomBar() {
    // Use a lógica que você definiu para a PerfilPage, garantindo que isActive é true para o ícone do perfil
    final String _currentPageRoute =
        '/perfil'; // Definindo a rota atual para esta página
    return BottomAppBar(
      color: kDarkSurface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _bottomBarIcon(Icons.home_rounded,
                isActive: _currentPageRoute == '/habitos',
                onTap: () => _navigateToRoute('/habitos')),
            _bottomBarIcon(Icons.settings_outlined,
                isActive: _currentPageRoute == '/settings',
                onTap: () => _navigateToRoute('/settings')),
            const SizedBox(width: 40),
            _bottomBarIcon(Icons.book_outlined,
                isActive: _currentPageRoute == '/planner',
                onTap: () => _navigateToRoute('/planner')),
            _bottomBarIcon(Icons.person_outline,
                isActive: _currentPageRoute == '/perfil',
                onTap: () => _navigateToRoute('/perfil')),
          ],
        ),
      ),
    );
  }

  Widget _bottomBarIcon(IconData icon,
      {bool isActive = false, required VoidCallback onTap}) {
    // Usando a versão IconButton que você tem na HabitsScreen para consistência
    return IconButton(
      icon: Icon(icon,
          color: isActive ? kAccentPurple : kDarkTextSecondary.withOpacity(0.6),
          size: 26),
      onPressed: onTap,
      padding: const EdgeInsets.all(12),
    );
  }
  // ... e assim por diante para todos os seus outros métodos _build ...
  // Cole o restante dos seus métodos _build... aqui. O código que você enviou era extenso.
  // O método build principal é o mais importante e deve estar lá.

  // Coloque o método build principal aqui, como você o enviou.
  // Vou colocar uma versão simplificada dele para garantir que ele usa as variáveis de estado.
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance
        .currentUser; // Pode ser útil ter screenWidth/Height aqui também
    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black, // ou kDarkPrimaryBg
      extendBody: true,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(), // Chama a versão atualizada
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Stack(
                children: [/* Seus _animatedCircle aqui */],
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildProfileSection(), // Este método usará _userName, _userHandle, _userBio
                  const SizedBox(height: 30),
                  _buildStatsSection(), // Este método usará _userStats
                  const SizedBox(height: 30),
                  _buildRecentActivitiesSection(), // Este método usará _recentActivities
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            if (_isCardVisible && _firestoreTasksService != null)
              _buildAiCardSection(
                  context), // Mostra se visível e serviço pronto
            if (_isCardVisible) _buildDimOverlay(),
            if (_isCardVisible) _buildSlidingMenu(), // O seu já tem Positioned

            // O Positioned para o CloseableAiCard (chatbot) para estar sempre visível (se não condicionado por _isCardVisible)
            // Se _buildAiCardSection já o posiciona e você quer que ele seja sempre visível (e não dependente de _isCardVisible),
            // você chamaria _buildAiCardSection(context) aqui sem o if(_isCardVisible)
            // Mas o seu código original da PerfilPage já o coloca dentro do Stack principal no final
            // Vamos manter o seu original para o chatbot:
            Positioned(
              bottom: -26, // Conforme seu código da PerfilPage
              right: -60,
              child: CloseableAiCard(
                geminiService: _geminiService,
                firestoreService:
                    _firestoreTasksService!, // Garanta que esta é a instância correta com UID
                scaleFactor:
                    MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
                enableScroll: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cole todos os seus outros métodos _build... (_buildHeader, _buildProfileSection, etc.)
  // _animatedCircle, _buildHeader, _buildProfileSection, _buildStatsSection, _buildRecentActivitiesSection,
  // _buildActivityItem, _buildActionButtons, _showEditProfileDialog, _showEditAvatarOptions, _showOptionsMenu,
  // _buildFloatingActionButton, _buildDimOverlay, _buildSlidingMenu, _menuItem
  // Estes métodos devem permanecer como você os definiu no código que me enviou, pois eles
  // lidam com a parte visual e agora devem receber dados reais através das variáveis de estado.
  // ...
  Widget _animatedCircle(
      double top, double right, double speed, List<Color> colors, int index) {
    /* ... seu código ... */ return AnimatedBuilder(
      animation: _circleController,
      builder: (context, child) => Positioned(
        top: top + sin(_circleController.value * 2 * pi + index * pi / 3) * 10,
        right:
            right + cos(_circleController.value * 2 * pi + index * pi / 3) * 10,
        child: Transform.scale(
          scale:
              1 + sin(_circleController.value * 2 * pi + index * pi / 2) * 0.1,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    /* ... seu código ... */ return Stack(
      alignment: Alignment.center,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: kDarkTextPrimary,
                  size: 30,
                ))),
        const Text(
          'Perfil',
          style: TextStyle(
            color: kDarkTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: kDarkTextPrimary),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Stack(
          children: [
            _buildProfileImage(),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndSaveImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentPurple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: kDarkTextPrimary,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          style: const TextStyle(
            color: kDarkTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userHandle,
          style: const TextStyle(color: kDarkTextSecondary, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          _userBio,
          style: TextStyle(
            color: kDarkTextPrimary.withOpacity(0.8),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            _showEditProfileDialog();
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kAccentPurple),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Editar Perfil',
            style: TextStyle(color: kAccentPurple, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final double size = 100;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: kAccentPurple.withOpacity(0.2),
      backgroundImage:
          _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
      child: _profileImageBytes == null
          ? const Icon(Icons.person, color: kDarkTextPrimary, size: 48)
          : null,
    );
  }

  Future<void> _pickAndSaveImage() async {
    try {
      final pickedBytes = await ImagePickerService.pickImage();
      if (pickedBytes != null && _currentUserId != null) {
        setState(() => _profileImageBytes = pickedBytes);

        // Converte para Base64 e salva no Firestore
        final base64Image = base64Encode(pickedBytes);

        // Salva no cache local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImage_$_currentUserId', base64Image);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUserId)
            .update({
          'profileImage': base64Image,
          'lastUpdated':
              FieldValue.serverTimestamp(), // Este campo é importante
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar imagem: $e')),
      );
      print('Erro ao salvar imagem: $e');
    }
  }

  Widget _buildStatsSection() {
    /* ... seu código, usando _userStats ... */ return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkElementBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _userStats.map((stat) {
          return Column(
            children: [
              Text(
                stat["value"].toString(),
                style: const TextStyle(
                  color: kDarkTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat["label"],
                style: const TextStyle(color: kDarkTextSecondary, fontSize: 14),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    /* ... seu código, usando _recentActivities ... */ return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Atividades Recentes',
              style: TextStyle(
                color: kDarkTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentActivities.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    /* ... seu código ... */ IconData activityIcon;
    switch (activity["type"]) {
      case "project":
        activityIcon = Icons.folder;
        break;
      case "task":
        activityIcon = Icons.task_alt;
        break;
      case "team":
        activityIcon = Icons.group;
        break;
      default:
        activityIcon = Icons.event_note;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkElementBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (activity["color"] as Color).withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (activity["color"] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(activityIcon, color: activity["color"] as Color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity["title"],
                  style: const TextStyle(
                    color: kDarkTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity["date"],
                  style:
                      const TextStyle(color: kDarkTextSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (activity["color"] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              activity["status"],
              style: TextStyle(
                color: activity["color"] as Color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    /* ... seu código ... */ return Column(
      children: [
        _buildActionButton(
          icon: Icons.folder,
          label: 'Meus Projetos',
          onTap: () {
            _navigateToRoute('/detalhesprojeto');
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.settings,
          label: 'Configurações',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsApp()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.analytics,
          label: 'Meus Eventos ',
          onTap: () {
            _navigateToRoute('/detalheseventos');
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.analytics,
          label: 'Minhas Atividades',
          onTap: () {
            _navigateToRoute('/detalhestarefa');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    /* ... seu código ... */ return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: kDarkElementBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: kAccentPurple),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: kDarkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: kDarkTextSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {/* ... seu código ... */}
  void _showEditAvatarOptions() {/* ... seu código ... */}
  void _showOptionsMenu() {/* ... seu código ... */}

  // Estes são da HabitsScreen, adapte ou use os da PerfilPage se forem diferentes
  Widget _buildFloatingActionButton() {
    /* ... seu código da PerfilPage ... */ return Transform.translate(
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

  Widget _buildDimOverlay() {
    /* ... seu código da PerfilPage ... */ return Positioned.fill(
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
    /* ... seu código da PerfilPage ... */ return Positioned(
      bottom: 8,
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
    /* ... seu código da PerfilPage ... */ return Container(
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

  @override
  void dispose() {
    _circleController.dispose();
    _slideController.dispose();
    // Remova as linhas abaixo se as classes não possuem dispose()
    // _geminiService.dispose();
    // _firestoreTasksService?.dispose();
    super.dispose();
  }
}

class ImagePickerService {
  static Future<Uint8List?> pickImage() async {
    if (kIsWeb) {
      return _pickImageWeb();
    } else {
      return _pickImageMobile();
    }
  }

  static Future<Uint8List?> _pickImageMobile() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return await pickedFile.readAsBytes();
      }
    } catch (e) {
      print('Erro ao selecionar imagem (mobile): $e');
    }
    return null;
  }

  static Future<Uint8List?> _pickImageWeb() async {
    try {
      final pickedFile = await ImagePickerWeb.getImageAsBytes();
      return pickedFile;
    } catch (e) {
      print('Erro ao selecionar imagem (web): $e');
    }
    return null;
  }
}
