import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importação adicionada
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final geminiService = GeminiService(apiKey: 'AIzaSyBFS5lVuEZzNklLyta4ioepOs2DDw2xPGA');

  runApp(
    MultiProvider(
      providers: [
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
      initialRoute: '/',
      routes: {
        '/': (context) => const Inicial(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/settings': (context) => const SettingsPage(),
        '/planner': (context) => PlannerDiarioPage(geminiService: geminiService),
        '/perfil': (context) => const PerfilPage(),
        '/adicionartarefa': (context) => const AddTaskPage(),
        '/criarevento': (context) => const CreateEventPage(),
        '/criarprojeto': (context) => const CreateProjectScreen(),
        '/criartime': (context) => const CreateTeamPage(),
        '/detalhestarefa': (context) => DetailsTaskPage(geminiService: geminiService),
        '/detalheseventos': (context) => Detalhesdoevento(geminiService: geminiService),
        '/detalhesprojeto': (context) => Detalhesdoprojeto(geminiService: geminiService),
        '/habitos': (context) => habits.HabitsPage(geminiService: geminiService),
        '/iconia': (context) => iconedaia.CloseableAiCard(
              geminiService: geminiService,
              firestoreService: Provider.of<FirestoreService>(context, listen: false),
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