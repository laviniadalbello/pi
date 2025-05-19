import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 


const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage>
    with TickerProviderStateMixin {
  bool _isCardVisible = false;
  String _selectedType = 'Private';
  File? _logoImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _memberEmailController = TextEditingController();
  List<Map<String, String>> _teamMembers = [
    {
      "name": "Jeny",
      "imageUrl": "assets/jeny.png", 
    },
    {
      "name": "Mehrin",
      "imageUrl": "assets/mehrin.png",
    },
    {
      "name": "Avishek",
      "imageUrl": "assets/avishek.png",
    },
    {
      "name": "Jafor",
      "imageUrl": "assets/jafor.png",
    },
  ];


  late AnimationController _circleController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  List<Animation<double>> _menuItemAnimations = [];

  final List<Map<String, dynamic>> _menuItemsData = [
    {'icon': Icons.edit_outlined, 'label': 'Create Task'},
    {'icon': Icons.add_circle_outline, 'label': 'Create Project'},
    {'icon': Icons.group_outlined, 'label': 'Create Team'},
    {'icon': Icons.schedule_outlined, 'label': 'Create Event'},
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

    _menuItemAnimations = List.generate(
      _menuItemsData.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _slideController,
          curve: Interval(
            0.2 + (0.6 / _menuItemsData.length) * index,
            0.4 + (0.6 / _menuItemsData.length) * index,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    _slideController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickLogoImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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
            style: TextStyle(color: kDarkTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
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
                borderSide: BorderSide(color: kAccentPurple, width: 1),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Adicionar',
                style: TextStyle(color: kDarkTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (_memberEmailController.text.isNotEmpty &&
                    _memberEmailController.text.contains('@')) {
                  setState(() {
                    String email = _memberEmailController.text;
                    String name = email.split('@')[0];
                    name = name[0].toUpperCase() + name.substring(1);
                    _teamMembers.add({
                      "name": name,
                      "imageUrl": "",
                    });
                  });
                  Navigator.of(context).pop();
                  _memberEmailController.clear();
                } else {
              
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, insira um e-mail válido.', style: TextStyle(color: kDarkTextPrimary)),
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

  @override
  Widget build(BuildContext context) {
    final fabHeight = 56.0;
    final bottomNavBarHeight = kToolbarHeight + 5; 

    return Scaffold(
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
                  _animatedCircle(20, 150, 6, [
                    Colors.lightBlueAccent,
                    const Color.fromARGB(255, 243, 33, 208),
                  ], 0),
                  _animatedCircle(350, 130, 4, [
                    Color.fromARGB(164, 180, 34, 238),
                    Colors.deepPurpleAccent,
                  ], 1),
                  _animatedCircle(180, 150, 5, [
                    Colors.amberAccent,
                    Colors.orange,
                  ], 2),
                  _animatedCircle(40, 115, 5, [
                    Colors.pinkAccent,
                    const Color.fromARGB(255, 149, 226, 4),
                  ], 3),
                  _animatedCircle(370, 150, 8, [
                    Color.fromARGB(173, 36, 17, 204),
                    const Color.fromARGB(255, 218, 20, 20),
                  ], 4),
                  _animatedCircle(100, 120, 6, [
                    Color.fromARGB(255, 222, 87, 240),
                    const Color.fromARGB(255, 27, 112, 1),
                  ], 5),
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
                  _buildLabel('Team Name'),
                  const SizedBox(height: 8),
                  _buildTextField('Team Align'),
                  const SizedBox(height: 20),
                  _buildLabel('Team Member'),
                  const SizedBox(height: 10),
                  _buildTeamMemberSection(),
                  const SizedBox(height: 30),
                  Divider(color: kDarkTextSecondary.withOpacity(0.3)),
                  const SizedBox(height: 20),
                  _buildLabel('Type'),
                  const SizedBox(height: 10),
                  _buildTypeSelector(),
                  const SizedBox(height: 50),
                  _buildCreateTeamButton(),
                  SizedBox(height: bottomNavBarHeight + fabHeight / 2 + 20), 
                ],
              ),
            ),
            if (_isCardVisible) _buildDimOverlay(),
             
            Positioned(
              bottom: 0.0, 
              left: 20,
              right: 20,
              child: Visibility(
                visible: _isCardVisible,
                child: _buildSlidingMenu(),
              ),
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
          'Create Team',
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
                ? Icon(
                    Icons.image_outlined,
                    color: kAccentPurple,
                    size: 40,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload logo file',
            style: TextStyle(
              color: kAccentPurple,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your logo will be public',
            style: TextStyle(color: kDarkTextSecondary.withOpacity(0.8), fontSize: 12),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            borderSide: BorderSide(color: kAccentPurple, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMemberSection() {
    return SizedBox(
      height: 70, // Increased height to accommodate names and alignment
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
        children: [
          ..._teamMembers.map((member) => _avatar(member['imageUrl']!, member['name']!)).toList(),
          _addMemberButton(),
        ],
      ),
    );
  }

  Widget _avatar(String assetPathOrUrl, String name) {
    
    bool isAsset = assetPathOrUrl.startsWith('assets/');
    ImageProvider? backgroundImage;
    if (_logoImage != null && name == "You") { 
        backgroundImage = FileImage(_logoImage!);
    } else if (!isAsset && assetPathOrUrl.isNotEmpty) {
        // backgroundImage = NetworkImage(assetPathOrUrl); 
    } else if (isAsset) {
        // backgroundImage = AssetImage(assetPathOrUrl); 
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center avatar and name
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: kDarkElementBg,
            backgroundImage: backgroundImage,
            child: backgroundImage == null 
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: kAccentPurple, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(color: kDarkTextSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _addMemberButton() {
    return GestureDetector(
      onTap: _showAddMemberDialog, 
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 0), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, 
              height: 44,
              decoration: BoxDecoration(
                color: kDarkElementBg,
                shape: BoxShape.circle,
                border: Border.all(color: kAccentPurple.withOpacity(0.7), width: 1.5),
              ),
              child: Icon(Icons.add, color: kAccentPurple, size: 24),
            ),
            const SizedBox(height: 6),
            Text("Add", style: const TextStyle(color: Colors.transparent, fontSize: 11)), // Invisible text for spacing
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = ['Private', 'Public', 'Secret'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: types.map((type) {
        bool isSelected = _selectedType == type;
        return Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: ChoiceChip(
            label: Text(type),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedType = type;
                });
              }
            },
            backgroundColor: kDarkElementBg,
            selectedColor: kAccentPurple,
            labelStyle: TextStyle(
              color: isSelected ? kDarkTextPrimary : kDarkTextSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: isSelected ? kAccentPurple : kDarkElementBg)
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCreateTeamButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {},
        child: const Text(
          'Create Team',
          style: TextStyle(color: kDarkTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
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
      child: Icon(Icons.add, size: 28, color: kDarkTextPrimary),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: kDarkElementBg,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: kToolbarHeight + 16, // Explicit height
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.home_rounded), color: kAccentPurple, onPressed: () {}),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.folder_outlined), color: kDarkTextSecondary.withOpacity(0.7), onPressed: () {}),
              ],
            ),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.chat_bubble_outline), color: kDarkTextSecondary.withOpacity(0.7), onPressed: () {}),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.person_outline), color: kDarkTextSecondary.withOpacity(0.7), onPressed: () {}),
              ],
            ),
          ],
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
    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20, left: 24, right: 24),
          decoration: BoxDecoration(
            color: kDarkElementBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(_menuItemsData.length, (index) {
                return AnimatedListItem(
                  animation: _menuItemAnimations[index],
                  child: _menuItem(
                    _menuItemsData[index]['icon'] as IconData,
                    _menuItemsData[index]['label'] as String,
                  ),
                );
              }),
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
                child: const Icon(Icons.close, size: 20, color: kDarkTextPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: kDarkSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: kDarkTextPrimary, size: 22),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(color: kDarkTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
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
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const AnimatedListItem({Key? key, required this.child, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}

