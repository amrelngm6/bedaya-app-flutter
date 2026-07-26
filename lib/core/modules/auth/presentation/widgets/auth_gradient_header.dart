import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/styles.dart';

/// Teal gradient hero header with a wave-cut bottom edge, used on every
/// auth screen.  Renders the hospital icon, page [title] and optional
/// [subtitle].  The back button is shown when the route can be popped.
class AuthGradientHeader extends StatelessWidget {
  const AuthGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.iconData = Icons.local_hospital_rounded,
  });

  final String title;
  final String? subtitle;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        // The extra bottom padding (≈40 px) is eaten by the wave clip.
        height: 235,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryTeal, AppColors.darkTeal],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Back button ──────────────────────────────────────────────
                if (canPop)
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 10),

                const Spacer(),

                Row(
                  children: [
                    // ── Icon badge ───────────────────────────────────────────────
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(iconData, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),

                    // ── Title ────────────────────────────────────────────────────
                    Text(
                      title,
                      style: AppStyles.whiteTitle.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),

                // ── Subtitle ─────────────────────────────────────────────────
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle!,
                    style: AppStyles.whiteBody.copyWith(
                      fontSize: 13,
                      height: 1.45,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Wave clip ────────────────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 42)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height + 4,
        size.width * 0.5,
        size.height - 18,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height - 42,
        size.width,
        size.height - 8,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
