import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../providers/voxbridge_provider.dart';
import '../widgets/received_text_widget.dart';
import 'gestures_screen.dart';

// ── Daily quotes by differently-abled people ──────────────────────────────────
const List<Map<String, String>> _quotes = [
  {
    'text': 'The only disability in life is a bad attitude.',
    'author': 'Scott Hamilton',
    'note': 'Olympic champion & cancer survivor',
    'emoji': '🏅',
  },
  {
    'text': 'I choose not to place "DIS" in my ability.',
    'author': 'Robert M. Hensel',
    'note': 'World record holder, spina bifida',
    'emoji': '💪',
  },
  {
    'text':
        'Concentrate on things your disability doesn\'t prevent you doing well, and don\'t regret the things it interferes with.',
    'author': 'Stephen Hawking',
    'note': 'Theoretical physicist, ALS',
    'emoji': '🌌',
  },
  {
    'text':
        'We need to make every single thing accessible to every single person with a disability.',
    'author': 'Stevie Wonder',
    'note': 'Legendary musician, blind since birth',
    'emoji': '🎵',
  },
  {
    'text':
        'Although the world is full of suffering, it is full also of the overcoming of it.',
    'author': 'Helen Keller',
    'note': 'Author & activist, deaf-blind',
    'emoji': '✨',
  },
  {
    'text':
        'Optimism is the faith that leads to achievement. Nothing can be done without hope and confidence.',
    'author': 'Helen Keller',
    'note': 'Author & activist, deaf-blind',
    'emoji': '🌟',
  },
  {
    'text':
        'Disability doesn\'t mean inability. It just means you do it differently.',
    'author': 'Nick Vujicic',
    'note': 'Motivational speaker, born without limbs',
    'emoji': '🙌',
  },
  {
    'text':
        'What makes you different makes you beautiful. Own every part of who you are.',
    'author': 'Lizzie Velasquez',
    'note': 'Motivational speaker, Marfan syndrome',
    'emoji': '🌸',
  },
  {
    'text': 'Every day is a new opportunity to reach that goal.',
    'author': 'Christopher Reeve',
    'note': 'Actor & spinal cord injury activist',
    'emoji': '🎯',
  },
  {
    'text':
        'So many of our dreams first seem impossible, then improbable, and then, when we summon the will — inevitable.',
    'author': 'Christopher Reeve',
    'note': 'Actor & spinal cord injury activist',
    'emoji': '🚀',
  },
  {
    'text':
        'There is no greater disability in society than the inability to see a person as more.',
    'author': 'Robert M. Hensel',
    'note': 'Disability rights activist',
    'emoji': '👁️',
  },
  {
    'text': 'We all have ability. The difference is how we use it.',
    'author': 'Stevie Wonder',
    'note': 'Legendary musician, blind since birth',
    'emoji': '🎶',
  },
  {
    'text': 'Life is either a daring adventure or nothing at all.',
    'author': 'Helen Keller',
    'note': 'Author & activist, deaf-blind',
    'emoji': '🌊',
  },
  {
    'text':
        'Disability is a matter of perception. If you can do just one thing well, you\'re needed by someone.',
    'author': 'Martina Navratilova',
    'note': 'Tennis champion',
    'emoji': '🎾',
  },
  {
    'text':
        'I was told I had a disability, but I prefer to call it a different ability.',
    'author': 'Robert M. Hensel',
    'note': 'World record holder, spina bifida',
    'emoji': '⚡',
  },
  {
    'text': 'You are not your disability. You are so much more than that.',
    'author': 'Nick Vujicic',
    'note': 'Motivational speaker, born without limbs',
    'emoji': '💫',
  },
  {
    'text': 'The human spirit is stronger than anything that can happen to it.',
    'author': 'C.C. Scott',
    'note': 'Disability advocate & author',
    'emoji': '🔥',
  },
  {
    'text':
        'My advice to other disabled people would be: concentrate on things your disability doesn\'t prevent you doing well.',
    'author': 'Stephen Hawking',
    'note': 'Theoretical physicist, ALS',
    'emoji': '🧠',
  },
  {
    'text':
        'Don\'t limit yourself. Many people limit themselves to what they think they can do.',
    'author': 'Mary Kay Ash',
    'note': 'Entrepreneur & disability advocate',
    'emoji': '🌈',
  },
  {
    'text':
        'Aerodynamically, the bumblebee shouldn\'t be able to fly. But the bumblebee doesn\'t know it, so it goes on flying.',
    'author': 'Mary Kay Ash',
    'note': 'Entrepreneur & disability advocate',
    'emoji': '🐝',
  },
];

Map<String, String> _getTodaysQuote() {
  final day = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return _quotes[day % _quotes.length];
}

Color _getTodaysAccent() {
  final day = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  return AppTheme.quoteAccents[day % AppTheme.quoteAccents.length];
}

// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _quoteController;
  late AnimationController _blobController;
  late Animation<double> _quoteFade;
  late Animation<Offset> _quoteSlide;
  late Animation<double> _blobAnim;
  final List<Animation<double>> _items = [];

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Hindi', 'code': 'hi'},
    {'name': 'Tamil', 'code': 'ta'},
    {'name': 'Malayalam', 'code': 'ml'},
  ];

  @override
  void initState() {
    super.initState();

    // Stagger for content items
    _staggerController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    for (int i = 0; i < 7; i++) {
      final s = (i * 0.10).clamp(0.0, 1.0);
      final e = (s + 0.5).clamp(0.0, 1.0);
      _items.add(CurvedAnimation(
          parent: _staggerController,
          curve: Interval(s, e, curve: Curves.easeOut)));
    }
    _staggerController.forward();

    // Quote card entrance
    _quoteController = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);
    _quoteFade =
        CurvedAnimation(parent: _quoteController, curve: Curves.easeOut);
    _quoteSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _quoteController, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _quoteController.forward();
    });

    // Subtle background blob animation
    _blobController =
        AnimationController(duration: const Duration(seconds: 6), vsync: this)
          ..repeat(reverse: true);
    _blobAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _blobController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _quoteController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _greetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️';
    if (h < 17) return '👋';
    return '🌙';
  }

  String _firstName() {
    final u = FirebaseAuth.instance.currentUser;
    if (u?.displayName != null && u!.displayName!.isNotEmpty) {
      return u.displayName!.split(' ').first;
    }
    if (u?.email != null) return u!.email!.split('@').first;
    return 'there';
  }

  String _initials() {
    final u = FirebaseAuth.instance.currentUser;
    if (u?.displayName != null && u!.displayName!.isNotEmpty) {
      final p = u.displayName!.split(' ');
      if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
      return u.displayName![0].toUpperCase();
    }
    if (u?.email != null) return u!.email![0].toUpperCase();
    return 'V';
  }

  // ── Bottom Sheets ──────────────────────────────────────────────────────────
  void _showLanguageSheet(BuildContext ctx) {
    final p = Provider.of<VoxBridgeProvider>(ctx, listen: false);
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PremiumSheet(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _SheetHandle(),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: AppTheme.iconContainer(
                    color: AppTheme.accentBlue, radius: 12),
                child: const Icon(Icons.translate_rounded,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text('Output Language', style: AppTheme.heading(size: 17)),
            ]),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text('Choose how VoxBridge speaks your gestures',
                style: AppTheme.body(size: 12, color: AppTheme.textLight)),
          ),
          const SizedBox(height: 16),
          Divider(color: AppTheme.border, height: 1),
          ..._languages.map((lang) {
            final sel = p.selectedLanguageCode == lang['code'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                p.setLanguage(lang['code']!, lang['name']!);
                Navigator.pop(ctx);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                color: sel
                    ? AppTheme.accentMint.withOpacity(0.25)
                    : Colors.transparent,
                child: Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.accentMint : AppTheme.surface2,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: sel
                            ? AppTheme.primary.withOpacity(0.2)
                            : AppTheme.border,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (lang['name'] ?? 'L').substring(0, 1).toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: sel ? AppTheme.primary : AppTheme.textMid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang['name']!,
                            style: AppTheme.body(
                              size: 15,
                              color: sel ? AppTheme.primary : AppTheme.textDark,
                              weight: sel ? FontWeight.w600 : FontWeight.w400,
                            )),
                        if (sel)
                          Text('Currently selected',
                              style: AppTheme.caption(color: AppTheme.primary)),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: sel ? 24 : 0,
                    height: 24,
                    decoration: BoxDecoration(
                        color: sel ? AppTheme.primary : Colors.transparent,
                        shape: BoxShape.circle),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ]),
              ),
            );
          }),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  void _showActivitySheet(BuildContext ctx) {
    final p = Provider.of<VoxBridgeProvider>(ctx, listen: false);
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: p,
        child: _PremiumSheet(
          height: MediaQuery.of(ctx).size.height * 0.62,
          child: Column(children: [
            const _SheetHandle(),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: AppTheme.iconContainer(
                      color: AppTheme.accentPink, radius: 12),
                  child: const Icon(Icons.timeline_rounded,
                      color: AppTheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text('Activity', style: AppTheme.heading(size: 17)),
                const Spacer(),
                Consumer<VoxBridgeProvider>(
                  builder: (_, pr, __) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: AppTheme.pill(
                      color: pr.isConnected
                          ? AppTheme.accentMint
                          : const Color(0xFFFFE0E0),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pr.isConnected
                              ? AppTheme.success
                              : AppTheme.error,
                          boxShadow: [
                            BoxShadow(
                              color: (pr.isConnected
                                      ? AppTheme.success
                                      : AppTheme.error)
                                  .withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        pr.isConnected ? 'live' : 'offline',
                        style: AppTheme.label(
                          size: 10,
                          color: pr.isConnected
                              ? AppTheme.primary
                              : AppTheme.error,
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Divider(color: AppTheme.border, height: 1),
            Expanded(
              child: Consumer<VoxBridgeProvider>(
                builder: (_, pr, __) => pr.activityLog.isEmpty
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppTheme.accentMint.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.timeline_rounded,
                              color: AppTheme.primary, size: 30),
                        ),
                        const SizedBox(height: 16),
                        Text('No activity yet',
                            style: AppTheme.body(
                                size: 15,
                                color: AppTheme.textMid,
                                weight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Spoken phrases will appear here',
                            style: AppTheme.body(
                                size: 13, color: AppTheme.textLight)),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.all(22),
                        itemCount: pr.activityLog.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: AppTheme.border, height: 16),
                        itemBuilder: (_, i) {
                          final log =
                              pr.activityLog[pr.activityLog.length - 1 - i];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 5),
                                decoration:
                                    AppTheme.pill(color: AppTheme.accentBlue),
                                child: Text(log.time,
                                    style: AppTheme.label(
                                        size: 9, color: AppTheme.primary)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(log.message,
                                    style: AppTheme.body(
                                        size: 13, color: AppTheme.textMid)),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext ctx) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _PremiumSheet(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _SheetHandle(),
          const SizedBox(height: 30),
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentPurple,
              border: Border.all(color: AppTheme.border2, width: 2.5),
              boxShadow: AppTheme.softShadow,
            ),
            alignment: Alignment.center,
            child: Text(_initials(),
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(height: 14),
          Text(_firstName(),
              style: AppTheme.heading(size: 20, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
            style: AppTheme.body(size: 13, color: AppTheme.textLight),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration:
                AppTheme.pill(color: AppTheme.accentMint.withOpacity(0.6)),
            child: Text('VoxBridge member',
                style: AppTheme.label(size: 10, color: AppTheme.primary)),
          ),
          const SizedBox(height: 28),
          Divider(color: AppTheme.border, height: 1),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(ctx);
              _showLogoutDialog(ctx);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.errorLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: AppTheme.error, size: 20),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Sign out',
                      style: AppTheme.body(
                          size: 15,
                          color: AppTheme.error,
                          weight: FontWeight.w600)),
                  Text('You\'ll be redirected to login',
                      style: AppTheme.caption(color: AppTheme.textLight)),
                ]),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppTheme.textLight, size: 14),
              ]),
            ),
          ),
          const SizedBox(height: 28),
        ]),
      ),
    );
  }

  void _showLogoutDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: AppTheme.border, width: 1)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.errorLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppTheme.error, size: 24),
              ),
              const SizedBox(height: 18),
              Text('Sign out?', style: AppTheme.heading(size: 20)),
              const SizedBox(height: 8),
              Text(
                "You'll need to sign back in to use VoxBridge. Your gestures and settings will be saved.",
                style: AppTheme.body(
                    size: 13, color: AppTheme.textLight, height: 1.6),
              ),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      alignment: Alignment.center,
                      child: Text('Cancel',
                          style: AppTheme.body(
                              size: 15,
                              color: AppTheme.textMid,
                              weight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.error.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text('Sign out',
                          style: AppTheme.buttonText(size: 15)),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VoxBridgeProvider>(context);
    final quote = _getTodaysQuote();
    final quoteAccent = _getTodaysAccent();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        // ── Subtle background blobs ──────────────────────────────────────
        AnimatedBuilder(
          animation: _blobAnim,
          builder: (_, __) => Stack(children: [
            Positioned(
              top: -80 + (_blobAnim.value * 14),
              right: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentMint.withOpacity(0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -60 + (_blobAnim.value * -10),
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentPurple.withOpacity(0.12),
                ),
              ),
            ),
          ]),
        ),

        SafeArea(
          child: Column(children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: _FadeSlide(
                animation: _items[0],
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('${_greeting()} ',
                            style: AppTheme.body(
                                size: 13, color: AppTheme.textLight)),
                        Text(_greetingEmoji(),
                            style: const TextStyle(fontSize: 13)),
                      ]),
                      Text(_firstName(),
                          style: AppTheme.heading(
                              size: 24, color: AppTheme.textDark)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: AppTheme.card(radius: 13, shadow: false),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: AppTheme.textMid, size: 20),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showProfileSheet(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border2, width: 2),
                        boxShadow: AppTheme.softShadow,
                      ),
                      alignment: Alignment.center,
                      child: Text(_initials(),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ]),
              ),
            ),

            // ── Scrollable body ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Last spoken phrase (MOVED UP) ───────────────────
                    _FadeSlide(
                      animation: _items[1],
                      child: Row(children: [
                        Text('Last spoken phrase',
                            style: AppTheme.body(
                                size: 13,
                                color: AppTheme.textMid,
                                weight: FontWeight.w600)),
                        const Spacer(),
                        Consumer<VoxBridgeProvider>(
                          builder: (_, p, __) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: AppTheme.pill(
                                color: p.isConnected
                                    ? AppTheme.accentMint
                                    : const Color(0xFFFFE0E0)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p.isConnected
                                      ? AppTheme.success
                                      : AppTheme.error,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (p.isConnected
                                              ? AppTheme.success
                                              : AppTheme.error)
                                          .withOpacity(0.5),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.isConnected ? 'live' : 'offline',
                                style: AppTheme.label(
                                    size: 9,
                                    color: p.isConnected
                                        ? AppTheme.primary
                                        : AppTheme.error),
                              ),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    _FadeSlide(
                      animation: _items[1],
                      child: const ReceivedTextWidget(),
                    ),
                    const SizedBox(height: 22),

                    // ── Language selector ──────────────────────────────
                    _FadeSlide(
                      animation: _items[2],
                      child: GestureDetector(
                        onTap: () => _showLanguageSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          decoration: AppTheme.card(),
                          child: Row(children: [
                            // ✅ emoji removed: premium icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.accentMint.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.translate_rounded,
                                color: AppTheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Output language',
                                      style: AppTheme.label(
                                          size: 9, color: AppTheme.textLight)),
                                  const SizedBox(height: 3),
                                  Text(provider.selectedLanguageName,
                                      style: AppTheme.body(
                                          size: 15,
                                          color: AppTheme.textDark,
                                          weight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppTheme.surface2,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.textMid,
                                  size: 18),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Stat chips (Gestures chip REMOVED) ─────────────
                    _FadeSlide(
                      animation: _items[3],
                      child: Row(children: [
                        _StatChip(
                          label: 'Language',
                          value: provider.selectedLanguageName,
                          color: AppTheme.accentPurple,
                          icon: Icons.translate_rounded,
                        ),
                        const SizedBox(width: 10),
                        Consumer<VoxBridgeProvider>(
                          builder: (_, p, __) => _StatChip(
                            label: 'Status',
                            value: p.isConnected ? 'Live' : 'Offline',
                            color: p.isConnected
                                ? AppTheme.accentMint
                                : const Color(0xFFFFE0E0),
                            icon: p.isConnected
                                ? Icons.wifi_rounded
                                : Icons.wifi_off_rounded,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 22),

                    // ── Manage gestures CTA (subtitle removed) ─────────
                    _FadeSlide(
                      animation: _items[4],
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const GesturesScreen(),
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              transitionsBuilder: (_, a, __, c) =>
                                  FadeTransition(
                                      opacity: CurvedAnimation(
                                          parent: a, curve: Curves.easeOut),
                                      child: c),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: AppTheme.primaryCard(radius: 24),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.pan_tool_alt_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Manage Gestures',
                                      style: AppTheme.buttonText(size: 16)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── Daily Quote Card (MOVED DOWN) ───────────────────
                    FadeTransition(
                      opacity: _quoteFade,
                      child: SlideTransition(
                        position: _quoteSlide,
                        child:
                            _QuoteCard(quote: quote, accentColor: quoteAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom nav ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border:
                    Border(top: BorderSide(color: AppTheme.border, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.timeline_rounded,
                    label: 'Activity',
                    color: AppTheme.accentPink,
                    onTap: () => _showActivitySheet(context),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const GesturesScreen(),
                          transitionDuration: const Duration(milliseconds: 500),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: a, curve: Curves.easeOut),
                              child: c),
                        ),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.primaryShadow(opacity: 0.42),
                      ),
                      child: const Icon(Icons.pan_tool_alt_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    color: AppTheme.accentPurple,
                    onTap: () => _showProfileSheet(context),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Premium Quote Card ────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final Map<String, String> quote;
  final Color accentColor;
  const _QuoteCard({required this.quote, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.accentCard(color: accentColor, radius: 24),
      child: Stack(children: [
        Positioned(
          top: -10,
          right: 14,
          child: Text(
            '\u201C',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 120,
              fontWeight: FontWeight.w900,
              color: accentColor.withOpacity(0.35),
              height: 1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(100),
                  border:
                      Border.all(color: accentColor.withOpacity(0.3), width: 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 11, color: AppTheme.primary),
                  const SizedBox(width: 5),
                  Text('Daily Inspiration',
                      style: AppTheme.label(size: 9, color: AppTheme.primary)),
                ]),
              ),
              const SizedBox(height: 16),
              Text(quote['emoji'] ?? '✨', style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 10),
              Text('\u201C${quote['text']!}\u201D',
                  style:
                      AppTheme.quoteText(size: 15, color: AppTheme.textDark)),
              const SizedBox(height: 16),
              Container(height: 1, color: accentColor.withOpacity(0.5)),
              const SizedBox(height: 14),
              Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: accentColor.withOpacity(0.3), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    quote['author']![0],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quote['author']!,
                          style: AppTheme.body(
                              size: 13,
                              color: AppTheme.textDark,
                              weight: FontWeight.w600)),
                      if ((quote['note'] ?? '').isNotEmpty)
                        Text(quote['note']!,
                            style: AppTheme.caption(color: AppTheme.textMid)),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppTheme.primary, size: 17),
          const SizedBox(height: 7),
          Text(label,
              style: AppTheme.label(size: 9, color: AppTheme.textLight)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.body(
                size: 12, color: AppTheme.textDark, weight: FontWeight.w700),
          ),
        ]),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 21),
        ),
        const SizedBox(height: 5),
        Text(label, style: AppTheme.label(size: 9, color: AppTheme.textMid)),
      ]),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _FadeSlide({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}

class _PremiumSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  const _PremiumSheet({required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: child,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Center(
        child: Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.border2,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
