import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key});

  @override
  _AlterarSenhaPageState createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  bool _obscureText = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(),
                const SizedBox(height: 20),
                _buildPasswordForm(context),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
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
          "Change your ",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF3254FF), Color(0xFFCDA2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "Password",
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

  Widget _buildPasswordForm(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(141, 11, 13, 34).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildPasswordField("New Password", _newPasswordController),
              const SizedBox(height: 20),
              _buildPasswordField("Confirm Password", _confirmPasswordController),
              const SizedBox(height: 20),
              _buildCheckbox(),
              const SizedBox(height: 25),
              _buildChangeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: _obscureText,
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
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label is required';
        if (value.length < 8) return 'Password must be at least 8 characters';
        if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])').hasMatch(value)) {
          return 'Password must contain uppercase, lowercase and numbers';
        }
        if (label == "Confirm Password" && 
            value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          const AnimatedCheckbox(),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: RichText(
              text: const TextSpan(
                text: "Confirm   password  ",
                style: TextStyle(color: Colors.white70, fontSize: 12),
                children: [
                  TextSpan(
                    text: "Change",
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
    );
  }

  Widget _buildChangeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _changePassword,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) => states.contains(MaterialState.disabled)
                ? Colors.grey
                : Colors.transparent,
          ),
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
            height: 50,
            alignment: Alignment.center,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Change",
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog("No user logged in");
        return;
      }

      await user.updatePassword(_newPasswordController.text);
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _showErrorDialog("An unexpected error occurred");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleFirebaseError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'requires-recent-login':
        message = 'Please reauthenticate before changing password';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      default:
        message = 'Error: ${e.message}';
    }
    _showErrorDialog(message);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Password changed successfully"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
