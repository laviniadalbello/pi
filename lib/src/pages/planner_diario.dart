import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/widgets.dart' as Widgets;
import 'iconedaia.dart';
import '../../services/gemini_service.dart';


const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

enum TimelineItemType { event, task, projectTask }

class EventModel {
  final String id;
  final String name;
  final DateTime startDate;
  final TimeOfDay startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final Color eventColor;
  final String? location;
  bool isCompleted;
  EventModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.startTime,
    this.endDate,
    this.endTime,
    this.eventColor = kAccentPurple,
    this.location,
    this.isCompleted = false,
  });

  Duration get duration {
    if (endDate == null || endTime == null) {
      return const Duration(hours: 1);
    }
    final startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );
    return endDateTime.difference(startDateTime);
  }
}

class TaskModel {
  final String id;
  final String name;
  bool isCompleted;
  final DateTime? date;
  final TimeOfDay? time;
  final Color? taskColor;
  final String? projectName;
  TaskModel({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.date,
    this.time,
    this.taskColor,
    this.projectName,
  });

  Duration get duration => const Duration(hours: 1);
}

class TimelineItem {
  final String id;
  final TimelineItemType type;
  final String title;
  final TimeOfDay startTime;
  final Duration duration;
  final Color itemColor;
  final String? subtitle;
  bool isCompleted;

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
}

class PlannerDiarioPage extends StatefulWidget {
  final GeminiService geminiService;

  const PlannerDiarioPage({
    super.key,
    required this.geminiService, // <<-- Modifique o construtor

  });

  @override
  State<PlannerDiarioPage> createState() => _PlannerDiarioPageState();
}

class _PlannerDiarioPageState extends State<PlannerDiarioPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _selectedDate = DateTime.now();
  int _selectedDateIndexHorizontal = 2;
  bool _isCardVisible = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final Map<String, bool> _completionStatus = {};

  String _currentFilter = "Todos"; // Opções: "Todos", "Eventos", "Tarefas"

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    // Fecha o drawer se estiver aberto
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushNamed(routeName);
  }

  List<EventModel> _getMockEvents(DateTime date) {
    if (date.day == DateTime.now().day) {
      return [
        EventModel(
          id: 'e1',
          name: 'Reunião de Kickoff',
          startDate: date,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 30),
          eventColor: kAccentPurple,
          location: 'Online',
          isCompleted: _completionStatus['e1'] ?? false,
        ),
        EventModel(
          id: 'e2',
          name: 'Almoço com Equipe',
          startDate: date,
          startTime: const TimeOfDay(hour: 12, minute: 30),
          endTime: const TimeOfDay(hour: 13, minute: 30),
          eventColor: kAccentSecondary,
          location: 'Restaurante Central',
          isCompleted: _completionStatus['e2'] ?? false,
        ),
      ];
    }
    return [];
  }

  List<TaskModel> _getMockTasks(DateTime date) {
    if (date.day == DateTime.now().day) {
      return [
        TaskModel(
          id: 't1',
          name: 'Revisar Documento XPTO',
          date: date,
          time: const TimeOfDay(hour: 11, minute: 0),
          taskColor: Colors.orangeAccent,
          isCompleted: _completionStatus['t1'] ?? false,
        ),
        TaskModel(
          id: 't2',
          name: 'Ligar para Cliente Y',
          date: date,
          taskColor: Colors.pinkAccent,
          isCompleted: _completionStatus['t2'] ?? false,
        ), // Sem hora específica
        TaskModel(
          id: 'pt1',
          name: 'Desenvolver Feature A',
          date: date,
          time: const TimeOfDay(hour: 14, minute: 0),
          taskColor: Colors.teal,
          projectName: 'Projeto Phoenix',
          isCompleted: _completionStatus['pt1'] ?? false,
        ),
      ];
    }
    if (date.day == DateTime.now().add(const Duration(days: 1)).day) {
      return [
        TaskModel(
          id: 't3',
          name: 'Preparar Apresentação',
          date: date,
          time: const TimeOfDay(hour: 10, minute: 0),
          taskColor: Colors.blueAccent,
          isCompleted: _completionStatus['t3'] ?? false,
        ),
      ];
    }
    return [];
  }

  List<TimelineItem> _generateTimelineItems(DateTime date) {
    List<TimelineItem> items = [];
    final events = _getMockEvents(date);
    final tasks = _getMockTasks(date);

    for (var event in events) {
      items.add(
        TimelineItem(
          id: event.id,
          type: TimelineItemType.event,
          title: event.name,
          startTime: event.startTime,
          duration: event.duration,
          itemColor: event.eventColor,
          subtitle: event.location,
          isCompleted: event.isCompleted,
        ),
      );
    }

    for (var task in tasks) {
      if (task.time != null) {
        items.add(
          TimelineItem(
            id: task.id,
            type: task.projectName != null
                ? TimelineItemType.projectTask
                : TimelineItemType.task,
            title: task.name,
            startTime: task.time!,
            duration: task.duration,
            itemColor: task.taskColor ?? kAccentSecondary,
            subtitle: task.projectName,
            isCompleted: task.isCompleted,
          ),
        );
      }
    }

    if (_currentFilter == "Eventos") {
      items =
          items.where((item) => item.type == TimelineItemType.event).toList();
    } else if (_currentFilter == "Tarefas") {
      items = items
          .where(
            (item) =>
                item.type == TimelineItemType.task ||
                item.type == TimelineItemType.projectTask,
          )
          .toList();
    }

    items.sort((a, b) {
      final timeA = a.startTime.hour * 60 + a.startTime.minute;
      final timeB = b.startTime.hour * 60 + b.startTime.minute;
      return timeA.compareTo(timeB);
    });

    return items;
  }

  List<TaskModel> _getTasksWithoutTime(DateTime date) {
    final tasks = _getMockTasks(date);
    return tasks.where((task) => task.time == null).toList();
  }

  void _onHorizontalDateSelected(int index, DateTime date) {
    setState(() {
      _selectedDateIndexHorizontal = index;
      _selectedDate = date;
    });
  }

  void _toggleItemCompletion(String id) {
    setState(() {
      _completionStatus[id] = !(_completionStatus[id] ?? false);
    });
  }

  void _toggleTaskCompletion(TaskModel task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      _completionStatus[task.id] = task.isCompleted;
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
    final screenHeight = MediaQuery.of(context).size.height;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    double adjustedSize = baseSize;

    // Para telas muito pequenas (< 320dp)
    if (screenWidth < 320) {
      adjustedSize = baseSize * 0.8;
    }
    // Para telas pequenas (320dp - 360dp)
    else if (screenWidth < 360) {
      adjustedSize = baseSize * 0.9;
    }
    // Para telas grandes (> 480dp)
    else if (screenWidth > 480) {
      adjustedSize = baseSize * 1.1;
    }

    // Ajuste adicional para fontes em telas de alta densidade
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

    final List<TimelineItem> timelineItems = _generateTimelineItems(
      _selectedDate,
    );
    final List<TaskModel> tasksWithoutTime = _getTasksWithoutTime(
      _selectedDate,
    );

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final notchMargin = _getResponsiveSize(context, 8.0);

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHorizontalDateSelector(context),
                _buildFilterSelector(context),
                if (tasksWithoutTime.isNotEmpty)
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
                        // Fundo da timeline com horas
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

                        ...timelineItems.map((item) {
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
                              _getResponsiveSize(context, screenHeight * 0.1),
                            ),
                            child: _buildTimelineItemCard(item, context),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
          if (_isCardVisible) _buildDimOverlay(),
          if (_isCardVisible) _buildSlidingMenu(),
          Positioned(
            bottom: 56, // Posição ajustável
            right: -60, // Posição ajustável
            child: CloseableAiCard(
              scaleFactor: MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
              enableScroll: true,
              geminiService: widget.geminiService, 
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      extendBody: true,
    );
  }

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
                _navigateToRoute('/');
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
              child: _bottomBarIcon(Icons.book_outlined),
            ),
            InkWell(
              onTap: () {},
              child: _bottomBarIcon(Icons.person_outline, isActive: true),
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
    List<TaskModel> tasks,
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
                  onTap: () => _toggleTaskCompletion(task),
                  child: Container(
                    width: _getResponsiveSize(context, 24.0),
                    height: _getResponsiveSize(context, 24.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? (task.taskColor ?? kAccentSecondary)
                          : Colors.transparent,
                      border: Border.all(
                        color: task.taskColor ?? kAccentSecondary,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? Icon(
                            Icons.check,
                            size: _getResponsiveSize(context, 16.0),
                            color: kDarkTextPrimary,
                          )
                        : null,
                  ),
                ),
                title: Text(
                  task.name,
                  style: TextStyle(
                    color: kDarkTextPrimary,
                    fontSize: _getResponsiveSize(
                      context,
                      screenWidth * 0.035,
                      isFont: true,
                    ),
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: task.projectName != null
                    ? Text(
                        task.projectName!,
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
                    // Implementar menu de opções para a tarefa
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
          // Implementar ação ao tocar no card
        },
        borderRadius: _getResponsiveBorderRadius(context, 12.0),
        child: Padding(
          padding: EdgeInsets.all(_getResponsiveSize(context, 12.0)),
          child: Row(
            children: [
              // Indicador de status (checkbox para tarefas, círculo para eventos)
              GestureDetector(
                onTap: () => _toggleItemCompletion(item.id),
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
              // Conteúdo do item
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
              // Horário do item
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
}

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
