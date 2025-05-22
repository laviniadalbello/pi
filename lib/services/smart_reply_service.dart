import 'package:flutter/services.dart'; // Mantenha este import para MethodChannel

// Definições de status do Smart Reply
enum SmartReplySuggestionResultStatus {
  success,
  notSupportedLanguage,
  noReply,
}

/// Representa uma mensagem de texto de um determinado usuário em uma conversa,
/// fornecendo contexto para o SmartReply gerar sugestões de resposta.
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

  /// Retorna uma representação JSON de uma instância de [Message].
  Map<String, dynamic> toJson() => {
        'message': text,
        'timestamp': timestamp,
        'userId': sender, // O Smart Reply nativo espera 'userId', mapeamos 'sender' para ele.
      };
}

/// Especifica o status do resultado da resposta inteligente.
enum SmartReplySuggestionResultStatus {
  success,
  notSupportedLanguage,
  noReply,
}

/// Um objeto que contém os resultados da sugestão de resposta inteligente.
class SmartReplySuggestionResult {
  /// Status dos resultados da sugestão de resposta inteligente.
  SmartReplySuggestionResultStatus status;

  /// Uma lista das sugestões.
  List<String> suggestions;

  /// Construtor para criar uma instância de [SmartReplySuggestionResult].
  SmartReplySuggestionResult({required this.status, required this.suggestions});

  /// Retorna uma instância de [SmartReplySuggestionResult] de um dado [json].
  factory SmartReplySuggestionResult.fromJson(Map<dynamic, dynamic> json) {
    // Certifique-se de que 'status' é int antes de toInt()
    final status =
        SmartReplySuggestionResultStatus.values[json['status'] is int ? json['status'] : (json['status'] as double).toInt()];
    final suggestions = <String>[];
    if (status == SmartReplySuggestionResultStatus.success) {
      for (final dynamic line in json['suggestions']) {
        suggestions.add(line);
      }
    }
    return SmartReplySuggestionResult(status: status, suggestions: suggestions);
  }

  /// Retorna uma representação JSON de uma instância de [SmartReplySuggestionResult].
  Map<String, dynamic> toJson() => {
        'status': status.index, // Use index para serializar para JSON
        'suggestions': suggestions,
      };
}


class SmartReply {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_smart_reply'); // Nome do canal

  final List<Message> _conversation = [];

  List<Message> get conversation => _conversation;

  // Não use 'final id' aqui, pois ele será criado apenas uma vez.
  // Geraremos um ID no invokeMethod ou faremos com que a instância nativa gerencie.
  // Por enquanto, vamos passar o ID da conversa.

  /// Adiciona uma [Message] à [conversation] para o usuário local.
  void addMessageFromUser(String messageText, int timestamp) {
    _conversation.add(Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: messageText,
      timestamp: timestamp,
      sender: 'user',
      isUser: true,
    ));
    // Não precisa invocar canal aqui, será enviado em suggestReplies
  }

  /// Adiciona uma [Message] à [conversation] para um usuário remoto (chatbot).
  void addMessageFromChatbot(String messageText, int timestamp) {
    _conversation.add(Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: messageText,
      timestamp: timestamp,
      sender: 'bot',
      isUser: false,
    ));
    // Não precisa invocar canal aqui, será enviado em suggestReplies
  }

  /// Limpa a [conversation].
  void clearConversation() {
    _conversation.clear();
  }

  /// Sugere possíveis respostas no contexto de uma conversa de chat.
  Future<SmartReplySuggestionResult> suggestReplies() async {
    if (_conversation.isEmpty) {
      return SmartReplySuggestionResult(
          status: SmartReplySuggestionResultStatus.noReply, suggestions: []);
    }

    try {
      final result =
          await _channel.invokeMethod('nlp#startSmartReply', <String, dynamic>{
        // Não precisa de um 'id' global aqui se a API nativa não exigir
        'conversation': _conversation.map((message) => message.toJson()).toList()
      });

      if (result == null) {
        return SmartReplySuggestionResult(status: SmartReplySuggestionResultStatus.error, suggestions: []);
      }

      return SmartReplySuggestionResult.fromJson(result);
    } on PlatformException catch (e) {
      print("Failed to get smart replies via MethodChannel: ${e.message}");
      return SmartReplySuggestionResult(status: SmartReplySuggestionResultStatus.error, suggestions: []);
    }
  }

  /// Fecha os recursos subjacentes usados para inferência de resposta.
  // O método close() geralmente não precisa do 'id' global se a instância for única
  Future<void> close() => _channel.invokeMethod('nlp#closeSmartReply');
}