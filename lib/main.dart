import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:planify/src/pages/adicionartarefa.dart';
import 'package:planify/src/pages/criarevento.dart';
import 'package:planify/src/pages/criarprojeto.dart';
import 'package:planify/src/pages/criartime.dart';
import 'package:planify/src/pages/detalhesdastarefas.dart';
import 'package:planify/src/pages/detalhesdoevento.dart';
import 'package:planify/src/pages/detalhesdoprojeto.dart';
import 'package:planify/src/pages/iconedaia.dart'; // Renomeado de iconedaia.dart para CloseableAiCard
import 'package:planify/services/gemini_service.dart';
import './src/pages/inicial.dart';
import './src/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './src/pages/cadastro.dart';
import './src/pages/configuracoes.dart';
import './src/pages/planner_diario.dart';
import './src/pages/perfil.dart';
import './src/pages/habits.dart';
import './src/pages/perfilvazio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Garanta que esta linha está correta
  );

  // Instancia o GeminiService passando a chave da API diretamente
  final geminiService = GeminiService(apiKey: 'AIzaSyBh4Pf0G-YZJJqEL_UGFzWMCciG3-KH9vQ'); // <<-- SUBSTITUA PELA SUA CHAVE REAL AQUI

  // Chamada de diagnóstico: Para verificar quais modelos estão disponíveis.
  // Você pode remover esta linha após confirmar que o modelo 'gemini-pro' funciona.
  await geminiService.listAvailableModels();

  runApp(MyApp(geminiService: geminiService));
}

class MyApp extends StatelessWidget {
  final GeminiService geminiService;

  const MyApp({
    super.key,
    required this.geminiService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Inicial(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/settings': (context) => const SettingsPage(),
        '/planner': (context) => PlannerDiarioPage(
              geminiService: geminiService,
            ),
        '/perfil': (context) => const PerfilPage(),
        '/adicionartarefa': (context) => const AddTaskPage(),
        '/criarevento': (context) => const CreateEventPage(),
        '/criarprojeto': (context) => const CreateProjectScreen(),
        '/criartime': (context) => const CreateTeamPage(),
        '/detalhestarefa': (context) => DetailsTaskPage(geminiService: geminiService),
        '/detalheseventos': (context) => Detalhesdoevento(geminiService: geminiService),
        '/detalhesprojeto': (context) => Detalhesdoprojeto(geminiService: geminiService),
        '/habitos': (context) => HabitsPage(geminiService: geminiService),
        '/iconia': (context) {
          return CloseableAiCard(geminiService: geminiService);
        },
        '/perfilvazio': (context) => const PerfilvazioPage(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português (Brasil)
        Locale('en', ''), // Inglês (como fallback ou outro idioma suportado)
      ],
    );
  }
}