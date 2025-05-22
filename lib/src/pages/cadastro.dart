import 'package:flutter/material.dart';
import 'dart:math';
import 'package:planify/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseServiceAuth _authService = FirebaseServiceAuth();
  void _validateAndSubmit() {
  if (_formKey.currentState?.validate() ?? false) {
    // Chama a função de registro com os dados dos controllers
    submitRegistration(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
  } else {
    _showDialog('Error', 'Please correct the errors in the form');
  }
}

  bool _isLoading = false;

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
                _buildTitle(),
                const SizedBox(height: 20),
                _buildLoginForm(context),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
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

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          "Create your",
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
            "Account",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(141, 11, 13, 34).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "SIGN UP",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Name", _nameController),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailController, isEmail: true),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AnimatedCheckbox(),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {},
                    child: RichText(
                      text: const TextSpan(
                        text: "I have read the ",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        children: [
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              color: Color(0xFFBF99F8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.transparent,
                    ),
                    elevation: WidgetStateProperty.all(0),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
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
                      constraints: const BoxConstraints(
                        minHeight: 38,
                        maxWidth: 160,
                      ),

                      alignment: Alignment.center,
                      child: const Text(
                        "SIGN UP",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (isEmail &&
            !RegExp(
              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
            ).hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.purpleAccent),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          tooltip: _obscureText ? 'Show password' : 'Hide password',
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (!RegExp(
          r'^(?=.*?[0-9])(?=.*?[A-Za-z])(?=.*?[A-Z])',
        ).hasMatch(value)) {
          return 'Password must contain letters, numbers, and at least one uppercase letter';
        }
        return null;
      },
    );
  }

Future<void> submitRegistration(
  String name,
  String email,
  String password,
) async {
  setState(() {
    _isLoading = true;
  });

  try {
    print('Registrando usuário no Firebase...');
    final user = await _authService.registerUser(
      name: name,
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      print('Registro com sucesso: ${user.uid}');
      
      // Exibe o SnackBar de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      // Redireciona para a tela de login ou home
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      print('Erro ao registrar: usuário é nulo');
      _showDialog('Erro', 'Não foi possível registrar o usuário.');
    }
 } catch (e) {
  setState(() {
    _isLoading = false;
  });
  
  print('Erro no Firebase: $e');
  
  String errorMessage = 'Ocorreu um erro. Tente novamente mais tarde.';
  if (e is FirebaseAuthException) {  // Agora vai reconhecer o tipo
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'Este email já está em uso.';
        break;
      case 'invalid-email':
        errorMessage = 'Email inválido.';
        break;
      case 'weak-password':
        errorMessage = 'Senha muito fraca. Use pelo menos 6 caracteres.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Operação não permitida.';
        break;
      default:
        errorMessage = 'Erro no cadastro: ${e.message}';
    }
  }
  
  _showDialog('Erro', errorMessage);
}
}
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AnimatedCheckbox extends StatefulWidget {
  const AnimatedCheckbox({super.key});

  @override
  _AnimatedCheckboxState createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color:
              isChecked
                  ? const Color.fromARGB(255, 187, 100, 221)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                isChecked
                    ? const Color.fromARGB(255, 176, 48, 250)
                    : Colors.white70,
            width: 2,
          ),
        ),
        child:
            isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
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

    // Gradientes de cor
    final List<List<Color>> gradientColors = [
      [const Color(0xFF7526D4), const Color(0xFFAB82E9)], // Roxo
      [const Color(0xFF2C26D4), const Color(0xFF497FF5)], // Azul
      [const Color(0xFFF549D6), const Color(0xFFAB82E9)], // Rosa
    ];

    // Calculando posições dinâmicas com base em senos e cossenos
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
