import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          const AnimatedBlurredBackground(),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF3254FF), Color(0xFFCDA2FF)],
                    ).createShader(bounds),
                    child: const Text(
                      "Dear Friend",
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.purpleAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SizedBox(
      width: 320,
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
            _buildTextField("Email", controller: _emailController),
            const SizedBox(height: 15),
            _buildTextField(
              "Password",
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  final email = _emailController.text.trim();

                  if (email.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Por favor, insira seu e-mail"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }

                  try {
                    setState(() => _isLoading = true);
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: email,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "E-mail de recuperação enviado para $email",
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    if (mounted) {
                      String errorMessage;
                      switch (e.code) {
                        case 'invalid-email':
                          errorMessage = 'E-mail inválido';
                          break;
                        case 'user-not-found':
                          errorMessage =
                              'Nenhum usuário encontrado com este e-mail';
                          break;
                        default:
                          errorMessage =
                              'Erro ao enviar e-mail de recuperação: ${e.message}';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                child: const Text(
                  "Forgot Password ?",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => login(
                          _emailController.text,
                          _passwordController.text,
                          context,
                        ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor:
                      Colors.transparent, // Mantém o estilo quando desabilitado
                ).copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.disabled)
                        ? Colors.transparent
                        : Colors.transparent,
                  ),
                  elevation: WidgetStateProperty.all(0),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _isLoading
                        ? const LinearGradient(
                            // Gradiente mais suave durante loading
                            colors: [Color(0xFFC9B2F0), Color(0xFF8E5DDB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
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
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "LOGIN",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white70,
                    thickness: 1,
                    endIndent: 10,
                  ),
                ),
                Text(
                  "TUDO EM UM PLANO.",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white70,
                    thickness: 1,
                    indent: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroPage(),
                    ),
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

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      setState(() => _isLoading = true);

      // Adicionar logs para depuração
      debugPrint('Tentando login com email: $email');

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Tempo excedido ao tentar conectar');
      });

      if (!mounted) return;

      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/habitos');
        debugPrint('DEBUG: Login bem-sucedido. Navegando para /habitos.');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'E-mail inválido';
          break;
        case 'user-not-found':
          errorMessage = 'Nenhum usuário encontrado com este e-mail';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta';
          break;
        case 'user-disabled':
          errorMessage = 'Conta desativada';
          break;
        case 'network-request-failed':
          errorMessage = 'Problema de conexão com a internet';
          break;
        default:
          errorMessage = 'Erro ao fazer login: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      debugPrint('Erro de autenticação: ${e.code} - ${e.message}');
    } on TimeoutException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Tempo excedido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro desconhecido: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erro desconhecido: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Mantenha suas classes AnimatedBlurredBackground e BlurredGradientPainter existentes
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
    final Paint paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

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
