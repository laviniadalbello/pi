import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'chatdaia.dart'; // Importe chatdaia.dart
import 'package:planify/services/gemini_service.dart';
import 'package:planify/services/firestore_service.dart';

// Cores e SVGs existentes
const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

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
  final bool enableScroll;
  final GeminiService geminiService;
  final FirestoreService firestoreService;

  const CloseableAiCard({
    super.key,
    required this.geminiService,
    required this.firestoreService,
    this.scaleFactor = 0.4,
    this.enableScroll = false,
  });

  @override
  State<CloseableAiCard> createState() => _CloseableAiCardState();
}

class _CloseableAiCardState extends State<CloseableAiCard> {
  bool _isHovering = false;
  // bool _isChecked = false; // Não precisamos mais desse estado para expandir o chat aqui
  final GlobalKey _cardKey = GlobalKey();

  // Removemos os controladores de scroll e a lista de mensagens daqui,
  // pois a lógica de chat se move para ChatScreen.

  @override
  void initState() {
    super.initState();
  }

  // Não precisamos de _handleTapOutside nem _toggleChecked
  // porque o clique agora navega.

  @override
  void dispose() {
    // Removemos o dispose do _scrollController
    super.dispose();
  }

  // Novo método para navegar para a ChatScreen
  void _navigateToChatScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          title: "Assistente IA", // Título da tela de chat
          geminiService: widget.geminiService,
          firestoreService: widget.firestoreService,
          // Não passamos uma mensagem inicial aqui,
          // a ChatScreen vai lidar com isso sozinha.
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _navigateToChatScreen, // <--- O clique agora navega para ChatScreen
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Não precisamos mais do AnimatedSlide, nem do Positioned.fill
            // porque não há expansão dentro deste widget.
            Transform.scale(
              scale: widget.scaleFactor, // Mantém a escala inicial
              child: AiInputCard(
                key: _cardKey,
                isHovering: _isHovering,
                // Não precisamos mais de isChecked, onToggleChecked, scrollController, enableScroll, messages, onSendMessage aqui.
                // Apenas os serviços para o caso do AiInputCard precisar passar para a próxima tela
                geminiService: widget.geminiService,
                firestoreService: widget.firestoreService,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiInputCard extends StatefulWidget {
  final bool isHovering;
  // final bool isChecked; // Removido
  // final VoidCallback onToggleChecked; // Removido
  // final ScrollController scrollController; // Removido
  // final bool enableScroll; // Removido
  // final List<Map<String, String>> messages; // Removido
  final GeminiService geminiService; // Mantido para passar adiante, se necessário
  final FirestoreService firestoreService; // Mantido para passar adiante, se necessário
  // final ValueChanged<String> onSendMessage; // Removido

  const AiInputCard({
    super.key,
    // required this.isChecked, // Removido
    // required this.onToggleChecked, // Removido
    required this.isHovering,
    // required this.scrollController, // Removido
    // required this.enableScroll, // Removido
    // required this.messages, // Removido
    required this.geminiService,
    required this.firestoreService,
    // required this.onSendMessage, // Removido
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
  // final double _checkedCardWidth = 360.0; // Não usado
  // final double _checkedCardHeight = 480.0; // Não usado
  final double _borderRadius = 3 * 16.0;
  // final double _checkedBorderRadius = 20.0; // Não usado
  final double _eyeMovementFactor = 0.05;
  final double _maxEyeOffset = 5.0;
  // final TextEditingController _messageController = TextEditingController(); // Não usado

  // O método _handleSendMessage foi removido pois a lógica de chat não está mais aqui.

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
    // _messageController.dispose(); // Removido
    super.dispose();
  }

  Matrix4 _calculateTransform(Offset position, Size containerSize) {
    // Apenas aplica a transformação de hover, já que não há mais isChecked para expandir
    if (!widget.isHovering) {
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
    if (!widget.isHovering || _cardContentKey.currentContext == null) { // Removido isChecked
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
    // Reduzimos as variáveis de largura/altura dinâmicas, pois o card não expande aqui
    final double currentCardWidth = _initialCardWidth;
    final double currentCardHeight = _initialCardHeight;
    final double currentBorderRadius = _borderRadius; // Não precisamos de _checkedBorderRadius

    return AnimatedContainer(
      duration: _transitionDuration,
      padding: EdgeInsets.all(widget.isHovering ? 0 : 4), // Removido !widget.isChecked
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulação do :after
          AnimatedContainer(
            duration: _transitionDuration,
            width: _initialCardWidth,
            height: widget.isHovering
                ? _initialCardHeight
                : 11 * 16.0,
            decoration: BoxDecoration(
              color: kDarkSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3.2 * 16.0),
            ),
            transform: Matrix4.translationValues(
              0,
              widget.isHovering
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
                  borderRadius: BorderRadius.circular(currentBorderRadius),
                  boxShadow: widget.isHovering
                      ? [ // Removido !widget.isChecked
                          BoxShadow(
                            color: kAccentPurple.withOpacity(0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 10),
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
    );
  }

  Widget _buildBackgroundBalls() {
    final double currentBorderRadius = _borderRadius; // Não precisamos de _checkedBorderRadius

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
            builder: (context, child) => Transform.rotate(
              angle: _ballRotationController.value *
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
                  child: _buildBlurBall(kAccentPurple),
                ),
                Positioned(
                  bottom: -3 * 16.0,
                  left: _initialCardWidth / 2 - (3 * 16.0),
                  child: _buildBlurBall(kAccentSecondary),
                ),
                Positioned(
                  top: _initialCardHeight / 2 - (3 * 16.0),
                  left: -3 * 16.0,
                  child: _buildBlurBall(kAccentPurple.withOpacity(0.5)),
                ),
                Positioned(
                  top: _initialCardHeight / 2 - (3 * 16.0),
                  right: -3 * 16.0,
                  child: _buildBlurBall(kAccentSecondary.withOpacity(0.5)),
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
    final double currentBorderRadius = _borderRadius; // Não precisamos de _checkedBorderRadius
    return ClipRRect(
      key: _cardContentKey,
      borderRadius: BorderRadius.circular(currentBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
        child: Container(
          color: Colors.transparent, // Necessário para BackdropFilter
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildEyes(),
              // REMOVIDO: A interface de chat expandido não é mais construída aqui.
              // if (widget.isChecked) _buildChatInterface() else Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEyes() {
    final Offset eyeOffset = _calculateEyeOffset();
    return AnimatedOpacity(
      duration: _transitionDuration,
      opacity: 1.0, // Sempre visível, já que não há mais "isChecked" para ocultar
      child: IgnorePointer(
        ignoring: false, // Não está ignorando
        child: Padding(
          padding: EdgeInsets.only(bottom: _initialCardHeight * 0.1),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Olhos normais (piscando e seguindo)
              AnimatedOpacity(
                duration: _transitionDuration,
                opacity: widget.isHovering ? 0.0 : 1.0,
                child: Transform.translate(
                  offset: eyeOffset,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSingleEye(),
                      const SizedBox(width: 2 * 16.0),
                      _buildSingleEye(),
                    ],
                  ),
                ),
              ),
              // Olhos felizes (quando hover)
              AnimatedOpacity(
                duration: _transitionDuration,
                opacity: widget.isHovering ? 1.0 : 0.0,
                child: SvgPicture.string(
                  happyEyeSvg,
                  width: 6 * 16.0,
                  height: 6 * 16.0,
                  colorFilter: const ColorFilter.mode(
                    kDarkTextPrimary,
                    BlendMode.srcIn,
                  ),
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
      builder: (context, child) {
        return Container(
          width: 2 * 16.0,
          height: _eyeAnimation.value,
          decoration: BoxDecoration(
            color: kDarkTextPrimary,
            borderRadius: BorderRadius.circular(16.0),
          ),
        );
      },
    );
  }

  // REMOVIDO: O método _buildChatInterface não existe mais aqui.
  // REMOVIDO: O método _buildChatMessages não existe mais aqui.
}