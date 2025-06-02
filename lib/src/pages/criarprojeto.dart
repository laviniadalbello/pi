import 'package:flutter/material.dart';
import 'iconedaia.dart';
import 'package:planify/services/gemini_service.dart';
import 'package:planify/services/firestore_tasks_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen>
    with TickerProviderStateMixin {
  late GeminiService _geminiService;
  late FirestoreTasksService _firestoreService;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _projectDueDateController = TextEditingController();
  final _memberEmailController = TextEditingController();

  final List<Map<String, String>> _teamMembers = [];

  String? _selectedPriority = 'Média';
  Color _selectedProjectColor = kAccentPurple;
  final List<Color> _availableProjectColors = [
    kAccentPurple,
    kAccentSecondary,
    Colors.pinkAccent.shade200,
    Colors.orangeAccent.shade200,
    Colors.teal.shade300,
    Colors.lightBlue.shade300,
  ];

  bool _isCardVisible = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<String> _attachments = [];

  final List<String> _emailsConvidados = []; // Lista de e-mails para convidar
  bool _isEnviandoConvites = false;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreTasksService(userId: 'userId');
    _geminiService =
        GeminiService(apiKey: 'AIzaSyBFS5lVuEZzNklLyta4ioepOs2DDw2xPGA');
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
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _projectDueDateController.dispose();
    _memberEmailController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushNamed(routeName);
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Membro',
            style: TextStyle(color: Colors.white)),
        backgroundColor: kDarkElementBg,
        content: TextField(
          controller: _memberEmailController,
          decoration: const InputDecoration(
            hintText: 'email@exemplo.com',
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancelar', style: TextStyle(color: kAccentPurple)),
          ),
          TextButton(
            onPressed: () {
              if (_validateEmail(_memberEmailController.text)) {
                setState(() {
                  _emailsConvidados.add(_memberEmailController.text);
                  _teamMembers.add({
                    "name": _memberEmailController.text.split('@')[0],
                    "email": _memberEmailController.text
                  });
                });
                Navigator.pop(context);
                _memberEmailController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('E-mail inválido!')),
                );
              }
            },
            child: const Text('Adicionar',
                style: TextStyle(color: kAccentSecondary)),
          ),
        ],
      ),
    );
  }

  bool _validateEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  Future<void> _selectDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: kDarkElementBg),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
      if (mounted) {
        setState(() {
          _projectDueDateController.text = formattedDate;
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final userId = user.uid;

        // Cria o projeto com ownerId e o próprio userId em members
        final projetoRef =
            await FirebaseFirestore.instance.collection('projects').add({
          'ownerId': userId,
          'name': _projectNameController.text,
          'description': _projectDescriptionController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'members': [userId], // só o criador inicialmente
          'color': _selectedProjectColor.value.toRadixString(16),
          'status': 'ativo'
        });

        // Envia convites para cada email adicionado
        for (final email in _emailsConvidados) {
          await FirebaseFirestore.instance.collection('invitations').add({
            'projectId': projetoRef.id,
            'fromUserId': userId,
            'toUserEmail': email,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Redireciona para a tela de projetos ou mostra sucesso
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar projeto: $e')),
        );
      }
    }
  }

  Future<void> _submitFormNovo() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser!;

        await FirebaseFirestore.instance.collection('projects').add({
          'userId': user.uid, // OBRIGATÓRIO pelas regras
          'name': _projectNameController.text, // OBRIGATÓRIO
          'description': _projectDescriptionController.text,
          'createdAt': FieldValue.serverTimestamp(), // OBRIGATÓRIO
          'members': [], // Adicione os membros aqui se desejar
          'color': _selectedProjectColor.value.toRadixString(16),
        });

        Navigator.pop(context, true); // Retorna sucesso
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar projeto: $e')),
        );
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: kDarkTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kDarkTextSecondary),
        filled: true,
        fillColor: kDarkElementBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: kAccentPurple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: kDarkTextSecondary)
            : null,
      ),
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, preencha este campo.';
            }
            return null;
          },
    );
  }

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
      bottom: 16,
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
            // Ícone de convites
            InkWell(
              onTap: () {
                _navigateToRoute('/convites');
              },
              child: _bottomBarIcon(Icons.mail_outline), // Ícone de convite
            ),
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

  void _pickFiles() async {
    if (mounted) {
      setState(() {
        _attachments.add("document_${_attachments.length + 1}.pdf");
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Arquivo "${_attachments.last}" anexado (simulação).',
            style: const TextStyle(color: kDarkTextPrimary),
          ),
          backgroundColor: kAccentSecondary,
        ),
      );
    }
    print("Função _pickFiles chamada.");
  }

  Widget _buildTeamMemberSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Botão de adicionar membro
          GestureDetector(
            onTap: _showAddMemberDialog,
            child: _buildAddMemberButton(),
          ),
          // Lista de membros existentes
          ..._teamMembers.map((member) => _buildMemberAvatar(member)),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(Map<String, String> member) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kDarkElementBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kDarkTextSecondary.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    member["name"]?.substring(0, 1).toUpperCase() ?? "?",
                    style: const TextStyle(
                      color: kDarkTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _teamMembers.removeWhere(
                          (m) => m["email"] == member["email"],
                        );
                      });
                    }
                  },
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: kDarkTextPrimary,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            member["name"] ?? "Sem nome",
            style: const TextStyle(color: kDarkTextSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberButton() {
    return GestureDetector(
      onTap: _showAddMemberDialog,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: kDarkElementBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: kDarkTextSecondary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.add, color: kDarkTextSecondary, size: 28),
            ),
            const SizedBox(height: 4),
            const Text(
              "Adic.",
              style: TextStyle(color: kDarkTextSecondary, fontSize: 12),
            ),
          ],
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
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkSurface,
          elevation: 0.5,
          iconTheme: IconThemeData(color: kDarkTextPrimary),
          titleTextStyle: TextStyle(
            color: kDarkTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: kDarkTextSecondary),
          filled: true,
          fillColor: kDarkElementBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kAccentPurple, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentPurple,
            foregroundColor: kDarkTextPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: kDarkElementBg,
          labelStyle: const TextStyle(color: kDarkTextPrimary),
          selectedColor: kAccentPurple,
          deleteIconColor: kDarkTextSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(color: kDarkBorder),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: kAccentPurple,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: kDarkElementBg),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Criar Novo Projeto'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Detalhes do Projeto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kDarkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _projectNameController,
                      'Nome do Projeto',
                      validator: (val) => val == null || val.isEmpty
                          ? "Nome do projeto é obrigatório"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _projectDescriptionController,
                      'Descrição do Projeto',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Membros do Projeto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kDarkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTeamMemberSection(), // Nova seção de membros
                    const SizedBox(height: 20),
                    _buildTextField(
                      _projectDueDateController,
                      'Data de Entrega (DD/MM/AAAA)',
                      onTap: _selectDueDate,
                      readOnly: true,
                      suffixIcon: Icons.calendar_today,
                      validator: (val) => val == null || val.isEmpty
                          ? "Data de entrega é obrigatória"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Prioridade do Projeto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kDarkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPrioritySelector(),
                    const SizedBox(height: 20),
                    const Text(
                      'Cor do Projeto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kDarkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildProjectColorSelector(),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isEnviandoConvites ? null : _submitForm,
                        child: _isEnviandoConvites
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Criar Projeto'),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            if (_isCardVisible) _buildDimOverlay(),
            if (_isCardVisible) _buildSlidingMenu(),
            Positioned(
              bottom: 12,
              right: -60,
              child: CloseableAiCard(
                geminiService: _geminiService,
                firestoreService: _firestoreService,
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

  Widget _buildPrioritySelector() {
    final priorities = ['Baixa', 'Média', 'Alta', 'Urgente'];
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      items: priorities.map((String priority) {
        return DropdownMenuItem<String>(
          value: priority,
          child: Text(priority),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (mounted) {
          setState(() {
            _selectedPriority = newValue;
          });
        }
      },
      decoration: InputDecoration(
        // labelText: 'Prioridade',
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
      ),
      dropdownColor: kDarkElementBg,
      style: const TextStyle(color: kDarkTextPrimary),
    );
  }

  Widget _buildProjectColorSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableProjectColors.length,
        itemBuilder: (context, index) {
          final color = _availableProjectColors[index];
          final bool isSelected = color == _selectedProjectColor;
          return GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() {
                  _selectedProjectColor = color;
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: kDarkTextPrimary.withOpacity(0.8),
                        width: 2.5,
                      )
                    : Border.all(color: Colors.transparent, width: 0),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: kDarkTextPrimary.withOpacity(0.8),
                      size: 20,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
