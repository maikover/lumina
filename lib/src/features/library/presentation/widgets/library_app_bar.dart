import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/src/core/theme/color_schemes.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../application/bookshelf_notifier.dart';
import '../../domain/shelf_group.dart';

/// AppBar widget for the Library screen with Bauhaus design styling.
/// Features geometric accents and thick borders.
class LibraryAppBar extends StatefulWidget {
  const LibraryAppBar({
    required this.state,
    required this.tabController,
    required this.onSortPressed,
    required this.onSelectionToggle,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onEditGroup,
    super.key,
  });

  final BookshelfState state;
  final TabController tabController;
  final VoidCallback onSortPressed;
  final VoidCallback onSelectionToggle;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final void Function(ShelfGroup group, AppLocalizations l10n) onEditGroup;

  @override
  State<LibraryAppBar> createState() => _LibraryAppBarState();
}

class _LibraryAppBarState extends State<LibraryAppBar>
    with SingleTickerProviderStateMixin {
  // The intrinsic height of a Flutter TabBar.
  static const double _kTabBarHeight = 48.0;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.state.isSelectionMode ? 0.0 : 1.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(LibraryAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.isSelectionMode != oldWidget.state.isSelectionMode) {
      if (widget.state.isSelectionMode) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = widget.state.isSelectionMode;
    final logoSvgPath = 'assets/logos/logo.svg';

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedHeight = _kTabBarHeight * _animation.value;

        return SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: BauhausColors.background,
            leading: isSelectionMode
                ? _BauhausIconButton(
                    icon: Icons.close,
                    onPressed: widget.onSelectionToggle,
                    isCircle: false,
                  )
                : null,
            title: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isSelectionMode ? null : () => context.push('/settings'),
              child: isSelectionMode
                  ? Text(
                      AppLocalizations.of(context)!.selected(widget.state.selectedCount),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: BauhausColors.foreground,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          logoSvgPath,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            BauhausColors.foreground,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Geometric accent
                        Container(
                          width: 8,
                          height: 24,
                          color: BauhausColors.primaryRed,
                        ),
                        Container(
                          width: 8,
                          height: 24,
                          color: BauhausColors.primaryBlue,
                        ),
                        Container(
                          width: 8,
                          height: 24,
                          color: BauhausColors.primaryYellow,
                        ),
                      ],
                    ),
            ),
            actions: [
              if (isSelectionMode)
                _BauhausIconButton(
                  icon: widget.state.selectedCount == widget.state.books.length
                      ? Icons.deselect_outlined
                      : Icons.select_all_outlined,
                  onPressed: () {
                    if (widget.state.selectedCount == widget.state.books.length) {
                      widget.onClearSelection();
                    } else {
                      widget.onSelectAll();
                    }
                  },
                  isCircle: false,
                )
              else ...[
                _BauhausIconButton(
                  icon: Icons.tune_outlined,
                  onPressed: widget.onSortPressed,
                  isCircle: false,
                ),
                const SizedBox(width: 8),
              ],
            ],
            bottom: _AnimatedTabBarWrapper(
              height: animatedHeight,
              opacity: _animation.value,
              child: TabBar(
                controller: widget.tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: _buildTabs(context),
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: BauhausColors.border,
                labelPadding: EdgeInsets.zero,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: BauhausColors.foreground,
                    width: 4,
                  ),
                ),
                labelColor: BauhausColors.foreground,
                unselectedLabelColor: BauhausColors.foreground.withValues(alpha: 0.5),
                labelStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                unselectedLabelStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    final tabs = <Widget>[];

    tabs.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13),
        child: Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BauhausCircle(
                color: BauhausColors.primaryRed,
                size: 8,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.all.toUpperCase(),
              ),
            ],
          ),
        ),
      ),
    );
    tabs.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13),
        child: Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BauhausSquare(
                color: BauhausColors.primaryBlue,
                size: 8,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.uncategorized.toUpperCase(),
              ),
            ],
          ),
        ),
      ),
    );

    for (final group in widget.state.availableGroups) {
      tabs.add(
        GestureDetector(
          onLongPress: () {
            HapticFeedback.selectionClick();
            final l10n = AppLocalizations.of(context)!;
            widget.onEditGroup(group, l10n);
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13),
            child: Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BauhausTriangle(
                    color: BauhausColors.primaryYellow,
                    size: 8,
                  ),
                  const SizedBox(width: 8),
                  Text(group.name.toUpperCase()),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return tabs;
  }
}

/// Animated tab bar wrapper with Bauhaus styling
class _AnimatedTabBarWrapper extends StatelessWidget
    implements PreferredSizeWidget {
  const _AnimatedTabBarWrapper({
    required this.height,
    required this.opacity,
    required this.child,
  });

  final double height;
  final double opacity;
  final Widget child;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.topCenter,
        child: Opacity(opacity: opacity, child: child),
      ),
    );
  }
}

/// Bauhaus-style icon button
class _BauhausIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isCircle;

  const _BauhausIconButton({
    required this.icon,
    this.onPressed,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          border: Border.all(
            color: BauhausColors.border,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 0,
              color: BauhausColors.border,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: BauhausColors.foreground,
        ),
      ),
    );
  }
}
