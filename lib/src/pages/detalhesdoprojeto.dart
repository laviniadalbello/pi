import 'package:flutter/material.dart';
import 'iconedaia.dart';
import 'package:planify/services/gemini_service.dart'; 
import 'package:planify/services/firestore_tasks_service.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class TrelloCard {
  String id;
  String title;
  List<TrelloTask> tasks;
  Color color;

  TrelloCard({
    required this.id,
    required this.title,
    required this.tasks,
    this.color = kAccentPurple,
  });
}

class TrelloTask {
  String id;
  String title;
  bool isCompleted;
  DateTime? dueDate;
  List<String> members;
  String? description;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? priority;
  String? status;
  List<String>? attachments;
  bool isDetailed;

  TrelloTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.members = const [],
    this.description,
    this.startTime,
    this.endTime,
    this.priority,
    this.status,
    this.attachments,
    this.isDetailed = false,
  });
}

class Detalhesdoprojeto extends StatefulWidget {
  final GeminiService geminiService;
  const Detalhesdoprojeto({super.key, required this.geminiService});


  @override
  State<Detalhesdoprojeto> createState() => _DetalhesdoprojetoState();
}

class _DetalhesdoprojetoState extends State<Detalhesdoprojeto> {
  late FirestoreTasksService _firestoreService;
  List<TrelloCard> cards = [
    TrelloCard(
      id: '1',
      title: 'Tarefas em Andamento',
      color: kAccentPurple,
      tasks: [
        TrelloTask(
          id: '1',
          title: 'Implementar tela de login',
          members: ['Ana', 'Carlos'],
          dueDate: DateTime.now().add(const Duration(days: 2)),
          description:
              'Criar tela de login com validação de campos e integração com API',
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 12, minute: 0),
          priority: 'Alta',
          status: 'Em Andamento',
          attachments: ['login_mockup.png', 'api_docs.pdf'],
          isDetailed: true,
        ),
        TrelloTask(
          id: '2',
          title: 'Criar componentes reutilizáveis',
          members: ['Bruno'],
        ),
        TrelloTask(
          id: '3',
          title: 'Revisar pull requests',
          members: ['Ana', 'Diego'],
          dueDate: DateTime.now().add(const Duration(days: 1)),
          description: 'Revisar e aprovar PRs pendentes no GitHub',
          startTime: const TimeOfDay(hour: 14, minute: 0),
          endTime: const TimeOfDay(hour: 16, minute: 0),
          priority: 'Média',
          status: 'Em Andamento',
          isDetailed: true,
        ),
      ],
    ),
    TrelloCard(
      id: '2',
      title: 'Concluídas',
      color: kAccentSecondary,
      tasks: [
        TrelloTask(
          id: '4',
          title: 'Setup do projeto',
          isCompleted: true,
          members: ['Carlos'],
          description: 'Configurar ambiente de desenvolvimento e dependências',
          startTime: const TimeOfDay(hour: 8, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          priority: 'Alta',
          status: 'Concluída',
          attachments: ['setup_guide.md'],
          isDetailed: true,
        ),
        TrelloTask(
          id: '5',
          title: 'Definir paleta de cores',
          isCompleted: true,
          members: ['Ana'],
        ),
      ],
    ),
  ];

  final TextEditingController _newTaskController = TextEditingController();
  final TextEditingController _renameCardController = TextEditingController();
  final TextEditingController _editTaskTitleController =
      TextEditingController();
  final TextEditingController _editTaskDescriptionController =
      TextEditingController();
  final TextEditingController _newCardController = TextEditingController();

  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _selectedPriority;
  String? _selectedStatus;
  List<String> _selectedMembers = [];
  List<String> _selectedAttachments = [];

   @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreTasksService(userId: 'userId'); 
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    _renameCardController.dispose();
    _editTaskTitleController.dispose();
    _editTaskDescriptionController.dispose();
    _newCardController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addTask(String cardId) {
    if (_newTaskController.text.trim().isEmpty) return;

    setState(() {
      final cardIndex = cards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        cards[cardIndex].tasks.add(
              TrelloTask(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _newTaskController.text.trim(),
                isDetailed: false,
              ),
            );
      }
    });
    _newTaskController.clear();
    Navigator.pop(context);
  }

  void _renameCard(String cardId) {
    if (_renameCardController.text.trim().isEmpty) return;

    setState(() {
      final cardIndex = cards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        cards[cardIndex].title = _renameCardController.text.trim();
      }
    });
    _renameCardController.clear();
    Navigator.pop(context);
  }

  void _addCard() {
    if (_newCardController.text.trim().isEmpty) return;

    setState(() {
      cards.add(
        TrelloCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _newCardController.text.trim(),
          tasks: [],
        ),
      );
    });
    _newCardController.clear();
    Navigator.pop(context);
  }

  void _deleteCard(String cardId) {
    setState(() {
      cards.removeWhere((card) => card.id == cardId);
    });
  }

  void _deleteTask(String cardId, String taskId) {
    setState(() {
      final cardIndex = cards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        cards[cardIndex].tasks.removeWhere((task) => task.id == taskId);
      }
    });
  }

  void _toggleTaskCompletion(String cardId, String taskId) {
    setState(() {
      final cardIndex = cards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final taskIndex = cards[cardIndex].tasks.indexWhere(
              (task) => task.id == taskId,
            );
        if (taskIndex != -1) {
          cards[cardIndex].tasks[taskIndex].isCompleted =
              !cards[cardIndex].tasks[taskIndex].isCompleted;

          // Atualiza o status se for uma tarefa detalhada
          if (cards[cardIndex].tasks[taskIndex].isDetailed) {
            cards[cardIndex].tasks[taskIndex].status =
                cards[cardIndex].tasks[taskIndex].isCompleted
                    ? 'Concluída'
                    : 'Em Andamento';
          }
        }
      }
    });
  }

  // Método para editar uma tarefa simples - quando a tarefa foi adicionada no modo simples ela vai ser editada por esse metodo
  void _editSimpleTask(String cardId, String taskId) {
    if (_editTaskTitleController.text.trim().isEmpty) return;

    setState(() {
      final cardIndex = cards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final taskIndex = cards[cardIndex].tasks.indexWhere(
              (task) => task.id == taskId,
            );
        if (taskIndex != -1) {
          cards[cardIndex].tasks[taskIndex].title =
              _editTaskTitleController.text.trim();
        }
      }
    });
    _editTaskTitleController.clear();
    Navigator.pop(context);
  }

  // Método para editar uma tarefa detalhada , quando a tarefa e adiconada pela tela adicionar tarefa aonde tem descricao, ela e editada aqui
  void _editDetailedTask(String cardId, String taskId) {
    if (_editTaskTitleController.text.trim().isEmpty) return;

    setState(() {
      final cardIndex = cards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        final taskIndex = cards[cardIndex].tasks.indexWhere(
              (task) => task.id == taskId,
            );
        if (taskIndex != -1) {
          cards[cardIndex].tasks[taskIndex].title =
              _editTaskTitleController.text.trim();
          cards[cardIndex].tasks[taskIndex].description =
              _editTaskDescriptionController.text.trim();
          cards[cardIndex].tasks[taskIndex].priority = _selectedPriority;
          cards[cardIndex].tasks[taskIndex].status = _selectedStatus;
          cards[cardIndex].tasks[taskIndex].members = _selectedMembers;
          cards[cardIndex].tasks[taskIndex].attachments = _selectedAttachments;
          if (_startTimeController.text.isNotEmpty &&
              _endTimeController.text.isNotEmpty) {
            //implementaria a lógica para converter os textos em TimeOfDay
          }
        }
      }
    });

    _editTaskTitleController.clear();
    _editTaskDescriptionController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _durationController.clear();
    _selectedPriority = null;
    _selectedStatus = null;
    _selectedMembers = [];
    _selectedAttachments = [];

    Navigator.pop(context);
  }

  void _moveTaskToCard(
    String sourceCardId,
    String taskId,
    String targetCardId,
  ) {
    if (sourceCardId == targetCardId) return;

    setState(() {
      final sourceCardIndex = cards.indexWhere(
        (card) => card.id == sourceCardId,
      );
      if (sourceCardIndex == -1) return;

      final taskIndex = cards[sourceCardIndex].tasks.indexWhere(
            (task) => task.id == taskId,
          );
      if (taskIndex == -1) return;

      final task = cards[sourceCardIndex].tasks[taskIndex];
      cards[sourceCardIndex].tasks.removeAt(taskIndex);

      final targetCardIndex = cards.indexWhere(
        (card) => card.id == targetCardId,
      );
      if (targetCardIndex != -1) {
        cards[targetCardIndex].tasks.add(task);
      }
    });
  }

  void _navigateToAddTaskPage(String cardId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegando para AddTaskPage (simulação)'),
        backgroundColor: kAccentPurple,
      ),
    );

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AddTaskPage(cardId: cardId),
    //   ),
    // );
  }

  void _showAddTaskDialog(String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkElementBg,
        title: const Text(
          'Adicionar Tarefa',
          style: TextStyle(color: kDarkTextPrimary),
        ),
        content: TextField(
          controller: _newTaskController,
          style: const TextStyle(color: kDarkTextPrimary),
          decoration: const InputDecoration(
            hintText: 'Nome da tarefa',
            hintStyle: TextStyle(color: kDarkTextSecondary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: kDarkTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () => _addTask(cardId),
            child: const Text(
              'Adicionar',
              style: TextStyle(color: kAccentPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameCardDialog(TrelloCard card) {
    _renameCardController.text = card.title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkElementBg,
        title: const Text(
          'Renomear Cartão',
          style: TextStyle(color: kDarkTextPrimary),
        ),
        content: TextField(
          controller: _renameCardController,
          style: const TextStyle(color: kDarkTextPrimary),
          decoration: const InputDecoration(
            hintText: 'Nome do cartão',
            hintStyle: TextStyle(color: kDarkTextSecondary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: kDarkTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () => _renameCard(card.id),
            child: const Text(
              'Renomear',
              style: TextStyle(color: kAccentPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkElementBg,
        title: const Text(
          'Adicionar Cartão',
          style: TextStyle(color: kDarkTextPrimary),
        ),
        content: TextField(
          controller: _newCardController,
          style: const TextStyle(color: kDarkTextPrimary),
          decoration: const InputDecoration(
            hintText: 'Nome do cartão',
            hintStyle: TextStyle(color: kDarkTextSecondary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: kDarkTextSecondary),
            ),
          ),
          TextButton(
            onPressed: _addCard,
            child: const Text(
              'Adicionar',
              style: TextStyle(color: kAccentPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showSimpleEditTaskDialog(String cardId, TrelloTask task) {
    _editTaskTitleController.text = task.title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkElementBg,
        title: const Text(
          'Editar Tarefa',
          style: TextStyle(color: kDarkTextPrimary),
        ),
        content: TextField(
          controller: _editTaskTitleController,
          style: const TextStyle(color: kDarkTextPrimary),
          decoration: const InputDecoration(
            hintText: 'Nome da tarefa',
            hintStyle: TextStyle(color: kDarkTextSecondary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: kDarkTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () => _editSimpleTask(cardId, task.id),
            child: const Text(
              'Salvar',
              style: TextStyle(color: kAccentPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedEditTaskDialog(String cardId, TrelloTask task) {
    // Inicializar controladores com valores existentes
    _editTaskTitleController.text = task.title;
    _editTaskDescriptionController.text = task.description ?? '';

    if (task.startTime != null) {
      _startTimeController.text =
          '${task.startTime!.hour}:${task.startTime!.minute.toString().padLeft(2, '0')}';
    }

    if (task.endTime != null) {
      _endTimeController.text =
          '${task.endTime!.hour}:${task.endTime!.minute.toString().padLeft(2, '0')}';
    }

    if (task.startTime != null && task.endTime != null) {
      final startMinutes = task.startTime!.hour * 60 + task.startTime!.minute;
      final endMinutes = task.endTime!.hour * 60 + task.endTime!.minute;
      final durationMinutes = endMinutes - startMinutes;

      if (durationMinutes > 0) {
        final hours = durationMinutes ~/ 60;
        final minutes = durationMinutes % 60;
        _durationController.text = hours > 0
            ? '$hours h ${minutes > 0 ? '$minutes min' : ''}'
            : '$minutes min';
      }
    }

    _selectedPriority = task.priority;
    _selectedStatus = task.status;
    _selectedMembers = List.from(task.members);
    _selectedAttachments =
        task.attachments != null ? List.from(task.attachments!) : [];

    // Lista de prioridades e status para os dropdowns
    final priorities = ['Baixa', 'Média', 'Alta', 'Urgente'];
    final statuses = ['Pendente', 'Em Andamento', 'Em Revisão', 'Concluída'];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: kDarkElementBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabeçalho do diálogo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: kDarkSurface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: kAccentPurple),
                      const SizedBox(width: 8),
                      const Text(
                        'Editar Tarefa',
                        style: TextStyle(
                          color: kDarkTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: kDarkTextSecondary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        const Text(
                          'Título',
                          style: TextStyle(
                            color: kDarkTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _editTaskTitleController,
                          style: const TextStyle(color: kDarkTextPrimary),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kDarkSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Título da tarefa',
                            hintStyle: TextStyle(
                              color: kDarkTextSecondary.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Descrição
                        const Text(
                          'Descrição',
                          style: TextStyle(
                            color: kDarkTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _editTaskDescriptionController,
                          style: const TextStyle(color: kDarkTextPrimary),
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kDarkSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Descrição da tarefa',
                            hintStyle: TextStyle(
                              color: kDarkTextSecondary.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Horários
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Horário de Início',
                                    style: TextStyle(
                                      color: kDarkTextSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _startTimeController,
                                    style: const TextStyle(
                                      color: kDarkTextPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: kDarkSurface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintText: 'HH:MM',
                                      hintStyle: TextStyle(
                                        color: kDarkTextSecondary.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      suffixIcon: const Icon(
                                        Icons.access_time,
                                        color: kDarkTextSecondary,
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      final TimeOfDay? picked =
                                          await showTimePicker(
                                        context: context,
                                        initialTime:
                                            task.startTime ?? TimeOfDay.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData.dark().copyWith(
                                              colorScheme:
                                                  const ColorScheme.dark(
                                                primary: kAccentPurple,
                                                onPrimary: kDarkTextPrimary,
                                                surface: kDarkSurface,
                                                onSurface: kDarkTextPrimary,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _startTimeController.text =
                                              '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Horário de Fim',
                                    style: TextStyle(
                                      color: kDarkTextSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _endTimeController,
                                    style: const TextStyle(
                                      color: kDarkTextPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: kDarkSurface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintText: 'HH:MM',
                                      hintStyle: TextStyle(
                                        color: kDarkTextSecondary.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      suffixIcon: const Icon(
                                        Icons.access_time,
                                        color: kDarkTextSecondary,
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      final TimeOfDay? picked =
                                          await showTimePicker(
                                        context: context,
                                        initialTime:
                                            task.endTime ?? TimeOfDay.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData.dark().copyWith(
                                              colorScheme:
                                                  const ColorScheme.dark(
                                                primary: kAccentPurple,
                                                onPrimary: kDarkTextPrimary,
                                                surface: kDarkSurface,
                                                onSurface: kDarkTextPrimary,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _endTimeController.text =
                                              '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Duração
                        const Text(
                          'Duração',
                          style: TextStyle(
                            color: kDarkTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _durationController,
                          style: const TextStyle(color: kDarkTextPrimary),
                          enabled: false,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kDarkSurface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Calculado automaticamente',
                            hintStyle: TextStyle(
                              color: kDarkTextSecondary.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Prioridade
                        const Text(
                          'Prioridade',
                          style: TextStyle(
                            color: kDarkTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: kDarkSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedPriority,
                              hint: Text(
                                'Selecione a prioridade',
                                style: TextStyle(
                                  color: kDarkTextSecondary.withOpacity(0.5),
                                ),
                              ),
                              dropdownColor: kDarkSurface,
                              style: const TextStyle(color: kDarkTextPrimary),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: kDarkTextSecondary,
                              ),
                              items: priorities.map((String priority) {
                                return DropdownMenuItem<String>(
                                  value: priority,
                                  child: Text(priority),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPriority = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status
                        const Text(
                          'Status',
                          style: TextStyle(
                            color: kDarkTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: kDarkSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedStatus,
                              hint: Text(
                                'Selecione o status',
                                style: TextStyle(
                                  color: kDarkTextSecondary.withOpacity(0.5),
                                ),
                              ),
                              dropdownColor: kDarkSurface,
                              style: const TextStyle(color: kDarkTextPrimary),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: kDarkTextSecondary,
                              ),
                              items: statuses.map((String status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStatus = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Membros
                        const Text(
                          'Membros',
                          style: TextStyle(
                            color: kDarkTextSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._selectedMembers.map(
                              (member) => Chip(
                                backgroundColor: kDarkSurface,
                                label: Text(
                                  member,
                                  style: const TextStyle(
                                    color: kDarkTextPrimary,
                                  ),
                                ),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: kDarkTextSecondary,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selectedMembers.remove(member);
                                  });
                                },
                              ),
                            ),
                            ActionChip(
                              backgroundColor: kDarkSurface,
                              label: const Icon(
                                Icons.add,
                                size: 20,
                                color: kDarkTextSecondary,
                              ),
                              onPressed: () {
                                // Aqui você implementaria a lógica para adicionar membros
                                // Por simplicidade, estamos apenas adicionando um membro fictício
                                setState(() {
                                  final newMember =
                                      'Novo Membro ${_selectedMembers.length + 1}';
                                  if (!_selectedMembers.contains(newMember)) {
                                    _selectedMembers.add(newMember);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Anexos
                        if (task.attachments != null &&
                            task.attachments!.isNotEmpty) ...[
                          const Text(
                            'Anexos',
                            style: TextStyle(
                              color: kDarkTextSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...task.attachments!.map(
                                (attachment) => Chip(
                                  backgroundColor: kDarkSurface,
                                  avatar: const Icon(
                                    Icons.attach_file,
                                    size: 18,
                                    color: kDarkTextSecondary,
                                  ),
                                  label: Text(
                                    attachment,
                                    style: const TextStyle(
                                      color: kDarkTextPrimary,
                                    ),
                                  ),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: kDarkTextSecondary,
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedAttachments.remove(
                                        attachment,
                                      );
                                    });
                                  },
                                ),
                              ),
                              ActionChip(
                                backgroundColor: kDarkSurface,
                                avatar: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: kDarkTextSecondary,
                                ),
                                label: const Text(
                                  'Adicionar',
                                  style: TextStyle(color: kDarkTextSecondary),
                                ),
                                onPressed: () {
                                  // lógica para adicionar anexos

                                  setState(() {
                                    final newAttachment =
                                        'novo_anexo_${_selectedAttachments.length + 1}.pdf';
                                    if (!_selectedAttachments.contains(
                                      newAttachment,
                                    )) {
                                      _selectedAttachments.add(newAttachment);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: kDarkSurface,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: kDarkTextSecondary,
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _editDetailedTask(cardId, task.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentPurple,
                          foregroundColor: kDarkTextPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTaskDetailsDialog(String cardId, TrelloTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkElementBg,
        title: Text(
          task.title,
          style: const TextStyle(color: kDarkTextPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.dueDate != null) ...[
              const Text(
                'Data de Entrega:',
                style: TextStyle(
                  color: kDarkTextSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                style: const TextStyle(color: kDarkTextPrimary),
              ),
              const SizedBox(height: 12),
            ],
            if (task.members.isNotEmpty) ...[
              const Text(
                'Membros:',
                style: TextStyle(
                  color: kDarkTextSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: task.members
                    .map(
                      (member) => Chip(
                        backgroundColor: kDarkSurface,
                        label: Text(
                          member,
                          style: const TextStyle(
                            color: kDarkTextPrimary,
                          ),
                        ),
                        avatar: CircleAvatar(
                          backgroundColor: kAccentPurple,
                          child: Text(
                            member[0].toUpperCase(),
                            style: const TextStyle(
                              color: kDarkTextPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(color: kDarkTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (task.isDetailed) {
                _showDetailedEditTaskDialog(cardId, task);
              } else {
                _showSimpleEditTaskDialog(cardId, task);
              }
            },
            child: const Text(
              'Editar',
              style: TextStyle(color: kAccentPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showCardOptionsMenu(BuildContext context, TrelloCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkElementBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add, color: kDarkTextSecondary),
              title: const Text(
                'Adicionar Tarefa',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddTaskDialog(card.id);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.add_task,
                color: kDarkTextSecondary,
              ),
              title: const Text(
                'Adicionar Tarefa Detalhada',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddTaskPage(card.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: kDarkTextSecondary),
              title: const Text(
                'Renomear Cartão',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _showRenameCardDialog(card);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Excluir Cartão',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteCard(card.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskOptionsMenu(
    BuildContext context,
    String cardId,
    TrelloTask task,
  ) {
    final List<Widget> moveOptions = cards
        .where((card) => card.id != cardId)
        .map(
          (card) => ListTile(
            leading: const Icon(
              Icons.arrow_forward,
              color: kDarkTextSecondary,
            ),
            title: Text(
              'Mover para ${card.title}',
              style: const TextStyle(color: kDarkTextPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              _moveTaskToCard(cardId, task.id, card.id);
            },
          ),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkElementBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.visibility,
                  color: kDarkTextSecondary,
                ),
                title: const Text(
                  'Abrir Cartão',
                  style: TextStyle(color: kDarkTextPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showTaskDetailsDialog(cardId, task);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: kDarkTextSecondary),
                title: const Text(
                  'Editar Tarefa',
                  style: TextStyle(color: kDarkTextPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Abrir o diálogo de edição apropriado com base no tipo de tarefa
                  if (task.isDetailed) {
                    _showDetailedEditTaskDialog(cardId, task);
                  } else {
                    _showSimpleEditTaskDialog(cardId, task);
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_add,
                  color: kDarkTextSecondary,
                ),
                title: const Text(
                  'Alterar Membros',
                  style: TextStyle(color: kDarkTextPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Implementação simplificada - apenas mostra um snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Funcionalidade de alterar membros simulada',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: kDarkTextSecondary,
                ),
                title: const Text(
                  'Editar Data',
                  style: TextStyle(color: kDarkTextPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Implementação simplificada - apenas mostra um snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Funcionalidade de editar data simulada',
                      ),
                    ),
                  );
                },
              ),
              if (moveOptions.isNotEmpty) ...[
                const Divider(color: kDarkBorder),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mover para',
                      style: TextStyle(
                        color: kDarkTextSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ...moveOptions,
              ],
              const Divider(color: kDarkBorder),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text(
                  'Excluir Tarefa',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTask(cardId, task.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: kDarkPrimaryBg,
        scaffoldBackgroundColor: kDarkPrimaryBg,
        colorScheme: const ColorScheme.dark(
          primary: kAccentPurple,
          secondary: kAccentSecondary,
          surface: kDarkSurface,
          error: Colors.redAccent,
          onPrimary: kDarkTextPrimary,
          onSecondary: kDarkTextPrimary,
          onSurface: kDarkTextPrimary,
          onError: kDarkTextPrimary,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kDarkSurface,
          title: const Text(
            'Meu Projeto',
            style: TextStyle(color: kDarkTextPrimary),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: kDarkTextPrimary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade de busca simulada'),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kAccentPurple,
          onPressed: _showAddCardDialog,
          child: const Icon(Icons.add, color: kDarkTextPrimary),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: Stack(
          children: [
            cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.view_kanban,
                          size: 64,
                          color: kDarkTextSecondary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum cartão criado',
                          style:
                              TextStyle(color: kDarkTextPrimary, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Toque no botão + para adicionar um cartão',
                          style: TextStyle(color: kDarkTextSecondary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _showAddCardDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccentPurple,
                            foregroundColor: kDarkTextPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Adicionar Cartão'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return _buildCardWidget(card);
                    },
                  ),
            Positioned(
              bottom: -26,
              right: -60,
              child: CloseableAiCard(
                scaleFactor:
                    MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
                enableScroll: true,
                geminiService: widget.geminiService,
                firestoreService: _firestoreService,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWidget(TrelloCard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kDarkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDarkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do cartão - modificado para ser clicável e mostrar o menu
          InkWell(
            onTap: () => _showCardOptionsMenu(context, card),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: card.color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                border: Border(
                  bottom: const BorderSide(color: kDarkBorder),
                  left: BorderSide(color: card.color, width: 4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nome do cartão com estilo mais destacado
                  Expanded(
                    child: Text(
                      card.title,
                      style: const TextStyle(
                        color: kDarkTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const Icon(Icons.more_vert, color: kDarkTextSecondary),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cartão: ${card.title}',
                  style: const TextStyle(
                    color: kDarkTextPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: kDarkTextSecondary),
                  onPressed: () => _showCardOptionsMenu(context, card),
                  tooltip: 'Opções do cartão',
                ),
              ],
            ),
          ),

          if (card.tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Nenhuma tarefa neste cartão',
                  style: TextStyle(color: kDarkTextSecondary.withOpacity(0.7)),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: card.tasks.length,
              itemBuilder: (context, index) {
                final task = card.tasks[index];
                return _buildTaskWidget(card.id, task);
              },
            ),
          // Botão para adicionar tarefa
          InkWell(
            onTap: () => _showAddTaskDialog(card.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: kDarkBorder)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: kDarkTextSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Adicionar Tarefa',
                    style: TextStyle(
                      color: kDarkTextSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskWidget(String cardId, TrelloTask task) {
    return Draggable<Map<String, String>>(
      // Dados para o drag and drop
      data: {'cardId': cardId, 'taskId': task.id},
      // O que é arrastado
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kDarkElementBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            task.title,
            style: const TextStyle(color: kDarkTextPrimary),
          ),
        ),
      ),
      childWhenDragging: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kDarkElementBg.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kDarkBorder.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 24), // Espaço para o checkbox
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  color: kDarkTextSecondary.withOpacity(0.5),
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),

      child: DragTarget<Map<String, String>>(
        onWillAcceptWithDetails: (details) {
          // Aceita apenas se for de outro cartão
          return details.data['cardId'] != cardId;
        },
        onAcceptWithDetails: (details) {
          // Move a tarefa para este cartão
          _moveTaskToCard(
              details.data['cardId']!, details.data['taskId']!, cardId);
        },
        builder: (context, candidateData, rejectedData) {
          return InkWell(
            onTap: () => _showTaskDetailsDialog(cardId, task),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kDarkElementBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kDarkBorder),
              ),
              child: Row(
                children: [
                  // Checkbox
                  InkWell(
                    onTap: () => _toggleTaskCompletion(cardId, task.id),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? kAccentSecondary
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                              ? kAccentSecondary
                              : kDarkTextSecondary,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: kDarkTextPrimary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Título da tarefa
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: kDarkTextPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),

                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (task.isDetailed) {
                          _showDetailedEditTaskDialog(cardId, task);
                        } else {
                          _showSimpleEditTaskDialog(cardId, task);
                        }
                      },
                      child: const Icon(
                        Icons.edit,
                        color: kDarkTextSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


