import 'package:flutter/material.dart';

void main() => runApp(const SettingsApp());

class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const SettingsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool permission = true;
  bool pushNotification = false;
  bool darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {},
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 30), // desce o título
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            _buildSwitchTile("Permission", permission, (val) {
              setState(() => permission = val);
            }),
            const SizedBox(height: 12),
            _buildSwitchTile("Push Notification", pushNotification, (val) {
              setState(() => pushNotification = val);
            }),
            const SizedBox(height: 12),
            _buildSwitchTile("Dark Mood", darkMode, (val) {
              setState(() => darkMode = val);
            }),
            const SizedBox(height: 20),
            _buildNavTile("Security"),
            const SizedBox(height: 12),
            _buildNavTile("Help"),
            const SizedBox(height: 12),
            _buildNavTile("About Application"),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10101E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10101E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}
