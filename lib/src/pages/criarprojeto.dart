import 'package:flutter/material.dart';
import 'dart:math';
<<<<<<< HEAD

=======
import 'iconedaia.dart';
>>>>>>> 29e6bff (telasnovas)

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

<<<<<<< HEAD

=======
>>>>>>> 29e6bff (telasnovas)
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _projectDueDateController = TextEditingController();
  final _memberEmailController = TextEditingController(); // Para o diálogo de adicionar membro

=======
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _projectDueDateController = TextEditingController();
  final _memberEmailController = TextEditingController();
>>>>>>> 29e6bff (telasnovas)

  List<Map<String, String>> _teamMembers = [];

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
<<<<<<< HEAD
  // final Random _random = Random(); 

  
  bool _isFabMenuActive = false; 
  late AnimationController _fabMenuSlideController; 
  late Animation<Offset> _fabMenuSlideAnimation;

  
=======

  bool _isCardVisible = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

>>>>>>> 29e6bff (telasnovas)
  List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _fabMenuSlideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabMenuSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Slide de baixo para cima
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _fabMenuSlideController, curve: Curves.easeOut));
=======
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
>>>>>>> 29e6bff (telasnovas)
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _projectDueDateController.dispose();
    _memberEmailController.dispose();
<<<<<<< HEAD
    _fabMenuSlideController.dispose();
    super.dispose();
  }

=======
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushNamed(routeName);
  }

>>>>>>> 29e6bff (telasnovas)
  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kDarkElementBg,
<<<<<<< HEAD
          title: const Text('Adicionar Membro', style: TextStyle(color: kDarkTextPrimary)),
=======
          title: const Text(
            'Adicionar Membro',
            style: TextStyle(color: kDarkTextPrimary),
          ),
>>>>>>> 29e6bff (telasnovas)
          content: TextField(
            controller: _memberEmailController,
            style: const TextStyle(color: kDarkTextPrimary),
            decoration: InputDecoration(
              hintText: 'E-mail do membro',
              hintStyle: TextStyle(color: kDarkTextSecondary.withOpacity(0.7)),
<<<<<<< HEAD
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kDarkTextSecondary)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kAccentPurple)),
=======
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kDarkTextSecondary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kAccentPurple),
              ),
>>>>>>> 29e6bff (telasnovas)
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
<<<<<<< HEAD
              child: const Text('Cancelar', style: TextStyle(color: kDarkTextSecondary)),
=======
              child: const Text(
                'Cancelar',
                style: TextStyle(color: kDarkTextSecondary),
              ),
>>>>>>> 29e6bff (telasnovas)
              onPressed: () {
                Navigator.of(context).pop();
                _memberEmailController.clear();
              },
            ),
            TextButton(
<<<<<<< HEAD
              child: const Text('Adicionar', style: TextStyle(color: kAccentPurple)),
=======
              child: const Text(
                'Adicionar',
                style: TextStyle(color: kAccentPurple),
              ),
>>>>>>> 29e6bff (telasnovas)
              onPressed: () {
                if (_memberEmailController.text.isNotEmpty &&
                    _memberEmailController.text.contains('@')) {
                  if (mounted) {
                    setState(() {
                      String email = _memberEmailController.text;
                      String name = email.split('@')[0];
                      if (name.isNotEmpty) {
                        name = name[0].toUpperCase() + name.substring(1);
                      }
                      _teamMembers.add({"name": name, "email": email});
                    });
                  }
                  Navigator.of(context).pop();
                  _memberEmailController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
<<<<<<< HEAD
                      content: const Text('Por favor, insira um e-mail válido.', style: TextStyle(color: kDarkTextPrimary)),
=======
                      content: const Text(
                        'Por favor, insira um e-mail válido.',
                        style: TextStyle(color: kDarkTextPrimary),
                      ),
>>>>>>> 29e6bff (telasnovas)
                      backgroundColor: kDarkElementBg,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
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
            dialogBackgroundColor: kDarkElementBg,
<<<<<<< HEAD
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
=======
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
>>>>>>> 29e6bff (telasnovas)
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Lógica de submissão do formulário
      print("Nome do Projeto: ${_projectNameController.text}");
      print("Descrição: ${_projectDescriptionController.text}");
      print("Data de Entrega: ${_projectDueDateController.text}");
      print("Membros: ${_teamMembers}");
      print("Prioridade: $_selectedPriority");
      print("Cor: $_selectedProjectColor");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
<<<<<<< HEAD
          content: const Text('Projeto criado com sucesso! (Simulação)', style: TextStyle(color: kDarkTextPrimary)),
=======
          content: const Text(
            'Projeto criado com sucesso! (Simulação)',
            style: TextStyle(color: kDarkTextPrimary),
          ),
>>>>>>> 29e6bff (telasnovas)
          backgroundColor: kAccentSecondary,
        ),
      );
      // Navigator.pop(context); // Opcional: fechar a tela após submissão
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
<<<<<<< HEAD
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: kDarkTextSecondary) : null,
=======
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        suffixIcon:
            suffixIcon != null
                ? Icon(suffixIcon, color: kDarkTextSecondary)
                : null,
>>>>>>> 29e6bff (telasnovas)
      ),
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
<<<<<<< HEAD
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, preencha este campo.';
        }
        return null;
      },
    );
  }
  void _toggleFabMenuVisibility() {
    if (mounted) {
      setState(() {
        _isFabMenuActive = !_isFabMenuActive;
        if (_isFabMenuActive) {
          _fabMenuSlideController.forward();
        } else {
          _fabMenuSlideController.reverse();
        }
      });
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: kAccentPurple,
      elevation: 6,
      shape: const CircleBorder(),
      onPressed: _toggleFabMenuVisibility,
      child: Icon(
        _isFabMenuActive ? Icons.close : Icons.add,
        color: kDarkTextPrimary,
        size: 28,
=======
      validator:
          validator ??
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
>>>>>>> 29e6bff (telasnovas)
      ),
    );
  }

  Widget _buildDimOverlay() {
<<<<<<< HEAD
    return GestureDetector(
      onTap: _toggleFabMenuVisibility,
      child: Container(color: Colors.black.withOpacity(0.6)),
    );
  }

  Widget _buildFabSlidingMenu() {
    return Positioned(
      bottom: 80, 
      left: 30,
      right: 30,
      child: SlideTransition(
        position: _fabMenuSlideAnimation,
=======
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
>>>>>>> 29e6bff (telasnovas)
        child: Material(
          color: Colors.transparent,
          elevation: 8,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: kDarkElementBg,
              borderRadius: BorderRadius.circular(24),
<<<<<<< HEAD
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
=======
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
>>>>>>> 29e6bff (telasnovas)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
<<<<<<< HEAD
                _menuItem(Icons.attach_file, 'Anexar Arquivo', onTapAction: _pickFiles),
                const SizedBox(height: 12),
                _menuItem(Icons.notifications_none_outlined, 'Definir Lembrete', onTapAction: () {
                  print("Definir Lembrete Tocado");
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lembrete (simulação)")));
                }),
                const SizedBox(height: 12),
                _menuItem(Icons.format_list_bulleted, 'Adicionar Subtarefa', onTapAction: () {
                   print("Adicionar Subtarefa Tocado");
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subtarefa (simulação)")));
                }),
                const SizedBox(height: 12),
                _menuItem(Icons.comment_outlined, 'Comentários', onTapAction: () {
                  print("Comentários Tocado");
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Comentários (simulação)")));
                }),
=======
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
>>>>>>> 29e6bff (telasnovas)
                const SizedBox(height: 16),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: kAccentPurple,
                  elevation: 0,
                  shape: const CircleBorder(),
<<<<<<< HEAD
                  onPressed: _toggleFabMenuVisibility,
                  child: const Icon(Icons.close, size: 20, color: kDarkTextPrimary),
=======
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
>>>>>>> 29e6bff (telasnovas)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _menuItem(IconData icon, String label, {VoidCallback? onTapAction}) {
    return GestureDetector(
      onTap: () {
        if (onTapAction != null) {
          onTapAction();
        }
        _toggleFabMenuVisibility(); // Fecha o menu após a ação
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: kDarkSurface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDarkBorder.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: kDarkTextSecondary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: kDarkTextSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
=======
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
              onTap: () {
                _navigateToRoute('/perfil');
              },
              child: _bottomBarIcon(Icons.person_outline),
            ),
>>>>>>> 29e6bff (telasnovas)
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  void _pickFiles() async {
    
=======
  Widget _bottomBarIcon(IconData icon, {bool isActive = false}) {
    return Icon(
      icon,
      color: isActive ? kAccentPurple : kDarkTextSecondary.withOpacity(0.6),
      size: 24,
    );
  }

  void _pickFiles() async {
>>>>>>> 29e6bff (telasnovas)
    if (mounted) {
      setState(() {
        _attachments.add("document_${_attachments.length + 1}.pdf");
      });
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        SnackBar(content: Text('Arquivo "${_attachments.last}" anexado (simulação).', style: const TextStyle(color: kDarkTextPrimary)), backgroundColor: kAccentSecondary)
=======
        SnackBar(
          content: Text(
            'Arquivo "${_attachments.last}" anexado (simulação).',
            style: const TextStyle(color: kDarkTextPrimary),
          ),
          backgroundColor: kAccentSecondary,
        ),
>>>>>>> 29e6bff (telasnovas)
      );
    }
    print("Função _pickFiles chamada.");
  }
<<<<<<< HEAD
  

  
=======

>>>>>>> 29e6bff (telasnovas)
  Widget _buildTeamMemberSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
<<<<<<< HEAD
          ..._teamMembers.map((member) {
            return _memberAvatar(member['imageUrl'], member['name']!);
          }).toList(),
          _addMemberButton(), // O botão "+"
=======
          // Botão de adicionar membro
          GestureDetector(
            onTap: _showAddMemberDialog,
            child: _buildAddMemberButton(),
          ),
          // Lista de membros existentes
          ..._teamMembers.map((member) => _buildMemberAvatar(member)).toList(),
>>>>>>> 29e6bff (telasnovas)
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _memberAvatar(String? imageUrl, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: kDarkElementBg,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: kDarkTextPrimary, fontWeight: FontWeight.bold, fontSize: 18)) : null,
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: kDarkTextSecondary, fontSize: 12)),
=======
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
>>>>>>> 29e6bff (telasnovas)
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _addMemberButton() {
=======
  Widget _buildAddMemberButton() {
>>>>>>> 29e6bff (telasnovas)
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
<<<<<<< HEAD
                border: Border.all(color: kDarkTextSecondary.withOpacity(0.5), width: 1.5),
=======
                border: Border.all(
                  color: kDarkTextSecondary.withOpacity(0.5),
                  width: 1.5,
                ),
>>>>>>> 29e6bff (telasnovas)
              ),
              child: const Icon(Icons.add, color: kDarkTextSecondary, size: 28),
            ),
            const SizedBox(height: 4),
<<<<<<< HEAD
            const Text("Adic.", style: TextStyle(color: kDarkTextSecondary, fontSize: 12)),
=======
            const Text(
              "Adic.",
              style: TextStyle(color: kDarkTextSecondary, fontSize: 12),
            ),
>>>>>>> 29e6bff (telasnovas)
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
  
=======

>>>>>>> 29e6bff (telasnovas)
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
          background: kDarkPrimaryBg,
          error: Colors.redAccent,
          onPrimary: kDarkTextPrimary,
          onSecondary: kDarkTextPrimary,
          onSurface: kDarkTextPrimary,
          onBackground: kDarkTextPrimary,
          onError: kDarkTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkSurface,
          elevation: 0.5,
          iconTheme: IconThemeData(color: kDarkTextPrimary),
<<<<<<< HEAD
          titleTextStyle: TextStyle(color: kDarkTextPrimary, fontWeight: FontWeight.bold, fontSize: 18),
=======
          titleTextStyle: TextStyle(
            color: kDarkTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
>>>>>>> 29e6bff (telasnovas)
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
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: kAccentPurple, width: 1.5),
          ),
<<<<<<< HEAD
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
=======
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
>>>>>>> 29e6bff (telasnovas)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentPurple,
            foregroundColor: kDarkTextPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
<<<<<<< HEAD
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
=======
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
>>>>>>> 29e6bff (telasnovas)
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
<<<<<<< HEAD
        textSelectionTheme: const TextSelectionThemeData(cursorColor: kAccentPurple),
        dialogBackgroundColor: kDarkElementBg,
      ),
      child: Scaffold(
=======
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: kAccentPurple,
        ),
        dialogBackgroundColor: kDarkElementBg,
      ),
      child: Scaffold(
        key: _scaffoldKey,
>>>>>>> 29e6bff (telasnovas)
        appBar: AppBar(
          title: const Text('Criar Novo Projeto'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
<<<<<<< HEAD
        bottomNavigationBar: BottomAppBar(
            color: kDarkSurface,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(icon: const Icon(Icons.home_outlined, color: kDarkTextSecondary), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.folder_outlined, color: kDarkTextSecondary), onPressed: () {}),
                  const SizedBox(width: 40), // Espaço para o FAB
                  IconButton(icon: const Icon(Icons.bar_chart_outlined, color: kDarkTextSecondary), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.person_outline, color: kDarkTextSecondary), onPressed: () {}),
                ],
              ),
            ),
        ),
=======
        bottomNavigationBar: _buildBottomBar(),
>>>>>>> 29e6bff (telasnovas)
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
<<<<<<< HEAD
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkTextPrimary),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_projectNameController, 'Nome do Projeto', validator: (val) => val == null || val.isEmpty ? "Nome do projeto é obrigatório" : null),
                    const SizedBox(height: 20),
                    _buildTextField(_projectDescriptionController, 'Descrição do Projeto', maxLines: 3),
                    const SizedBox(height: 20),
                    const Text(
                      'Membros do Projeto',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kDarkTextSecondary),
=======
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
                      validator:
                          (val) =>
                              val == null || val.isEmpty
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
>>>>>>> 29e6bff (telasnovas)
                    ),
                    const SizedBox(height: 12),
                    _buildTeamMemberSection(), // Nova seção de membros
                    const SizedBox(height: 20),
<<<<<<< HEAD
                    _buildTextField(_projectDueDateController, 'Data de Entrega (DD/MM/AAAA)', onTap: _selectDueDate, readOnly: true, suffixIcon: Icons.calendar_today, validator: (val) => val == null || val.isEmpty ? "Data de entrega é obrigatória" : null),
                    const SizedBox(height: 20),
                    const Text(
                      'Prioridade do Projeto',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kDarkTextSecondary),
=======
                    _buildTextField(
                      _projectDueDateController,
                      'Data de Entrega (DD/MM/AAAA)',
                      onTap: _selectDueDate,
                      readOnly: true,
                      suffixIcon: Icons.calendar_today,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
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
>>>>>>> 29e6bff (telasnovas)
                    ),
                    const SizedBox(height: 10),
                    _buildPrioritySelector(),
                    const SizedBox(height: 20),
                    const Text(
                      'Cor do Projeto',
<<<<<<< HEAD
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kDarkTextSecondary),
=======
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kDarkTextSecondary,
                      ),
>>>>>>> 29e6bff (telasnovas)
                    ),
                    const SizedBox(height: 10),
                    _buildProjectColorSelector(),
                    const SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Criar Projeto'),
                      ),
                    ),
<<<<<<< HEAD
                    const SizedBox(height: 100), // Espaço para o BottomAppBar e FAB
=======
                    const SizedBox(height: 100),
>>>>>>> 29e6bff (telasnovas)
                  ],
                ),
              ),
            ),
<<<<<<< HEAD
            if (_isFabMenuActive) _buildDimOverlay(),
            if (_isFabMenuActive) _buildFabSlidingMenu(),
=======
            if (_isCardVisible) _buildDimOverlay(),
            if (_isCardVisible) _buildSlidingMenu(),
            Positioned(
              bottom: 12,
              right: -60,
              child: CloseableAiCard(
                scaleFactor:
                    MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
                enableScroll: true,
              ),
            ),
>>>>>>> 29e6bff (telasnovas)
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final priorities = ['Baixa', 'Média', 'Alta', 'Urgente'];
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
<<<<<<< HEAD
      items: priorities.map((String priority) {
        return DropdownMenuItem<String>(
          value: priority,
          child: Text(priority),
        );
      }).toList(),
=======
      items:
          priorities.map((String priority) {
            return DropdownMenuItem<String>(
              value: priority,
              child: Text(priority),
            );
          }).toList(),
>>>>>>> 29e6bff (telasnovas)
      onChanged: (String? newValue) {
        if (mounted) {
          setState(() {
            _selectedPriority = newValue;
          });
        }
      },
      decoration: InputDecoration(
<<<<<<< HEAD
        // labelText: 'Prioridade', // Removido para consistência com _buildTextField
        filled: true,
        fillColor: kDarkElementBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kAccentPurple)),
=======
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
>>>>>>> 29e6bff (telasnovas)
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
<<<<<<< HEAD
                border: isSelected
                    ? Border.all(color: kDarkTextPrimary.withOpacity(0.8), width: 2.5) 
                    : Border.all(color: Colors.transparent, width: 0),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 5, spreadRadius: 1)]
                    : [],
              ),
              child: isSelected
                  ? Icon(Icons.check, color: kDarkTextPrimary.withOpacity(0.8), size: 20) // Ajuste na cor do ícone
                  : null,
=======
                border:
                    isSelected
                        ? Border.all(
                          color: kDarkTextPrimary.withOpacity(0.8),
                          width: 2.5,
                        )
                        : Border.all(color: Colors.transparent, width: 0),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ]
                        : [],
              ),
              child:
                  isSelected
                      ? Icon(
                        Icons.check,
                        color: kDarkTextPrimary.withOpacity(0.8),
                        size: 20,
                      )
                      : null,
>>>>>>> 29e6bff (telasnovas)
            ),
          );
        },
      ),
    );
  }
}
<<<<<<< HEAD

=======
>>>>>>> 29e6bff (telasnovas)
