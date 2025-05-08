import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// --- Strings SVG ---
const String happyEyeSvg = '''
<svg fill="none" viewBox="0 0 24 24">
  <path fill="currentColor" d="M8.28386 16.2843C8.9917 15.7665 9.8765 14.731 12 14.731C14.1235 14.731 15.0083 15.7665 15.7161 16.2843C17.8397 17.8376 18.7542 16.4845 18.9014 15.7665C19.4323 13.1777 17.6627 11.1066 17.3088 10.5888C16.3844 9.23666 14.1235 8 12 8C9.87648 8 7.61556 9.23666 6.69122 10.5888C6.33728 11.1066 4.56771 13.1777 5.09858 15.7665C5.24582 16.4845 6.16034 17.8376 8.28386 16.2843Z"></path>
</svg>
''';

const String attachmentSvg = '''
<svg viewBox="0 0 24 24" height="20" width="20" xmlns="http://www.w3.org/2000/svg">
  <path d="M7 8v8a5 5 0 1 0 10 0V6.5a3.5 3.5 0 1 0-7 0V15a2 2 0 0 0 4 0V8" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" stroke="currentColor" fill="none"></path>
</svg>
''';

const String addSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24">
  <path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1zm0 10a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1zm10 0a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1h-4a1 1 0 0 1-1-1zm0-8h6m-3-3v6"></path>
</svg>
''';

const String globeSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24">
  <path fill="currentColor" d="M12 22C6.477 22 2 17.523 2 12S6.477 2 12 2s10 4.477 10 10s-4.477 10-10 10m-2.29-2.333A17.9 17.9 0 0 1 8.027 13H4.062a8.01 8.01 0 0 0 5.648 6.667M10.03 13c.151 2.439.848 4.73 1.97 6.752A15.9 15.9 0 0 0 13.97 13zm9.908 0h-3.965a17.9 17.9 0 0 1-1.683 6.667A8.01 8.01 0 0 0 19.938 13M4.062 11h3.965A17.9 17.9 0 0 1 9.71 4.333A8.01 8.01 0 0 0 4.062 11m5.969 0h3.938A15.9 15.9 0 0 0 12 4.248A15.9 15.9 0 0 0 10.03 11m4.259-6.667A17.9 17.9 0 0 1 15.973 11h3.965a8.01 8.01 0 0 0-5.648-6.667"></path>
</svg>
''';

const String submitSvg = '''
<svg viewBox="0 0 512 512">
  <path d="M473 39.05a24 24 0 0 0-25.5-5.46L47.47 185h-.08a24 24 0 0 0 1 45.16l.41.13l137.3 58.63a16 16 0 0 0 15.54-3.59L422 80a7.07 7.07 0 0 1 10 10L226.66 310.26a16 16 0 0 0-3.59 15.54l58.65 137.38c.06.2.12.38.19.57c3.2 9.27 11.3 15.81 21.09 16.25h1a24.63 24.63 0 0 0 23-15.46L478.39 64.62A24 24 0 0 0 473 39.05" fill="currentColor"></path>
</svg>
''';

class CloseableAiCard extends StatefulWidget {
  final double scaleFactor;

  const CloseableAiCard({super.key, this.scaleFactor = 1.0}); // Valor padrão 1.0

  @override
  _CloseableAiCardState createState() => _CloseableAiCardState();
}

class _CloseableAiCardState extends State<CloseableAiCard> {
  bool _isHovering = false;
  bool _isChecked = false;
  final GlobalKey _cardKey = GlobalKey();

  void _handleTapOutside() {
    if (_isChecked) {
      setState(() {
        _isChecked = false;
      });
    }
  }

  void _toggleChecked() {
    setState(() {
      _isChecked = !_isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isChecked)
            Positioned.fill(
              child: GestureDetector(
                onTap: _handleTapOutside,
                child: Container(color: Colors.transparent),
              ),
            ),
          // O Card em si, envolvido por Transform.scale
          AnimatedSlide(
            offset: _isChecked ? const Offset(-0.15, 0.0) : Offset.zero,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: Transform.scale(
              scale: _isChecked ? 1.0 : widget.scaleFactor,
              child: AiInputCard(
                key: _cardKey,
                isChecked: _isChecked,
                onToggleChecked: _toggleChecked,
                isHovering: _isHovering,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiInputCard extends StatefulWidget {
  final bool isHovering;
  final bool isChecked;
  final VoidCallback onToggleChecked;

  const AiInputCard({
    super.key,
    required this.isChecked,
    required this.onToggleChecked,
    required this.isHovering,
  });

  @override
  _AiInputCardState createState() => _AiInputCardState();
}

class _AiInputCardState extends State<AiInputCard>
    with TickerProviderStateMixin {
  final Offset _mousePosition = Offset.zero;
  final Offset _relativeMousePosition = Offset.zero;
  final GlobalKey _cardContentKey = GlobalKey();

  late AnimationController _eyeAnimationController;
  late Animation<double> _eyeAnimation;
  late AnimationController _ballRotationController;

  // Constantes
  final double _perspective = 1000.0;
  final double _translateY = 45.0;
  final Duration _transitionDuration = const Duration(milliseconds: 300);
  final Duration _cardTransitionDuration = const Duration(milliseconds: 600);
  final double _initialCardWidth = 12 * 16.0;
  final double _initialCardHeight = 12 * 16.0;
  final double _checkedCardWidth = 360.0;
  final double _checkedCardHeight = 180.0;
  final double _borderRadius = 3 * 16.0;
  final double _checkedBorderRadius = 20.0;
  final double _eyeMovementFactor = 0.05;
  final double _maxEyeOffset = 5.0;
  final TextEditingController _messageController = TextEditingController();

    Future<void> _handleSendMessage() async {
    final message = _messageController.text;
    if (message.isEmpty) return;

    final response = await _processMessageWithML(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response)),
    );

    _messageController.clear();
  }

  Future<String> _processMessageWithML(String message) async {
    // Implementação real do ML Kit virá aqui
    return "📌 ML Kit respondeu: $message";
  }

  @override
  void initState() {
    super.initState();
    _eyeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _eyeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(52.0), weight: 46),
      TweenSequenceItem(
        tween: Tween<double>(begin: 52.0, end: 20.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 20.0, end: 52.0),
        weight: 2,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(52.0), weight: 46),
      TweenSequenceItem(
        tween: Tween<double>(begin: 52.0, end: 20.0),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 20.0, end: 52.0),
        weight: 2,
      ),
    ]).animate(_eyeAnimationController);
    _ballRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _eyeAnimationController.dispose();
    _ballRotationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Matrix4 _calculateTransform(Offset position, Size containerSize) {
    // UPDATED: Use widget.isHovering
    if (!widget.isHovering || widget.isChecked) {
      return Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(0.0, 0.0, 50.0);
    }
    final double normalizedX = (position.dx / containerSize.width) * 2 - 1;
    final double normalizedY = (position.dy / containerSize.height) * 2 - 1;
    final double rotateY = normalizedX * (math.pi / 12);
    final double rotateX = -normalizedY * (math.pi / 12);
    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(rotateX)
      ..rotateY(rotateY)
      ..translate(0.0, 0.0, _translateY);
  }

  Offset _calculateEyeOffset() {
    // UPDATED: Use widget.isHovering
    if (!widget.isHovering ||
        widget.isChecked ||
        _cardContentKey.currentContext == null) {
      return Offset.zero;
    }
    final RenderBox cardBox =
        _cardContentKey.currentContext!.findRenderObject() as RenderBox;
    final Size cardSize = cardBox.size;
    final Offset center = Offset(cardSize.width / 2, cardSize.height / 2);
    final Offset delta = _relativeMousePosition - center;
    final double offsetX = (delta.dx * _eyeMovementFactor).clamp(
      -_maxEyeOffset,
      _maxEyeOffset,
    );
    final double offsetY = (delta.dy * _eyeMovementFactor).clamp(
      -_maxEyeOffset,
      _maxEyeOffset,
    );
    return Offset(offsetX, offsetY);
  }

  @override
  Widget build(BuildContext context) {
    final double currentCardWidth =
        widget.isChecked ? _checkedCardWidth : _initialCardWidth;
    final double currentCardHeight =
        widget.isChecked ? _checkedCardHeight : _initialCardHeight;

    return GestureDetector(
      onTap: widget.onToggleChecked,
      child: AnimatedContainer(
        duration: _transitionDuration,
        // UPDATED: Use widget.isHovering
        padding: EdgeInsets.all(widget.isHovering && !widget.isChecked ? 0 : 4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Simulação do :after
            AnimatedContainer(
              duration: _transitionDuration,
              width: _initialCardWidth,
              // UPDATED: Use widget.isHovering
              height:
                  widget.isHovering && !widget.isChecked
                      ? _initialCardHeight
                      : 11 * 16.0,
              decoration: BoxDecoration(
                color: Color.fromARGB(0, 222, 223, 224),
                borderRadius: BorderRadius.circular(3.2 * 16.0),
              ),
              // UPDATED: Use widget.isHovering
              transform: Matrix4.translationValues(
                0,
                widget.isHovering && !widget.isChecked
                    ? 0
                    : -(_initialCardHeight * 0.05),
                0,
              ),
              transformAlignment: Alignment.center,
            ),
            // Card Principal
            LayoutBuilder(
              builder: (context, constraints) {
                final Size actualSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                return AnimatedContainer(
                  duration: _cardTransitionDuration,
                  width: currentCardWidth,
                  height: currentCardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      widget.isChecked ? _checkedBorderRadius : _borderRadius,
                    ),
                    // UPDATED: Use widget.isHovering
                    boxShadow:
                        widget.isHovering && !widget.isChecked
                            ? [
                              BoxShadow(
                                color: Color(0xFF00003C).withOpacity(0.25),
                                blurRadius: 40,
                                offset: Offset(0, 10),
                              ),
                            ]
                            : [],
                  ),
                  transform: _calculateTransform(
                    _relativeMousePosition,
                    actualSize,
                  ),
                  transformAlignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [_buildBackgroundBalls(), _buildCardContent()],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundBalls() {
    final double currentBorderRadius =
        widget.isChecked ? _checkedBorderRadius : _borderRadius;

    return AnimatedContainer(
      duration: _transitionDuration,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(currentBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ballRotationController,
            // UPDATED: Use widget.isHovering
            builder:
                (context, child) => Transform.rotate(
                  angle:
                      _ballRotationController.value *
                      2 *
                      math.pi *
                      (widget.isHovering ? 0 : 1),
                  child: child,
                ),
            child: Stack(
              children: [
                Positioned(
                  top: -3 * 16.0,
                  left: _initialCardWidth / 2 - (3 * 16.0),
                  child: _buildBlurBall(
                    Colors.deepPurpleAccent.shade400,
                  ), // Neon violeta
                ),
                Positioned(
                  bottom: -3 * 16.0,
                  left: _initialCardWidth / 2 - (3 * 16.0),
                  child: _buildBlurBall(Color(0xFF00FFAA)), // Verde neon
                ),
                Positioned(
                  top: _initialCardHeight / 2 - (3 * 16.0),
                  left: -3 * 16.0,
                  child: _buildBlurBall(Color(0xFFFF1E8E)), // Rosa neon
                ),
                Positioned(
                  top: _initialCardHeight / 2 - (3 * 16.0),
                  right: -3 * 16.0,
                  child: _buildBlurBall(Color(0xFF00FFFF)), // Ciano puro
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBall(Color color) {
    return Container(
      width: 6 * 16.0,
      height: 6 * 16.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.7),
            blurRadius: 40,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    final double currentBorderRadius =
        widget.isChecked ? _checkedBorderRadius : _borderRadius;
    return ClipRRect(
      key: _cardContentKey,
      borderRadius: BorderRadius.circular(currentBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
        child: Container(
          color: Colors.transparent, // Necessário para BackdropFilter
          child: Stack(
            alignment: Alignment.center,
            children: [_buildEyes(), _buildChatInterface()],
          ),
        ),
      ),
    );
  }

  Widget _buildEyes() {
    final Offset eyeOffset = _calculateEyeOffset();
    return AnimatedOpacity(
      duration: _transitionDuration,
      opacity: widget.isChecked ? 0.0 : 1.0,
      child: IgnorePointer(
        ignoring: widget.isChecked,
        child: Padding(
          padding: EdgeInsets.only(bottom: _initialCardHeight * 0.1),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Olhos normais (piscando e seguindo)
              AnimatedOpacity(
                duration: _transitionDuration,
                // UPDATED: Use widget.isHovering
                opacity: widget.isHovering ? 0.0 : 1.0,
                child: Transform.translate(
                  offset: eyeOffset,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSingleEye(),
                      SizedBox(width: 2 * 16.0),
                      _buildSingleEye(),
                    ],
                  ),
                ),
              ),
              // Olhos felizes (hover)
              AnimatedOpacity(
                duration: _transitionDuration,
                // UPDATED: Use widget.isHovering
                opacity: widget.isHovering ? 1.0 : 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.string(
                      happyEyeSvg,
                      width: 60,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SvgPicture.string(
                      happyEyeSvg,
                      width: 60,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleEye() {
    return AnimatedBuilder(
      animation: _eyeAnimation,
      builder:
          (context, child) => Container(
            width: 26,
            height: _eyeAnimation.value,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }

  Widget _buildChatInterface() {
    return AnimatedOpacity(
      duration: _transitionDuration,
      opacity: widget.isChecked ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !widget.isChecked,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'sans-serif',
                      ),
                      decoration: InputDecoration(
                        hintText: "Imagine Something...✦˚",
                        hintStyle: TextStyle(color: Color(0xFFDEDFE0)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          // CORRIGIDO: Usa o widget _HoverTranslateSvgButton
                          _HoverTranslateSvgButton(
                            svgData: attachmentSvg,
                            initialColor: Colors.white,
                            hoverColor: Color(0xFF8B8B8B),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          _HoverTranslateSvgButton(
                            svgData: addSvg,
                            initialColor: Colors.white,
                            hoverColor: Color(0xFF8B8B8B),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          _HoverTranslateSvgButton(
                            svgData: globeSvg,
                            initialColor: Colors.white,
                            hoverColor: Color(0xFF8B8B8B),
                            size: 20,
                          ),
                        ],
                      ),
                      // CORRIGIDO: Usa o widget _HoverScaleButton com builder
                      _HoverScaleButton(
                        initialOpacity: 0.7,
                        hoverOpacity: 1.0,
                        activeScale: 0.92,
                        onTap: _handleSendMessage,
                        builder: (context, isHovering, isDown) {
                          final Color iconColor = Colors.white;
                          final List<BoxShadow>? iconShadow =
                              isHovering
                                  ? [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      blurRadius: 5,
                                    ),
                                  ]
                                  : null;
                          return Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF9147FF),
                                  Color(0xFFFF4141),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 2.0,
                                  spreadRadius: -4.0,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Container(
                              width: 30,
                              height: 30,
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: iconShadow, // Aplica sombra no hover
                              ),
                              child: SvgPicture.string(
                                submitSvg,
                                colorFilter: ColorFilter.mode(
                                  iconColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverTranslateSvgButton extends StatefulWidget {
  final String svgData;
  final Color initialColor;
  final Color hoverColor;
  final double size;

  const _HoverTranslateSvgButton({
    required this.svgData,
    required this.initialColor,
    required this.hoverColor,
    required this.size,
  });

  @override
  __HoverTranslateSvgButtonState createState() =>
      __HoverTranslateSvgButtonState();
}

class __HoverTranslateSvgButtonState extends State<_HoverTranslateSvgButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final Color currentColor =
        _isHovering ? widget.hoverColor : widget.initialColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          /* Ação do botão de opção */
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0, _isHovering ? -5 : 0, 0),
          child: SvgPicture.string(
            widget.svgData,
            width: widget.size,
            height: widget.size,
            colorFilter: ColorFilter.mode(currentColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

// CORRIGIDO: Botão que muda opacidade e escala, passando estado para o builder
class _HoverScaleButton extends StatefulWidget {
  final double initialOpacity;
  final double hoverOpacity;
  final double activeScale;
  final Widget Function(BuildContext context, bool isHovering, bool isDown)
  builder;
  final VoidCallback onTap;

  const _HoverScaleButton({
    required this.builder,
    this.initialOpacity = 1.0,
    this.hoverOpacity = 1.0,
    this.activeScale = 1.0,
    required this.onTap
  });

  @override
  __HoverScaleButtonState createState() => __HoverScaleButtonState();
}

class __HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _isHovering = false;
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    final double currentScale = _isDown ? widget.activeScale : 1.0;
    final double currentOpacity =
        _isHovering ? widget.hoverOpacity : widget.initialOpacity;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isDown = true),
        onTapUp: (_) => setState(() => _isDown = false),
        onTapCancel: () => setState(() => _isDown = false),
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: currentOpacity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.identity()..scale(currentScale),
            transformAlignment: Alignment.center,
            child: widget.builder(context, _isHovering, _isDown),
          ),
        ),
      ),
    );
  }
}
