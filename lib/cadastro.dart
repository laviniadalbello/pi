import 'package:flutter/material.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Container(color: Colors.black),
            const AnimatedBlurredBackground(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    shaderCallback: (bounds) => const LinearGradient(
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

  Widget _buildLoginForm(BuildContext context) {
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
              "SIGN UP",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField("Name"),
            const SizedBox(height: 15),
            _buildTextField("Email"),
            const SizedBox(height: 15),
            _buildPasswordField(),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedCheckbox(),
                const SizedBox(width: 8),
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
                onPressed: () {},
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
                    child: const Text("SIGN UP", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return TextField(
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

  Widget _buildPasswordField() {
    return TextField(
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
        ),
      ),
    );
  }
}

class AnimatedCheckbox extends StatefulWidget {
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
          color: isChecked ? const Color.fromARGB(255, 187, 100, 221) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isChecked ? const Color.fromARGB(255, 176, 48, 250) : Colors.white70,
            width: 2,
          ),
        ),
        child: isChecked
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }
}


/* fundo animado */
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
          painter: BlurredGradientPainter(_controller.value, context),
        );
      },
    );
  }
}

class BlurredGradientPainter extends CustomPainter {
  final double animationValue;
  final BuildContext context;

  BlurredGradientPainter(this.animationValue, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, 100);

    List<List<Color>> gradientColors = [
      [Color(0xFF7526D4), Color(0xFFAB82E9)],
      [Color(0xFF2C26D4), Color(0xFF497FF5)],
      [Color(0xFFF549D6), Color(0xFFAB82E9)],
    ];

    List<Offset> positions = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.8),
    ];

    double circleSize = size.width * 0.4;

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
