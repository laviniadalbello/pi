import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart' as mlcommons; // <<--- ESSA LINHA É CRÍTICA!
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'dart:io';

class SmartReplyService {
  late SmartReply smartReply;
  final List<mlcommons.TextMessage> _conversation = []; // Use mlcommons.TextMessage
  bool _isModelLoaded = false;

  SmartReplyService() {
    _initSmartReply();
  }

  Future<void> _initSmartReply() async {
    try {

      final model = await FirebaseMlModelDownloader.instance.getModel(
        'smart_reply_model', 
        FirebaseModelDownloadType.latestModel,
        FirebaseModelDownloadConditions(
          androidAllowsFirewallApks: true,
          androidAllowsDeviceIdle: true,
          androidAllowsUnmeteredNetwork: true,
          iosAllowsCellularAccess: true,
          iosUnmeteredOnly: false,
        ),
      );
      final modelFile = model.file;

      smartReply = SmartReply(localModel: mlcommons.LocalModel(modelFile.path)); 
      _isModelLoaded = true;
      print("ML Kit Smart Reply model loaded from Firebase: ${modelFile.path}");
    } catch (e) {
      print("Erro ao baixar o modelo do Firebase ML Kit Smart Reply: $e");
      print("Usando o modelo padrão embutido do SmartReply.");
  
      smartReply = SmartReply(); 
      _isModelLoaded = false;
    }
  }

  void addConversation(String text, bool isUser) {
    if (isUser) {
      _conversation.add(mlcommons.TextMessage.createForLocalUser(
        text,
        DateTime.now().millisecondsSinceEpoch,
      ));
    } else {
      _conversation.add(mlcommons.TextMessage.createForRemoteUser(
        text,
        DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<List<String>> suggestReplies() async {
    if (_conversation.isEmpty) {
      print("Conversa vazia, sem sugestões SmartReply.");
      return [];
    }
    try {
      final SmartReplySuggestionResult result =
          await smartReply.suggestRepliesFromConversations(_conversation);
      return result.suggestions;
    } catch (e) {
      print("Erro ao gerar sugestões de Smart Reply: $e");
      return [];
    }
  }

  void dispose() {
    smartReply.close();
  }
}