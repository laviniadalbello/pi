import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/widgets.dart' as Widgets;
import 'iconedaia.dart';
import '../../services/gemini_service.dart';
import 'package:planify/services/firestore_tasks_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/models/events_model.dart';
import 'package:planify/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planify/services/firestore_planner_service.dart';
import 'package:planify/services/firestore_service.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

enum TimelineItemType { event, task, projectTask }

class TimelineItem {
  final String id;
  final TimelineItemType type;
  final String title;
  final TimeOfDay startTime; // Mantido como TimeOfDay
  final Duration duration;
  final Color itemColor;
  final String? subtitle;
  final bool isCompleted; // Definido como 'final' para imutabilidade

  TimelineItem({
    required this.id,
    required this.type,
    required this.title,
    required this.startTime,
    required this.duration,
    required this.itemColor,
    this.subtitle,
    this.isCompleted = false,
  });

  // Factory constructor para criar TimelineItem a partir de Event
  factory TimelineItem.fromEvent(Event event) {
    return TimelineItem(
      id: event.id!, // Assumindo que o ID do evento não será nulo vindo do Firestore
      type: TimelineItemType.event,
      title: event.title,
      // CONVERSÃO: DateTime (do modelo Event) para TimeOfDay (para o TimelineItem)
      startTime: TimeOfDay.fromDateTime(event.startTime),
      duration: event.endTime?.difference(event.startTime) ?? const Duration(hours: 1),
      itemColor: event.eventColor,
      subtitle: event.location,
      isCompleted: event.isCompleted,
    );
  }

  // Factory constructor para criar TimelineItem a partir de Task
  factory TimelineItem.fromTask(Task task) {
    bool taskIsCompleted = task.status == 'completed';

    // ATENÇÃO: task.dueDate já é DateTime?, não precisa de .toDate()
    // E precisamos garantir que task.dueDate e task.time não são nulos aqui,
    // pois esta factory é para itens com horário na timeline.
    // A lógica de _getTasksWithoutTime já deve filtrar os sem horário.
    if (task.dueDate == null || task.time == null) {
      // Isso não deve acontecer se a lógica de filtragem estiver correta,
      // mas é uma salvaguarda. Poderia lançar um erro ou retornar um item nulo.
      // Por simplicidade, vamos assumir que dueDate e time não são nulos se chegar aqui.
      debugPrint('DEBUG: Erro na TimelineItem.fromTask: Task sem dueDate ou time sendo processada como TimelineItem com horário. ID: ${task.id}, Título: ${task.title}');
      // Retornar um TimelineItem com dados padrão ou lançar um erro.
      // Para evitar crash, retornando um item básico.
      return TimelineItem(
        id: task.id!,
        type: TimelineItemType.task,
        title: task.title,
        startTime: TimeOfDay.now(),
        duration: const Duration(hours: 1),
        itemColor: Colors.red, // Cor de erro
        subtitle: 'Erro de data/hora',
        isCompleted: false,
      );
    }

    // Compondo o DateTime completo a partir de dueDate e time
    final parts = task.time!.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    final DateTime fullTaskDateTime = DateTime(
      task.dueDate!.year, // Usar ! pois verificamos que não é nulo acima
      task.dueDate!.month,
      task.dueDate!.day,
      hour,
      minute,
    );

    return TimelineItem(
      id: task.id!, // Assumindo que o ID da tarefa não será nulo vindo do Firestore
      type: task.projectId != null ? TimelineItemType.projectTask : TimelineItemType.task, // <--- CORRIGIDO: usando projectId
      title: task.title, // <--- CORRIGIDO: usando 'title' da Task
      // CONVERSÃO: DateTime (composto da data e hora da Task) para TimeOfDay (para o TimelineItem)
      startTime: TimeOfDay.fromDateTime(fullTaskDateTime),
      duration: const Duration(hours: 1), // Duração padrão para tarefas
      itemColor: kAccentSecondary, // <--- CORRIGIDO: Usando kAccentSecondary como cor padrão para tarefas
      subtitle: task.description, // Usando description como subtitle
      isCompleted: taskIsCompleted,
    );
  }
}

// Início da classe PlannerDiarioPage
class PlannerDiarioPage extends StatefulWidget {
  final GeminiService geminiService;

  const PlannerDiarioPage({
    super.key,
    required this.geminiService,
  });

  @override
  State<PlannerDiarioPage> createState() => _PlannerDiarioPageState();
}

class _PlannerDiarioPageState extends State<PlannerDiarioPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _selectedDate = DateTime.now();
  int _selectedDateIndexHorizontal = 2; // Default to today's index
  bool _isCardVisible = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String _currentFilter = "Todos";

  // ATENÇÃO: Agora usa FirestorePlannerService
  late final FirestorePlannerService _firestoreService; // Tipo concreto

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("DEBUG: Erro: Usuário não logado no FirestorePlannerService. Usando ID 'guest'.");
      // Considere redirecionar para tela de login ou mostrar erro robusto
      _firestoreService = FirestorePlannerService(userId: 'guest');
    } else {
      _firestoreService = FirestorePlannerService(userId: user.uid);
      debugPrint("DEBUG: FirestorePlannerService inicializado para o usuário: ${user.uid}");
    }

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    final today = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final date = today.add(Duration(days: i - 2));
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        _selectedDateIndexHorizontal = i;
        break;
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    // Usar pushReplacementNamed se for para substituir a rota atual na pilha
    Navigator.of(context).pushNamed(routeName);
  }

  Future<void> _toggleTimelineItemCompletion(TimelineItem item) async {
    // A UI será atualizada automaticamente pelo StreamBuilder após a mudança no Firestore.
    if (item.type == TimelineItemType.event) {
      await _firestoreService.updateEventCompletion(item.id, !item.isCompleted);
    } else { // Task or ProjectTask
      await _firestoreService.updateTaskCompletion(item.id, !item.isCompleted);
    }
  }

  // Esta função é correta para filtrar as tarefas sem horário
  List<Task> _getTasksWithoutTime(List<Task> allTasks, DateTime date) {
    return allTasks.where((task) {
      // Verifica se a tarefa tem um campo 'dueDate' e se ele corresponde à data selecionada
      // E se o campo 'time' é nulo ou vazio
      if (task.dueDate != null && (task.time == null || task.time!.isEmpty)) {
        final taskDate = task.dueDate!; // Já é DateTime, usar ! após a verificação de nulo
        return taskDate.year == date.year &&
            taskDate.month == date.month &&
            taskDate.day == date.day;
      }
      return false;
    }).toList();
  }

  void _onHorizontalDateSelected(int index, DateTime date) {
    setState(() {
      _selectedDateIndexHorizontal = index;
      _selectedDate = date;
      debugPrint("DEBUG: Data selecionada alterada para: $_selectedDate");
    });
  }

  Future<void> _selectDateFromPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kAccentPurple,
              onPrimary: kDarkTextPrimary,
              surface: kDarkSurface,
              onSurface: kDarkTextPrimary,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: kDarkElementBg),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        debugPrint("DEBUG: Data selecionada no picker: $_selectedDate");
        final today = DateTime.now();
        int newIndex = -1;
        for (int i = 0; i < 5; i++) {
          final dateInSelector = today.add(Duration(days: i - 2));
          if (dateInSelector.year == picked.year &&
              dateInSelector.month == picked.month &&
              dateInSelector.day == picked.day) {
            newIndex = i;
            break;
          }
        }
        if (newIndex != -1) {
          _selectedDateIndexHorizontal = newIndex;
        } else {
          _selectedDateIndexHorizontal = 2; // Volta para o "Hoje"
        }
      });
    }
  }

  String _getFormattedAppBarDate(DateTime date) {
    if (date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day) {
      return 'Hoje, ${DateFormat('d MMM', 'pt_BR').format(date)}';
    }
    return DateFormat('E, d MMM y', 'pt_BR').format(date);
  }

  double _getResponsiveSize(
    BuildContext context,
    double baseSize, {
    bool isFont = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    double adjustedSize = baseSize;

    if (screenWidth < 320) {
      adjustedSize = baseSize * 0.8;
    } else if (screenWidth > 480) {
      adjustedSize = baseSize * 1.1;
    }

    if (isFont && pixelRatio > 2.5) {
      adjustedSize = adjustedSize * 0.95;
    }

    return adjustedSize;
  }

  BorderRadius _getResponsiveBorderRadius(
    BuildContext context,
    double baseRadius,
  ) {
    final adjustedRadius = _getResponsiveSize(context, baseRadius);
    return BorderRadius.circular(adjustedRadius);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    final double hourHeight = screenHeight * 0.075;
    final double leftPaddingForTimeline = screenWidth * 0.12;

    const int startHour = 7;
    const int endHour = 22;

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    return Scaffold(
      backgroundColor: kDarkPrimaryBg,
      appBar: AppBar(
        backgroundColor: kDarkSurface,
        elevation: 0.5,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Planner Diário',
              style: TextStyle(
                color: kDarkTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: _getResponsiveSize(
                  context,
                  screenWidth * 0.045,
                  isFont: true,
                ),
              ),
            ),
            Text(
              _getFormattedAppBarDate(_selectedDate),
              style: TextStyle(
                color: kDarkTextSecondary,
                fontSize: _getResponsiveSize(
                  context,
                  screenWidth * 0.033,
                  isFont: true,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: kDarkTextPrimary,
            size: _getResponsiveSize(context, screenWidth * 0.05),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: kDarkTextPrimary,
              size: _getResponsiveSize(context, screenWidth * 0.055),
            ),
            onPressed: () => _selectDateFromPicker(context),
          ),
          SizedBox(width: _getResponsiveSize(context, screenWidth * 0.02)),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _firestoreService.getEventsAndTasksForSelectedDay(_selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAccentPurple));
          }
          if (snapshot.hasError) {
            debugPrint('DEBUG: StreamBuilder Error: ${snapshot.error}'); // Para depuração
            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}', style: const TextStyle(color: kDarkTextPrimary)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('DEBUG: Nenhum dado recebido do StreamBuilder para a data: $_selectedDate');
            return Center(
              child: Text(
                'Nenhum evento ou tarefa para esta data.',
                style: TextStyle(color: kDarkTextSecondary, fontSize: _getResponsiveSize(context, screenWidth * 0.038, isFont: true)),
              ),
            );
          }

          debugPrint('DEBUG: Dados recebidos do StreamBuilder: ${snapshot.data!.length} itens.');

          // LÓGICA DE GERAÇÃO E FILTRAGEM DOS TIMELINE ITEMS
          final List<TimelineItem> timelineItems = [];
          final List<Task> tasksWithoutTime = []; // Para tarefas sem horário definido

          for (var item in snapshot.data!) {
            if (item is Event) {
              timelineItems.add(TimelineItem.fromEvent(item));
              debugPrint('DEBUG: Evento adicionado: ${item.title} (ID: ${item.id})');
            } else if (item is Task) {
              // Verifica se a tarefa tem horário para ser adicionada à linha do tempo principal
              // E se tem uma data de vencimento (dueDate)
              if (item.time != null && item.time!.isNotEmpty && item.dueDate != null) {
                timelineItems.add(TimelineItem.fromTask(item));
                debugPrint('DEBUG: Tarefa com horário adicionada: ${item.title} (ID: ${item.id}, Hora: ${item.time})');
              } else {
                tasksWithoutTime.add(item);
                debugPrint('DEBUG: Tarefa sem horário adicionada à lista separada: ${item.title} (ID: ${item.id})');
              }
            }
          }

          debugPrint('DEBUG: Total de itens na timeline principal: ${timelineItems.length}');
          debugPrint('DEBUG: Total de tarefas sem horário: ${tasksWithoutTime.length}');


          // Filtra os itens da linha do tempo com base no _currentFilter
          List<TimelineItem> filteredTimelineItems = [];
          if (_currentFilter == "Eventos") {
            filteredTimelineItems = timelineItems.where((item) => item.type == TimelineItemType.event).toList();
            debugPrint('DEBUG: Filtro "Eventos" aplicado. Itens filtrados: ${filteredTimelineItems.length}');
          } else if (_currentFilter == "Tarefas") {
            filteredTimelineItems = timelineItems
                .where(
                    (item) =>
                        item.type == TimelineItemType.task ||
                        item.type == TimelineItemType.projectTask,
                )
                .toList();
            debugPrint('DEBUG: Filtro "Tarefas" aplicado. Itens filtrados: ${filteredTimelineItems.length}');
          } else { // "Todos"
            filteredTimelineItems = timelineItems;
            debugPrint('DEBUG: Filtro "Todos" aplicado. Itens filtrados: ${filteredTimelineItems.length}');
          }

          // Ordena os itens da linha do tempo
          filteredTimelineItems.sort((a, b) {
            final timeA = a.startTime.hour * 60 + a.startTime.minute;
            final timeB = b.startTime.hour * 60 + b.startTime.minute;
            return timeA.compareTo(timeB);
          });
          // FIM DA LÓGICA DE GERAÇÃO DOS TIMELINE ITEMS

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHorizontalDateSelector(context),
                    _buildFilterSelector(context),
                    if (tasksWithoutTime.isNotEmpty && (_currentFilter == "Todos" || _currentFilter == "Tarefas"))
                      _buildTasksWithoutTimeSection(tasksWithoutTime, context),
                    Padding(
                      padding: EdgeInsets.only(
                        top: _getResponsiveSize(context, screenHeight * 0.02),
                        bottom: _getResponsiveSize(context, screenHeight * 0.1) +
                            safeAreaBottom,
                        right: _getResponsiveSize(context, screenWidth * 0.04),
                        left: _getResponsiveSize(context, screenWidth * 0.02),
                      ),
                      child: SizedBox(
                        height: (endHour - startHour + 1) * hourHeight,
                        child: Stack(
                          children: [
                            // Linhas do tempo e horas
                            Positioned.fill(
                              child: CustomPaint(
                                painter: TimelinePainter(
                                  startHour: startHour,
                                  endHour: endHour,
                                  hourHeight: hourHeight,
                                  leftPadding: leftPaddingForTimeline,
                                  textSize: _getResponsiveSize(
                                    context,
                                    screenWidth * 0.025,
                                    isFont: true,
                                  ),
                                ),
                              ),
                            ),
                            // Linha indicadora do tempo atual (se for hoje)
                            if (isToday &&
                                currentHour >= startHour &&
                                currentHour <= endHour)
                              Positioned(
                                top: (currentHour -
                                        startHour +
                                        (currentMinute / 60.0)) *
                                    hourHeight,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: _getResponsiveSize(context, 2.0),
                                  color: Colors.redAccent,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: _getResponsiveSize(
                                          context,
                                          screenWidth * 0.02,
                                        ),
                                        height: _getResponsiveSize(
                                          context,
                                          screenWidth * 0.02,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Itens da linha do tempo (Eventos e Tarefas com horário)
                            ...filteredTimelineItems.map((item) {
                              final itemTop = (item.startTime.hour -
                                      startHour +
                                      (item.startTime.minute / 60.0)) *
                                  hourHeight;
                              final itemHeight =
                                  (item.duration.inMinutes / 60.0) * hourHeight;
                              return Positioned(
                                top: itemTop,
                                left: leftPaddingForTimeline +
                                    _getResponsiveSize(context, screenWidth * 0.02),
                                right: 0,
                                height: max(
                                  itemHeight,
                                  _getResponsiveSize(context, screenHeight * 0.05),
                                ),
                                child: _buildTimelineItemCard(item, context),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Dim Overlay para o card flutuante
              if (_isCardVisible) _buildDimOverlay(),
              // Sliding Menu para o card flutuante
              if (_isCardVisible) _buildSlidingMenu(),
              // CloseableAiCard (Placeholder - você precisa fornecer o código real em iconedaia.dart)
              Positioned(
                bottom: 56, // Ajuste para ficar acima do BottomAppBar
                right: -_getResponsiveSize(context, screenWidth * 0.15), // Ajuste a posição para caber na tela
                child: CloseableAiCard(
                  scaleFactor: MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
                  enableScroll: true,
                  geminiService: widget.geminiService,
                  firestoreService: _firestoreService, // Passando o FirestorePlannerService
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      extendBody: true, // Permite que o body se estenda para debaixo do BottomAppBar
    );
  }

  // --- Widgets de Auxílio ---

  Widget _buildFilterSelector(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double horizontalSpacing =
        screenWidth < 360 ? screenWidth * 0.02 : screenWidth * 0.03;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveSize(context, screenWidth * 0.04),
        vertical: _getResponsiveSize(context, screenHeight * 0.01),
      ),
      color: kDarkSurface.withOpacity(0.3),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFilterChip(context, "Todos"),
            SizedBox(width: _getResponsiveSize(context, horizontalSpacing)),
            _buildFilterChip(context, "Eventos"),
            SizedBox(width: _getResponsiveSize(context, horizontalSpacing)),
            _buildFilterChip(context, "Tarefas"),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _currentFilter == label;

    final double horizontalPadding =
        screenWidth < 360 ? screenWidth * 0.025 : screenWidth * 0.03;
    final double verticalPadding =
        screenWidth < 360 ? screenWidth * 0.01 : screenWidth * 0.015;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = label;
          debugPrint('DEBUG: Filtro alterado para: $_currentFilter');
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getResponsiveSize(context, horizontalPadding),
          vertical: _getResponsiveSize(context, verticalPadding),
        ),
        decoration: BoxDecoration(
          color: isSelected ? kAccentPurple : kDarkElementBg,
          borderRadius: _getResponsiveBorderRadius(context, 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kDarkTextPrimary : kDarkTextSecondary,
            fontSize: _getResponsiveSize(
              context,
              screenWidth * 0.03,
              isFont: true,
            ),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
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

  Widget _buildHorizontalDateSelector(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double itemWidth = screenWidth < 360
        ? _getResponsiveSize(context, screenWidth * 0.13)
        : _getResponsiveSize(context, screenWidth * 0.14);

    final List<Map<String, dynamic>> dates = List.generate(5, (index) {
      final date = DateTime.now().add(Duration(days: index - 2));
      return {
        'date': date,
        'day': DateFormat('d', 'pt_BR').format(date),
        'week': DateFormat('E', 'pt_BR').format(date).substring(0, 3),
      };
    });

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: _getResponsiveSize(context, screenHeight * 0.015),
      ),
      color: kDarkSurface,
      child: SizedBox(
        height: _getResponsiveSize(context, screenHeight * 0.09),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: _getResponsiveSize(context, screenWidth * 0.04),
          ),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final dateInfo = dates[index];
            final date = dateInfo['date'] as DateTime;
            final isSelected = _selectedDateIndexHorizontal == index;
            final isToday = date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;

            return GestureDetector(
              onTap: () => _onHorizontalDateSelected(index, date),
              child: Container(
                width: itemWidth,
                margin: EdgeInsets.symmetric(
                  horizontal: _getResponsiveSize(context, screenWidth * 0.01),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kAccentPurple : Colors.transparent,
                  borderRadius: _getResponsiveBorderRadius(context, 12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateInfo['week'] as String,
                      style: TextStyle(
                        color:
                            isSelected ? kDarkTextPrimary : kDarkTextSecondary,
                        fontSize: _getResponsiveSize(
                          context,
                          screenWidth * 0.03,
                          isFont: true,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: _getResponsiveSize(context, screenHeight * 0.005),
                    ),
                    Container(
                      width: _getResponsiveSize(context, screenWidth * 0.08),
                      height: _getResponsiveSize(context, screenWidth * 0.08),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday && !isSelected
                            ? kAccentPurple.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          dateInfo['day'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? kDarkTextPrimary
                                : (isToday
                                    ? kAccentPurple
                                    : kDarkTextSecondary),
                            fontSize: _getResponsiveSize(
                              context,
                              screenWidth * 0.04,
                              isFont: true,
                            ),
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
    );
  }

  Widget _buildTasksWithoutTimeSection(
    List<Task> tasks, // Agora recebe List<Task>
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _getResponsiveSize(context, screenWidth * 0.04),
        vertical: _getResponsiveSize(context, 12.0),
      ),
      decoration: BoxDecoration(
        color: kDarkSurface,
        borderRadius: _getResponsiveBorderRadius(context, 16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(_getResponsiveSize(context, 16.0)),
            child: Text(
              'Tarefas sem horário definido',
              style: TextStyle(
                color: kDarkTextPrimary,
                fontSize: _getResponsiveSize(
                  context,
                  screenWidth * 0.04,
                  isFont: true,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1, color: kDarkBorder),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: tasks.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: kDarkBorder),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                leading: GestureDetector(
                  // ATENÇÃO: Chamando _toggleTimelineItemCompletion para consistência
                  onTap: () => _toggleTimelineItemCompletion(
                    // Crie um TimelineItem temporário para passar à função genérica
                    TimelineItem.fromTask(task),
                  ),
                  child: Container(
                    width: _getResponsiveSize(context, 24.0),
                    height: _getResponsiveSize(context, 24.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.status == 'completed' // Usando status da Task
                          ? kAccentSecondary // Cor quando concluído
                          : Colors.transparent,
                      border: Border.all(
                        color: kAccentSecondary, // Cor da borda padrão para tarefas
                        width: 2,
                      ),
                    ),
                    child: task.status == 'completed' // Usando status da Task
                        ? Icon(
                            Icons.check,
                            size: _getResponsiveSize(context, 16.0),
                            color: kDarkTextPrimary,
                          )
                        : null,
                  ),
                ),
                title: Text(
                  task.title, // <--- CORRIGIDO: usando 'title' da Task
                  style: TextStyle(
                    color: kDarkTextPrimary,
                    fontSize: _getResponsiveSize(
                      context,
                      screenWidth * 0.035,
                      isFont: true,
                    ),
                    decoration:
                        task.status == 'completed' ? TextDecoration.lineThrough : null, // Usando status da Task
                  ),
                ),
                subtitle: task.projectId != null // <--- CORRIGIDO: usando projectId
                    ? Text(
                        task.projectId!, // <--- CORRIGIDO: usando projectId
                        style: TextStyle(
                          color: kDarkTextSecondary,
                          fontSize: _getResponsiveSize(
                            context,
                            screenWidth * 0.03,
                            isFont: true,
                          ),
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: kDarkTextSecondary,
                    size: _getResponsiveSize(context, 20.0),
                  ),
                  onPressed: () {
                    // TODO: Implementar ações para a tarefa
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItemCard(TimelineItem item, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    IconData itemIcon;
    switch (item.type) {
      case TimelineItemType.event:
        itemIcon = Icons.event;
        break;
      case TimelineItemType.task:
        itemIcon = Icons.check_circle_outline;
        break;
      case TimelineItemType.projectTask:
        itemIcon = Icons.folder;
        break;
    }

    return Card(
      color: kDarkElementBg,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: _getResponsiveBorderRadius(context, 12.0),
        side: BorderSide(color: item.itemColor.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implementar ação de clique para o item da timeline
          debugPrint('Item clicado: ${item.title}');
        },
        borderRadius: _getResponsiveBorderRadius(context, 12.0),
        child: Padding(
          padding: EdgeInsets.all(_getResponsiveSize(context, 8.0)),
          child: Row(
            children: [
              // Checkbox de conclusão
              GestureDetector(
                onTap: () => _toggleTimelineItemCompletion(item),
                child: Container(
                  width: _getResponsiveSize(context, 24.0),
                  height: _getResponsiveSize(context, 24.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        item.isCompleted ? item.itemColor : Colors.transparent,
                    border: Border.all(color: item.itemColor, width: 2),
                  ),
                  child: item.isCompleted
                      ? Icon(
                          Icons.check,
                          size: _getResponsiveSize(context, 16.0),
                          color: kDarkTextPrimary,
                        )
                      : null,
                ),
              ),
              SizedBox(width: _getResponsiveSize(context, 12.0)),

              // Título e subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: kDarkTextPrimary,
                        fontSize: _getResponsiveSize(
                          context,
                          screenWidth * 0.035,
                          isFont: true,
                        ),
                        fontWeight: FontWeight.bold,
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          color: kDarkTextSecondary,
                          fontSize: _getResponsiveSize(
                            context,
                            screenWidth * 0.03,
                            isFont: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Hora e duração
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.startTime.format(context),
                    style: TextStyle(
                      color: kDarkTextSecondary,
                      fontSize: _getResponsiveSize(
                        context,
                        screenWidth * 0.03,
                        isFont: true,
                      ),
                    ),
                  ),
                  SizedBox(height: _getResponsiveSize(context, 4.0)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        itemIcon,
                        color: item.itemColor,
                        size: _getResponsiveSize(context, 16.0),
                      ),
                      SizedBox(width: _getResponsiveSize(context, 4.0)),
                      Text(
                        '${item.duration.inMinutes} min',
                        style: TextStyle(
                          color: kDarkTextSecondary,
                          fontSize: _getResponsiveSize(
                            context,
                            screenWidth * 0.025,
                            isFont: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
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
      bottom: 25,
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

  Widget _buildFloatingActionButton(BuildContext context) {
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
                _navigateToRoute('/perfil');
              },
              child: _bottomBarIcon(Icons.person_outline),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe TimelinePainter
class TimelinePainter extends CustomPainter {
  final int startHour;
  final int endHour;
  final double hourHeight;
  final double leftPadding;
  final double textSize;

  TimelinePainter({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.leftPadding,
    required this.textSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kDarkBorder
      ..strokeWidth = 1.0;

    final paintText = TextPainter(
      textAlign: TextAlign.right,
      textDirection: Widgets.TextDirection.ltr,
    );

    for (int hour = startHour; hour <= endHour; hour++) {
      final y = (hour - startHour) * hourHeight;

      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), paint);

      final String hourText = hour < 12
          ? '$hour AM'
          : hour == 12
              ? '12 PM'
              : '${hour - 12} PM';

      paintText.text = TextSpan(
        text: hourText,
        style: TextStyle(color: kDarkTextSecondary, fontSize: textSize),
      );

      paintText.layout();
      paintText.paint(
        canvas,
        Offset(leftPadding - paintText.width - 8, y - paintText.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
