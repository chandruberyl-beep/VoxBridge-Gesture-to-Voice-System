import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _blobController;
  late AnimationController _shakeController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _blobAnim;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _slideController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));

    _blobController =
        AnimationController(duration: const Duration(seconds: 4), vsync: this)
          ..repeat(reverse: true);
    _blobAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _blobController, curve: Curves.easeInOut));

    _shakeController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));

    _fadeController.forward();
    _slideController.forward();

    _emailFocus.addListener(() {
      setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _blobController.dispose();
    _shakeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      _triggerShake();
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      pendingWelcome = true;
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _friendlyError(e.code));
      _triggerShake();
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Try again.');
      _triggerShake();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'channel-error':
        return 'Please check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  void _switchMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
    _fadeController.forward(from: 0.7);
    _slideController.forward(from: 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        // ── Animated pastel blobs ──────────────────────────────────────────
        AnimatedBuilder(
          animation: _blobAnim,
          builder: (_, __) => Stack(children: [
            Positioned(
              top: -70 + (_blobAnim.value * 20),
              right: -80,
              child: _LoginBlob(
                  size: 260, color: AppTheme.accentPurple.withOpacity(0.5)),
            ),
            Positioned(
              bottom: -50 + (_blobAnim.value * -16),
              left: -60,
              child: _LoginBlob(
                  size: 220, color: AppTheme.accentMint.withOpacity(0.55)),
            ),
            Positioned(
              top: size.height * 0.38 + (_blobAnim.value * 12),
              right: -30,
              child: _LoginBlob(
                  size: 120, color: AppTheme.accentPink.withOpacity(0.4)),
            ),
            Positioned(
              top: size.height * 0.18 - (_blobAnim.value * 10),
              left: -20,
              child: _LoginBlob(
                  size: 90, color: AppTheme.accentYellow.withOpacity(0.45)),
            ),
            Positioned(
              bottom: size.height * 0.28 + (_blobAnim.value * 8),
              right: size.width * 0.1,
              child: _LoginBlob(
                  size: 55, color: AppTheme.accentBlue.withOpacity(0.4)),
            ),
          ]),
        ),

        // ── Main scrollable content ────────────────────────────────────────
        FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      _shakeAnim.value > 0
                          ? 8 * (0.5 - _shakeAnim.value).abs() * 4
                          : 0,
                      0,
                    ),
                    child: child,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.06),

                      // ── Logo row ───────────────────────────────────────
                      Row(children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: AppTheme.primaryShadow(opacity: 0.28),
                          ),
                          child: const Icon(
                            Icons.spatial_audio_off_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VoxBridge',
                                style: AppTheme.heading(
                                    size: 18, color: AppTheme.primary)),
                            Text('gesture to voice',
                                style: AppTheme.label(
                                    size: 9, color: AppTheme.textLight)),
                          ],
                        ),
                      ]),
                      SizedBox(height: size.height * 0.05),

                      // ── Animated heading ──────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child)),
                        child: Column(
                          key: ValueKey(_isLogin),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLogin
                                  ? 'Welcome\nback! 👋'
                                  : 'Create your\naccount ✨',
                              style: AppTheme.display(
                                size: 34,
                                color: AppTheme.textDark,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isLogin
                                  ? 'Sign in to continue bridging voices with gestures.'
                                  : 'Join VoxBridge and give your hands a voice today.',
                              style: AppTheme.body(
                                  size: 14,
                                  color: AppTheme.textLight,
                                  height: 1.6),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.042),

                      // ── Email field ───────────────────────────────────
                      _FieldLabel(label: 'Email address'),
                      const SizedBox(height: 8),
                      _PremiumInputField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        isFocused: _emailFocused,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: 20),

                      // ── Password field ────────────────────────────────
                      _FieldLabel(label: 'Password'),
                      const SizedBox(height: 8),
                      _PremiumInputField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        isFocused: _passwordFocused,
                        obscure: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        suffix: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              key: ValueKey(_obscurePassword),
                              color: _passwordFocused
                                  ? AppTheme.primary
                                  : AppTheme.textLight,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // ── Animated error message ────────────────────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: _errorMessage != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorLight,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppTheme.error.withOpacity(0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.error.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.error_outline_rounded,
                                          color: AppTheme.error, size: 15),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: AppTheme.body(
                                            size: 13,
                                            color: AppTheme.error,
                                            height: 1.4),
                                      ),
                                    ),
                                  ]),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 32),

                      // ── Premium submit button ─────────────────────────
                      GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? AppTheme.primary.withOpacity(0.7)
                                : AppTheme.primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _isLoading
                                ? []
                                : AppTheme.primaryShadow(opacity: 0.32),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _isLoading
                                  ? const SizedBox(
                                      key: ValueKey('loading'),
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white),
                                    )
                                  : Row(
                                      key: ValueKey('button'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isLogin
                                              ? 'Sign in'
                                              : 'Create account',
                                          style: AppTheme.buttonText(size: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded,
                                            color: Colors.white, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Divider ───────────────────────────────────────
                      Row(children: [
                        Expanded(
                            child: Divider(color: AppTheme.border2, height: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('or',
                              style: AppTheme.body(
                                  size: 12, color: AppTheme.textLight)),
                        ),
                        Expanded(
                            child: Divider(color: AppTheme.border2, height: 1)),
                      ]),
                      const SizedBox(height: 22),

                      // ── Toggle card ───────────────────────────────────
                      GestureDetector(
                        onTap: _switchMode,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 16),
                          decoration: AppTheme.card(shadow: true),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLogin
                                    ? "Don't have an account? "
                                    : 'Already have an account? ',
                                style: AppTheme.body(
                                    size: 14, color: AppTheme.textLight),
                              ),
                              Text(
                                _isLogin ? 'Sign up →' : 'Sign in →',
                                style: AppTheme.body(
                                  size: 14,
                                  color: AppTheme.primary,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Trust badges row ──────────────────────────────
                      Row(children: [
                        Expanded(
                          child: _TrustBadge(
                            icon: Icons.verified_outlined,
                            label: 'Encrypted',
                            color: AppTheme.accentMint,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TrustBadge(
                            icon: Icons.accessibility_new_rounded,
                            label: 'Accessible',
                            color: AppTheme.accentPurple,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TrustBadge(
                            icon: Icons.favorite_border_rounded,
                            label: 'Inclusive',
                            color: AppTheme.accentPink,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Premium Input Field ───────────────────────────────────────────────────────
class _PremiumInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool isFocused;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _PremiumInputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.isFocused,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppTheme.primary : AppTheme.border,
          width: isFocused ? 1.8 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppTheme.softShadow,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscure,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: AppTheme.body(size: 15, color: AppTheme.textDark, height: 1.2),
        cursorColor: AppTheme.primary,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.body(size: 15, color: AppTheme.textFaint),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              icon,
              color: isFocused ? AppTheme.primary : AppTheme.textLight,
              size: 20,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16), child: suffix)
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTheme.body(
          size: 13, color: AppTheme.textMid, weight: FontWeight.w600),
    );
  }
}

// ── Trust Badge ───────────────────────────────────────────────────────────────
class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TrustBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(children: [
        Icon(icon, color: AppTheme.primary, size: 16),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.label(size: 9, color: AppTheme.textMid)),
      ]),
    );
  }
}

// ── Blob Helper ───────────────────────────────────────────────────────────────
class _LoginBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _LoginBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
