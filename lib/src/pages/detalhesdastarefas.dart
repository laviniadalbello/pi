import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';


enum TaskFilter { all, completed, inProgress }

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E); 
const Color kDarkElementBg = Color(0xFF202A44); 
const Color kAccentPurple = Color(0xFF7F5AF0); 
const Color kDarkTextPrimary = Color(0xFFFFFFFF); 
const Color kDarkTextSecondary = Color(0xFFA0AEC0); 

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
  final String? statusBoard; // Ex: "Urgente", "Em Andamento", "Concluído"

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

void main() => runApp(const DetailsTaskPage());

class DetailsTaskPage extends StatelessWidget {
  const DetailsTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Today Task',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: TodayTaskPage(),
    );
  }
}

class TodayTaskPage extends StatefulWidget {
  const TodayTaskPage({super.key});

  @override
  State<TodayTaskPage> createState() => _TodayTaskPageState();
}

class _TodayTaskPageState extends State<TodayTaskPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isCardVisible = false; // For the floating card menu

  late AnimationController _circleController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  
  int _selectedDateIndex = 1; (e.g., '20 Sun' to match image)
  late Map<int, List<Task>> _tasksByDateIndex;
  TaskFilter _currentFilter = TaskFilter.all; 

  @override
  void initState() {
    super.initState();
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

    
    _tasksByDateIndex = {
      0: [ // Tasks for dates[0] - '19 Sat'
        Task(
          id: '1', title: 'Weekend Prep', time: '10:00 - 11:00', durationLabel: '1 hour', isCompleted: true,
          description: 'Prepare for the weekend activities. Clean the house, plan meals.',
          members: ['Alice', 'Bob'], priority: 'Média', taskColor: Colors.blue[300],
          attachments: ['plan.pdf'], statusBoard: 'Concluído',
        ),
        Task(
          id: '2', title: 'Grocery Shopping', time: '14:00 - 15:30', durationLabel: '1.5 hr',
          description: 'Buy groceries for the next week. Check the list before going.',
          members: ['Alice'], priority: 'Alta', taskColor: Colors.green[300],
          statusBoard: 'Em Andamento',
        ),
      ],
      1: [ // Tasks for dates[1] - '20 Sun' (example from image)
        Task(
          id: '3', title: 'Buy a pack of coffee', time: '10:30 - 11:00', durationLabel: '1 hour', isCompleted: true,
          description: 'Favorite brand of coffee from the local store.',
          priority: 'Baixa', statusBoard: 'Concluído',
        ),
        Task(
          id: '4', title: 'Add new partners', time: '11:30 - 13:30', durationLabel: '2 hours', highlightColor: kAccentPurple,
          description: 'Finalize partnership agreements and send emails.',
          members: ['Charlie', 'David'], priority: 'Alta', taskColor: kAccentPurple,
          attachments: ['agreement_v1.docx', 'contact_list.xlsx'], statusBoard: 'Urgente',
        ),
        Task(
          id: '5', title: 'Add new partners', time: '11:30 - 13:30', durationLabel: '2 hours',
          description: 'Follow up with potential new partners.', // Different description for the second 'Add new partners'
          members: ['Eve'], priority: 'Média', 
          statusBoard: 'Em Andamento',
        ),
        Task(id: '6', title: 'Meeting on work', time: '15:00 - 15:30', durationLabel: '30 mins', description: 'Quick sync meeting with the team.', priority: 'Média', statusBoard: 'Em Andamento'),
        Task(id: '7', title: 'Team Football', time: '17:00 - 19:00', durationLabel: '2 hours', description: 'Friendly football match.', priority: 'Baixa', statusBoard: 'Pendente'),
        Task(id: '8', title: 'New project', time: '21:00 - 23:00', durationLabel: '2 hours', description: 'Kick off new project planning.', members: ['Alice', 'Bob', 'Charlie'], priority: 'Alta', statusBoard: 'Pendente'),
      ],
      2: [ // Tasks for dates[2] - '21 Mon'
        Task(
          id: '9', title: 'Morning Standup', time: '09:00 - 09:15', durationLabel: '15 mins',
          description: 'Daily standup meeting.', priority: 'Alta', statusBoard: 'Concluído',
        ),
        Task(
          id: '10', title: 'Client Call', time: '11:00 - 12:00', durationLabel: '1 hour', isCompleted: true,
          description: 'Discuss project updates with the client.', members: ['David'], priority: 'Alta', taskColor: Colors.orange[300],
          statusBoard: 'Concluído',
        ),
      ],
      3: [], // No tasks for dates[3] - '22 Tue'
      4: [ // Tasks for dates[4] - '23 Wed'
        Task(
          id: '11', title: 'Design Review', time: '14:00 - 16:00', durationLabel: '2 hours',
          description: 'Review the latest UI/UX designs.', members: ['Eve', 'Frank'], priority: 'Média', taskColor: Colors.teal[300],
          statusBoard: 'Em Andamento',
        ),
      ],
    };
  }

  @override
  void dispose() {
    _circleController.dispose();
    _slideController.dispose();
    super.dispose();
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

    // _buildTaskArea
    //currentTasks = _tasksByDateIndex[_selectedDateIndex] ?? [];
    // final taskCountString = currentTasks.isEmpty ? "No tasks today" : "${currentTasks.length} task${currentTasks.length == 1 ? '' : 's'} today";

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
              onPressed: () {Navigator.of(context).pop();},
            ),
            actions: [
              // _iconCircle(Icons.calendar_today_outlined), 
              // _iconCircle(Icons.edit), 
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack( 
              children: [
                _animatedCircle(20, 50, 6, [Colors.lightBlueAccent, const Color.fromARGB(255, 243, 33, 208)], 0),
                _animatedCircle(300, 60, 4, [const Color.fromARGB(164, 180, 34, 238), Colors.deepPurpleAccent], 1),
                _animatedCircle(180, 50, 5, [Colors.amberAccent, Colors.orange], 2),
                _animatedCircle(40, 45, 5, [Colors.pinkAccent, const Color.fromARGB(255, 149, 226, 4)], 3),
                _animatedCircle(310, 50, 8, [const Color.fromARGB(173, 36, 17, 204), const Color.fromARGB(255, 218, 20, 20)], 4),
                _animatedCircle(100, 30, 3, [const Color.fromARGB(255, 222, 87, 240), const Color.fromARGB(255, 27, 112, 1)], 5),
              ],
            ),
          ),
          Padding( // Main content area
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
                const Text(
                  '15 task today',
                  style: TextStyle(color: kDarkTextSecondary),
                ),
                const SizedBox(height: 28),
                _buildDateSelector(dates),
                const SizedBox(height: 24),
                Expanded(child: _buildTaskArea()),
              ],
            ),
          ),
          if (_isCardVisible)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCardVisible = false;
                  _slideController.reverse();
                });
              },
              child: Container(color: Colors.black54),
            ),
          if (_isCardVisible)
            Positioned(
              bottom: 70, // Ajustado de 20 para 70 para subir o card
              left: 30,
              right: 30,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildFloatingCard(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _animatedCircle(double x, double y, double size, List<Color> colors, int index) {
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
                        color: isSelected ? kDarkTextPrimary : kDarkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['week']!,
                      style: TextStyle(
                        color: isSelected ? kDarkTextPrimary : kDarkTextSecondary,
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
            const SizedBox(width: 5 + 8), 
          Container(
            width: 60,
            padding: const EdgeInsets.only(top: 4.0), 
            child: Text(
              task.durationLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kDarkTextSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
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
                        // Encontrar e atualizar a tarefa específica
                        final tasks = _tasksByDateIndex[_selectedDateIndex]!;
                        final taskIndex = tasks.indexWhere((t) => t.id == task.id);
                        if (taskIndex != -1) {
                          tasks[taskIndex] = tasks[taskIndex].copyWith(isCompleted: !tasks[taskIndex].isCompleted);
                        }
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked_outlined,
                        key: ValueKey<bool>(task.isCompleted), // Chave para o AnimatedSwitcher funcionar corretamente
                        color: task.isCompleted ? kAccentPurple : kDarkTextSecondary,
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
                            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: kDarkTextSecondary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.time,
                          style: const TextStyle(color: kDarkTextSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Add Edit and View buttons
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, color: kDarkTextSecondary, size: 20),
                    onPressed: () {
                      // Placeholder for view action
                      print("View task: ${task.id}");
                      _showTaskDetailsPopup(context, task, false); // false for view mode
                    },
                    tooltip: "Visualizar",
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: kDarkTextSecondary, size: 20),
                    onPressed: () {
                      // Placeholder for edit action
                      print("Edit task: ${task.id}");
                      _showTaskDetailsPopup(context, task, true); // true for edit mode
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
  final TextEditingController titleController = TextEditingController(text: task.title);
  final TextEditingController descriptionController = TextEditingController(text: task.description ?? '');
  final TextEditingController timeController = TextEditingController(text: task.time)

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: kDarkElementBg,
        title: Text(isEditMode ? "Editar Tarefa" : "Detalhes da Tarefa", style: const TextStyle(color: kDarkTextPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDetailRow("Título:", isEditMode ? TextField(controller: titleController, style: const TextStyle(color: kDarkTextPrimary), decoration: const InputDecoration(hintStyle: TextStyle(color: kDarkTextSecondary))) : task.title),
              _buildDetailRow("Descrição:", isEditMode ? TextField(controller: descriptionController, style: const TextStyle(color: kDarkTextPrimary), maxLines: 3, decoration: const InputDecoration(hintStyle: TextStyle(color: kDarkTextSecondary))) : task.description),
              _buildDetailRow("Horário:", isEditMode ? TextField(controller: timeController, style: const TextStyle(color: kDarkTextPrimary), decoration: const InputDecoration(hintStyle: TextStyle(color: kDarkTextSecondary))) : task.time),
              _buildDetailRow("Duração:", task.durationLabel),
              _buildDetailRow("Prioridade:", task.priority, isChip: true, chipColor: task.taskColor ?? kAccentPurple.withOpacity(0.3)),
              _buildDetailRow("Status Board:", task.statusBoard, isChip: true, chipColor: kAccentPurple.withOpacity(0.3)),
              if (task.members != null && task.members!.isNotEmpty)
                _buildDetailRow("Membros:", task.members!.join(', ')),
              if (task.attachments != null && task.attachments!.isNotEmpty)
                _buildDetailRow("Anexos:", task.attachments!.join(', ')),
              // Add more fields here: members, taskColor, attachments etc.
              // For editable fields, use TextField, DropdownButton, etc.
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Fechar", style: TextStyle(color: kAccentPurple)),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          if (isEditMode)
            TextButton(
              child: const Text("Salvar", style: TextStyle(color: kAccentPurple)),
              onPressed: () {
                // Implementar a lógica aqui
                 _TodayTaskPageState.setState, so this popup
                 StatefulWidget or passed a callback.
                print("Salvar alterações para: ${task.id}");
                print("Novo título: ${titleController.text}");
                // Example of how to update (needs access to _tasksByDateIndex and setState):
                // final taskIndex = _tasksByDateIndex[_selectedDateIndex]!.indexWhere((t) => t.id == task.id);
                // if (taskIndex != -1) {
                //   _tasksByDateIndex[_selectedDateIndex]![taskIndex] = task.copyWith(
                //     title: titleController.text,
                //     description: descriptionController.text,
                //     time: timeController.text,
                //     
                //   );
                //   // Call setState in the parent widget
                // }
                Navigator.of(dialogContext).pop();
              },
            ),
        ],
      );
    },
  );
}

Widget _buildDetailRow(String label, dynamic value, {bool isChip = false, Color? chipColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kDarkTextSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        if (value is Widget) 
          value 
        else if (isChip && value is String)
          Chip(
            label: Text(value, style: const TextStyle(color: kDarkTextPrimary)),
            backgroundColor: chipColor ?? kDarkSurface,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          )
        else
          Text(value?.toString() ?? 'N/A', style: const TextStyle(color: kDarkTextPrimary, fontSize: 16)),
      ],
    ),
  );
}

  Widget _buildTaskArea() {
    final allTasksForSelectedDate = _tasksByDateIndex[_selectedDateIndex] ?? [];
    List<Task> tasksForSelectedDate;

    switch (_currentFilter) {
      case TaskFilter.completed:
        tasksForSelectedDate = allTasksForSelectedDate.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.inProgress:
        tasksForSelectedDate = allTasksForSelectedDate.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.all:
      default:
        tasksForSelectedDate = allTasksForSelectedDate;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Minhas tarefas do dia",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kDarkTextPrimary,
                ),
              ),
              PopupMenuButton<TaskFilter>(
                icon: const Icon(Icons.more_vert, color: kDarkTextSecondary),
                onSelected: (TaskFilter result) {
                  setState(() {
                    _currentFilter = result;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<TaskFilter>>[
                  const PopupMenuItem<TaskFilter>(
                    value: TaskFilter.all,
                    child: Text('Todas'),
                  ),
                  const PopupMenuItem<TaskFilter>(
                    value: TaskFilter.completed,
                    child: Text('Concluídas'),
                  ),
                  const PopupMenuItem<TaskFilter>(
                    value: TaskFilter.inProgress,
                    child: Text('Em Andamento'),
                  ),
                ],
                color: kDarkElementBg, // Background color for the popup menu
              ),
            ],
          ),
        ),
        if (tasksForSelectedDate.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentFilter == TaskFilter.all ? "Nenhuma tarefa para este dia." : "Nenhuma tarefa encontrada com este filtro.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kDarkTextSecondary, fontSize: 16),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Ensure space for FAB/BottomNav
              itemCount: tasksForSelectedDate.length,
              itemBuilder: (context, index) {
                return _buildTaskCard(tasksForSelectedDate[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingCard() {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
            _menuItem(Icons.edit_outlined, 'Create Task'),
            const SizedBox(height: 12),
            _menuItem(Icons.add_circle_outline, 'Create Project'),
            const SizedBox(height: 12),
            _menuItem(Icons.group_outlined, 'Create Team'),
            const SizedBox(height: 12),
            _menuItem(Icons.schedule_outlined, 'Create Event'),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCardVisible = false;
                  _slideController.reverse();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: kAccentPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: kDarkTextPrimary),
              ),
            ),
          ],
        ),
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
      color: kDarkElementBg,
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
                  color: kAccentPurple,
                  onPressed: () {},
                ),
                const SizedBox(width: 28),
                IconButton(
                  icon: const Icon(Icons.folder_rounded),
                  color: kDarkTextSecondary.withOpacity(0.7),
                  onPressed: () {},
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: kDarkTextSecondary.withOpacity(0.7),
                  onPressed: () {},
                ),
                const SizedBox(width: 28),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  color: kDarkTextSecondary.withOpacity(0.7), // Changed from Colors.white30 for consistency
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

