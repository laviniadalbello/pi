import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';

class SmartReplyService {
  final SmartReply _smartReply = SmartReply();
  final List<TextMessage> _conversation = [];

 
  void addConversation(String text, bool isFromUser) {
    _conversation.add(
      TextMessage(
        text: text,
        timestampMs: DateTime.now().millisecondsSinceEpoch,
        userId: 'unique_user_id', 
        isLocalUser: isFromUser,
      ),
    );
  }

  Future<List<String>> suggestReplies() async {
    if (_conversation.isEmpty) return [];

    try {
      final result = await _smartReply.suggestReplies(_conversation);
      if (result.status == SmartReplySuggestionResultStatus.success) {
        return result.suggestions.map((s) => s.text).toList();
      }
      return [];
    } catch (e) {
      print("Erro no Smart Reply: $e");
      return [];
    }
  }


  void clearConversation() => _conversation.clear();


  void dispose() => _smartReply.close();
}