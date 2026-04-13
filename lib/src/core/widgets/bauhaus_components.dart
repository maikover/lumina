import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/color_schemes.dart';

/// Bauhaus Design System Components for Lectra
/// Based on geometric, constructivist design principles

/// Bauhaus Button Variants
enum BauhausButtonVariant {
  primary, // Red background, white text
  secondary, // Blue background, white text
  yellow, // Yellow background, black text
  outline, // White background, black border
  ghost, // Transparent, no border
}

/// Bauhaus Button - Primary component with hard shadows and geometric styling
class BauhausButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final BauhausButtonVariant variant;
  final bool isCircle;
  final bool isSmall;
  final IconData? icon;

  const BauhausButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = BauhausButtonVariant.primary,
    this.isCircle = false,
    this.isSmall = false,
    this.icon,
  });

  @override
  State<BauhausButton> createState() => _BauhausButtonState();
}

class _BauhausButtonState extends State<BauhausButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    switch (widget.variant) {
      case BauhausButtonVariant.primary:
        return BauhausColors.primaryRed;
      case BauhausButtonVariant.secondary:
        return BauhausColors.primaryBlue;
      case BauhausButtonVariant.yellow:
        return BauhausColors.primaryYellow;
      case BauhausButtonVariant.outline:
      case BauhausButtonVariant.ghost:
        return Colors.white;
    }
  }

  Color get _foregroundColor {
    switch (widget.variant) {
      case BauhausButtonVariant.primary:
      case BauhausButtonVariant.secondary:
        return Colors.white;
      case BauhausButtonVariant.yellow:
      case BauhausButtonVariant.outline:
      case BauhausButtonVariant.ghost:
        return BauhausColors.foreground;
    }
  }

  BoxBorder? get _border {
    if (widget.variant == BauhausButtonVariant.ghost) {
      return BorderSide.none;
    }
    return const Border(
      color: BauhausColors.border,
      width: 3,
    );
  }

  BoxShadow get _shadow {
    if (widget.variant == BauhausButtonVariant.ghost) {
      return const BoxShadow(
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 0,
        color: Colors.transparent,
      );
    }
    if (_isPressed) {
      return const BoxShadow(
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 0,
        color: Colors.transparent,
      );
    }
    return const BoxShadow(
      offset: Offset(4, 4),
      blurRadius: 0,
      spreadRadius: 0,
      color: BauhausColors.border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 4.0 : 0.0,
          _isPressed ? 4.0 : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          color: isDisabled ? BauhausColors.muted : _backgroundColor,
          border: widget.isCircle ? null : _border,
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          boxShadow: isDisabled ? [] : [_shadow],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSmall ? 12 : 20,
          vertical: widget.isSmall ? 8 : 16,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: isDisabled
                    ? BauhausColors.foreground.withValues(alpha: 0.5)
                    : _foregroundColor,
                size: widget.isSmall ? 16 : 20,
              ),
              if (widget.label.isNotEmpty)
                SizedBox(width: widget.isSmall ? 6 : 8),
            ],
            if (widget.label.isNotEmpty)
              Text(
                widget.label.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: widget.isSmall ? 12 : 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: isDisabled
                      ? BauhausColors.foreground.withValues(alpha: 0.5)
                      : _foregroundColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bauhaus Card - Card component with geometric accent
class BauhausCard extends StatefulWidget {
  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool isSelected;

  const BauhausCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<BauhausCard> createState() => _BauhausCardState();
}

class _BauhausCardState extends State<BauhausCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -4.0 : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: widget.isSelected
                ? BauhausColors.primaryBlue
                : BauhausColors.border,
            width: widget.isSelected ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              offset: Offset(_isHovered ? 6 : 4, _isHovered ? 6 : 4),
              blurRadius: 0,
              spreadRadius: 0,
              color: widget.isSelected
                  ? BauhausColors.primaryBlue
                  : BauhausColors.border,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
            // Geometric accent in top-right corner
            if (widget.accentColor != null)
              Positioned(
                top: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(24, 24),
                  painter: _GeometricAccentPainter(widget.accentColor!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GeometricAccentPainter extends CustomPainter {
  final Color color;

  _GeometricAccentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a triangle in the corner
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bauhaus Text Field - Square input with thick borders
class BauhausTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const BauhausTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.onEditingComplete,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: BauhausColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: BauhausColors.border,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: BauhausColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: BauhausColors.muted,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bauhaus App Bar - Minimal AppBar with thick bottom border
class BauhausAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? leading;

  const BauhausAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      decoration: const BoxDecoration(
        color: BauhausColors.background,
        border: Border(
          bottom: BorderSide(
            color: BauhausColors.border,
            width: 4,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (leading != null)
                leading!
              else if (showBackButton)
                IconButton(
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: BauhausColors.foreground,
                    ),
                  ),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: BauhausColors.foreground,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Bauhaus FAB - Circular FAB with hard shadow
class BauhausFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const BauhausFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = BauhausColors.primaryRed,
    this.iconColor = Colors.white,
  });

  @override
  State<BauhausFAB> createState() => _BauhausFABState();
}

class _BauhausFABState extends State<BauhausFAB> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 4.0 : 0.0,
          _isPressed ? 4.0 : 0.0,
          0.0,
        ),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: BauhausColors.border,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              offset: _isPressed
                  ? const Offset(0, 0)
                  : const Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 0,
              color: BauhausColors.border,
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor,
          size: 24,
        ),
      ),
    );
  }
}

// ============================================================
// GEOMETRIC SHAPES
// ============================================================

/// Bauhaus Circle - Simple geometric circle
class BauhausCircle extends StatelessWidget {
  final Color color;
  final double size;
  final bool hasBorder;

  const BauhausCircle({
    super.key,
    required this.color,
    this.size = 24,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(
                color: BauhausColors.border,
                width: 2,
              )
            : null,
      ),
    );
  }
}

/// Bauhaus Square - Simple geometric square (optionally rotated 45°)
class BauhausSquare extends StatelessWidget {
  final Color color;
  final double size;
  final bool rotated;
  final bool hasBorder;

  const BauhausSquare({
    super.key,
    required this.color,
    this.size = 24,
    this.rotated = false,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotated ? 3.14159 / 4 : 0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          border: hasBorder
              ? Border.all(
                  color: BauhausColors.border,
                  width: 2,
                )
              : null,
        ),
      ),
    );
  }
}

/// Bauhaus Triangle - Equilateral triangle pointing up
class BauhausTriangle extends StatelessWidget {
  final Color color;
  final double size;
  final bool hasBorder;

  const BauhausTriangle({
    super.key,
    required this.color,
    this.size = 24,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrianglePainter(
        color: color,
        hasBorder: hasBorder,
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool hasBorder;

  _TrianglePainter({
    required this.color,
    required this.hasBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    if (hasBorder) {
      final borderPaint = Paint()
        ..color = BauhausColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bauhaus Progress Bar - Square ends, yellow accent
class BauhausProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color activeColor;
  final Color inactiveColor;

  const BauhausProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.activeColor = BauhausColors.primaryYellow,
    this.inactiveColor = BauhausColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: inactiveColor,
        border: Border.all(
          color: BauhausColors.border,
          width: 1,
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          color: activeColor,
        ),
      ),
    );
  }
}

/// Bauhaus Icon Button - Square icon button with geometric container
class BauhausIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final bool isCircle;

  const BauhausIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.iconColor = BauhausColors.foreground,
    this.size = 40,
    this.isCircle = false,
  });

  @override
  State<BauhausIconButton> createState() => _BauhausIconButtonState();
}

class _BauhausIconButtonState extends State<BauhausIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0.0,
        ),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          border: Border.all(
            color: BauhausColors.border,
            width: 2,
          ),
          boxShadow: widget.onPressed == null
              ? []
              : [
                  BoxShadow(
                    offset: _isPressed
                        ? Offset.zero
                        : const Offset(2, 2),
                    blurRadius: 0,
                    spreadRadius: 0,
                    color: BauhausColors.border,
                  ),
                ],
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}
