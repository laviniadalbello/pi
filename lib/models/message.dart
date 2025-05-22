// lib/models/message.dart
class Message {
  final String id;
  final String text;
  final int timestamp;
  final String sender; // 'user' for the human, 'bot' for the chatbot
  final bool isUser;
  String? fileName;
  String? filePath;
  String? reaction; // Campo para reações de emoji

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.sender,
    required this.isUser,
    this.fileName,
    this.filePath,
    this.reaction,
  });
}