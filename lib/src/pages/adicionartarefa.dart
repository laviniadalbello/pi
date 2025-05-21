import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'dart:math';
import 'iconedaia.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);
>>>>>>> 29e6bff (telasnovas)

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
<<<<<<< HEAD
  final GlobalKey _cardKey = GlobalKey();

  bool _isCardVisible = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

=======
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isCardVisible = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _taskNameController = TextEditingController(
    text: 'Mobile Application design',
  );
  final TextEditingController _dateController = TextEditingController(
    text: 'November 01, 2021',
  );
  final TextEditingController _startTimeController = TextEditingController(
    text: '9:30 am',
  );
  final TextEditingController _endTimeController = TextEditingController(
    text: '12:30 am',
  );

  String? _selectedPriority = 'Média';
  String? _selectedProject = 'Nenhum'; // ADICIONADO
  final List<String> _availableProjects = [
    'Nenhum',
    'Projeto Alpha',
    'Projeto Beta',
    'Projeto Gamma',
  ]; // ADICIONADO
  Color _selectedTaskColor = kAccentPurple;
  List<String> _attachments = [];
  String? _selectedBoard = 'Running';

  final List<Color> _availableTaskColors = [
    kAccentPurple,
    kAccentSecondary,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.teal,
  ];

>>>>>>> 29e6bff (telasnovas)
  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
<<<<<<< HEAD

=======
>>>>>>> 29e6bff (telasnovas)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
<<<<<<< HEAD
    super.dispose();
  }

=======
    _taskNameController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushNamed(routeName);
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kAccentPurple,
              onPrimary: kDarkTextPrimary,
              surface: kDarkSurface,
              onSurface: kDarkTextPrimary,
            ),
            dialogBackgroundColor: kDarkElementBg,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${_getMonthName(picked.month)} ${picked.day.toString().padLeft(2, '0')}, ${picked.year}";
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'ABril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kAccentPurple,
              onPrimary: kDarkTextPrimary,
              surface: kDarkSurface,
              onSurface: kDarkTextPrimary,
            ),
            dialogBackgroundColor: kDarkElementBg,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _pickFiles() async {
    setState(() {
      _attachments.add("document_${_attachments.length + 1}.pdf");
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      print("Task Name: ${_taskNameController.text}");
      print("Project: $_selectedProject");
      print("Date: ${_dateController.text}");
      print("Start Time: ${_startTimeController.text}");
      print("End Time: ${_endTimeController.text}");
      print("Board: $_selectedBoard");
      print("Priority: $_selectedPriority");
      print("Task Color: $_selectedTaskColor");
      print("Attachments: $_attachments");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tarefa salva com sucesso!',
            style: TextStyle(color: kDarkTextPrimary),
          ),
          backgroundColor: kAccentSecondary,
        ),
      );
    }
  }

>>>>>>> 29e6bff (telasnovas)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
<<<<<<< HEAD
      backgroundColor: Colors.black,
=======
      backgroundColor: kDarkPrimaryBg,
>>>>>>> 29e6bff (telasnovas)
      extendBody: true,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
<<<<<<< HEAD
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Voltar e título centralizado
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 46),
                            child: Text(
                              'Add Task',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Opacity(opacity: 0, child: Icon(Icons.arrow_back)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Task Name
                    _buildLabel("Task Name"),
                    const SizedBox(height: 8),
                    _buildTextField('Mobile Application design'),
                    const SizedBox(height: 30),

                    _buildLabel("Team Member"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _memberAvatar(
                          "https://randomuser.me/api/portraits/women/1.jpg",
                          "Jeny",
                        ),
                        _memberAvatar(
                          "https://randomuser.me/api/portraits/women/2.jpg",
                          "Mehrin",
                        ),
                        _memberAvatar(
                          "https://randomuser.me/api/portraits/men/1.jpg",
                          "Avishek",
                          selected: true,
                        ),
                        _memberAvatar(
                          "https://randomuser.me/api/portraits/men/2.jpg",
                          "Jafor",
                        ),
                        _addMemberButton(),
                      ],
                    ),
                    const SizedBox(height: 35),

                    _buildLabel("Date"),
                    const SizedBox(height: 8),
                    _buildTextField("November 01, 2021"),
                    const SizedBox(height: 34),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Start Time", left: 24),
                              const SizedBox(height: 8),
                              _timeBox("9:30 am"),
                            ],
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("End Time", left: 24),
                              const SizedBox(height: 8),
                              _timeBox("12:30 am"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),

                    _buildLabel("Board"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _boardButton("Urgent"),
                        const SizedBox(width: 10),
                        _boardButton("Running", selected: true),
                        const SizedBox(width: 10),
                        _boardButton("Ongoing"),
                      ],
                    ),
                    const SizedBox(height: 60),

                    Center(
                      child: SizedBox(
                        width: 195,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8875FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
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
              bottom: 20,
              left: 30,
              right: 30,
              child: SlideTransition(
                position: _slideAnimation,
                child: Material(
                  color: Colors.transparent,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    key: _cardKey,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(223, 17, 24, 39),
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
                        FloatingActionButton(
                          mini: true, // Make it smaller
                          backgroundColor: Colors.blueAccent,
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
                            color: Colors.white,
                          ), // White icon
                        ),
                      ],
                    ),
=======
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildLabel("Nome da Tarefa"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _taskNameController,
                        'Ex: Design do App Mobile',
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Nome da tarefa é obrigatório"
                                    : null,
                      ),
                      const SizedBox(height: 30),
                      _buildLabel("Adicionar atividade em um projeto:"),
                      const SizedBox(height: 10),
                      _buildProjectSelector(),
                      const SizedBox(height: 35),
                      _buildLabel("Data"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        _dateController,
                        'Selecione a data',
                        readOnly: true,
                        onTap: _selectDate,
                        suffixIcon: Icons.calendar_today,
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Data é obrigatória"
                                    : null,
                      ),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Hora de Início"),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  _startTimeController,
                                  'Ex: 9:30 am',
                                  readOnly: true,
                                  onTap:
                                      () => _selectTime(_startTimeController),
                                  suffixIcon: Icons.access_time,
                                  validator:
                                      (val) =>
                                          val == null || val.isEmpty
                                              ? "Hora de início é obrigatória"
                                              : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Hora de Término"),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  _endTimeController,
                                  'Ex: 12:30 pm',
                                  readOnly: true,
                                  onTap: () => _selectTime(_endTimeController),
                                  suffixIcon: Icons.access_time,
                                  validator:
                                      (val) =>
                                          val == null || val.isEmpty
                                              ? "Hora de término é obrigatória"
                                              : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      _buildLabel("Prioridade"),
                      const SizedBox(height: 10),
                      _buildPrioritySelector(),
                      const SizedBox(height: 35),
                      _buildLabel("Cor da Tarefa"),
                      const SizedBox(height: 10),
                      _buildTaskColorSelector(),
                      const SizedBox(height: 35),
                      _buildLabel("Anexos"),
                      const SizedBox(height: 10),
                      _buildAttachmentSection(),
                      const SizedBox(height: 35),
                      _buildLabel("Tipo"),
                      const SizedBox(height: 10),
                      _buildBoardSelector(),
                      const SizedBox(height: 60),
                      _buildSaveButton(),
                      const SizedBox(height: 100),
                    ],
>>>>>>> 29e6bff (telasnovas)
                  ),
                ),
              ),
            ),
<<<<<<< HEAD
=======
          ),
          if (_isCardVisible) _buildDimOverlay(),
          if (_isCardVisible) _buildSlidingMenu(),
          Positioned(
            bottom: 56, // Posição ajustável
            right: -60, // Posição ajustável
            child: CloseableAiCard(
              scaleFactor: MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
              enableScroll: true,
            ),
          ),
>>>>>>> 29e6bff (telasnovas)
        ],
      ),
    );
  }

<<<<<<< HEAD
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

  InputDecoration _whiteInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildLabel(String text, {double left = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: left),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _memberAvatar(String imageUrl, String name, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 16),
              if (selected)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF8875FF),
                    size: 26,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(name, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
=======
  Widget _buildHeader() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: kDarkTextPrimary,
              size: 30,
            ),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 0),
            child: Text(
              'Adicionar Tarefa',
              style: TextStyle(
                color: kDarkTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: kDarkTextSecondary, fontSize: 16),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: kDarkTextPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: kDarkTextSecondary.withOpacity(0.7)),
        filled: true,
        fillColor: kDarkElementBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentPurple),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon:
            suffixIcon != null
                ? Icon(suffixIcon, color: kDarkTextSecondary)
                : null,
      ),
      validator: validator,
    );
  }

  Widget _buildProjectSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedProject,
      dropdownColor: kDarkElementBg,
      style: const TextStyle(color: kDarkTextPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: kDarkElementBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentPurple),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items:
          _availableProjects.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedProject = newValue!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione um projeto ou "Nenhum"';
        }
        return null;
      },
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      dropdownColor: kDarkElementBg,
      style: const TextStyle(color: kDarkTextPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: kDarkElementBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items:
          ['Baixa', 'Média', 'Alta'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedPriority = newValue!;
        });
      },
    );
  }

  Widget _buildTaskColorSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            _availableTaskColors.map((color) {
              bool isSelected = _selectedTaskColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedTaskColor = color),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? kDarkTextPrimary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(
            Icons.attach_file,
            color: kDarkTextPrimary,
            size: 20,
          ),
          label: const Text(
            'Adicionar Anexo',
            style: TextStyle(color: kDarkTextPrimary),
          ),
          onPressed: _pickFiles,
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkElementBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children:
              _attachments.asMap().entries.map((entry) {
                int idx = entry.key;
                String fileName = entry.value;
                return Chip(
                  backgroundColor: kDarkElementBg,
                  label: Text(
                    fileName,
                    style: const TextStyle(color: kDarkTextSecondary),
                  ),
                  deleteIcon: const Icon(
                    Icons.close,
                    color: kDarkTextSecondary,
                    size: 18,
                  ),
                  onDeleted: () => _removeAttachment(idx),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBoardSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            ['Urgente', 'Em Andamento', 'Concluído'].map((board) {
              bool isSelected = _selectedBoard == board;
              return GestureDetector(
                onTap: () => setState(() => _selectedBoard = board),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kAccentPurple : kDarkElementBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    board,
                    style: TextStyle(
                      color: isSelected ? kDarkTextPrimary : kDarkTextSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saveTask,
          child: const Text(
            'Salvar Tarefa',
            style: TextStyle(
              color: kDarkTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
>>>>>>> 29e6bff (telasnovas)
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Transform.translate(
<<<<<<< HEAD
      offset: const Offset(0, 30),
      child: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
=======
      offset: const Offset(0, 0),
      child: FloatingActionButton(
        backgroundColor: kAccentPurple,
>>>>>>> 29e6bff (telasnovas)
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
<<<<<<< HEAD

        child: const Icon(Icons.add, size: 28),
=======
        child: const Icon(Icons.add, size: 28, color: kDarkTextPrimary),
>>>>>>> 29e6bff (telasnovas)
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
<<<<<<< HEAD
      color: Colors.black,
=======
      color: kDarkSurface,
>>>>>>> 29e6bff (telasnovas)
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
<<<<<<< HEAD
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home_rounded),
                  color: Colors.blueAccent,
                  onPressed: () {},
                ),
                const SizedBox(width: 28),
                IconButton(
                  icon: const Icon(Icons.folder_rounded),
                  color: Colors.white30,
                  onPressed: () {},
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: Colors.white30,
                  onPressed: () {},
                ),
                const SizedBox(width: 28),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  color: Colors.white30,
                  onPressed: () {},
                ),
              ],
=======
            InkWell(
              onTap: () {},
              child: _bottomBarIcon(Icons.home_rounded, isActive: true),
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
              onTap: () {
                _navigateToRoute('/perfil');
              },
              child: _bottomBarIcon(Icons.person_outline),
>>>>>>> 29e6bff (telasnovas)
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _addMemberButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF8875FF), width: 2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Icon(Icons.add, color: Color(0xFF8875FF)),
            ),
          ),
          SizedBox(height: 4),
          Text('', style: TextStyle(color: Colors.white, fontSize: 12)),
=======
  Widget _bottomBarIcon(IconData icon, {bool isActive = false}) {
    return Icon(
      icon,
      color: isActive ? kAccentPurple : kDarkTextSecondary.withOpacity(0.6),
      size: 24,
    );
  }

  Widget _buildDimOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCardVisible = false;
          _slideController.reverse();
        });
      },
      child: Container(color: Colors.black.withOpacity(0.6)),
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
                    _navigateToRoute('/habitos');
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
                    _navigateToRoute('/criartime');
                  },
                  child: _menuItem(Icons.group_outlined, 'Criar Equipe'),
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
>>>>>>> 29e6bff (telasnovas)
        ],
      ),
    );
  }
<<<<<<< HEAD

  Widget _timeBox(String time) {
    return Padding(
      padding: const EdgeInsets.only(left: 26),
      child: Container(
        height: 44,
        width: 110,
        padding: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(time, style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildTextField(String initialValue) {
    return SizedBox(
      width: 360,
      height: 55,
      child: TextFormField(
        initialValue: initialValue,
        style: TextStyle(color: Colors.black),
        decoration: _whiteInputDecoration(),
      ),
    );
  }

  Widget _boardButton(
    String text, {
    bool selected = false,
    double leftPadding = 14,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Container(
        height: 38,
        width: 100,
        decoration: BoxDecoration(
          color: selected ? Color(0xFF8875FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
=======
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tarefas Modificado',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: kDarkPrimaryBg),
      home: const AddTaskPage(),
      debugShowCheckedModeBanner: false,
>>>>>>> 29e6bff (telasnovas)
    );
  }
}
