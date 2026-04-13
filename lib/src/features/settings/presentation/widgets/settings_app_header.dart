import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/src/core/theme/color_schemes.dart';

/// App header with Bauhaus geometric styling
class SettingsAppHeader extends StatelessWidget {
  const SettingsAppHeader({super.key, required this.version});

  final String version;

  static const _appSvgPath = 'assets/icons/icon.svg';
  static const _logoSvgPath = 'assets/logos/logo.svg';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Geometric frame with app icon
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: BauhausColors.border,
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                offset: Offset(6, 6),
                blurRadius: 0,
                color: BauhausColors.border,
              ),
            ],
          ),
          child: Stack(
            children: [
              // App icon
              Positioned.fill(
                child: SvgPicture.asset(
                  _appSvgPath,
                  width: 56,
                  height: 56,
                  colorFilter: ColorFilter.mode(
                    BauhausColors.foreground,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              // Geometric accent - top right corner
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  color: BauhausColors.primaryRed,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  color: BauhausColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Geometric logo bar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 32,
              color: BauhausColors.primaryRed,
            ),
            Container(
              width: 24,
              height: 32,
              color: BauhausColors.primaryYellow,
            ),
            Container(
              width: 24,
              height: 32,
              color: BauhausColors.primaryBlue,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // App name
        Text(
          'LECTRA',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 4.0,
            color: BauhausColors.foreground,
          ),
        ),

        const SizedBox(height: 8),

        // Version
        if (version.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: BauhausColors.border,
                width: 2,
              ),
            ),
            child: Text(
              'V$version',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: BauhausColors.foreground,
              ),
            ),
          ),
      ],
    );
  }
}
