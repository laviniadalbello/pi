import 'package:flutter/material.dart';
import 'dart:math';
import 'configuracoes.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class PerfilvazioPage extends StatefulWidget {
  const PerfilvazioPage({super.key});

  @override
  State<PerfilvazioPage> createState() => _PerfilvazioPageState();
}

class _PerfilvazioPageState extends State<PerfilvazioPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _circleController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _isCardVisible = false;

  final String _userName = "USER";
  final String _userHandle = "@nomedousuario";
  final String _userBio = "Bio"; // Modificado: "Designer & Developer" -> "Bio"
  final List<Map<String, dynamic>> _userStats = [
    {"label": "Projetos", "value": 0}, // Modificado: 12 -> 0
    {"label": "Tarefas", "value": 0}, // Modificado: 48 -> 0
    {"label": "Equipes", "value": 0}, // Modificado: 3 -> 0
  ];

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
  }

  @override
  void dispose() {
    _circleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateToRoute(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushNamed(routeName);
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
                // Já está na tela de perfil
              },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      extendBody: true,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: Stack(
          children: [
            // Círculos animados (mantidos do original)
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Cabeçalho
                  _buildHeader(),
                  const SizedBox(height: 30),

                  // Seção de perfil
                  _buildProfileSection(),
                  const SizedBox(height: 30),

                  // Estatísticas do usuário
                  _buildStatsSection(),
                  const SizedBox(height: 30),

                  _buildEmptyActivitiesSection(),
                  const SizedBox(height: 30),

                  _buildActionButtons(),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            if (_isCardVisible) _buildDimOverlay(),
            if (_isCardVisible) _buildSlidingMenu(),
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
          'Perfil',
          style: TextStyle(
            color: kDarkTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: kDarkTextPrimary),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: kDarkElementBg,
              child: Icon(Icons.person, color: kAccentPurple, size: 50),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  _showEditAvatarOptions();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentPurple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: kDarkTextPrimary,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          style: const TextStyle(
            color: kDarkTextPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userHandle,
          style: const TextStyle(color: kDarkTextSecondary, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          _userBio,
          style: TextStyle(
            color: kDarkTextPrimary.withOpacity(0.8),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            _showEditProfileDialog();
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kAccentPurple),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Editar Perfil',
            style: TextStyle(color: kAccentPurple, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDarkElementBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _userStats.map((stat) {
          return Column(
            children: [
              Text(
                stat["value"].toString(),
                style: const TextStyle(
                  color: kDarkTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat["label"],
                style: const TextStyle(color: kDarkTextSecondary, fontSize: 14),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Atividades Recentes',
              style: TextStyle(
                color: kDarkTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: kDarkElementBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note,
                color: kDarkTextSecondary.withOpacity(0.6),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhuma atividade',
                style: TextStyle(
                  color: kDarkTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Suas atividades recentes aparecerão aqui',
                style: TextStyle(color: kDarkTextSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.folder,
          label: 'Meus Projetos',
          onTap: () {
            _navigateToRoute('/my_projects');
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.settings,
          label: 'Configurações',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsApp()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.analytics,
          label: 'Estatísticas',
          onTap: () {
            _navigateToRoute('/statistics');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: kDarkElementBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: kAccentPurple),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: kDarkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: kDarkTextSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final handleController = TextEditingController(text: _userHandle);
    final bioController = TextEditingController(text: _userBio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkElementBg,
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: kDarkTextPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: kDarkTextPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: kDarkTextSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kDarkTextSecondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kAccentPurple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: handleController,
                style: const TextStyle(color: kDarkTextPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nome de usuário',
                  labelStyle: TextStyle(color: kDarkTextSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kDarkTextSecondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kAccentPurple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                style: const TextStyle(color: kDarkTextPrimary),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(color: kDarkTextSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kDarkTextSecondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kAccentPurple),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: kDarkTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              //  lógica para salvar as alterações
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Perfil atualizado com sucesso!',
                    style: TextStyle(color: kDarkTextPrimary),
                  ),
                  backgroundColor: kAccentSecondary,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kAccentPurple),
            child: const Text(
              'Salvar',
              style: TextStyle(color: kDarkTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkElementBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Alterar foto de perfil',
              style: TextStyle(
                color: kDarkTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: kAccentPurple,
              ),
              title: const Text(
                'Escolher da galeria',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Lógica para escolher da galeria
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Foto de perfil atualizada!',
                      style: TextStyle(color: kDarkTextPrimary),
                    ),
                    backgroundColor: kAccentSecondary,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: kAccentPurple),
              title: const Text(
                'Tirar foto',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Lógica para tirar foto, pode remoevr essa parte
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Foto de perfil atualizada!',
                      style: TextStyle(color: kDarkTextPrimary),
                    ),
                    backgroundColor: kAccentSecondary,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Remover foto',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Lógica para remover foto
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Foto de perfil removida!',
                      style: TextStyle(color: kDarkTextPrimary),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkElementBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opções',
              style: TextStyle(
                color: kDarkTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.share, color: kAccentPurple),
              title: const Text(
                'Compartilhar perfil',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Lógica para compartilhar perfil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Link do perfil copiado para a área de transferência!',
                      style: TextStyle(color: kDarkTextPrimary),
                    ),
                    backgroundColor: kAccentSecondary,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: kAccentPurple),
              title: const Text(
                'Exportar dados',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Lógica para exportar dados
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Dados exportados com sucesso!',
                      style: TextStyle(color: kDarkTextPrimary),
                    ),
                    backgroundColor: kAccentSecondary,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sair',
                style: TextStyle(color: kDarkTextPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                // Lógica para sair
                _showLogoutConfirmationDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDarkElementBg,
        title: const Text(
          'Sair',
          style: TextStyle(color: kDarkTextPrimary),
        ),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(color: kDarkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: kDarkTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Lógica para fazer logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Logout realizado com sucesso!',
                    style: TextStyle(color: kDarkTextPrimary),
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child:
                const Text('Sair', style: TextStyle(color: kDarkTextPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _animatedCircle(
    double x,
    double y,
    double size,
    List<Color> colors,
    int index,
  ) {
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
}
