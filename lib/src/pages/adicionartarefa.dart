import 'package:flutter/material.dart';
import 'iconedaia.dart';
import 'package:planify/services/gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planify/services/firestore_tasks_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planify/models/task.dart';
import 'package:intl/intl.dart'; 
import 'package:planify/models/project_model.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isCardVisible = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late GeminiService _geminiService;
  late FirestoreTasksService _firestoreService; // Usado pelo CloseableAiCard
  late String _currentUserId;

  // Controladores para os campos de texto
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  // Adicione um controller para descrição se quiser salvar uma descrição
  // final TextEditingController _descriptionController = TextEditingController();

  // Variáveis de estado para os seletores
  String? _selectedPriority = 'Média'; // Prioridade padrão
  String? _selectedProjectId; // Para guardar o ID do projeto selecionado
  String _selectedProjectDisplay = 'Nenhum'; // Para exibir no dropdown

  List<Project> _fetchedProjects = []; // Lista de projetos buscados do Firestore
  List<DropdownMenuItem<String>> _projectDropdownItems = [
    const DropdownMenuItem<String>(value: 'Nenhum', child: Text('Nenhum')),
  ];

  Color _selectedTaskColor = kAccentPurple; // Cor padrão da tarefa
  final List<String> _attachments = []; // Mock de anexos
  String? _selectedBoardStatus = 'Em Andamento'; // Status inicial/board

  // Objetos DateTime e TimeOfDay para guardar os valores selecionados dos pickers
  DateTime? _selectedDateObject;
  TimeOfDay? _selectedStartTimeObject;
  TimeOfDay? _selectedEndTimeObject; // Se você for usar o horário de término para algo

  final List<Color> _availableTaskColors = [
    kAccentPurple, kAccentSecondary, Colors.pinkAccent, Colors.orangeAccent, Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _geminiService = GeminiService(apiKey: 'AIzaSyBFS5lVuEZzNklLyta4ioepOs2DDw2xPGA'); // ATENÇÃO: Use sua chave real

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _firestoreService = FirestoreTasksService(userId: _currentUserId);
      _loadAvailableProjects(); // Carrega os projetos para o dropdown
    } else {
      _currentUserId = 'anonymous_user'; // Fallback, mas idealmente o usuário deve estar logado
      _firestoreService = FirestoreTasksService(userId: _currentUserId);
      print("AVISO: Usuário não logado em AddTaskPage! Funcionalidades limitadas.");
    }

    // Valores iniciais para os controllers (opcional, pode deixar vazio)
    // _taskNameController.text = 'Mobile Application design';
    // _dateController.text = 'November 01, 2021'; // Melhor deixar vazio ou data atual
    // _startTimeController.text = '9:30 am';
    // _endTimeController.text = '12:30 am';
  }

  Future<void> _loadAvailableProjects() async {
    if (_currentUserId == 'anonymous_user') return;
    try {
      QuerySnapshot projectSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('userId', isEqualTo: _currentUserId)
          // Adicione .where('status', isNotEqualTo: 'arquivado') se necessário
          .orderBy('name')
          .get();

      List<Project> projects = projectSnapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
      
      List<DropdownMenuItem<String>> dropdownItems = [
        const DropdownMenuItem<String>(value: 'Nenhum', child: Text('Nenhum')),
      ];
      dropdownItems.addAll(projects.map((project) => DropdownMenuItem<String>(
        value: project.id, // O valor é o ID do projeto
        child: Text(project.name), // O texto exibido é o nome
      )));

      if (mounted) {
        setState(() {
          _fetchedProjects = projects;
          _projectDropdownItems = dropdownItems;
          // Se _selectedProjectDisplay ainda é 'Nenhum', _selectedProjectId será null (ou 'Nenhum' se você mapear assim)
          // Se você quiser um projeto padrão selecionado, pode definir aqui.
        });
      }
    } catch (e) {
      print("Erro ao carregar projetos para dropdown: $e");
      // Manter a lista apenas com "Nenhum" em caso de erro
       if (mounted) {
        setState(() {
          _projectDropdownItems = [const DropdownMenuItem<String>(value: 'Nenhum', child: Text('Nenhum'))];
        });
      }
    }
  }


  @override
  void dispose() {
    _slideController.dispose();
    _taskNameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _geminiService.close();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) Navigator.of(context).pop();
    Navigator.of(context).pushNamed(routeName);
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker( /* ... seu código do DatePicker ... */ 
      context: context, initialDate: _selectedDateObject ?? DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime(2101),
      builder: (context, child) => Theme( /* ... seu tema ... */ data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: kAccentPurple,onPrimary: kDarkTextPrimary,surface: kDarkSurface,onSurface: kDarkTextPrimary,),dialogTheme: const DialogThemeData(backgroundColor: kDarkElementBg),), child: child!),
    );
    if (picked != null) {
      setState(() {
        _selectedDateObject = picked; // GUARDA O DateTime
        _dateController.text = DateFormat('dd MMM, yyyy', 'pt_BR').format(picked); // Formato mais simples
      });
    }
  }

  String _getMonthName(int month) { /* Seu código _getMonthName aqui */ 
    const months = ['Janeiro','Fevereiro','Março','ABril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro',];
    return months[month - 1];
  }

  Future<void> _selectTime(TextEditingController controller, {bool isStartTime = true}) async {
    TimeOfDay? picked = await showTimePicker( /* ... seu código do TimePicker ... */ 
      context: context, initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme( /* ... seu tema ... */ data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: kAccentPurple,onPrimary: kDarkTextPrimary,surface: kDarkSurface,onSurface: kDarkTextPrimary,),dialogTheme: const DialogThemeData(backgroundColor: kDarkElementBg),), child: child!),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTimeObject = picked; // GUARDA O TimeOfDay
        } else {
          _selectedEndTimeObject = picked;
        }
        controller.text = picked.format(context);
      });
    }
  }

  void _pickFiles() { /* Sua lógica de anexos */ setState(() => _attachments.add("document_${_attachments.length + 1}.pdf"));}
  void _removeAttachment(int index) { /* Sua lógica de anexos */ setState(() => _attachments.removeAt(index));}

  Future<void> _saveTask() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    _formKey.currentState!.save();

    if (_currentUserId == 'anonymous_user') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Faça login para salvar tarefas.'), backgroundColor: Colors.red));
      return;
    }

    DateTime? taskDueDate;
    if (_selectedDateObject != null) {
      TimeOfDay timeToUse = _selectedStartTimeObject ?? const TimeOfDay(hour: 0, minute: 0); // Usa 00:00 se hora não selecionada
      taskDueDate = DateTime(
        _selectedDateObject!.year,
        _selectedDateObject!.month,
        _selectedDateObject!.day,
        timeToUse.hour,
        timeToUse.minute,
      );
    }

    // Mapear _selectedBoardStatus para o status da Task
    String taskStatus = 'pending'; // Default
    if (_selectedBoardStatus == 'Concluído') {
      taskStatus = 'completed';
    } else if (_selectedBoardStatus == 'Em Andamento') {
      taskStatus = 'pending'; // Ou 'in_progress' se seu modelo Task usar isso
    } // 'Urgente' pode ser mais para prioridade do que status

    // Se você quiser salvar a cor como string hexadecimal
    String? taskColorHex = '#${_selectedTaskColor.value.toRadixString(16).substring(2)}';


    final newTask = Task(
      id: '', // Firestore gerará
      title: _taskNameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty 
                 ? _descriptionController.text.trim() 
                 : null, // Adicione um controller se tiver campo de descrição
      dueDate: taskDueDate,
      priority: _selectedPriority?.toLowerCase(), // Salvar como 'baixa', 'média', 'alta'
      status: taskStatus,
      createdAt: DateTime.now(),
      userId: _currentUserId,
      isCompleted: taskStatus == 'completed',
      projectId: _selectedProjectId == 'Nenhum' ? null : _selectedProjectId, // Usa o ID do projeto
      progressPercentage: taskStatus == 'completed' ? 100 : 0,
      // taskColor: taskColorHex, // Se você adicionar 'taskColor' ao seu modelo Task
    );

    try {
      await FirebaseFirestore.instance.collection('tasks').add(newTask.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarefa salva com sucesso!'), backgroundColor: kAccentSecondary));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      print("Erro ao salvar tarefa no Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definir screenWidth e screenHeight aqui para estarem disponíveis para todos os _build métodos
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    // final screenHeight = screenSize.height; // Se não for usado, pode remover
    final horizontalPadding = screenWidth * 0.05; // Se for usado no padding principal

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kDarkPrimaryBg,
      // extendBody: true, // Verifique se isso é realmente necessário aqui, pode afetar o posicionamento do FAB
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(), // Garanta que este método usa o _currentPageIdentifier correto
      body: Stack( // Stack principal para overlays
        children: [
          SafeArea(
            child: Padding( // Padding geral da página
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      _buildTextField(_taskNameController, 'Ex: Design do App Mobile',
                        validator: (val) => val == null || val.isEmpty ? "Nome da tarefa é obrigatório" : null,
                      ),
                      const SizedBox(height: 30),
                     _buildLabel("Descrição (opcional)"), // Seu label está correto
const SizedBox(height: 8),
_buildTextField(
  _descriptionController, // <<< USE O NOVO CONTROLLER AQUI
  'Ex: Criar wireframes e protótipos detalhados para as telas X, Y e Z.', // Hint text para descrição
  // readOnly: false, // readOnly é false por padrão, não precisa especificar se for editável
  // validator: (val) => null, // Correto, descrição é opcional, sem validação
  // Você pode querer adicionar maxLines para o campo de descrição se espera um texto maior:
  // maxLines: 3, // Exemplo para permitir 3 linhas visíveis, com scroll se mais texto
),
                      const SizedBox(height: 30),
                      _buildLabel("Adicionar atividade em um projeto:"),
                      const SizedBox(height: 10),
                      _buildProjectSelector(), // Este método agora usa _projectDropdownItems
                      const SizedBox(height: 35),
                      _buildLabel("Data"),
                      const SizedBox(height: 8),
                      _buildTextField(_dateController, 'Selecione a data', readOnly: true, onTap: _selectDate, suffixIcon: Icons.calendar_today,
                        validator: (val) => val == null || val.isEmpty ? "Data é obrigatória" : null,
                      ),
                      const SizedBox(height: 34),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildLabel("Hora de Início"), const SizedBox(height: 8),
                          _buildTextField(_startTimeController, 'Ex: 9:30 am', readOnly: true, onTap: () => _selectTime(_startTimeController, isStartTime: true), suffixIcon: Icons.access_time,
                            validator: (val) => val == null || val.isEmpty ? "Hora de início é obrigatória" : null,
                          ),
                        ])),
                        const SizedBox(width: 20),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildLabel("Hora de Término"), const SizedBox(height: 8),
                          _buildTextField(_endTimeController, 'Ex: 12:30 pm', readOnly: true, onTap: () => _selectTime(_endTimeController, isStartTime: false), suffixIcon: Icons.access_time,
                            validator: (val) => val == null || val.isEmpty ? "Hora de término é obrigatória" : null,
                          ),
                        ])),
                      ]),
                      const SizedBox(height: 35),
                      _buildLabel("Prioridade"), const SizedBox(height: 10),
                      _buildPrioritySelector(),
                      const SizedBox(height: 35),
                      _buildLabel("Cor da Tarefa"), const SizedBox(height: 10),
                      _buildTaskColorSelector(),
                      const SizedBox(height: 35),
                      _buildLabel("Anexos"), const SizedBox(height: 10),
                      _buildAttachmentSection(),
                      const SizedBox(height: 35),
                      _buildLabel("Status da Tarefa"), // Mudei o label de "Tipo" para "Status da Tarefa"
                      const SizedBox(height: 10),
                      _buildBoardSelector(), // Este seleciona o status
                      const SizedBox(height: 60),
                      _buildSaveButton(),
                      const SizedBox(height: 100), // Espaço para o FAB e BottomNav se extendBody for false ou para scroll
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Overlays (Dim, SlidingMenu, Chatbot)
          if (_isCardVisible) _buildDimOverlay(),
          if (_isCardVisible) _buildSlidingMenu(), // _buildSlidingMenu já é Positioned
          
          // Chatbot posicionado como nas outras telas
          if (_firestoreService != null) // Garante que o serviço está pronto
            Positioned(
              bottom: -26, // Posição consistente
              right: -60,
              child: CloseableAiCard(
                geminiService: _geminiService,
                firestoreService: _firestoreService, // Passa a instância correta
                scaleFactor: MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
                enableScroll: true,
              ),
            ),
        ],
      ),
    );
  }

  // Método _buildHeader (como você forneceu)
  Widget _buildHeader() { /* ... seu código ... */ return Stack(children: [Align(alignment: Alignment.topLeft, child: GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: kDarkTextPrimary, size: 30))), const Center(child: Padding(padding: EdgeInsets.only(top: 0), child: Text('Adicionar Tarefa', style: TextStyle(color: kDarkTextPrimary, fontSize: 22, fontWeight: FontWeight.bold))))]); }

  // Método _buildLabel (como você forneceu)
  Widget _buildLabel(String text) { /* ... seu código ... */ return Text(text, style: const TextStyle(color: kDarkTextSecondary, fontSize: 16)); }

  // Método _buildTextField (como você forneceu)
  Widget _buildTextField(TextEditingController controller, String hintText, {bool readOnly = false, VoidCallback? onTap, IconData? suffixIcon, String? Function(String?)? validator}) { /* ... seu código ... */ return TextFormField(controller: controller, readOnly: readOnly, onTap: onTap, style: const TextStyle(color: kDarkTextPrimary), decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(color: kDarkTextSecondary.withOpacity(0.7)), filled: true, fillColor: kDarkElementBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kAccentPurple)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: kDarkTextSecondary) : null), validator: validator); }

  // Método _buildProjectSelector MODIFICADO para usar _projectDropdownItems e _selectedProjectId
  Widget _buildProjectSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedProjectId ?? 'Nenhum', // Usa o ID, mas o default pode ser 'Nenhum' se nada foi carregado/selecionado
      dropdownColor: kDarkElementBg,
      style: const TextStyle(color: kDarkTextPrimary),
      decoration: InputDecoration( /* ... sua decoração ... */ filled: true, fillColor: kDarkElementBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      items: _projectDropdownItems, // Usa a lista de DropdownMenuItem<String>
      onChanged: (String? newProjectId) {
        setState(() {
          _selectedProjectId = newProjectId;
          // Opcional: atualizar _selectedProjectDisplay se precisar mostrar o nome em outro lugar
          if (newProjectId == 'Nenhum') {
            _selectedProjectDisplay = 'Nenhum';
          } else {
            _selectedProjectDisplay = _fetchedProjects.firstWhere((p) => p.id == newProjectId, orElse: () => Project(id: '', name: 'Erro', description: '', color: '', userId: '', status: '', members: [], createdAt: Timestamp.now())).name;
          }
        });
      },
      validator: (value) => (value == null || value == 'Nenhum' && _projectDropdownItems.length > 1) // Valida se 'Nenhum' é uma escolha válida
          ? null // Permite "Nenhum"
          : (value == null ? 'Selecione um projeto' : null),
    );
  }

  // Método _buildPrioritySelector (como você forneceu)
  Widget _buildPrioritySelector() { /* ... seu código ... */ return DropdownButtonFormField<String>(value: _selectedPriority, dropdownColor: kDarkElementBg, style: const TextStyle(color: kDarkTextPrimary), decoration: InputDecoration(filled: true, fillColor: kDarkElementBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), items: ['Baixa', 'Média', 'Alta'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(), onChanged: (String? newValue) => setState(() => _selectedPriority = newValue!)); }

  // Método _buildTaskColorSelector (como você forneceu)
  Widget _buildTaskColorSelector() { /* ... seu código ... */ return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: _availableTaskColors.map((color) { bool isSelected = _selectedTaskColor == color; return GestureDetector(onTap: () => setState(() => _selectedTaskColor = color), child: Container(margin: const EdgeInsets.only(right: 10), width: 36, height: 36, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: isSelected ? kDarkTextPrimary : Colors.transparent, width: 2.5)))); }).toList())); }

  // Método _buildAttachmentSection (como você forneceu)
  Widget _buildAttachmentSection() { /* ... seu código ... */ return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ElevatedButton.icon(icon: const Icon(Icons.attach_file, color: kDarkTextPrimary, size: 20), label: const Text('Adicionar Anexo', style: TextStyle(color: kDarkTextPrimary)), onPressed: _pickFiles, style: ElevatedButton.styleFrom(backgroundColor: kDarkElementBg, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 10), Wrap(spacing: 8.0, runSpacing: 4.0, children: _attachments.asMap().entries.map((entry) { int idx = entry.key; String fileName = entry.value; return Chip(backgroundColor: kDarkElementBg, label: Text(fileName, style: const TextStyle(color: kDarkTextSecondary)), deleteIcon: const Icon(Icons.close, color: kDarkTextSecondary, size: 18), onDeleted: () => _removeAttachment(idx)); }).toList())]); }

  // Método _buildBoardSelector (como você forneceu, mas o label no build() foi mudado para "Status da Tarefa")
  Widget _buildBoardSelector() { /* ... seu código ... */ return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['Urgente', 'Em Andamento', 'Concluído'].map((board) { bool isSelected = _selectedBoardStatus == board; return GestureDetector(onTap: () => setState(() => _selectedBoardStatus = board), child: Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: isSelected ? kAccentPurple : kDarkElementBg, borderRadius: BorderRadius.circular(10)), child: Text(board, style: TextStyle(color: isSelected ? kDarkTextPrimary : kDarkTextSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)))); }).toList())); }
  
  // Método _buildSaveButton (como você forneceu)
  Widget _buildSaveButton() { /* ... seu código ... */ return Center(child: SizedBox(width: 200, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kAccentSecondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _saveTask, child: const Text('Salvar Tarefa', style: TextStyle(color: kDarkTextPrimary, fontSize: 16, fontWeight: FontWeight.bold))))); }

  // Métodos de FAB e BottomBar (como você forneceu, mas _buildBottomBar foi ajustado para consistência)
  Widget _buildFloatingActionButton() { /* ... seu código ... */ return Transform.translate(offset: const Offset(0,0), child: FloatingActionButton(backgroundColor: kAccentPurple, elevation: 6, shape: const CircleBorder(), onPressed: (){setState((){_isCardVisible = !_isCardVisible; if(_isCardVisible){_slideController.forward();}else{_slideController.reverse();}});}, child: const Icon(Icons.add, size: 28, color: kDarkTextPrimary))); }
  
  Widget _buildBottomBar() {
    // Adotando a lógica de passar a rota atual para destacar o ícone correto
    // Para AddTaskPage, nenhum ícone da barra principal estaria "ativo"
    // a menos que você a considere uma sub-página de /habitos, por exemplo.
    // Ou você pode definir uma String _currentPageRoute = '/adicionartarefa'; e não ter nenhum ativo.
    // Por simplicidade, vou assumir que nenhum está ativo na AddTaskPage.
    const String currentPageRouteForAddTask = '/adicionartarefa_interna'; // Rota fictícia para não ativar outros

    return BottomAppBar(
      color: kDarkSurface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      // height: 60, // Removido para consistência com PerfilPage, se desejado
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ou spaceAround
          children: [
            _bottomBarIcon(Icons.home_rounded, isActive: currentPageRouteForAddTask == '/habitos', onTap: () => _navigateToRoute('/habitos')),
            _bottomBarIcon(Icons.settings_outlined, isActive: currentPageRouteForAddTask == '/settings', onTap: () => _navigateToRoute('/settings')),
            const SizedBox(width: 40),
            _bottomBarIcon(Icons.book_outlined, isActive: currentPageRouteForAddTask == '/planner', onTap: () => _navigateToRoute('/planner')),
            _bottomBarIcon(Icons.person_outline, isActive: currentPageRouteForAddTask == '/perfil', onTap: () => _navigateToRoute('/perfil')),
          ],
        ),
      ),
    );
  }

  Widget _bottomBarIcon(IconData icon, {bool isActive = false, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(icon, color: isActive ? kAccentPurple : kDarkTextSecondary.withOpacity(0.6), size: 26),
      onPressed: onTap,
      padding: const EdgeInsets.all(12),
    );
  }
  Widget _buildDimOverlay() { /* ... seu código ... */ return GestureDetector(onTap: () => setState((){ _isCardVisible = false; _slideController.reverse(); }), child: Container(color: Colors.black.withOpacity(0.6)));}
  Widget _buildSlidingMenu() { /* ... seu código ... */ return Positioned(bottom: 80, left: 30, right: 30, child: SlideTransition(position: _slideAnimation, child: Material(color: Colors.transparent, elevation: 8, borderRadius: BorderRadius.circular(24), child: Container(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24), decoration: BoxDecoration(color: kDarkElementBg, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0,6))]), child: Column(mainAxisSize: MainAxisSize.min, children: [ InkWell(onTap: (){ setState((){ _isCardVisible = false; _slideController.reverse(); }); _navigateToRoute('/adicionartarefa'); }, child: _menuItem(Icons.edit_outlined, 'Criar Tarefa')), const SizedBox(height: 12), InkWell(onTap: (){ setState((){ _isCardVisible = false; _slideController.reverse(); }); _navigateToRoute('/criarprojeto'); }, child: _menuItem(Icons.add_circle_outline, 'Criar Projeto')), const SizedBox(height: 12), InkWell(onTap: (){ setState((){ _isCardVisible = false; _slideController.reverse(); }); _navigateToRoute('/criartime'); }, child: _menuItem(Icons.group_outlined, 'Criar Equipe')), const SizedBox(height: 12), InkWell(onTap: (){ setState((){ _isCardVisible = false; _slideController.reverse(); }); _navigateToRoute('/criarevento'); }, child: _menuItem(Icons.schedule_outlined, 'Criar Evento')), const SizedBox(height: 16), FloatingActionButton(mini: true, backgroundColor: kAccentPurple, elevation: 0, shape: const CircleBorder(), onPressed: (){ setState((){ _isCardVisible = false; _slideController.reverse(); });}, child: const Icon(Icons.close, size: 20, color: kDarkTextPrimary))]))))); }
  Widget _menuItem(IconData icon, String label) { /* ... seu código ... */ return Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), decoration: BoxDecoration(border: Border.all(color: kDarkBorder.withOpacity(0.5)), borderRadius: BorderRadius.circular(16), color: kDarkSurface.withOpacity(0.5)), child: Row(children: [ Icon(icon, color: kDarkTextSecondary, size: 20), const SizedBox(width: 12), Text(label, style: const TextStyle(color: kDarkTextSecondary, fontSize: 14))])); }

}

// main() e MyApp() para teste, remova se for parte de um app maior
// void main() {
//   // WidgetsFlutterBinding.ensureInitialized(); // Adicione se precisar inicializar Firebase antes
//   // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Exemplo
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'App de Tarefas Modificado',
//       theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: kDarkPrimaryBg),
//       home: const AddTaskPage(), // Testando AddTaskPage
//       debugShowCheckedModeBanner: false,
//       // Defina suas rotas aqui se _navigateToRoute for usado extensivamente
//       // routes: {
//       //   '/habitos': (context) => HabitsScreen(geminiService: GeminiService(apiKey: 'SUA_CHAVE')),
//       //   '/settings': (context) => SettingsPage(),
//       //   '/planner': (context) => PlannerPage(),
//       //   '/perfil': (context) => PerfilPage(),
//       //   // adicione outras rotas
//       // },
//     );
//   }
// }