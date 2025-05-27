// lib/screens/chatdaia.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:planify/models/task.dart'; // Certifique-se de que task.dart está em lib/models/
import 'package:planify/services/gemini_service.dart'; // Certifique-se de que gemini_service.dart está em lib/services/
import 'package:planify/services/firestore_tasks_service.dart'; // Certifique-se de que firestore_tasks_service.dart está em lib/services/
import 'package:planify/models/message.dart';
import 'package:planify/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Certifique-se de que message.dart está em lib/models/

// Cores (mantidas do seu código original)
const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class ChatScreen extends StatefulWidget {
  final String title;
  final GeminiService geminiService;
  final FirestoreService firestoreService;
  // <--- ESTA LINHA É CRÍTICA

  const ChatScreen({
    super.key,
    required this.title,
    required this.geminiService,
    required this.firestoreService,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  // DECLARAÇÃO DE VARIÁVEIS DE ESTADO
  late GeminiService _geminiService;
  late FirestoreTasksService _firestoreTasksService;
  late String _currentUserId;
  final List<Message> _messages = [];
  bool _isAiTyping = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();
    _geminiService = widget.geminiService;
    // Obtenha o ID do usuário autenticado
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous_user';
    if (_currentUserId == 'anonymous_user') {
      // Trate o caso de usuário não logado, talvez redirecionar para tela de login
      print(
          "AVISO: Usuário não logado! Usando ID anônimo. As tarefas podem não ser persistidas corretamente.");
    }

    _firestoreTasksService = FirestoreTasksService(userId: _currentUserId);

    _addInitialMessages();

    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _sendButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _addInitialMessages() {
    setState(() {
      _messages.addAll([
        Message(
          id: "1",
          text:
              "Olá! Sou seu assistente Planify. Como posso ajudar a organizar suas tarefas?",
          isUser: false,
          timestamp: DateTime.now().microsecondsSinceEpoch,
          sender: 'bot',
        ),
      ]);
    });
  }

  void _sendMessage({String? text, String? fileName, String? filePath}) async {
    final String messageText = text ?? _textController.text.trim();
    if (messageText.isEmpty && fileName == null) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: messageText,
      isUser: true,
      timestamp: DateTime.now().microsecondsSinceEpoch,
      sender: 'user',
      fileName: fileName,
      filePath: filePath,
    );

    setState(() {
      _messages.add(newMessage);
      _textController.clear();
      _isAiTyping = true;
    });

    _scrollToBottom();

    String aiRawResponse;
    String aiResponseText = "Não foi possível obter uma resposta.";

    try {
      aiRawResponse = await _geminiService.getGeminiResponse(newMessage.text);

      Map<String, dynamic>? aiAction;
      if (aiRawResponse.startsWith('{') && aiRawResponse.endsWith('}')) {
        try {
          aiAction = json.decode(aiRawResponse);
        } on FormatException catch (e) {
          // Captura especificamente o erro de formato JSON
          debugPrint("Resposta do Gemini não é JSON válido: $e");
          aiAction = null;
          aiResponseText =
              "Erro: A resposta da IA não está no formato esperado."; // Garante que não será tratado como ação se for inválido
        } catch (e) {
          // Outros erros de decodificação
          debugPrint("Erro inesperado ao decodificar JSON: $e");
          aiAction = null;
          aiResponseText =
              "Erro: Problema ao interpretar a resposta da IA. Detalhes: $e";
        }
      }

      if (aiAction != null &&
          aiAction.containsKey('action') &&
          aiAction.containsKey('parameters')) {
        final String action = aiAction['action'];
        final Map<String, dynamic> parameters = aiAction['parameters'];

        try {
          switch (action) {
            case 'create_task':
              DateTime? dueDate;
              if (parameters['dueDate'] != null) {
                try {
                  dueDate = DateTime.parse(parameters['dueDate']);
                } catch (e) {
                  debugPrint(
                      "Erro ao parsear data de vencimento: ${parameters['dueDate']}");
                }
              }
              await _firestoreTasksService.createUserTask(
                title: parameters['title'],
                description: parameters['description'],
                dueDate: dueDate,
                priority: parameters['priority'],
              );
              aiResponseText =
                  "Tarefa '${parameters['title']}' criada com sucesso no Firestore!";
              break;

            case 'list_tasks':
              final List<Task> tasks = await _firestoreTasksService
                  .listUserTasks(filter: parameters['filter']);
              if (tasks.isEmpty) {
                aiResponseText =
                    "Não encontrei nenhuma tarefa com este filtro no Firestore.";
              } else {
                aiResponseText =
                    "Aqui estão as tarefas (${parameters['filter'] ?? 'todas'}):";
                for (var i = 0; i < tasks.length; i++) {
                  aiResponseText +=
                      "\n${i + 1}. ${tasks[i].title} (Vence: ${tasks[i].dueDate?.toIso8601String().substring(0, 10) ?? 'N/A'}, Pri: ${tasks[i].priority ?? 'N/A'}, Concluída: ${tasks[i].status == 'completed' ? 'Sim' : 'Não'})";
                }
              }
              break;

            case 'update_task':
              String? taskIdToUpdate;
              if (parameters['taskId'] != null) {
                taskIdToUpdate = parameters['taskId'];
              } else if (parameters['title'] != null) {
                final Task? task = await _firestoreTasksService
                    .findTaskByTitle(parameters['title']);
                if (task != null) {
                  taskIdToUpdate = task.id;
                }
              }

              if (taskIdToUpdate == null) {
                aiResponseText =
                    "Não consegui identificar a tarefa para atualizar. Por favor, forneça o ID ou o nome exato.";
                break;
              }

              DateTime? newDueDate;
              if (parameters.containsKey('newDueDate') &&
                  parameters['newDueDate'] != null) {
                // Adicionado containsKey
                try {
                  newDueDate = DateTime.parse(parameters['newDueDate']);
                } catch (e) {
                  debugPrint(
                      "Erro ao parsear nova data de vencimento: ${parameters['newDueDate']}");
                }
              }

              await _firestoreTasksService.updateUserTask(
                taskId: taskIdToUpdate,
                newTitle: parameters.containsKey('newTitle')
                    ? parameters['newTitle']
                    : null, // CORREÇÃO AQUI
                newDueDate: newDueDate,
                newPriority: parameters.containsKey('newPriority')
                    ? parameters['newPriority']
                    : null, // CORREÇÃO AQUI
                isCompleted: parameters.containsKey('isCompleted')
                    ? parameters['isCompleted']
                    : null, // CORREÇÃO AQUI
              );
              aiResponseText = "Tarefa atualizada com sucesso no Firestore!";
              break;

            case 'delete_task':
              String? taskIdToDelete;
              if (parameters.containsKey('taskId') &&
                  parameters['taskId'] != null) {
                // Adicionado containsKey
                taskIdToDelete = parameters['taskId'];
              } else if (parameters.containsKey('title') &&
                  parameters['title'] != null) {
                // Adicionado containsKey
                final Task? task = await _firestoreTasksService
                    .findTaskByTitle(parameters['title']);
                if (task != null) {
                  taskIdToDelete = task.id;
                }
              }

              if (taskIdToDelete == null) {
                aiResponseText =
                    "Não consegui identificar a tarefa para deletar. Por favor, forneça o ID ou o nome exato.";
                break;
              }

              await _firestoreTasksService.deleteTask(taskId: taskIdToDelete);
              aiResponseText = "Tarefa deletada com sucesso do Firestore!";
              break;

            case 'add_project_task':
              final String? projectId = parameters['projectId'];
              final String? taskTitle = parameters['title'];
              if (projectId != null && taskTitle != null) {
                await _firestoreTasksService.addProjectTask(
                    projectId, taskTitle, 'test_user_id_gemini');
                aiResponseText =
                    "Tarefa '$taskTitle' adicionada ao projeto '$projectId' com sucesso.";
              } else {
                aiResponseText =
                    "Para adicionar uma tarefa de projeto, preciso do ID do projeto e do título da tarefa.";
              }
              break;

            default:
              // Se a ação não for reconhecida, trate a resposta como texto simples.
              aiResponseText =
                  "Ação de função desconhecida: $action. Resposta crua: $aiRawResponse";
              break;
          }
        } catch (e) {
          debugPrint("Erro ao executar ação do Firestore: $e");
          aiResponseText =
              "Ocorreu um erro ao tentar executar sua solicitação no banco de dados: $e";
        }
      } else {
        // Se não for uma FunctionCall (ou o JSON for inválido), trate como texto normal.
        aiResponseText = aiRawResponse;
      }
      // --------------------------------------------------------------------
    } catch (e) {
      // Captura erros da chamada ao GeminiService (incluindo o "models/gemini-pro is not found")
      debugPrint("Erro ao se comunicar com a API do Gemini: $e");
      aiResponseText =
          "Ocorreu um erro ao processar sua solicitação com a IA. Detalhes: $e";
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final aiResponse = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now().microsecondsSinceEpoch,
        sender: 'bot',
      );

      setState(() {
        _isAiTyping = false;
        _messages.add(aiResponse);
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      _sendMessage(
        text:
            "Acabei de enviar o arquivo: ${file.name}. Você pode me ajudar a analisá-lo?",
        fileName: file.name,
        filePath: file.path,
      );
    }
  }

  void _showReactionMenu(Message message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kDarkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Adicionar reação",
                style: TextStyle(
                  color: kDarkTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _reactionButton("👍", message),
                  _reactionButton("❤️", message),
                  _reactionButton("😂", message),
                  _reactionButton("😮", message),
                  _reactionButton("😢", message),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reactionButton(String emoji, Message message) {
    return InkWell(
      onTap: () {
        setState(() {
          message.reaction = emoji;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: kDarkElementBg,
          shape: BoxShape.circle,
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _sendButtonAnimationController.dispose();
    _geminiService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkPrimaryBg,
      appBar: AppBar(
        backgroundColor: kDarkSurface,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: kAccentPurple,
              child: Icon(Icons.assistant, color: kDarkTextPrimary),
            ),
            SizedBox(width: 10),
            Text(
              "Assistente IA",
              style: TextStyle(
                color: kDarkTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: kDarkTextSecondary),
            onPressed: () {
              // Implementar menu de opções
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kDarkPrimaryBg,
                image: DecorationImage(
                  image: const AssetImage("assets/astronaut.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    kDarkPrimaryBg.withOpacity(0.9),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isAiTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageItem(_messages[index]);
                },
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    return GestureDetector(
      onLongPress: () {
        if (!message.isUser) {
          _showReactionMenu(message);
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: message.isUser ? 64 : 0,
          right: message.isUser ? 0 : 64,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: message.isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!message.isUser)
                  const CircleAvatar(
                    backgroundColor: kAccentPurple,
                    radius: 16,
                    child: Icon(
                      Icons.assistant,
                      size: 18,
                      color: kDarkTextPrimary,
                    ),
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser ? kDarkElementBg : kDarkSurface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.fileName != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: kDarkElementBg.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kDarkBorder, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  size: 20,
                                  color: kAccentPurple,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    message.fileName!,
                                    style: const TextStyle(
                                      color: kDarkTextPrimary,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser
                                ? kDarkTextPrimary
                                : kDarkTextPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (message.isUser)
                  const CircleAvatar(
                    backgroundColor: kAccentSecondary,
                    radius: 16,
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: kDarkTextPrimary,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Row(
                mainAxisAlignment: message.isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (message.reaction != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: kDarkElementBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.reaction!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  Text(
                    _formatTimestamp(
                        DateTime.fromMicrosecondsSinceEpoch(message.timestamp)),
                    style: const TextStyle(
                        color: kDarkTextSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8, right: 64),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            backgroundColor: kAccentPurple,
            radius: 16,
            child: Icon(Icons.assistant, size: 18, color: kDarkTextPrimary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kDarkSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -3 * math.sin((value * math.pi * 2) + index * 0.5)),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: kDarkTextSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kDarkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: kDarkTextSecondary),
              onPressed: _pickFile,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: kDarkElementBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kDarkBorder, width: 1),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: kDarkTextPrimary),
                  decoration: const InputDecoration(
                    hintText: "Digite uma mensagem...",
                    hintStyle: TextStyle(color: kDarkTextSecondary),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      _sendMessage();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTapDown: (_) {
                _sendButtonAnimationController.forward();
              },
              onTapUp: (_) {
                _sendButtonAnimationController.reverse();
                if (_textController.text.trim().isNotEmpty) {
                  _sendMessage();
                }
              },
              onTapCancel: () {
                _sendButtonAnimationController.reverse();
              },
              child: AnimatedBuilder(
                animation: _sendButtonAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _sendButtonAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: kAccentPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: kDarkTextPrimary,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    } else {
      return "${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    }
  }
}
