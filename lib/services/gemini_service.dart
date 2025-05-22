// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kDebugMode; // Para prints de debug

class GeminiService {
  late GenerativeModel _model;
  late ChatSession _chat;

  GeminiService() {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      if (kDebugMode) {
        print('ERRO: GEMINI_API_KEY não encontrada no arquivo .env!');
        print('Por favor, adicione GEMINI_API_KEY=SUA_CHAVE_AQUI ao seu arquivo .env na raiz do projeto.');
      }
      throw Exception('GEMINI_API_KEY não configurada. Verifique seu arquivo .env.');
    }

    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _chat = _model.startChat(history: []);

    // O prompt inicial é CRUCIAL para a inteligência da IA.
    // Adapte-o para as funcionalidades exatas que você quer que a IA controle!
    _addInitialSystemMessage();
  }

  void _addInitialSystemMessage() {
    _chat.history.add(Content.text('''
    Você é um assistente de IA amigável e prestativo para um aplicativo de gerenciamento de tarefas chamado "Planify".
    Sua principal função é ajudar o usuário a gerenciar tarefas, o que inclui:
    1.  **Criar novas tarefas.**
    2.  **Listar tarefas existentes** (todas, pendentes, concluídas, por data).
    3.  **Atualizar tarefas** (marcar como concluída, mudar nome, data, prioridade).
    4.  **Deletar tarefas.**
    5.  **Responder perguntas sobre o aplicativo Planify** ou sobre funcionalidades gerais.
    6.  **Simular mudanças de UI ou banco de dados**, explicando como seriam feitas no código ou na estrutura de dados.

    **Sempre que o usuário solicitar uma ação de gerenciamento de tarefas (criar, listar, atualizar, deletar), você DEVE responder com um objeto JSON válido.** Este JSON será interpretado pelo aplicativo para executar a ação. O JSON deve ter a chave "action" e a chave "parameters".

    **Formato JSON para Ações de Tarefas:**

    * **Para criar uma tarefa:**
        `{"action": "create_task", "parameters": {"name": "Nome da tarefa", "dueDate": "YYYY-MM-DD" (opcional), "priority": "low"|"medium"|"high" (opcional)}}`
        Exemplo: `{"action": "create_task", "parameters": {"name": "Comprar pão", "dueDate": "2025-05-28", "priority": "medium"}}`

    * **Para listar tarefas:**
        `{"action": "list_tasks", "parameters": {"filter": "all"|"completed"|"pending"|"today"|"upcoming" (opcional)}}`
        Exemplo: `{"action": "list_tasks", "parameters": {"filter": "pending"}}`

    * **Para atualizar uma tarefa:**
        `{"action": "update_task", "parameters": {"taskId": "ID_DA_TAREFA", "newName": "Novo nome" (opcional), "newDueDate": "YYYY-MM-DD" (opcional), "newPriority": "low"|"medium"|"high" (opcional), "isCompleted": true|false (opcional)}}`
        (Nota: "ID_DA_TAREFA" será um placeholder por enquanto, você precisará de um sistema de IDs reais depois.)
        Exemplo: `{"action": "update_task", "parameters": {"taskId": "temp_id_123", "isCompleted": true}}`

    * **Para deletar uma tarefa:**
        `{"action": "delete_task", "parameters": {"taskId": "ID_DA_TAREFA"}}`
        Exemplo: `{"action": "delete_task", "parameters": {"taskId": "temp_id_456"}}`

    **Para perguntas sobre o aplicativo ou simulações de UI/Banco de Dados:**
    * **Não retorne JSON.** Responda em linguagem natural, explicando como a mudança *poderia ser feita* ou dando a informação solicitada.
    * Exemplo (UI): "Para mudar a cor de fundo da tela, você ajustaria a propriedade `backgroundColor` do `Scaffold` no seu arquivo `chat_screen.dart`."
    * Exemplo (DB): "Para adicionar um novo campo ao banco de dados para a tabela de tarefas, você precisaria adicionar uma nova coluna na sua definição de esquema e potencialmente criar uma migração, dependendo da sua solução de banco de dados (ex: SQLite com `sqflite`)."

    **Se a solicitação não for uma ação de tarefa nem uma pergunta sobre o app/simulação, responda de forma útil e conversacional.**

    Seja conciso ao retornar JSON (apenas o JSON), e seja informativo ao retornar texto.
    ''');
  }

  Future<String> getGeminiResponse(String userMessage) async {
    try {
      // Adiciona a mensagem do usuário ao histórico da sessão de chat.
      // Isso é crucial para que o Gemini mantenha o contexto da conversa.
      final userContent = Content.text(userMessage);
      _chat.history.add(userContent);

      // Envia a conversa atual para o Gemini e espera a resposta.
      final response = await _chat.getFuture();

      // Adiciona a resposta da IA ao histórico também.
      // Isso ajuda o Gemini a manter o contexto de "o que ele disse por último".
      if (response.text != null && response.text!.isNotEmpty) {
        final aiContent = Content.text(response.text!);
        _chat.history.add(aiContent);
        return response.text!;
      } else {
        return "Não consegui gerar uma resposta no momento. Poderia tentar de outra forma?";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao chamar a API Gemini: $e");
      }
      // Você pode retornar uma mensagem de erro mais amigável para o usuário final
      return "Ocorreu um erro ao processar sua solicitação. Por favor, tente novamente mais tarde.";
    }
  }

  void clearChatHistory() {
    _chat = _model.startChat(history: []);
    _addInitialSystemMessage(); // Garante que o prompt inicial seja adicionado novamente
  }

  void close() {
    // Atualmente, não há um método de 'close' explícito para o Gemini SDK
    // como no ML Kit, mas é bom ter para consistência.
  }
}