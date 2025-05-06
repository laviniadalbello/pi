import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _cardKey = GlobalKey();

  bool _isCardVisible = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      extendBody: true,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

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
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Transform.translate(
      offset: const Offset(0, 30),
      child: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
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

        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.black,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            ),
          ],
        ),
      ),
    );
  }

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
        ],
      ),
    );
  }

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
    );
  }
}
