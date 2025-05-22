import 'package:flutter/services.dart';


class SmartReply {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_smart_reply');

  final List<Message> _conversation = [];

  List<Message> get conversation => _conversation;


  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Adds a [Message] to the [conversation] for local user.
  void addMessageFromUser(String message, int timestamp) {
    // CORREÇÃO AQUI: Adicionando 'id' e 'isUser'
    _conversation.add(Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(), // Gerar um ID único
      text: message,
      timestamp: timestamp,
      sender: 'user',
      isUser: true, // É uma mensagem do usuário
    ));
  }

  /// Adds a [Message] to the [conversation] for a remote user.
  void addMessageFromChatbot(String message, int timestamp) {
    // CORREÇÃO AQUI: Adicionando 'id' e 'isUser'
    _conversation.add(Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(), // Gerar um ID único
      text: message,
      timestamp: timestamp,
      sender: 'bot',
      isUser: false, // É uma mensagem do chatbot
    ));
  }

  /// Clears the [conversation].
  void clearConversation() {
    _conversation.clear();
  }

  /// Suggests possible replies in the context of a chat [conversation].
  Future<SmartReplySuggestionResult> suggestReplies() async {
    if (_conversation.isEmpty) {
      return SmartReplySuggestionResult(
          status: SmartReplySuggestionResultStatus.noReply, suggestions: []);
    }

    final result =
        await _channel.invokeMethod('nlp#startSmartReply', <String, dynamic>{
      'id': id,
      'conversation': _conversation.map((message) => message.toJson()).toList()
    });

    return SmartReplySuggestionResult.fromJson(result);
  }

  /// Closes the underlying resources including models used for reply inference.
  Future<void> close() =>
      _channel.invokeMethod('nlp#closeSmartReply', {'id': id});
}

/// Represents a text message from a certain user in a conversation, providing context for SmartReply to generate reply suggestions.
class Message {
  final String id; // Campo adicionado
  final String text;
  final int timestamp;
  final String sender; // 'user' for the human, 'bot' for the chatbot
  final bool isUser; // Campo adicionado - para mapear de volta para a UI
  String? fileName; // Campo adicionado
  String? filePath; // Campo adicionado
  String? reaction; // Campo adicionado

  Message({
    required this.id, // Adicionado ao construtor
    required this.text,
    required this.timestamp,
    required this.sender,
    required this.isUser, // Adicionado ao construtor
    this.fileName,
    this.filePath,
    this.reaction,
  });

  /// Returns a json representation of an instance of [Message].
  Map<String, dynamic> toJson() => {
        'message': text,
        'timestamp': timestamp,
        'userId': sender, // O Smart Reply espera 'userId', mapeamos 'sender' para ele.
      };
}

/// Specifies the status of the smart reply result.
enum SmartReplySuggestionResultStatus {
  success,
  notSupportedLanguage,
  noReply,
}

/// An object that contains the smart reply suggestion results.
class SmartReplySuggestionResult {
  /// Status of the smart reply suggestions result.
  SmartReplySuggestionResultStatus status;

  /// A list of the suggestions.
  List<String> suggestions;

  /// Constructor to create an instance of [SmartReplySuggestionResult].
  SmartReplySuggestionResult({required this.status, required this.suggestions});

  /// Returns an instance of [SmartReplySuggestionResult] from a given [json].
  factory SmartReplySuggestionResult.fromJson(Map<dynamic, dynamic> json) {
    final status =
        SmartReplySuggestionResultStatus.values[json['status'].toInt()];
    final suggestions = <String>[];
    if (status == SmartReplySuggestionResultStatus.success) {
      for (final dynamic line in json['suggestions']) {
        suggestions.add(line);
      }
    }
    return SmartReplySuggestionResult(status: status, suggestions: suggestions);
  }

  /// Returns a json representation of an instance of [SmartReplySuggestionResult].
  Map<String, dynamic> toJson() => {
        'status': status.name,
        'suggestions': suggestions,
      };
}