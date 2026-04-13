import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/src/core/theme/app_theme.dart';
import 'package:lumina/src/core/theme/color_schemes.dart';
import 'package:lumina/src/core/widgets/bauhaus_components.dart';
import '../application/bookshelf_notifier.dart';
import '../domain/shelf_book.dart';
import 'mixins/library_actions_mixin.dart';
import 'widgets/book_grid_item.dart';
import 'widgets/library_app_bar.dart';
import 'widgets/library_selection_bar.dart';
import 'widgets/style_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';

/// Library Screen - Displays user's book collection with Bauhaus design
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with TickerProviderStateMixin, LibraryActionsMixin {
  TabController? _tabController;
  bool _isUpdatingFromState = false;
  int _lastTabIndex = 0;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabController(BookshelfState state) {
    final tabCount =
        2 + state.availableGroups.length; // All + Uncategorized + groups

    if (_tabController == null || _tabController!.length != tabCount) {
      final previousController = _tabController;
      previousController?.removeListener(_handleTabChange);
      _tabController = TabController(
        length: tabCount,
        vsync: this,
        initialIndex: _getTabIndexFromState(state),
      );
      _lastTabIndex = _tabController!.index;
      _tabController!.addListener(_handleTabChange);
      if (previousController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          previousController.dispose();
        });
      }
    }
  }

  int _getTabIndexFromState(BookshelfState state) {
    if (state.filterGroupId == -1) return 1;
    if (state.filterGroupId == null) return 0;
    final index = state.availableGroups.indexWhere(
      (g) => g.id == state.filterGroupId,
    );
    return index == -1 ? 0 : index + 2;
  }

  void _handleTabChange() {
    if (_tabController == null || _isUpdatingFromState) return;
    final newIndex = _tabController!.index;
    if (newIndex == _lastTabIndex) return;
    _lastTabIndex = newIndex;

    final state = ref.read(bookshelfNotifierProvider).valueOrNull;
    if (state == null) return;

    if (newIndex == 0) {
      ref.read(bookshelfNotifierProvider.notifier).filterByGroup(null);
      return;
    }

    if (newIndex == 1) {
      ref.read(bookshelfNotifierProvider.notifier).filterByGroup(-1);
      return;
    }

    final newGroupId = state.availableGroups[newIndex - 2].id;
    if (state.filterGroupId != newGroupId) {
      ref.read(bookshelfNotifierProvider.notifier).filterByGroup(newGroupId);
    }
  }

  void _syncTabIndexWithState(BookshelfState state) {
    if (_tabController == null) return;

    final expectedIndex = _getTabIndexFromState(state);
    if (_tabController!.index != expectedIndex) {
      _isUpdatingFromState = true;
      _lastTabIndex = expectedIndex;
      _tabController!.animateTo(expectedIndex);
      Future.delayed(const Duration(milliseconds: 100), () {
        _isUpdatingFromState = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final secondaryAnimation =
        route?.secondaryAnimation ?? const AlwaysStoppedAnimation(0.0);

    return AnimatedBuilder(
      animation: secondaryAnimation,
      builder: (context, child) {
        final isTransitioning =
            secondaryAnimation.value > 0.0 && secondaryAnimation.value < 1.0;

        return AbsorbPointer(absorbing: isTransitioning, child: child);
      },
      child: _buildContentWidget(context),
    );
  }

  Widget _buildContentWidget(BuildContext context) {
    final bookshelfState = ref.watch(bookshelfNotifierProvider);

    final state = ref.watch(bookshelfNotifierProvider).valueOrNull;
    final isSelectionMode = state?.isSelectionMode ?? false;

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        if (isSelectionMode) {
          ref.read(bookshelfNotifierProvider.notifier).toggleSelectionMode();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: BauhausColors.background,
            body: bookshelfState.when(
              loading: () => Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: BauhausColors.primaryRed,
                  ),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BauhausSquare(
                        color: BauhausColors.primaryRed,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.errorLoadingLibrary(error.toString()),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                _initializeTabController(state);
                _syncTabIndexWithState(state);
                return _buildTabView(context, ref, state);
              },
            ),
            floatingActionButton: _buildFAB(context, ref),
          ),
          if (isSelectingFiles)
            Positioned.fill(
              child: Container(
                color: BauhausColors.foreground.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 4,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(8, 8),
                          blurRadius: 0,
                          color: BauhausColors.border,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      color: BauhausColors.primaryRed,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildFAB(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookshelfNotifierProvider).valueOrNull;

    if (state?.isSelectionMode ?? false) {
      return null;
    }

    SpeedDialChild buildSpeedDialChild(
      IconData icon,
      String label,
      VoidCallback onTap,
      Color accentColor,
    ) {
      return SpeedDialChild(
        child: BauhausCircle(
          color: accentColor,
          size: 24,
        ),
        label: label.toUpperCase(),
        onTap: onTap,
        labelStyle: GoogleFonts.outfit(
          color: BauhausColors.foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          fontSize: 12,
        ),
        labelBackgroundColor: Colors.white,
        labelShadow: [],
        elevation: 0,
      );
    }

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      overlayColor: BauhausColors.foreground,
      overlayOpacity: 0.5,
      spaceBetweenChildren: 12,
      renderOverlay: true,
      useRotationAnimation: true,
      children: [
        buildSpeedDialChild(
          Icons.file_present_outlined,
          AppLocalizations.of(context)!.importFiles,
          () => _importFiles(context, ref),
          BauhausColors.primaryRed,
        ),
        buildSpeedDialChild(
          Icons.folder_open_outlined,
          AppLocalizations.of(context)!.importFromFolder,
          () => _scanFolder(context, ref),
          BauhausColors.primaryBlue,
        ),
        buildSpeedDialChild(
          Icons.settings_backup_restore_outlined,
          AppLocalizations.of(context)!.restoreFromBackup,
          () => handleRestoreBackup(context, ref),
          BauhausColors.primaryYellow,
        ),
      ],
    );
  }

  void _scanFolder(BuildContext context, WidgetRef ref) {
    handleScanFolder(context, ref);
  }

  void _importFiles(BuildContext context, WidgetRef ref) {
    handleImportFiles(context, ref);
  }

  Widget _buildTabView(
    BuildContext context,
    WidgetRef ref,
    BookshelfState state,
  ) {
    if (_tabController == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: BauhausColors.primaryRed,
          ),
        ),
      );
    }

    final bottomStatusBarHeight = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              LibraryAppBar(
                state: state,
                tabController: _tabController!,
                onSortPressed: () => _showStyleBottomSheet(context, ref, state),
                onSelectionToggle: () => ref
                    .read(bookshelfNotifierProvider.notifier)
                    .toggleSelectionMode(),
                onSelectAll: () =>
                    ref.read(bookshelfNotifierProvider.notifier).selectAll(),
                onClearSelection: () => ref
                    .read(bookshelfNotifierProvider.notifier)
                    .clearSelection(),
                onEditGroup: (group, l10n) =>
                    showEditGroupDialog(context, ref, group, l10n),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            physics: state.isSelectionMode
                ? const NeverScrollableScrollPhysics()
                : null,
            children: _buildTabViewChildren(context, ref, state),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(
            milliseconds: AppTheme.defaultAnimationDurationMs,
          ),
          curve: Curves.easeInOut,
          bottom: state.isSelectionMode
              ? 0
              : -(AppTheme.kBottomAppBarHeight + bottomStatusBarHeight),
          left: 0,
          right: 0,
          child: LibrarySelectionBar(
            state: state,
            onMove: () => showMoveToGroup(context, ref, state),
            onDelete: () => confirmDelete(context, ref),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTabViewChildren(
    BuildContext context,
    WidgetRef ref,
    BookshelfState state,
  ) {
    final tabs = <Widget>[];

    tabs.add(_buildTabContent(ref, state, null));
    tabs.add(_buildTabContent(ref, state, -1));

    for (final group in state.availableGroups) {
      tabs.add(_buildTabContent(ref, state, group.id));
    }

    return tabs;
  }

  Widget _buildTabContent(WidgetRef ref, BookshelfState state, int? groupId) {
    final isActiveTab = state.filterGroupId == groupId;
    final booksForTab = isActiveTab ? state.books : state.cachedBooks[groupId];
    if (booksForTab == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: BauhausColors.primaryRed,
          ),
        ),
      );
    }

    final bottomStatusBarHeight = MediaQuery.of(context).padding.bottom;

    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          key: PageStorageKey<String>('tab_$groupId'),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            _buildItemsGrid(context, ref, state, booksForTab),
            if (state.isSelectionMode)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: AppTheme.kBottomAppBarHeight + bottomStatusBarHeight,
                ),
              ),
          ],
        );
      },
    );
  }

  void _showStyleBottomSheet(
    BuildContext context,
    WidgetRef ref,
    BookshelfState state,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: BauhausColors.background,
          border: Border(
            top: BorderSide(
              color: BauhausColors.border,
              width: 4,
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: StyleBottomSheet(
            currentSort: state.sortBy,
            onSortSelected: (sortBy) {
              ref
                  .read(bookshelfNotifierProvider.notifier)
                  .changeSortOrder(sortBy);
              Navigator.pop(context);
            },
            currentViewMode: state.viewMode,
            onViewModeSelected: (mode) {
              ref.read(bookshelfNotifierProvider.notifier).changeViewMode(mode);
              Navigator.pop(context);
            },
          ),
        ),
      ),
      scrollControlDisabledMaxHeightRatio: 0.75,
      constraints: const BoxConstraints(maxWidth: double.infinity),
    );
  }

  Widget _buildItemsGrid(
    BuildContext context,
    WidgetRef ref,
    BookshelfState state,
    List<ShelfBook> books,
  ) {
    if (books.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BauhausTriangle(
                color: BauhausColors.muted,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noItemsInCategory,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: BauhausColors.foreground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 128),
      sliver: SliverGrid(
        gridDelegate: switch (state.viewMode) {
          ViewMode.relaxed => const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180.0,
            childAspectRatio: 0.55,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          ViewMode.compact => const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120.0,
            childAspectRatio: 0.68,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
        },
        delegate: SliverChildBuilderDelegate((context, index) {
          final book = books[index];
          return BookGridItem(
            book: book,
            isSelected: state.selectedBookIds.contains(book.id),
            isSelectionMode: state.isSelectionMode,
            viewMode: state.viewMode,
            onLongPress: () {
              if (!state.isSelectionMode) {
                HapticFeedback.selectionClick();
                ref
                    .read(bookshelfNotifierProvider.notifier)
                    .toggleSelectionMode();
                ref
                    .read(bookshelfNotifierProvider.notifier)
                    .toggleItemSelection(book);
              }
            },
          );
        }, childCount: books.length),
      ),
    );
  }
}
