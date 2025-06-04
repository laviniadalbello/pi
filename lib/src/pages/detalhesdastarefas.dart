import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:planify/src/pages/iconedaia.dart'; // Importação corrigida para o caminho do pacote
import 'package:planify/services/gemini_service.dart';
import 'package:planify/services/firestore_tasks_service.dart';

// --- Cores da UI ---
const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

// --- Enum para filtros de tarefa ---
enum TaskFilter { all, completed, inProgress }

// --- Classe Modelo Task ---
class Task {
  final String id;
  final String title;
  final String time;
  bool isCompleted;
  final String durationLabel;
  final Color? highlightColor;
  final String? description;
  final List<String>? members;
  final String? priority;
  final Color? taskColor;
  final List<String>? attachments;
  final String? statusBoard;

  Task({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
    required this.durationLabel,
    this.highlightColor,
    this.description,
    this.members,
    this.priority,
    this.taskColor,
    this.attachments,
    this.statusBoard,
  });

  Task copyWith({
    String? id,
    String? title,
    String? time,
    bool? isCompleted,
    String? durationLabel,
    Color? highlightColor,
    String? description,
    List<String>? members,
    String? priority,
    Color? taskColor,
    List<String>? attachments,
    String? statusBoard,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      durationLabel: durationLabel ?? this.durationLabel,
      highlightColor: highlightColor ?? this.highlightColor,
      description: description ?? this.description,
      members: members ?? this.members,
      priority: priority ?? this.priority,
      taskColor: taskColor ?? this.taskColor,
      attachments: attachments ?? this.attachments,
      statusBoard: statusBoard ?? this.statusBoard,
    );
  }
}

// --- REMOVIDO: void main() => runApp(const DetailsTaskPage());
// A função main() deve estar apenas no arquivo main.dart

// --- StatelessWidget: DetailsTaskPage (Responsável por receber o GeminiService) ---
class DetailsTaskPage extends StatelessWidget {
  final GeminiService geminiService; // Agora exige o GeminiService

  const DetailsTaskPage(
      {super.key, required this.geminiService}); // Construtor modificado

  @override
  Widget build(BuildContext context) {
    return TodayTaskPage(
        geminiService: geminiService); // Passa o serviço para TodayTaskPage
  }
}

// --- StatefulWidget: TodayTaskPage (Contém a lógica da UI e estado) ---
class TodayTaskPage extends StatefulWidget {
  final GeminiService geminiService; // Recebe o GeminiService

  const TodayTaskPage({super.key, required this.geminiService});

  @override
  State<TodayTaskPage> createState() => _TodayTaskPageState();
}

class _TodayTaskPageState extends State<TodayTaskPage>
    with TickerProviderStateMixin {
  late final GeminiService _geminiService;
  late FirestoreTasksService _firestoreService; // Usará o serviço recebido
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isCardVisible = false;

  late AnimationController _circleController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int _selectedDateIndex = 1;
  late Map<int, List<Task>> _tasksByDateIndex;
  TaskFilter _currentFilter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreTasksService(userId: 'userId');
    _geminiService = widget.geminiService; // Inicializa com o serviço recebido
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

    // --- Dados de Exemplo para Tarefas ---
    _tasksByDateIndex = {
      0: [
        Task(
          id: '1',
          title: 'Preparação para o fim de semana',
          time: '10:00 - 11:00',
          durationLabel: '1 hora',
          isCompleted: true,
          description:
              'Preparar para as atividades do fim de semana. Limpar a casa e planejar as refeições.',
          members: ['Alice', 'Bob'],
          priority: 'Média',
          taskColor: Colors.blue[300],
          attachments: ['plano.pdf'],
          statusBoard: 'Concluído',
        ),
        Task(
          id: '2',
          title: 'Compras na mercearia',
          time: '14:00 - 15:30',
          durationLabel: '1.5 horas',
          description:
              'Comprar mantimentos para a próxima semana. Verificar a lista antes de ir.',
          members: ['Alice'],
          priority: 'Alta',
          taskColor: Colors.green[300],
          statusBoard: 'Em Andamento',
        ),
      ],
      1: [
        Task(
          id: '3',
          title: 'Comprar um pacote de café',
          time: '10:30 - 11:00',
          durationLabel: '1 hora',
          isCompleted: true,
          description: 'Marca favorita de café da loja local.',
          priority: 'Baixa',
          statusBoard: 'Concluído',
        ),
        Task(
          id: '4',
          title: 'Adicionar novos parceiros',
          time: '11:30 - 13:30',
          durationLabel: '2 horas',
          highlightColor: kAccentPurple,
          description: 'Finalizar os email e adicionare membros ao projeto',
          members: ['Charlie', 'David'],
          priority: 'Alta',
          taskColor: kAccentPurple,
          attachments: ['agreement_v1.docx', 'contact_list.xlsx'],
          statusBoard: 'Urgente',
        ),
        Task(
          id: '5',
          title: 'Adicionar novos membros',
          time: '11:30 - 13:30',
          durationLabel: '2 horas',
          description: 'Acompanhamento com potenciais novos parceiros.',
          members: ['Eve'],
          priority: 'Média',
          statusBoard: 'Em Andamento',
        ),
        Task(
          id: '6',
          title: 'Meeting no trabalho',
          time: '15:00 - 15:30',
          durationLabel: '30 mins',
          description: 'Reunião de sincronização rápida com a equipe.',
          priority: 'Média',
          statusBoard: 'Em Andamento',
        ),
        Task(
          id: '7',
          title: 'Time de Futebol',
          time: '17:00 - 19:00',
          durationLabel: '2 horas',
          description: 'Jogar futebol com os amigos',
          priority: 'Baixa',
          statusBoard: 'Pendente',
        ),
        Task(
          id: '8',
          title: 'Novo projeto',
          time: '21:00 - 23:00',
          durationLabel: '2 horas',
          description: 'Pensar em um novo projeto',
          members: ['Alice', 'Bob', 'Charlie'],
          priority: 'Alta',
          statusBoard: 'Pendente',
        ),
      ],
      2: [
        Task(
          id: '9',
          title: 'Reunião da manhã',
          time: '09:00 - 09:15',
          durationLabel: '15 mins',
          description: 'Reunião Matinal.',
          priority: 'Alta',
          statusBoard: 'Concluído',
        ),
        Task(
          id: '10',
          title: 'Ligação com o cliente',
          time: '11:00 - 12:00',
          durationLabel: '1 hora',
          isCompleted: true,
          description: 'Discutir andamento do porjeto',
          members: ['David'],
          priority: 'Alta',
          taskColor: Colors.orange[300],
          statusBoard: 'Concluído',
        ),
      ],
      3: [], // No tasks for dates[3] - '22 Tue'
      4: [
        Task(
          id: '11',
          title: 'Rever o Design',
          time: '14:00 - 16:00',
          durationLabel: '2 horas',
          description: 'Rever o ultimo UI/UX designs.',
          members: ['Eve', 'Frank'],
          priority: 'Média',
          taskColor: Colors.teal[300],
          statusBoard: 'Em Andamento',
        ),
      ],
    };
  }

  @override
  void dispose() {
    _circleController.dispose();
    _slideController.dispose();
    _geminiService.close(); // Chame close no serviço Gemini
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pushNamed(routeName);
  }

  // --- Widgets de Construção da UI ---

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

  Widget _buildSlidingMenu() {
    return Positioned(
      bottom: 18,
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
              onTap: () {
                _navigateToRoute('/habitos');
              },
              child: _bottomBarIcon(Icons.home_rounded),
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
              child: _bottomBarIcon(Icons.book_outlined, isActive: true),
            ),
            InkWell(
              onTap: () {
                _navigateToRoute(
                    '/perfil'); // Corrigido de '/profile' para '/perfil'
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

  @override
  Widget build(BuildContext context) {
    final dates = [
      {'day': '19', 'week': 'Sat'},
      {'day': '20', 'week': 'Sun'},
      {'day': '21', 'week': 'Mon'},
      {'day': '22', 'week': 'Tue'},
      {'day': '23', 'week': 'Wed'},
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kDarkPrimaryBg,
      extendBody: true,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: AppBar(
            backgroundColor: kDarkPrimaryBg,
            title: const Text(
              'Today Task',
              style: TextStyle(fontSize: 24, color: kDarkTextPrimary),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: kDarkTextPrimary),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              // Adicione um botão para o filtro de tarefas
              PopupMenuButton<TaskFilter>(
                onSelected: (TaskFilter result) {
                  setState(() {
                    _currentFilter = result;
                  });
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<TaskFilter>>[
                  const PopupMenuItem<TaskFilter>(
                    value: TaskFilter.all,
                    child: Text('Todas as Tarefas',
                        style: TextStyle(color: kDarkTextPrimary)),
                  ),
                  const PopupMenuItem<TaskFilter>(
                    value: TaskFilter.completed,
                    child: Text('Tarefas Concluídas',
                        style: TextStyle(color: kDarkTextPrimary)),
                  ),
                  const PopupMenuItem<TaskFilter>(
                    value: TaskFilter.inProgress,
                    child: Text('Tarefas em Andamento',
                        style: TextStyle(color: kDarkTextPrimary)),
                  ),
                ],
                icon: const Icon(Icons.filter_list, color: kDarkTextPrimary),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                _animatedCircle(
                    20,
                    50,
                    6,
                    [
                      Colors.lightBlueAccent,
                      const Color.fromARGB(255, 243, 33, 208),
                    ],
                    0),
                _animatedCircle(
                    300,
                    60,
                    4,
                    [
                      const Color.fromARGB(164, 180, 34, 238),
                      Colors.deepPurpleAccent,
                    ],
                    1),
                _animatedCircle(
                    180,
                    50,
                    5,
                    [
                      Colors.amberAccent,
                      Colors.orange,
                    ],
                    2),
                _animatedCircle(
                    40,
                    45,
                    5,
                    [
                      Colors.pinkAccent,
                      const Color.fromARGB(255, 149, 226, 4),
                    ],
                    3),
                _animatedCircle(
                    310,
                    50,
                    8,
                    [
                      const Color.fromARGB(173, 36, 17, 204),
                      const Color.fromARGB(255, 218, 20, 20),
                    ],
                    4),
                _animatedCircle(
                    100,
                    30,
                    3,
                    [
                      const Color.fromARGB(255, 222, 87, 240),
                      const Color.fromARGB(255, 27, 112, 1),
                    ],
                    5),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  '${DateFormat('MMMM, d').format(DateTime.now())} ✍️',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kDarkTextPrimary,
                  ),
                ),
                Text(
                  '${(_tasksByDateIndex[_selectedDateIndex]?.length ?? 0)} task today',
                  style: const TextStyle(color: kDarkTextSecondary),
                ),
                const SizedBox(height: 28),
                _buildDateSelector(dates),
                const SizedBox(height: 24),
                Expanded(child: _buildTaskArea()),
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
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),
          if (_isCardVisible) _buildSlidingMenu(),
          Positioned(
            bottom: -26,
            right: -60,
            child: CloseableAiCard(
              geminiService: _geminiService,
              firestoreService: _firestoreService,
              scaleFactor: MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
              enableScroll: true,
            ),
          ),
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

  // Widget _iconCircle (não usado no código fornecido, mas mantido caso precise)
  Widget _iconCircle(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kAccentPurple.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: kDarkTextPrimary, size: 20),
    );
  }

  Widget _buildDateSelector(List<Map<String, String>> dates) {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final item = dates[index];
          final isSelected = index == _selectedDateIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDateIndex = index;
                });
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected ? kAccentPurple : kDarkElementBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['day']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? kDarkTextPrimary : kDarkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['week']!,
                      style: TextStyle(
                        color:
                            isSelected ? kDarkTextPrimary : kDarkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.taskColor != null)
            Container(
              width: 5,
              height: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: task.taskColor,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            const SizedBox(
                width: 5 + 8), // Espaço para alinhar se não houver barra de cor

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: task.highlightColor ?? kDarkSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        final tasks = _tasksByDateIndex[_selectedDateIndex]!;
                        final taskIndex = tasks.indexWhere(
                          (t) => t.id == task.id,
                        );
                        if (taskIndex != -1) {
                          tasks[taskIndex] = tasks[taskIndex].copyWith(
                            isCompleted: !tasks[taskIndex].isCompleted,
                          );
                        }
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked_outlined,
                        key: ValueKey<bool>(task.isCompleted),
                        color: task.isCompleted
                            ? kAccentPurple
                            : kDarkTextSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            color: kDarkTextPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor:
                                kDarkTextSecondary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.time,
                          style: const TextStyle(
                            color: kDarkTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: kDarkTextSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      print("View task: ${task.id}");
                      _showTaskDetailsPopup(
                        context,
                        task,
                        false,
                      ); // false for view mode
                    },
                    tooltip: "Visualizar",
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: kDarkTextSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      print("Edit task: ${task.id}");
                      _showTaskDetailsPopup(context, task, true);
                    },
                    tooltip: "Editar",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailsPopup(BuildContext context, Task task, bool isEditMode) {
    final TextEditingController titleController = TextEditingController(
      text: task.title,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: task.description ?? '',
    );
    final TextEditingController timeController = TextEditingController(
      text: task.time,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kDarkElementBg,
          title: Text(
            isEditMode ? "Editar Tarefa" : "Detalhes da Tarefa",
            style: const TextStyle(color: kDarkTextPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDetailRow(
                  "Título:",
                  isEditMode
                      ? TextField(
                          controller: titleController,
                          style: const TextStyle(color: kDarkTextPrimary),
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: kDarkTextSecondary),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kDarkBorder),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kAccentPurple),
                            ),
                          ),
                        )
                      : Text(task.title,
                          style: const TextStyle(
                              color: kDarkTextPrimary, fontSize: 16)),
                ),
                _buildDetailRow(
                  "Descrição:",
                  isEditMode
                      ? TextField(
                          controller: descriptionController,
                          style: const TextStyle(color: kDarkTextPrimary),
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: kDarkTextSecondary),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kDarkBorder),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kAccentPurple),
                            ),
                          ),
                        )
                      : Text(task.description ?? 'N/A',
                          style: const TextStyle(
                              color: kDarkTextPrimary, fontSize: 16)),
                ),
                _buildDetailRow(
                  "Horário:",
                  isEditMode
                      ? TextField(
                          controller: timeController,
                          style: const TextStyle(color: kDarkTextPrimary),
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: kDarkTextSecondary),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kDarkBorder),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kAccentPurple),
                            ),
                          ),
                        )
                      : Text(task.time,
                          style: const TextStyle(
                              color: kDarkTextPrimary, fontSize: 16)),
                ),
                _buildDetailRow("Duração:", task.durationLabel),
                _buildDetailRow(
                  "Prioridade:",
                  task.priority,
                  isChip: true,
                  chipColor: task.taskColor ?? kAccentPurple.withOpacity(0.3),
                ),
                _buildDetailRow(
                  "Status Board:",
                  task.statusBoard,
                  isChip: true,
                  chipColor: kAccentPurple.withOpacity(0.3),
                ),
                if (task.members != null && task.members!.isNotEmpty)
                  _buildDetailRow("Membros:", task.members!.join(', ')),
                if (task.attachments != null && task.attachments!.isNotEmpty)
                  _buildDetailRow("Anexos:", task.attachments!.join(', ')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Fechar",
                style: TextStyle(color: kAccentPurple),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            if (isEditMode)
              TextButton(
                child: const Text(
                  "Salvar",
                  style: TextStyle(color: kAccentPurple),
                ),
                onPressed: () {
                  // Lógica de salvar aqui
                  // Você precisará de uma forma de atualizar a lista de tarefas
                  // no estado de _TodayTaskPageState. Isso pode ser feito passando
                  // uma função de callback ou usando um gerenciador de estado.
                  // Por simplicidade, aqui apenas imprimimos os valores.

                  print("Salvar alterações para: ${task.id}");
                  print("Novo título: ${titleController.text}");
                  print("Nova descrição: ${descriptionController.text}");
                  print("Novo horário: ${timeController.text}");

                  // Exemplo de como você PODE querer atualizar o estado:
                  // setState(() {
                  //   final tasks = _tasksByDateIndex[_selectedDateIndex]!;
                  //   final taskIndex = tasks.indexWhere((t) => t.id == task.id);
                  //   if (taskIndex != -1) {
                  //     tasks[taskIndex] = tasks[taskIndex].copyWith(
                  //       title: titleController.text,
                  //       description: descriptionController.text,
                  //       time: timeController.text,
                  //     );
                  //   }
                  // });

                  Navigator.of(dialogContext).pop();
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    dynamic value, {
    bool isChip = false,
    Color? chipColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: kDarkTextSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          if (value is Widget)
            value // Permite passar um TextField diretamente
          else if (isChip && value is String)
            Chip(
              label: Text(
                value,
                style: const TextStyle(color: kDarkTextPrimary),
              ),
              backgroundColor: chipColor ?? kDarkSurface,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            )
          else
            Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(color: kDarkTextPrimary, fontSize: 16),
            ),
        ],
      ),
    );
  }

  // --- Método corrigido para filtrar e exibir tarefas ---
  Widget _buildTaskArea() {
    final allTasksForSelectedDate = _tasksByDateIndex[_selectedDateIndex] ?? [];
    List<Task> tasksForSelectedDate;

    switch (_currentFilter) {
      case TaskFilter.completed:
        tasksForSelectedDate =
            allTasksForSelectedDate.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.inProgress:
        tasksForSelectedDate =
            allTasksForSelectedDate.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.all: // Caso para "Todas as Tarefas"
      default: // Garante um fallback caso _currentFilter não seja nenhum dos acima
        tasksForSelectedDate = allTasksForSelectedDate;
        break;
    }

    if (tasksForSelectedDate.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma tarefa encontrada para esta data e filtro.',
          style: TextStyle(color: kDarkTextSecondary, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasksForSelectedDate.length,
      itemBuilder: (context, index) {
        final task = tasksForSelectedDate[index];
        return _buildTaskCard(task);
      },
    );
  }
}
