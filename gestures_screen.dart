import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../providers/voxbridge_provider.dart';

class GesturesScreen extends StatefulWidget {
  const GesturesScreen({super.key});

  @override
  State<GesturesScreen> createState() => _GesturesScreenState();
}

class _GesturesScreenState extends State<GesturesScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  final List<Animation<double>> _cardAnims = [];

  // Gesture metadata
  final List<Map<String, dynamic>> _gestureMeta = [
    {'icon': '👋', 'label': 'Open Hand', 'hint': 'e.g. Hello / Greet'},
    {'icon': '✌️', 'label': 'Peace Sign', 'hint': 'e.g. Thank you'},
    {'icon': '👍', 'label': 'Thumbs Up', 'hint': 'e.g. Yes / Good'},
    {'icon': '👊', 'label': 'Fist', 'hint': 'e.g. Stop / No'},
    {'icon': '🤙', 'label': 'Call Me', 'hint': 'e.g. Call someone'},
    {'icon': '☝️', 'label': 'Index Point', 'hint': 'e.g. I need help'},
    {'icon': '🖐️', 'label': 'Five Fingers', 'hint': 'e.g. Wait / Pause'},
    {'icon': '🤞', 'label': 'Crossed', 'hint': 'e.g. Please / Request'},
  ];

  @override
  void initState() {
    super.initState();

    // Header entrance
    _headerController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _headerFade =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    // Cards stagger
    _staggerController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    for (int i = 0; i < 8; i++) {
      final s = (i * 0.08).clamp(0.0, 1.0);
      final e = (s + 0.45).clamp(0.0, 1.0);
      _cardAnims.add(CurvedAnimation(
          parent: _staggerController,
          curve: Interval(s, e, curve: Curves.easeOut)));
    }

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _openEditSheet(
      BuildContext ctx, int index, String currentName, String currentPhrase) {
    HapticFeedback.lightImpact();
    final nameCtrl = TextEditingController(text: currentName);
    final phraseCtrl = TextEditingController(text: currentPhrase);
    bool isSaving = false;
    final meta = _gestureMeta[index];

    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Handle ───────────────────────────────────────────
                const _SheetHandle(),
                const SizedBox(height: 24),

                // ── Header ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.gestureAccents[index].withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.gestureAccents[index], width: 1.5),
                      ),
                      child: Center(
                        child: Text(meta['icon'],
                            style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Gesture ${index + 1}',
                              style: AppTheme.heading(size: 18)),
                          Text(meta['label'],
                              style: AppTheme.body(
                                  size: 13, color: AppTheme.textLight)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetCtx),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.surface2,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppTheme.textLight, size: 16),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 26),
                Divider(color: AppTheme.border, height: 1),
                const SizedBox(height: 24),

                // ── Gesture name field ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.gestureAccents[index],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Gesture Name',
                            style: AppTheme.body(
                                size: 13,
                                color: AppTheme.textMid,
                                weight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppTheme.border, width: 1.5),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: TextField(
                          controller: nameCtrl,
                          style:
                              AppTheme.body(size: 15, color: AppTheme.textDark),
                          cursorColor: AppTheme.primary,
                          decoration: InputDecoration(
                            hintText: 'e.g. ${meta['label']}',
                            hintStyle: AppTheme.body(
                                size: 15, color: AppTheme.textFaint),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(meta['icon'],
                                  style: const TextStyle(fontSize: 18)),
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 0, minHeight: 0),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Spoken phrase field ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Spoken Phrase',
                            style: AppTheme.body(
                                size: 13,
                                color: AppTheme.textMid,
                                weight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: AppTheme.pill(
                              color: AppTheme.accentMint.withOpacity(0.5)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.spatial_audio_rounded,
                                color: AppTheme.primary, size: 11),
                            const SizedBox(width: 4),
                            Text('will be spoken aloud',
                                style: AppTheme.label(
                                    size: 9, color: AppTheme.primary)),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppTheme.border, width: 1.5),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: TextField(
                          controller: phraseCtrl,
                          style:
                              AppTheme.body(size: 15, color: AppTheme.textDark),
                          cursorColor: AppTheme.primary,
                          maxLines: 3,
                          minLines: 2,
                          decoration: InputDecoration(
                            hintText: meta['hint'],
                            hintStyle: AppTheme.body(
                                size: 15, color: AppTheme.textFaint),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                              child: Icon(Icons.record_voice_over_rounded,
                                  color: AppTheme.textLight, size: 18),
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(minWidth: 0, minHeight: 0),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 16, 16, 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Save button ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: isSaving
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            setSheetState(() => isSaving = true);
                            final provider = Provider.of<VoxBridgeProvider>(ctx,
                                listen: false);
                            await provider.updateGesture(
                              index + 1,
                              phraseCtrl.text.trim(),
                              nameCtrl.text.trim(),
                            );
                            if (mounted) {
                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Row(children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 10),
                                  Text('Gesture ${index + 1} saved!',
                                      style: AppTheme.body(
                                          size: 13, color: Colors.white)),
                                ]),
                                backgroundColor: AppTheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 2),
                              ));
                            }
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSaving
                            ? AppTheme.primary.withOpacity(0.6)
                            : AppTheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSaving
                            ? []
                            : AppTheme.primaryShadow(opacity: 0.3),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: isSaving
                            ? Row(
                                key: const ValueKey('saving'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Saving...',
                                      style: AppTheme.buttonText(size: 15)),
                                ],
                              )
                            : Row(
                                key: const ValueKey('save'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save_rounded,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Save Changes',
                                      style: AppTheme.buttonText(size: 15)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VoxBridgeProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(children: [
          // ── Header ───────────────────────────────────────────────────
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: AppTheme.card(radius: 13, shadow: false),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textMid, size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gestures',
                              style: AppTheme.heading(
                                  size: 22, color: AppTheme.textDark)),
                          Text('Tap any card to edit its phrase',
                              style: AppTheme.body(
                                  size: 12, color: AppTheme.textLight)),
                        ],
                      ),
                    ),
                    // Gesture count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: AppTheme.pill(color: AppTheme.accentMint),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.pan_tool_alt_rounded,
                            color: AppTheme.primary, size: 13),
                        const SizedBox(width: 6),
                        Text('8 gestures',
                            style: AppTheme.label(
                                size: 10, color: AppTheme.primary)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Info banner ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.accentBlue, width: 1),
                    ),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.info_outline_rounded,
                            color: AppTheme.primary, size: 14),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Changes sync instantly to the Python detector via Firestore.',
                          style: AppTheme.body(
                              size: 12, color: AppTheme.textMid, height: 1.4),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppTheme.border, height: 1),
                ]),
              ),
            ),
          ),

          // ── Gesture grid ─────────────────────────────────────────────
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.88,
              ),
              itemCount: 8,
              itemBuilder: (ctx, i) {
                final gestureName = provider.getGestureName(i + 1);
                final gesturePhrase = provider.getGesturePhrase(i + 1);
                final accent = AppTheme.gestureAccents[i];
                final meta = _gestureMeta[i];

                return AnimatedBuilder(
                  animation: _cardAnims[i],
                  builder: (_, child) => Opacity(
                    opacity: _cardAnims[i].value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - _cardAnims[i].value)),
                      child: child,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        _openEditSheet(ctx, i, gestureName, gesturePhrase),
                    child: Container(
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: accent, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(children: [
                        // ── Gesture number watermark ───────────────
                        Positioned(
                          top: -8,
                          right: 10,
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: accent.withOpacity(0.3),
                              height: 1,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Emoji + edit button row ────────────
                              Row(children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: accent.withOpacity(0.4),
                                        width: 1),
                                  ),
                                  child: Center(
                                    child: Text(meta['icon'],
                                        style: const TextStyle(fontSize: 24)),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: accent.withOpacity(0.3),
                                        width: 1),
                                  ),
                                  child: Icon(Icons.edit_rounded,
                                      color: AppTheme.primary, size: 14),
                                ),
                              ]),
                              const SizedBox(height: 14),

                              // ── Gesture number pill ────────────────
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'Gesture ${i + 1}',
                                  style: AppTheme.label(
                                      size: 8, color: AppTheme.primary),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // ── Gesture name ───────────────────────
                              Text(
                                gestureName.isEmpty
                                    ? meta['label']
                                    : gestureName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.body(
                                  size: 14,
                                  color: AppTheme.textDark,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // ── Phrase preview ─────────────────────
                              Text(
                                gesturePhrase.isEmpty
                                    ? meta['hint']
                                    : gesturePhrase,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.body(
                                  size: 11,
                                  color: gesturePhrase.isEmpty
                                      ? AppTheme.textFaint
                                      : AppTheme.textMid,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Sheet Handle ──────────────────────────────────────────────────────────────
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
