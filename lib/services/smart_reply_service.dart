import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart' as mlcommons;
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'dart:io'; 

class SmartReplyService {
  late SmartReply smartReply;
  final List<TextMessage> _conversation = [];

  SmartReplyService() {
    _initSmartReply();
  }

  Future<void> _initSmartReply() async {

    try {
      final model = await FirebaseMlModelDownloader.instance.getModel(
        'smart_reply_model',
        mlcommons.ModelDownloadType.latestModel,
        FirebaseModelDownloadConditions(
          iosAllowsCellularAccess: true,
          iosAllowsBackgroundDownloading: true,
          androidAllowsUnmeteredNetwork: true,
          androidAllowsCharging: true,
        ),
      );
      final modelFile = model.file;
      smartReply = SmartReply(localModel: modelFile);
      print("ML Kit Smart Reply model loaded from: ${modelFile.path}");
    } catch (e) {
      print("Erro ao baixar o modelo do ML Kit Smart Reply: $e");
      smartReply = SmartReply(); 
    }
  }


  void addConversation(String text, bool isUser) {
    if (isUser) {
      _conversation.add(TextMessage.createForLocalUser(
        text,
        DateTime.now().millisecondsSinceEpoch,
      ));
    } else {
      _conversation.add(TextMessage.createForRemoteUser(
        text,
        DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<List<String>> suggestReplies() async {
    if (!_isModelLoaded && _conversation.isEmpty) {
      print("Modelo não carregado ou conversa vazia, sem sugestões SmartReply.");
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