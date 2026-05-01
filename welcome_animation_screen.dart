import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'home_screen.dart';

class WelcomeAnimationScreen extends StatefulWidget {
  const WelcomeAnimationScreen({super.key});

  @override
  State<WelcomeAnimationScreen> createState() => _WelcomeAnimationScreenState();
}

class _WelcomeAnimationScreenState extends State<WelcomeAnimationScreen>
    with TickerProviderStateMixin {
  // ── Typewriter ─────────────────────────────────────────────────────────────
  String _displayedText = '';
  final String _fullText = 'Welcome to VoxBridge';
  int _charIndex = 0;
  Timer? _typeTimer;

  bool _showBadge = false;
  bool _showSubtitle = false;
  bool _showDots = false;

  // ── Controllers ────────────────────────────────────────────────────────────
  late AnimationController _cardController;
  late AnimationController _badgeController;
  late AnimationController _subtitleController;
  late AnimationController _blobController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;

  // ── Animations ─────────────────────────────────────────────────────────────
  late Animation<double> _cardScale;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _badgeFade;
  late Animation<Offset> _badgeSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _blobAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _dotsFade;

  @override
  void initState() {
    super.initState();

    // Card entrance
    _cardController = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    _cardScale = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack));
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _cardController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _cardController, curve: Curves.easeOutCubic));

    // Success badge
    _badgeController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _badgeController, curve: Curves.easeOut));
    _badgeSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _badgeController, curve: Curves.easeOutBack));

    // Subtitle
    _subtitleController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut));
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _subtitleController, curve: Curves.easeOut));

    // Blobs
    _blobController =
        AnimationController(duration: const Duration(seconds: 4), vsync: this)
          ..repeat(reverse: true);
    _blobAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _blobController, curve: Curves.easeInOut));

    // Logo pulse
    _pulseController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this)
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Dots
    _dotsController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _dotsController, curve: Curves.easeOut));

    _startSequence();
  }

  void _startSequence() async {
    // Card flies in
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _cardController.forward();
    HapticFeedback.lightImpact();

    // Badge drops in
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _showBadge = true);
    _badgeController.forward();

    // Dots appear briefly
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _showDots = true);
    _dotsController.forward();

    // Typewriter starts
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _dotsController.reverse();
    setState(() => _showDots = false);
    _startTypewriter();
  }

  void _startTypewriter() {
    _typeTimer = Timer.periodic(const Duration(milliseconds: 58), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex < _fullText.length) {
        setState(() {
          _displayedText = _fullText.substring(0, _charIndex + 1);
          _charIndex++;
        });
        // Subtle haptic on each character
        if (_charIndex % 4 == 0) HapticFeedback.selectionClick();
      } else {
        timer.cancel();
        // Show subtitle
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          setState(() => _showSubtitle = true);
          _subtitleController.forward();
        });
        // Navigate to home
        Future.delayed(const Duration(milliseconds: 2600), () {
          if (!mounted) return;
          HapticFeedback.mediumImpact();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 800),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                child: child,
              ),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cardController.dispose();
    _badgeController.dispose();
    _subtitleController.dispose();
    _blobController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        // ── Animated pastel blobs ──────────────────────────────────────────
        AnimatedBuilder(
          animation: _blobAnim,
          builder: (_, __) => Stack(children: [
            Positioned(
              top: -65 + (_blobAnim.value * 24),
              right: -80,
              child: _WBlob(
                  size: 280, color: AppTheme.accentPink.withOpacity(0.5)),
            ),
            Positioned(
              bottom: 20 - (_blobAnim.value * 20),
              left: -70,
              child: _WBlob(
                  size: 240, color: AppTheme.accentPurple.withOpacity(0.45)),
            ),
            Positioned(
              top: size.height * 0.36 + (_blobAnim.value * 14),
              right: -35,
              child: _WBlob(
                  size: 160, color: AppTheme.accentMint.withOpacity(0.5)),
            ),
            Positioned(
              top: size.height * 0.15 - (_blobAnim.value * 10),
              left: size.width * 0.04,
              child: _WBlob(
                  size: 80, color: AppTheme.accentYellow.withOpacity(0.5)),
            ),
            Positioned(
              bottom: size.height * 0.22 + (_blobAnim.value * 8),
              right: size.width * 0.12,
              child: _WBlob(
                  size: 55, color: AppTheme.accentBlue.withOpacity(0.45)),
            ),
            Positioned(
              top: size.height * 0.55 - (_blobAnim.value * 6),
              left: size.width * 0.15,
              child: _WBlob(
                  size: 40, color: AppTheme.accentPeach.withOpacity(0.5)),
            ),
          ]),
        ),

        // ── Main card ──────────────────────────────────────────────────────
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: ScaleTransition(
                  scale: _cardScale,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(30, 32, 30, 36),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppTheme.border, width: 1),
                      boxShadow: AppTheme.strongShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Pulsing logo ─────────────────────────────────
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.primaryShadow(opacity: 0.38),
                            ),
                            child: const Icon(
                              Icons.spatial_audio_off_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),

                        // ── Success badge ────────────────────────────────
                        if (_showBadge)
                          FadeTransition(
                            opacity: _badgeFade,
                            child: SlideTransition(
                              position: _badgeSlide,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentMint,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: AppTheme.success.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.success.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.success,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.success
                                                .withOpacity(0.6),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'signed in successfully',
                                      style: AppTheme.label(
                                          size: 11, color: AppTheme.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 34),

                        const SizedBox(height: 22),

                        // ── Loading dots (before typewriter) ────────────
                        if (_showDots)
                          FadeTransition(
                            opacity: _dotsFade,
                            child: const _TypingDots(),
                          ),

                        // ── Typewriter text ──────────────────────────────
                        if (!_showDots)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  _displayedText,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.textDark,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (_charIndex < _fullText.length)
                                const _BlinkingCursor(),
                            ],
                          ),
                        const SizedBox(height: 14),

                        // ── Subtitle ─────────────────────────────────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          child: _showSubtitle
                              ? FadeTransition(
                                  opacity: _subtitleFade,
                                  child: SlideTransition(
                                    position: _subtitleSlide,
                                    child: Column(children: [
                                      Text(
                                        'your voice, bridged. 🌉',
                                        textAlign: TextAlign.center,
                                        style: AppTheme.body(
                                            size: 14,
                                            color: AppTheme.textLight,
                                            height: 1.5),
                                      ),
                                      const SizedBox(height: 20),
                                      // Feature pills row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _FeaturePill(
                                            icon: Icons.pan_tool_alt_rounded,
                                            label: 'Gesture',
                                            color: AppTheme.accentMint,
                                          ),
                                          const SizedBox(width: 8),
                                          _FeaturePill(
                                            icon: Icons.translate_rounded,
                                            label: 'Translate',
                                            color: AppTheme.accentPurple,
                                          ),
                                          const SizedBox(width: 8),
                                          _FeaturePill(
                                            icon: Icons.spatial_audio_rounded,
                                            label: 'Speak',
                                            color: AppTheme.accentPink,
                                          ),
                                        ],
                                      ),
                                    ]),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Bottom brand strip ─────────────────────────────────────────────
        Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: FadeTransition(
            opacity: _badgeFade,
            child: Column(children: [
              Text(
                'VoxBridge',
                style: AppTheme.label(size: 11, color: AppTheme.textFaint),
              ),
              const SizedBox(height: 4),
              Text(
                'Powered by gesture intelligence',
                style: AppTheme.caption(color: AppTheme.textFaint),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Typing dots widget ────────────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
          duration: const Duration(milliseconds: 500), vsync: this)
        ..repeat(reverse: true),
    );
    _anims = List.generate(
      3,
      (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut)),
    );
    // Stagger
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) _controllers[1].forward();
    });
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) _controllers[2].forward();
    });
    _controllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8 + (_anims[i].value * 6),
            decoration: BoxDecoration(
              color:
                  AppTheme.primary.withOpacity(0.3 + (_anims[i].value * 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

// ── Blinking cursor ───────────────────────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          '|',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}

// ── Feature pill ──────────────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppTheme.primary, size: 13),
        const SizedBox(width: 5),
        Text(label, style: AppTheme.label(size: 9, color: AppTheme.primary)),
      ]),
    );
  }
}

// ── Blob helper ───────────────────────────────────────────────────────────────
class _WBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _WBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
