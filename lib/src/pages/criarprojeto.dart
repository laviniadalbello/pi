import 'package:flutter/material.dart';
import 'dart:math';


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
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _projectDueDateController = TextEditingController();
  final _memberEmailController = TextEditingController(); // Para o diálogo de adicionar membro


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
  // final Random _random = Random(); 

  
  bool _isFabMenuActive = false; 
  late AnimationController _fabMenuSlideController; 
  late Animation<Offset> _fabMenuSlideAnimation;

  
  List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    _fabMenuSlideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabMenuSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Slide de baixo para cima
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _fabMenuSlideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _projectDueDateController.dispose();
    _memberEmailController.dispose();
    _fabMenuSlideController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kDarkElementBg,
          title: const Text('Adicionar Membro', style: TextStyle(color: kDarkTextPrimary)),
          content: TextField(
            controller: _memberEmailController,
            style: const TextStyle(color: kDarkTextPrimary),
            decoration: InputDecoration(
              hintText: 'E-mail do membro',
              hintStyle: TextStyle(color: kDarkTextSecondary.withOpacity(0.7)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kDarkTextSecondary)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kAccentPurple)),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: kDarkTextSecondary)),
              onPressed: () {
                Navigator.of(context).pop();
                _memberEmailController.clear();
              },
            ),
            TextButton(
              child: const Text('Adicionar', style: TextStyle(color: kAccentPurple)),
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
                      content: const Text('Por favor, insira um e-mail válido.', style: TextStyle(color: kDarkTextPrimary)),
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
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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
          content: const Text('Projeto criado com sucesso! (Simulação)', style: TextStyle(color: kDarkTextPrimary)),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: kDarkTextSecondary) : null,
      ),
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
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
      ),
    );
  }

  Widget _buildDimOverlay() {
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
        child: Material(
          color: Colors.transparent,
          elevation: 8,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: kDarkElementBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 16),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: kAccentPurple,
                  elevation: 0,
                  shape: const CircleBorder(),
                  onPressed: _toggleFabMenuVisibility,
                  child: const Icon(Icons.close, size: 20, color: kDarkTextPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          ],
        ),
      ),
    );
  }

  void _pickFiles() async {
    
    if (mounted) {
      setState(() {
        _attachments.add("document_${_attachments.length + 1}.pdf");
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arquivo "${_attachments.last}" anexado (simulação).', style: const TextStyle(color: kDarkTextPrimary)), backgroundColor: kAccentSecondary)
      );
    }
    print("Função _pickFiles chamada.");
  }
  

  
  Widget _buildTeamMemberSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._teamMembers.map((member) {
            return _memberAvatar(member['imageUrl'], member['name']!);
          }).toList(),
          _addMemberButton(), // O botão "+"
        ],
      ),
    );
  }

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
        ],
      ),
    );
  }

  Widget _addMemberButton() {
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
                border: Border.all(color: kDarkTextSecondary.withOpacity(0.5), width: 1.5),
              ),
              child: const Icon(Icons.add, color: kDarkTextSecondary, size: 28),
            ),
            const SizedBox(height: 4),
            const Text("Adic.", style: TextStyle(color: kDarkTextSecondary, fontSize: 12)),
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
          titleTextStyle: TextStyle(color: kDarkTextPrimary, fontWeight: FontWeight.bold, fontSize: 18),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentPurple,
            foregroundColor: kDarkTextPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
        textSelectionTheme: const TextSelectionThemeData(cursorColor: kAccentPurple),
        dialogBackgroundColor: kDarkElementBg,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Criar Novo Projeto'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                    ),
                    const SizedBox(height: 12),
                    _buildTeamMemberSection(), // Nova seção de membros
                    const SizedBox(height: 20),
                    _buildTextField(_projectDueDateController, 'Data de Entrega (DD/MM/AAAA)', onTap: _selectDueDate, readOnly: true, suffixIcon: Icons.calendar_today, validator: (val) => val == null || val.isEmpty ? "Data de entrega é obrigatória" : null),
                    const SizedBox(height: 20),
                    const Text(
                      'Prioridade do Projeto',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kDarkTextSecondary),
                    ),
                    const SizedBox(height: 10),
                    _buildPrioritySelector(),
                    const SizedBox(height: 20),
                    const Text(
                      'Cor do Projeto',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kDarkTextSecondary),
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
                    const SizedBox(height: 100), // Espaço para o BottomAppBar e FAB
                  ],
                ),
              ),
            ),
            if (_isFabMenuActive) _buildDimOverlay(),
            if (_isFabMenuActive) _buildFabSlidingMenu(),
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
        // labelText: 'Prioridade', // Removido para consistência com _buildTextField
        filled: true,
        fillColor: kDarkElementBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kAccentPurple)),
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
                    ? Border.all(color: kDarkTextPrimary.withOpacity(0.8), width: 2.5) 
                    : Border.all(color: Colors.transparent, width: 0),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 5, spreadRadius: 1)]
                    : [],
              ),
              child: isSelected
                  ? Icon(Icons.check, color: kDarkTextPrimary.withOpacity(0.8), size: 20) // Ajuste na cor do ícone
                  : null,
            ),
          );
        },
      ),
    );
  }
}

