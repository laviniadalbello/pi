import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:planify/services/firestore_service.dart';
import 'package:planify/src/pages/adicionartarefa.dart';
import 'package:planify/src/pages/criarevento.dart';
import 'package:planify/src/pages/criarprojeto.dart';
import 'package:planify/src/pages/criartime.dart';
import 'package:planify/src/pages/detalhesdastarefas.dart';
import 'package:planify/src/pages/detalhesdoevento.dart';
import 'package:planify/src/pages/detalhesdoprojeto.dart';
import 'package:planify/src/pages/iconedaia.dart' as iconedaia;
import 'package:planify/services/gemini_service.dart';
import 'package:planify/src/pages/inicial.dart';
import 'package:planify/src/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:planify/src/pages/cadastro.dart';
import 'package:planify/src/pages/configuracoes.dart';
import 'package:planify/src/pages/planner_diario.dart';
import 'package:planify/src/pages/perfil.dart';
import 'package:planify/src/pages/habits.dart' as habits;
import 'package:planify/src/pages/perfilvazio.dart';
import 'package:planify/repositories/invite_repository.dart'; // Adicione esta linha
import 'package:planify/services/invite_service.dart'; // Adicione esta linha
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Defina o navigatorKey globalmente
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicie o listener para notificações após o login
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      notificationService.iniciarListener(user.uid);
    } else {
      notificationService.dispose();
    }
  });

  final geminiService =
      GeminiService(apiKey: 'AIzaSyBFS5lVuEZzNklLyta4ioepOs2DDw2xPGA');

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: notificationService),
        Provider<GeminiService>(create: (_) => geminiService),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<InviteRepository>(create: (_) => InviteRepository()),
        Provider<InviteService>(
          create: (context) => InviteService(
            context.read<InviteRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final geminiService = Provider.of<GeminiService>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Adicione esta linha
      initialRoute: '/',
      routes: {
        '/': (context) => const Inicial(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/settings': (context) => const SettingsPage(),
        '/planner': (context) =>
            PlannerDiarioPage(geminiService: geminiService),
        '/perfil': (context) => const PerfilPage(),
        '/adicionartarefa': (context) => const AddTaskPage(),
        '/criarevento': (context) => const CreateEventPage(),
        '/criarprojeto': (context) => const CreateProjectScreen(),
        '/criartime': (context) => const CreateTeamPage(),
        '/detalhestarefa': (context) =>
            DetailsTaskPage(geminiService: geminiService),
        '/detalheseventos': (context) =>
            Detalhesdoevento(geminiService: geminiService),
        '/detalhesprojeto': (context) =>
            Detalhesdoprojeto(geminiService: geminiService),
        '/habitos': (context) =>
            habits.HabitsPage(geminiService: geminiService),
        '/iconia': (context) => iconedaia.CloseableAiCard(
              geminiService: geminiService,
              firestoreService:
                  Provider.of<FirestoreService>(context, listen: false),
            ),
        '/perfilvazio': (context) => const PerfilvazioPage(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', ''),
      ],
    );
  }
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription _sub;

  void iniciarListener(String userId) {
    _sub = _firestore
        .collection('notificacoes')
        .where('userId', isEqualTo: userId)
        .where('lida', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          _mostrarDialogoConvite(doc.doc);
        }
      }
    });
  }

  void _mostrarDialogoConvite(DocumentSnapshot notificacao) async {
    final context = navigatorKey.currentContext!;

    final convite = await _firestore
        .collection('convites')
        .where('projetoId', isEqualTo: notificacao['dados']['projetoId'])
        .where('convidadoId', isEqualTo: notificacao['userId'])
        .limit(1)
        .get();

    if (convite.docs.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Convite para ${notificacao['titulo']}"),
        content: Text(notificacao['mensagem']),
        actions: [
          TextButton(
            onPressed: () =>
                _responderConvite(false, convite.docs.first.id, notificacao.id),
            child: const Text('Recusar'),
          ),
          ElevatedButton(
            onPressed: () =>
                _responderConvite(true, convite.docs.first.id, notificacao.id),
            child: const Text('Aceitar'),
          ),
        ],
      ),
    );
  }

  Future<void> _responderConvite(
      bool aceito, String conviteId, String notificacaoId) async {
    final batch = _firestore.batch();
    final conviteRef = _firestore.collection('convites').doc(conviteId);
    final notificacaoRef =
        _firestore.collection('notificacoes').doc(notificacaoId);

    batch.update(conviteRef, {
      'status': aceito ? 'aceito' : 'recusado',
      'respondidoEm': FieldValue.serverTimestamp()
    });

    batch.update(notificacaoRef, {'lida': true});

    if (aceito) {
      final convite = await conviteRef.get();
      final projetoRef =
          _firestore.collection('projects').doc(convite['projetoId']);
      batch.update(projetoRef, {
        'members': FieldValue.arrayUnion([convite['convidadoId']])
      });
    }

    await batch.commit();
    Navigator.of(navigatorKey.currentContext!).pop();
  }

  void dispose() {
    _sub.cancel();
  }
}
