import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../providers/voxbridge_provider.dart';

class ReceivedTextWidget extends StatefulWidget {
  const ReceivedTextWidget({super.key});

  @override
  State<ReceivedTextWidget> createState() => _ReceivedTextWidgetState();
}

class _ReceivedTextWidgetState extends State<ReceivedTextWidget>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _pulseController;
  late AnimationController _textController;
  late AnimationController _badgeController;
  late AnimationController _glowController;
  late AnimationController _emptyController;

  late Animation<double> _pulseAnim;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _badgeFade;
  late Animation<Offset> _badgeSlide;
  late Animation<double> _glowAnim;
  late Animation<double> _emptyFade;

  String _lastText = '';
  bool _justUpdated = false;

  @override
  void initState() {
    super.initState();

    // Dot pulse for live indicator
    _pulseController = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this)
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Text entrance
    _textController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textController, curve: Curves.easeOutCubic));

    // Badge drop
    _badgeController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _badgeController, curve: Curves.easeOut));
    _badgeSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _badgeController, curve: Curves.easeOutBack));

    // Card glow on new text
    _glowController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeOut));

    // Empty state fade in
    _emptyController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _emptyFade =
        CurvedAnimation(parent: _emptyController, curve: Curves.easeOut);
    _emptyController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _badgeController.dispose();
    _glowController.dispose();
    _emptyController.dispose();
    super.dispose();
  }

  void _onNewText(String text) {
    if (text == _lastText) return;
    _lastText = text;
    _justUpdated = true;

    // Haptic + animations on new phrase
    HapticFeedback.mediumImpact();
    _textController.forward(from: 0);
    _badgeController.forward(from: 0);
    _glowController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _glowController.reverse();
          setState(() => _justUpdated = false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoxBridgeProvider>(
      builder: (_, provider, __) {
        final text = provider.receivedText;
        final translation = provider.translatedText;
        final isConnected = provider.isConnected;

        // Trigger animations when text changes
        if (text != _lastText && text.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _onNewText(text);
          });
        }

        return AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, child) => Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: text.isNotEmpty
                    ? Color.lerp(AppTheme.border,
                        AppTheme.primary.withOpacity(0.4), _glowAnim.value)!
                    : AppTheme.border,
                width: text.isNotEmpty ? 1.0 + (_glowAnim.value * 0.8) : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: text.isNotEmpty
                      ? AppTheme.primary
                          .withOpacity(0.06 + (_glowAnim.value * 0.1))
                      : AppTheme.primary.withOpacity(0.06),
                  blurRadius: 20 + (_glowAnim.value * 16),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
          child: text.isEmpty
              ? _EmptyState(
                  fadeAnim: _emptyFade,
                  isConnected: isConnected,
                  pulseAnim: _pulseAnim,
                )
              : _ActiveState(
                  text: text,
                  translation: translation,
                  textFade: _textFade,
                  textSlide: _textSlide,
                  badgeFade: _badgeFade,
                  badgeSlide: _badgeSlide,
                  pulseAnim: _pulseAnim,
                  justUpdated: _justUpdated,
                  isConnected: isConnected,
                ),
        );
      },
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<double> pulseAnim;
  final bool isConnected;

  const _EmptyState({
    required this.fadeAnim,
    required this.pulseAnim,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            // Animated icon container
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: isConnected ? pulseAnim.value : 1.0,
                child: child,
              ),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppTheme.accentMint.withOpacity(0.5)
                      : AppTheme.surface2,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isConnected
                        ? AppTheme.primary.withOpacity(0.2)
                        : AppTheme.border,
                    width: 1.5,
                  ),
                  boxShadow: isConnected
                      ? [
                          BoxShadow(
                            color: AppTheme.success.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isConnected
                      ? Icons.spatial_audio_rounded
                      : Icons.spatial_audio_off_rounded,
                  color: isConnected ? AppTheme.primary : AppTheme.textLight,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status text
            Text(
              isConnected
                  ? 'Listening for gestures…'
                  : 'Waiting for connection…',
              style: AppTheme.body(
                  size: 14,
                  color: isConnected ? AppTheme.textMid : AppTheme.textLight,
                  weight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              isConnected
                  ? 'Show a gesture and it will appear here'
                  : 'Make sure the Python script is running',
              textAlign: TextAlign.center,
              style: AppTheme.body(
                  size: 12, color: AppTheme.textLight, height: 1.5),
            ),
            const SizedBox(height: 18),

            // Connection status pill
            AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, child) => Opacity(
                opacity: isConnected ? 0.6 + (pulseAnim.value * 0.4) : 1.0,
                child: child,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: AppTheme.pill(
                  color: isConnected
                      ? AppTheme.accentMint
                      : const Color(0xFFFFE0E0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isConnected ? AppTheme.success : AppTheme.error,
                        boxShadow: [
                          BoxShadow(
                            color: (isConnected
                                    ? AppTheme.success
                                    : AppTheme.error)
                                .withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected
                          ? 'Python detector connected'
                          : 'Python detector offline',
                      style: AppTheme.label(
                        size: 10,
                        color: isConnected ? AppTheme.primary : AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active State ──────────────────────────────────────────────────────────────
class _ActiveState extends StatelessWidget {
  final String text;
  final String translation;
  final Animation<double> textFade;
  final Animation<Offset> textSlide;
  final Animation<double> badgeFade;
  final Animation<Offset> badgeSlide;
  final Animation<double> pulseAnim;
  final bool justUpdated;
  final bool isConnected;

  const _ActiveState({
    required this.text,
    required this.translation,
    required this.textFade,
    required this.textSlide,
    required this.badgeFade,
    required this.badgeSlide,
    required this.pulseAnim,
    required this.justUpdated,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: badge + copy button ─────────────────────────────
          Row(children: [
            FadeTransition(
              opacity: badgeFade,
              child: SlideTransition(
                position: badgeSlide,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.accentMint,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: AppTheme.success.withOpacity(0.3), width: 1),
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
                      AnimatedBuilder(
                        animation: pulseAnim,
                        builder: (_, child) => Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.success,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.success
                                    .withOpacity(pulseAnim.value * 0.6),
                                blurRadius: 6,
                                spreadRadius: pulseAnim.value * 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Gesture detected',
                          style: AppTheme.label(
                              size: 10, color: AppTheme.primary)),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),

            // Copy button
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                // Copy to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(children: [
                      const Icon(Icons.copy_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 8),
                      Text('Phrase copied!',
                          style: AppTheme.body(size: 13, color: Colors.white)),
                    ]),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(Icons.copy_rounded,
                    color: AppTheme.textLight, size: 15),
              ),
            ),
          ]),
          const SizedBox(height: 18),

          // ── Main phrase ───────────────────────────────────────────────
          FadeTransition(
            opacity: textFade,
            child: SlideTransition(
              position: textSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text('SPOKEN',
                      style:
                          AppTheme.label(size: 9, color: AppTheme.textLight)),
                  const SizedBox(height: 8),

                  // Phrase in quotes
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surface2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border2, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u201C',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary.withOpacity(0.3),
                            height: 0.9,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            text,
                            style: AppTheme.heading(
                              size: 20,
                              color: AppTheme.textDark,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Translation ───────────────────────────────────────────────
          if (translation.isNotEmpty && translation != text) ...[
            const SizedBox(height: 14),
            FadeTransition(
              opacity: textFade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRANSLATED',
                      style:
                          AppTheme.label(size: 9, color: AppTheme.textLight)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppTheme.accentPurple, width: 1),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.translate_rounded,
                            color: AppTheme.primary, size: 14),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          translation,
                          style: AppTheme.body(
                              size: 15,
                              color: AppTheme.textDark,
                              weight: FontWeight.w500),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],

          // ── Bottom: time stamp + speak again ─────────────────────────
          const SizedBox(height: 16),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration:
                  AppTheme.pill(color: AppTheme.accentYellow.withOpacity(0.6)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: AppTheme.primary, size: 11),
                  const SizedBox(width: 5),
                  Text(
                    _timeNow(),
                    style: AppTheme.label(size: 9, color: AppTheme.primary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.replay_rounded,
                      color: AppTheme.primary, size: 13),
                  const SizedBox(width: 5),
                  Text('Speak again',
                      style: AppTheme.label(size: 9, color: AppTheme.primary)),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
