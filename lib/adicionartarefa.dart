import 'package:flutter/material.dart';

class AddTaskPage extends StatelessWidget {
  const AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Voltar e Título Centralizado
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
                Opacity(
                    opacity: 0, // para manter o espaço equilibrado
                    child: Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Task Name
              Text(
                'Task Name',
                style: TextStyle(
                  color: Color.fromARGB(240, 255, 255, 255),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
             // Input com tamanho definido
              SizedBox(
                width: 360, // largura que você quiser
                height: 55, // altura do input
                child: TextFormField(
                  initialValue: 'Mobile Application design',
                  style: TextStyle(color: Colors.black),
                  decoration: _whiteInputDecoration(),
                ),
              ),
                SizedBox(height: 30),

                // Team Member
                Text(
                  'Team Member',
                  style: TextStyle(color: const Color.fromARGB(239, 255, 255, 255), fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    _memberAvatar("https://randomuser.me/api/portraits/women/1.jpg", "Jeny"),
                    _memberAvatar("https://randomuser.me/api/portraits/women/2.jpg", "Mehrin"),
                    _memberAvatar("https://randomuser.me/api/portraits/men/1.jpg", "Avishek", selected: true),
                    _memberAvatar("https://randomuser.me/api/portraits/men/2.jpg", "Jafor"),
                    _addMemberButton(),
                  ],
                ),
                SizedBox(height: 35),

                // Date
                Text(
                  'Date',
                  style: TextStyle(color: const Color.fromARGB(240, 255, 255, 255),
                  fontSize: 16
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                width: 360, // largura que você quiser
                height: 55, // altura do input
                child: TextFormField(
                  initialValue: 'Novemebr 01,2021',
                  style: TextStyle(color: Colors.black),
                  decoration: _whiteInputDecoration(),
                ),
              ),
                SizedBox(height: 34),

                // Time
                Row(
                  children: [
                    Expanded(
                     child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Padding(
                  padding: EdgeInsets.only(left: 24), // mais à esquerda
                  child: Text(
                     'Start Time',
                   style: TextStyle(color: Color.fromARGB(237, 255, 255, 255)),
                   ),
                   ),
                SizedBox(height: 8),
                     _timeBox('9:30 am'),
                   ],
                 ),
               ),

                SizedBox(width: 30),
                  Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 24), // mais à esquerda
                        child: Text(
                          'End Time',
                     style: TextStyle(color: Color.fromARGB(237, 255, 255, 255)),
                        ),
                      ),
                     SizedBox(height: 8),
                      _timeBox('12:30 am'),
                    ],
                  ),
                ),

                  ],
                ),
                SizedBox(height: 35),

                // Board
                Text('Board', style: TextStyle(color: const Color.fromARGB(240, 255, 255, 255), fontSize: 16)),
                SizedBox(height: 10),
                Row(
                  children: [
                    _boardButton('Urgent', selected: false),
                    SizedBox(width: 10),
                    _boardButton('Running', selected: true),
                    SizedBox(width: 10),
                    _boardButton('Ongoing', selected: false),
                  ],
                ),
                SizedBox(height: 60),

                // Save button
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
                      child: Text('Save', style: TextStyle(color: const Color.fromARGB(240, 255, 255, 255), fontSize: 16)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
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

  Widget _memberAvatar(String imageUrl, String name, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 16,
              ),
              if (selected)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: Icon(Icons.check_circle, color: Color(0xFF8875FF), size: 26),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(name, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
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
    padding: const EdgeInsets.only(left: 26), // distância da esquerda
    child: Container(
      height: 44,
      width: 110,
      padding: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        time,
        style: TextStyle(color: Colors.black),
      ),
    ),
  );
}


  Widget _boardButton(String text, {bool selected = false,double leftPadding = 14}) {
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
