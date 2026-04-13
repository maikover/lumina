import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/src/core/theme/app_theme.dart';
import 'package:lumina/src/core/theme/color_schemes.dart';
import 'package:lumina/src/core/widgets/bauhaus_components.dart';
import 'package:lumina/src/features/reader/application/reader_settings_notifier.dart';
import 'package:lumina/src/features/reader/presentation/widgets/reader_search_dialog.dart';
import 'widgets/reader_style_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';

class ControlPanel extends ConsumerStatefulWidget {
  final bool showControls;
  final String title;
  final int currentSpineItemIndex;
  final int totalSpineItems;
  final int currentPageInChapter;
  final int totalPagesInChapter;
  final int direction;
  final VoidCallback onBack;
  final VoidCallback onOpenDrawer;
  final VoidCallback onPreviousPage;
  final VoidCallback onFirstPage;
  final VoidCallback onNextPage;
  final VoidCallback onLastPage;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;
  final Function(bool show) onToggleStyleDrawer;
  // Search callbacks
  final Future<void> Function(String query) onSearch;
  final VoidCallback onSearchNext;
  final VoidCallback onSearchPrevious;
  final VoidCallback onSearchClose;
  // TTS callbacks
  final VoidCallback? onStartTts;
  final VoidCallback? onStopTts;
  final VoidCallback? onShowTtsControls;

  const ControlPanel({
    super.key,
    required this.showControls,
    required this.title,
    required this.currentSpineItemIndex,
    required this.totalSpineItems,
    required this.currentPageInChapter,
    required this.totalPagesInChapter,
    required this.direction,
    required this.onBack,
    required this.onOpenDrawer,
    required this.onPreviousPage,
    required this.onFirstPage,
    required this.onNextPage,
    required this.onLastPage,
    required this.onPreviousChapter,
    required this.onNextChapter,
    required this.onToggleStyleDrawer,
    required this.onSearch,
    required this.onSearchNext,
    required this.onSearchPrevious,
    required this.onSearchClose,
    this.onStartTts,
    this.onStopTts,
    this.onShowTtsControls,
  });

  bool get isVertical => direction == 1;

  @override
  ConsumerState<ControlPanel> createState() => _ControlPanelState();
}

/// Internal widget that manages search dialog state and delegates to callbacks
class _SearchDialogController extends StatefulWidget {
  final Future<void> Function(String query) onSearch;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;

  const _SearchDialogController({
    required this.onSearch,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
  });

  @override
  State<_SearchDialogController> createState() => _SearchDialogControllerState();
}

class _SearchDialogControllerState extends State<_SearchDialogController> {
  int _resultCount = 0;
  int _currentIndex = 0;
  String _lastQuery = '';

  @override
  Widget build(BuildContext context) {
    return ReaderSearchDialog(
      onSearch: (query) async {
        _lastQuery = query;
        if (query.isEmpty) {
          setState(() {
            _resultCount = 0;
            _currentIndex = 0;
          });
          await widget.onSearch('');
          return;
        }
        await widget.onSearch(query);
        setState(() {
          _resultCount = 1;
          _currentIndex = 0;
        });
      },
      onNext: () {
        if (_resultCount > 0) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _resultCount;
          });
          widget.onNext();
        }
      },
      onPrevious: () {
        if (_resultCount > 0) {
          setState(() {
            _currentIndex = (_currentIndex - 1 + _resultCount) % _resultCount;
          });
          widget.onPrevious();
        }
      },
      resultCount: _resultCount,
      currentIndex: _currentIndex,
      onClose: () {
        widget.onClose();
      },
    );
  }
}

class _ControlPanelState extends ConsumerState<ControlPanel> {
  Timer? _longPressTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  bool get _shouldHandleOnPreviousChapter {
    return widget.currentSpineItemIndex > 0 || widget.currentPageInChapter > 0;
  }

  bool get _shouldHandleOnNextChapter {
    return widget.currentSpineItemIndex < widget.totalSpineItems - 1 ||
        (widget.currentSpineItemIndex == widget.totalSpineItems - 1 &&
            widget.currentPageInChapter < widget.totalPagesInChapter - 1);
  }

  bool get _shouldHandleOnLongPressLeft {
    if (widget.isVertical) {
      return _shouldHandleOnNextChapter;
    } else {
      return _shouldHandleOnPreviousChapter;
    }
  }

  bool get _shouldHandleOnLongPressRight {
    if (widget.isVertical) {
      return _shouldHandleOnPreviousChapter;
    } else {
      return _shouldHandleOnNextChapter;
    }
  }

  bool get _shouldHandleOnPreviousPage {
    return widget.currentSpineItemIndex > 0 || widget.currentPageInChapter > 0;
  }

  bool get _shouldHandleOnNextPage {
    return widget.currentSpineItemIndex < widget.totalSpineItems - 1 ||
        widget.currentPageInChapter < widget.totalPagesInChapter - 1;
  }

  bool get _shouldHandleOnPressLeft {
    if (widget.isVertical) {
      return _shouldHandleOnNextPage;
    } else {
      return _shouldHandleOnPreviousPage;
    }
  }

  bool get _shouldHandleOnPressRight {
    if (widget.isVertical) {
      return _shouldHandleOnPreviousPage;
    } else {
      return _shouldHandleOnNextPage;
    }
  }

  void _handlePreviousChapter() {
    if (widget.currentPageInChapter == 0 && widget.currentSpineItemIndex > 0) {
      HapticFeedback.selectionClick();
      widget.onPreviousChapter();
    } else if (widget.currentPageInChapter > 0) {
      HapticFeedback.selectionClick();
      widget.onFirstPage();
    }
  }

  void _handleNextChapter() {
    if (widget.currentSpineItemIndex < widget.totalSpineItems - 1) {
      HapticFeedback.selectionClick();
      widget.onNextChapter();
    } else if (widget.currentSpineItemIndex == widget.totalSpineItems - 1 &&
        widget.currentPageInChapter < widget.totalPagesInChapter - 1) {
      HapticFeedback.selectionClick();
      widget.onLastPage();
    }
  }

  void _handleLongPressLeft() {
    if (widget.isVertical) {
      _handleNextChapter();
    } else {
      _handlePreviousChapter();
    }
  }

  void _handleLongPressRight() {
    if (widget.isVertical) {
      _handlePreviousChapter();
    } else {
      _handleNextChapter();
    }
  }

  void _handleTapLeft() {
    if (widget.isVertical) {
      widget.onNextPage();
    } else {
      widget.onPreviousPage();
    }
  }

  void _handleTapRight() {
    if (widget.isVertical) {
      widget.onPreviousPage();
    } else {
      widget.onNextPage();
    }
  }

  String _formatPageIndicator(int current, int total) {
    if (total == 0) {
      return '0/0';
    }
    current = current.clamp(1, total);
    final totalStr = total.toString();
    final currentStr = current.toString();
    return '$currentStr/$totalStr';
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _SearchDialogController(
        onSearch: widget.onSearch,
        onNext: widget.onSearchNext,
        onPrevious: widget.onSearchPrevious,
        onClose: () {
          widget.onSearchClose();
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readerSettingsNotifierProvider);
    final epubTheme = settings.toEpubTheme(context);
    final isDark = epubTheme.isDark;
    final themeData = AppTheme.buildTheme(epubTheme.colorScheme);

    final topStatusBarHeight = MediaQuery.of(context).padding.top;
    final bottomStatusBarHeight = MediaQuery.of(context).padding.bottom;
    return Theme(
      data: themeData,
      child: Stack(
        children: [
          // Top Bar - Bauhaus style
          AnimatedPositioned(
            duration: const Duration(
              milliseconds: AppTheme.defaultAnimationDurationMs,
            ),
            curve: Curves.easeInOut,
            top: widget.showControls
                ? 0
                : -(AppTheme.kTopAppBarHeight + topStatusBarHeight),
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(
                milliseconds: AppTheme.defaultAnimationDurationMs,
              ),
              opacity: widget.showControls ? 1.0 : 0.0,
              child: Container(
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
                  bottom: false,
                  child: Container(
                    height: AppTheme.kTopAppBarHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        // Back button - Bauhaus style
                        _BauhausControlButton(
                          icon: Icons.arrow_back,
                          onPressed: widget.onBack,
                        ),
                        const SizedBox(width: 8),
                        // Title
                        Expanded(
                          child: Text(
                            widget.title.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: BauhausColors.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Search button
                        _BauhausControlButton(
                          icon: Icons.search,
                          onPressed: () {
                            _showSearchDialog(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        // TTS button - circular blue
                        _BauhausControlButton(
                          icon: Icons.volume_up,
                          onPressed: widget.onShowTtsControls,
                          backgroundColor: BauhausColors.primaryBlue,
                          iconColor: Colors.white,
                          isCircle: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Bar - Bauhaus style
          AnimatedPositioned(
            duration: const Duration(
              milliseconds: AppTheme.defaultAnimationDurationMs,
            ),
            curve: Curves.easeInOut,
            bottom: widget.showControls
                ? 0
                : -(AppTheme.kBottomAppBarHeight + bottomStatusBarHeight),
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(
                milliseconds: AppTheme.defaultAnimationDurationMs,
              ),
              opacity: widget.showControls ? 1.0 : 0.0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: bottomStatusBarHeight + 16,
                ),
                decoration: const BoxDecoration(
                  color: BauhausColors.background,
                  border: Border(
                    top: BorderSide(
                      color: BauhausColors.border,
                      width: 4,
                    ),
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight:
                      AppTheme.kBottomAppBarHeight + bottomStatusBarHeight,
                  minHeight:
                      AppTheme.kBottomAppBarHeight + bottomStatusBarHeight,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu button
                    _BauhausControlButton(
                      icon: Icons.list,
                      onPressed: widget.onOpenDrawer,
                    ),
                    // Navigation controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Previous button
                        GestureDetector(
                          onLongPressStart: _shouldHandleOnLongPressLeft
                              ? (_) {
                                  _handleLongPressLeft();
                                  _longPressTimer = Timer.periodic(
                                    const Duration(milliseconds: 500),
                                    (timer) {
                                      _handleLongPressLeft();
                                    },
                                  );
                                }
                              : null,
                          onLongPressEnd: (_) {
                            _longPressTimer?.cancel();
                          },
                          onLongPressCancel: () {
                            _longPressTimer?.cancel();
                          },
                          child: _BauhausControlButton(
                            icon: Icons.chevron_left,
                            onPressed: _shouldHandleOnPressLeft
                                ? _handleTapLeft
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Progress indicator with Bauhaus slider
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Bauhaus progress slider
                            Container(
                              width: 100,
                              height: 20,
                              decoration: BoxDecoration(
                                color: BauhausColors.muted,
                                border: Border.all(
                                  color: BauhausColors.border,
                                  width: 2,
                                ),
                              ),
                              child: SliderTheme(
                                data: const SliderThemeData(
                                  trackHeight: 12,
                                  thumbShape: RectSliderThumbShape(),
                                  overlayShape: SliderComponentShape.noOverlay,
                                  activeTrackColor: BauhausColors.primaryYellow,
                                  inactiveTrackColor: BauhausColors.muted,
                                  thumbColor: BauhausColors.foreground,
                                ),
                                child: Slider(
                                  value: widget.totalSpineItems > 1
                                      ? widget.currentSpineItemIndex.toDouble()
                                      : 0,
                                  min: 0,
                                  max: (widget.totalSpineItems - 1).toDouble().clamp(0, double.infinity),
                                  divisions: widget.totalSpineItems > 1 ? (widget.totalSpineItems - 1).clamp(1, 100) : 1,
                                  onChanged: (value) {
                                    final targetIndex = value.round();
                                    if (targetIndex < widget.currentSpineItemIndex) {
                                      for (int i = widget.currentSpineItemIndex - 1; i >= targetIndex; i--) {
                                        if (i < widget.currentSpineItemIndex) {
                                          widget.onPreviousPage();
                                        }
                                      }
                                    } else if (targetIndex > widget.currentSpineItemIndex) {
                                      for (int i = widget.currentSpineItemIndex; i < targetIndex; i++) {
                                        widget.onNextPage();
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Page indicator
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const BauhausSquare(
                                  color: BauhausColors.primaryRed,
                                  size: 6,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatPageIndicator(
                                    widget.currentSpineItemIndex + 1,
                                    widget.totalSpineItems,
                                  ),
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: BauhausColors.foreground,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const BauhausSquare(
                                  color: BauhausColors.primaryBlue,
                                  size: 6,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Next button
                        GestureDetector(
                          onLongPressStart: _shouldHandleOnLongPressRight
                              ? (_) {
                                  _handleLongPressRight();
                                  _longPressTimer = Timer.periodic(
                                    const Duration(milliseconds: 500),
                                    (timer) {
                                      _handleLongPressRight();
                                    },
                                  );
                                }
                              : null,
                          onLongPressEnd: (_) {
                            _longPressTimer?.cancel();
                          },
                          onLongPressCancel: () {
                            _longPressTimer?.cancel();
                          },
                          child: _BauhausControlButton(
                            icon: Icons.chevron_right,
                            onPressed: _shouldHandleOnPressRight
                                ? _handleTapRight
                                : null,
                          ),
                        ),
                      ],
                    ),
                    // Style button
                    _BauhausControlButton(
                      icon: Icons.brush_outlined,
                      onPressed: () async {
                        widget.onToggleStyleDrawer(true);
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (ctx) {
                            return Consumer(
                              builder: (context, ref, child) {
                                final currentSettings = ref.watch(
                                  readerSettingsNotifierProvider,
                                );
                                final currentEpubTheme = currentSettings
                                    .toEpubTheme(context);
                                final activeTheme = AppTheme.buildTheme(
                                  currentEpubTheme.colorScheme,
                                );

                                return Theme(
                                  data: activeTheme,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: BauhausColors.background,
                                      border: Border(
                                        top: BorderSide(
                                          color: BauhausColors.border,
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.sizeOf(context).height *
                                              0.75,
                                    ),
                                    child: SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Bauhaus handle
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 16,
                                              bottom: 16,
                                            ),
                                            width: 48,
                                            height: 8,
                                            color: BauhausColors.foreground,
                                          ),
                                          const Flexible(
                                            child: ReaderStyleBottomSheet(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          barrierColor: BauhausColors.foreground.withValues(alpha: 0.5),
                          scrollControlDisabledMaxHeightRatio: 0.75,
                          constraints: const BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                        );
                        widget.onToggleStyleDrawer(false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bauhaus-style control button for the reader
class _BauhausControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final bool isCircle;

  const _BauhausControlButton({
    required this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.iconColor = BauhausColors.foreground,
    this.isCircle = false,
  });

  @override
  State<_BauhausControlButton> createState() => _BauhausControlButtonState();
}

class _BauhausControlButtonState extends State<_BauhausControlButton> {
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? BauhausColors.muted
              : widget.backgroundColor,
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
          size: 20,
          color: widget.onPressed == null
              ? BauhausColors.foreground.withValues(alpha: 0.4)
              : widget.iconColor,
        ),
      ),
    );
  }
}
