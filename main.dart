import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_animation_screen.dart';
import 'providers/voxbridge_provider.dart';

bool pendingWelcome = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFEDF4F0),
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(const VoxBridgeApp());
}

class VoxBridgeApp extends StatelessWidget {
  const VoxBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoxBridgeProvider(),
      child: MaterialApp(
        title: 'VoxBridge',
        debugShowCheckedModeBanner: false,

        // 🔥 Premium Scroll Behavior
        scrollBehavior:
            const MaterialScrollBehavior().copyWith(overscroll: false),

        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          scaffoldBackgroundColor: AppTheme.bg,
          colorScheme: const ColorScheme.light(
            surface: AppTheme.surface,
            primary: AppTheme.primary,
            secondary: AppTheme.primaryLight,
            error: AppTheme.error,
          ),
          textTheme: GoogleFonts.dmSansTextTheme(
            ThemeData.light().textTheme,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppTheme.primary,
            contentTextStyle: AppTheme.body(size: 13, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            behavior: SnackBarBehavior.floating,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
              side: BorderSide(color: AppTheme.border, width: 1),
            ),
            elevation: 0,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),

        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _SplashScreen();
            }

            if (snapshot.hasData) {
              if (pendingWelcome) {
                pendingWelcome = false;
                return const WelcomeAnimationScreen();
              }
              return const HomeScreen();
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🔥 Premium Animated Splash Screen (Enhanced)
// ─────────────────────────────────────────────────────────────

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;
  late AnimationController _blobController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _blobAnim;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack));

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _textController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _taglineController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _taglineController, curve: Curves.easeOut));

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _taglineController, curve: Curves.easeOut));

    _blobController =
        AnimationController(duration: const Duration(seconds: 4), vsync: this)
          ..repeat(reverse: true);

    _blobAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _blobController, curve: Curves.easeInOut));

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) _taglineController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // 🌈 Floating Background Blobs
          AnimatedBuilder(
            animation: _blobAnim,
            builder: (_, __) => Stack(
              children: [
                Positioned(
                  top: -50 + (_blobAnim.value * 16),
                  right: -70,
                  child: _Blob(
                    size: 220,
                    color: AppTheme.accentPurple.withOpacity(0.45),
                  ),
                ),
                Positioned(
                  bottom: -40 + (_blobAnim.value * -12),
                  left: -50,
                  child: _Blob(
                    size: 190,
                    color: AppTheme.accentMint.withOpacity(0.5),
                  ),
                ),
                Positioned(
                  top: size.height * 0.42 + (_blobAnim.value * 10),
                  right: size.width * 0.05,
                  child: _Blob(
                    size: 80,
                    color: AppTheme.accentPink.withOpacity(0.4),
                  ),
                ),
                Positioned(
                  top: size.height * 0.2 - (_blobAnim.value * 8),
                  left: size.width * 0.06,
                  child: _Blob(
                    size: 60,
                    color: AppTheme.accentYellow.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // ✨ Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppTheme.primaryShadow(opacity: 0.4),
                      ),
                      child: const Icon(
                        Icons.spatial_audio_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Text(
                      'VoxBridge',
                      style: AppTheme.heading(
                        size: 32,
                        color: AppTheme.textDark,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _taglineFade,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: AppTheme.pill(
                          color: AppTheme.accentMint.withOpacity(0.6)),
                      child: Text(
                        'Bridging voices, one gesture at a time.',
                        style: AppTheme.body(
                          size: 12,
                          color: AppTheme.primary,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineFade,
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary.withOpacity(0.35),
                      backgroundColor: AppTheme.border,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading...',
                    style: AppTheme.label(size: 10, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
