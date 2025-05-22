import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert'; // Para jsonEncode e jsonDecode

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    const String apiKey = String.fromEnvironment("GEMINI_API_KEY");
    if (apiKey.isEmpty) {
      throw Exception(
          'GEMINI_API_KEY não configurada. Por favor, adicione-a como uma variável de ambiente.');
    }

    final tools = [
      Tool(
        functionDeclarations: [
          FunctionDeclaration(
            'create_task',
            'Cria uma nova tarefa no banco de dados do usuário.',
            Schema(
              SchemaType.object,
              properties: {
                'title':
                    Schema(SchemaType.string, description: 'Título da tarefa'),
                'description': Schema(SchemaType.string,
                    description: 'Descrição detalhada da tarefa (opcional)'),
                'dueDate': Schema(SchemaType.string,
                    description:
                        'Data de vencimento no formato YYYY-MM-DD (opcional)'),
                'priority': Schema(SchemaType.string,
                    description:
                        'Prioridade da tarefa (baixa, média, alta) (opcional)'),
              },
            ),
          ),
          FunctionDeclaration(
            'list_tasks',
            'Lista tarefas existentes do usuário, com opção de filtro.',
            Schema(
              SchemaType.object,
              properties: {
                'filter': Schema(SchemaType.string,
                    description:
                        'Filtro para as tarefas (ex: "concluídas", "pendentes", "hoje", "futuras") (opcional)'),
              },
            ),
          ),
          FunctionDeclaration(
            'update_task',
            'Atualiza uma tarefa existente do usuário.',
            Schema(
              SchemaType.object,
              properties: {
                'taskId': Schema(SchemaType.string,
                    description:
                        'ID único da tarefa a ser atualizada. Preferencialmente use o ID.'),
                'title': Schema(SchemaType.string,
                    description:
                        'Título da tarefa a ser atualizada (usado se taskId não for fornecido ou para encontrar o ID).'),
                'newTitle': Schema(SchemaType.string,
                    description: 'Novo título da tarefa (opcional)'),
                'newDueDate': Schema(SchemaType.string,
                    description:
                        'Nova data de vencimento no formato YYYY-MM-DD (opcional)'),
                'newPriority': Schema(SchemaType.string,
                    description:
                        'Nova prioridade da tarefa (baixa, média, alta) (opcional)'),
                'isCompleted': Schema(SchemaType.boolean,
                    description:
                        'Define se a tarefa está concluída (true) ou pendente (false) (opcional)'),
              },
            ),
          ),
          FunctionDeclaration(
            'delete_task',
            'Deleta uma tarefa existente do usuário.',
            Schema(
              SchemaType.object,
              properties: {
                'taskId': Schema(SchemaType.string,
                    description:
                        'ID único da tarefa a ser deletada. Preferencialmente use o ID.'),
                'title': Schema(SchemaType.string,
                    description:
                        'Título da tarefa a ser deletada (usado se taskId não for fornecido ou para encontrar o ID).'),
              },
            ),
          ),
          FunctionDeclaration(
            'add_project_task',
            'Adiciona uma tarefa a um projeto existente.',
            Schema(
              SchemaType.object,
              properties: {
                'projectId': Schema(SchemaType.string,
                    description:
                        'ID do projeto ao qual a tarefa será adicionada.'),
                'title': Schema(SchemaType.string,
                    description: 'Título da tarefa do projeto.'),
              },
            ),
          ),
        ],
      )
    ];

    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      tools: tools,
    );

    // PASSE O HISTÓRICO INICIAL AQUI
    _chat = _model.startChat(history: [
      Content.text(
          'Você é um assistente de IA focado em ajudar o usuário a gerenciar suas tarefas e projetos. Use as ferramentas disponíveis para criar, listar, atualizar e deletar tarefas.'),
    ]);
  }

  Future<String> getGeminiResponse(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));

      if (response.candidates.isNotEmpty) {
        final candidate = response.candidates.first;
        if (candidate.content.parts.isNotEmpty) {
          for (var part in candidate.content.parts) {
            if (part is FunctionCall) {
              final call = part;
              return jsonEncode({
                'action': call.name,
                'parameters': call.args,
              });
            }
          }
        }
      }

      return response.text ?? "Não entendi sua solicitação.";
    } catch (e) {
      print("Erro ao se comunicar com a API do Gemini: $e");
      return "Ocorreu um erro ao processar sua solicitação. Por favor, tente novamente.";
    }
  }

  void clearChatHistory() {
    // Ao limpar o histórico, reinicie o chat com a mensagem inicial
    _chat = _model.startChat(history: [
      Content.text(
          'Você é um assistente de IA focado em ajudar o usuário a gerenciar suas tarefas e projetos. Use as ferramentas disponíveis para criar, listar, atualizar e deletar tarefas.'),
    ]);
  }

  void close() {
    // Atualmente, não há um método de 'close' explícito para o Gemini SDK
    // como no ML Kit, mas é bom ter para consistência.
  }
}
