import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cadastro.dart';
import 'alterarsenha.dart';
import 'dart:math';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Container(color: Colors.black),
            const AnimatedBlurredBackground(),
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome Back",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [Color(0xFF3254FF), Color(0xFFCDA2FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                    child: const Text(
                      "Dear Friend",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLoginForm(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLoginForm(BuildContext context) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  return SizedBox(
    width: 320,
    height: 428,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(141, 11, 13, 34).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          const Text(
            "LOGIN",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField("Email", controller: emailController),
          const SizedBox(height: 15),
          _buildTextField(
            "Password",
            obscureText: true,
            controller: passwordController,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // Redirecionando para a tela de alterar senha
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlterarSenhaPage()),
                );
              },
              child: Text(
                "Forgot Password ?",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Envia os dados de login
                login(emailController.text, passwordController.text, context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => Colors.transparent,
                ),
                elevation: MaterialStateProperty.all(0),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAB82E9), Color(0xFF7526D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: 129,
                  height: 28,
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 28),
                  child: const Text("LOGIN", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.white70,
                  thickness: 1,
                  endIndent: 10,
                ),
              ),
              Text(
                "Login with social accounts",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Expanded(
                child: Divider(color: Colors.white70, thickness: 1, indent: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.g_translate, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.facebook, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroPage()),
                );
              },
              child: RichText(
                text: const TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  children: [
                    TextSpan(
                      text: "Sign up",
                      style: TextStyle(
                        color: Color(0xFFBF99F8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTextField(
  String label, {
  bool obscureText = false,
  TextEditingController? controller,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.purpleAccent),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Future<void> login(String email, String password, BuildContext context) async {
  final url = Uri.parse('http://localhost:8080/login');

  final body = json.encode({'email': email, 'password': password});

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      // Login bem-sucedido
      final responseData = json.decode(response.body);
      print('Login bem-sucedido: $responseData');

      Navigator.pushNamed(context, '/home');
    } else {
      // Login falhou
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text('Erro de Login'),
              content: Text('Credenciais inválidas ou erro no servidor.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
      );
    }
  } catch (error) {
    print('Erro na requisição: $error');
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Erro'),
            content: Text(
              'Ocorreu um erro ao tentar realizar o login. Tente novamente mais tarde.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }
}

class AnimatedBlurredBackground extends StatefulWidget {
  const AnimatedBlurredBackground({super.key});

  @override
  AnimatedBlurredBackgroundState createState() =>
      AnimatedBlurredBackgroundState();
}

class AnimatedBlurredBackgroundState extends State<AnimatedBlurredBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: BlurredGradientPainter(_controller.value),
        );
      },
    );
  }
}

class BlurredGradientPainter extends CustomPainter {
  final double animationValue;

  BlurredGradientPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    final List<List<Color>> gradientColors = [
      [const Color(0xFF7526D4), const Color(0xFFAB82E9)], // Roxo
      [const Color(0xFF2C26D4), const Color(0xFF497FF5)], // Azul
      [const Color(0xFFF549D6), const Color(0xFFAB82E9)], // Rosa
    ];

    final List<Offset> positions = [
      Offset(
        size.width * (0.2 + 0.1 * sin(animationValue * pi * 2)),
        size.height * (0.2 + 0.1 * sin(animationValue * pi * 2)),
      ),
      Offset(
        size.width * (0.7 + 0.2 * cos(animationValue * pi * 2)),
        size.height * (0.5 + 0.2 * sin(animationValue * pi * 2)),
      ),
      Offset(
        size.width * (0.4 + 0.3 * sin(animationValue * pi * 2)),
        size.height * (0.8 + 0.2 * cos(animationValue * pi * 2)),
      ),
    ];

    final double circleSize = size.width * 0.4;

    for (int i = 0; i < gradientColors.length; i++) {
      paint.shader = LinearGradient(
        colors: gradientColors[i],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: positions[i], radius: circleSize));
      canvas.drawCircle(positions[i], circleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
