import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:planify/services/firestore_tasks_service.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage>
    with TickerProviderStateMixin {
  late final FirestoreTasksService _firestoreService;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // Adicionado scaffoldKey
  bool _isCardVisible = false;
  String _selectedType = 'Private';
  File? _logoImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _memberEmailController = TextEditingController();
  final List<Map<String, String>> _teamMembers = [
    {"name": "Jeny", "imageUrl": "assets/jeny.png"},
    {"name": "Mehrin", "imageUrl": "assets/mehrin.png"},
    {"name": "Avishek", "imageUrl": "assets/avishek.png"},
    {"name": "Jafor", "imageUrl": "assets/jafor.png"},
  ];

  late AnimationController _circleController;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreTasksService(userId: 'userId');
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
  }

  @override
  void dispose() {
    _circleController.dispose();
    _slideController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushNamed(routeName);
  }

  Future<void> _pickLogoImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kDarkElementBg,
          title: const Text(
            'Adicionar Membro',
            style: TextStyle(
              color: kDarkTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _memberEmailController,
            style: const TextStyle(color: kDarkTextPrimary),
            decoration: InputDecoration(
              hintText: 'E-mail do membro',
              hintStyle: TextStyle(color: kDarkTextSecondary.withOpacity(0.7)),
              filled: true,
              fillColor: kDarkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kAccentPurple, width: 1),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: kDarkTextSecondary, fontSize: 14),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _memberEmailController.clear();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Adicionar',
                style: TextStyle(
                  color: kDarkTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (_memberEmailController.text.isNotEmpty &&
                    _memberEmailController.text.contains('@')) {
                  setState(() {
                    String email = _memberEmailController.text;
                    String name = email.split('@')[0];
                    name = name[0].toUpperCase() + name.substring(1);
                    _teamMembers.add({"name": name, "imageUrl": ""});
                  });
                  Navigator.of(context).pop();
                  _memberEmailController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, insira um e-mail válido.',
                        style: TextStyle(color: kDarkTextPrimary),
                      ),
                      backgroundColor: Colors.redAccent,
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
    return SlideTransition(
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

  @override
  Widget build(BuildContext context) {
    const fabHeight = 56.0; // Standard FAB height
    const bottomNavBarHeight = kToolbarHeight + 5;

    return Scaffold(
      key: _scaffoldKey, // Adicionado scaffoldKey
      backgroundColor: kDarkPrimaryBg,
      extendBody: true,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Stack(
                children: [
                  _animatedCircle(
                      20,
                      150,
                      6,
                      [
                        Colors.lightBlueAccent,
                        const Color.fromARGB(255, 243, 33, 208),
                      ],
                      0),
                  _animatedCircle(
                      350,
                      130,
                      4,
                      [
                        const Color.fromARGB(164, 180, 34, 238),
                        Colors.deepPurpleAccent,
                      ],
                      1),
                  _animatedCircle(
                      180,
                      150,
                      5,
                      [
                        Colors.amberAccent,
                        Colors.orange,
                      ],
                      2),
                  _animatedCircle(
                      40,
                      115,
                      5,
                      [
                        Colors.pinkAccent,
                        const Color.fromARGB(255, 149, 226, 4),
                      ],
                      3),
                  _animatedCircle(
                      370,
                      150,
                      8,
                      [
                        const Color.fromARGB(173, 36, 17, 204),
                        const Color.fromARGB(255, 218, 20, 20),
                      ],
                      4),
                  _animatedCircle(
                      100,
                      120,
                      6,
                      [
                        const Color.fromARGB(255, 222, 87, 240),
                        const Color.fromARGB(255, 27, 112, 1),
                      ],
                      5),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildUploadLogoSection(),
                  const SizedBox(height: 30),
                  _buildLabel('Nome do time'),
                  const SizedBox(height: 8),
                  _buildTextField('@nomedotime'),
                  const SizedBox(height: 20),
                  _buildLabel('Membros do Time'),
                  const SizedBox(height: 10),
                  _buildTeamMemberSection(),
                  const SizedBox(height: 30),
                  Divider(color: kDarkTextSecondary.withOpacity(0.3)),
                  const SizedBox(height: 20),
                  _buildLabel('Tipo'),
                  const SizedBox(height: 10),
                  _buildTypeSelector(),
                  const SizedBox(height: 50),
                  _buildCreateTeamButton(),
                  const SizedBox(
                      height: bottomNavBarHeight + fabHeight / 2 + 20),
                ],
              ),
            ),
            if (_isCardVisible) _buildDimOverlay(),
            if (_isCardVisible)
              Positioned(
                bottom: 80,
                left: 30,
                right: 30,
                child: _buildSlidingMenu(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: kDarkTextPrimary,
              size: 30,
            ),
          ),
        ),
        const Text(
          'Criar Time',
          style: TextStyle(
            color: kDarkTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: kDarkTextSecondary, fontSize: 16),
      ),
    );
  }

  Widget _buildUploadLogoSection() {
    return GestureDetector(
      onTap: _pickLogoImage,
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: kDarkElementBg,
            backgroundImage: _logoImage != null ? FileImage(_logoImage!) : null,
            child: _logoImage == null
                ? const Icon(Icons.image_outlined,
                    color: kAccentPurple, size: 40)
                : null,
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload logo ',
            style: TextStyle(
              color: kAccentPurple,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sua logo vai ser pública',
            style: TextStyle(
              color: kDarkTextSecondary.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String initialValue) {
    return SizedBox(
      height: 55,
      child: TextFormField(
        initialValue: initialValue,
        style: const TextStyle(color: kDarkTextPrimary, fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: kDarkElementBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
            borderSide: const BorderSide(color: kAccentPurple, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMemberSection() {
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._teamMembers
              .map((member) => _avatar(member['imageUrl']!, member['name']!)),
          _addMemberButton(),
        ],
      ),
    );
  }

  Widget _avatar(String imageUrl, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: kDarkElementBg,
            backgroundImage: imageUrl.isNotEmpty ? AssetImage(imageUrl) : null,
            child: imageUrl.isEmpty
                ? Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: kDarkTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(color: kDarkTextSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _addMemberButton() {
    return GestureDetector(
      onTap: _showAddMemberDialog,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kDarkElementBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: kDarkTextSecondary.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.add, color: kDarkTextSecondary, size: 24),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add',
              style: TextStyle(color: kDarkTextSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _typeOption('Privado', Icons.lock_outline),
        const SizedBox(width: 20),
        _typeOption('Público', Icons.public),
      ],
    );
  }

  Widget _typeOption(String type, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: isSelected ? kAccentPurple.withOpacity(0.2) : kDarkElementBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? kAccentPurple : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? kAccentPurple : kDarkTextSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? kAccentPurple : kDarkTextSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTeamButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // Lógica para criar equipe
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Equipe criada com sucesso!',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              backgroundColor: kAccentSecondary,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Criar Time',
          style: TextStyle(
            color: kDarkTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _animatedCircle(
    double left,
    double top,
    double size,
    List<Color> colors,
    int offset,
  ) {
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _circleController,
        builder: (context, child) {
          final value = _circleController.value;
          final angle = 2 * pi * (value + offset / 6);
          final offsetX = sin(angle) * 10;
          final offsetY = cos(angle) * 10;

          return Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
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
