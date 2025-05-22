import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:planify/src/pages/adicionartarefa.dart';
import 'package:planify/src/pages/criarevento.dart';
import 'package:planify/src/pages/criarprojeto.dart';
import 'package:planify/src/pages/criartime.dart';
import 'package:planify/src/pages/detalhesdastarefas.dart';
import 'package:planify/src/pages/detalhesdoevento.dart';
import 'package:planify/src/pages/detalhesdoprojeto.dart';
import 'package:planify/src/pages/iconedaia.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';





void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Inicial(),
        '/login': (context) => const LoginPage(),
        '/cadastro': (context) => CadastroPage(),
        '/settings': (context) => const SettingsPage(),
        '/planner': (context) => const PlannerDiarioPage(),
        '/perfil': (context) => const PerfilPage(),
        '/adicionartarefa': (context) => const AddTaskPage(),
        '/criarevento': (context) => const CreateEventPage(),
        '/criarprojeto': (context) => const CreateProjectScreen(),
        '/criartime': (context) => const CreateTeamPage(),
        '/detalhestarefa': (context) => const DetailsTaskPage(),
        '/detalheseventos': (context) => const Detalhesdoevento(),
        '/detalhesprojeto': (context) => const Detalhesdoprojeto(),
        '/habitos': (context) => const HabitsPage(),
        '/iconia': (context) => const CloseableAiCard(),
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