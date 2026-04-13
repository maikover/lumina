import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:lumina/src/core/widgets/app_theme.dart';

/// PDF Reader Screen using pdfrx
class PdfReaderScreen extends ConsumerStatefulWidget {
  final String filePath;
  final String title;
  final int initialPage;

  const PdfReaderScreen({
    super.key,
    required this.filePath,
    required this.title,
    this.initialPage = 1,
  });

  @override
  ConsumerState<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends ConsumerState<PdfReaderScreen> {
  late PdfViewerController _controller;
  late int _currentPage;
  bool _showControls = true;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    _currentPage = widget.initialPage;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PDF Viewer
          GestureDetector(
            onTap: _toggleControls,
            child: PdfViewer.file(
              widget.filePath,
              controller: _controller,
              params: PdfViewerParams(
                onPageChanged: (pageNumber) {
                  setState(() {
                    _currentPage = pageNumber ?? 1;
                  });
                },
                onViewerReady: (document, controller) {
                  setState(() {
                    _totalPages = document.pages.length;
                  });
                },
                backgroundColor: Colors.black,
                pageDropShadow: const BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 0,
                ),
              ),
            ),
          ),

          // Top Bar
          AnimatedPositioned(
            duration: const Duration(
              milliseconds: AppTheme.defaultAnimationDurationMs,
            ),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -(56 + topPadding),
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(
                milliseconds: AppTheme.defaultAnimationDurationMs,
              ),
              opacity: _showControls ? 1.0 : 0.0,
              child: Container(
                padding: EdgeInsets.only(top: topPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(180),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_outlined),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  actions: [
                    // Page indicator
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          _formatPageIndicator(_currentPage, _totalPages),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Bar
          AnimatedPositioned(
            duration: const Duration(
              milliseconds: AppTheme.defaultAnimationDurationMs,
            ),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -(56 + bottomPadding),
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(
                milliseconds: AppTheme.defaultAnimationDurationMs,
              ),
              opacity: _showControls ? 1.0 : 0.0,
              child: Container(
                padding: EdgeInsets.only(bottom: bottomPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(180),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.first_page, color: Colors.white),
                        onPressed: _currentPage > 1
                            ? () => _controller.goToPage(pageNumber: 1)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: _currentPage > 1
                            ? () => _controller.goToPage(pageNumber: _currentPage - 1)
                            : null,
                      ),
                      // Page slider
                      SizedBox(
                        width: 200,
                        child: Slider(
                          value: _totalPages > 0
                              ? (_currentPage - 1).toDouble().clamp(0, _totalPages - 1)
                              : 0,
                          min: 0,
                          max: _totalPages > 1 ? (_totalPages - 1).toDouble() : 0,
                          divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                          onChanged: _totalPages > 0
                              ? (value) {
                                  _controller.goToPage(pageNumber: value.round() + 1);
                                }
                              : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        onPressed: _currentPage < _totalPages
                            ? () => _controller.goToPage(pageNumber: _currentPage + 1)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.last_page, color: Colors.white),
                        onPressed: _currentPage < _totalPages
                            ? () => _controller.goToPage(pageNumber: _totalPages)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
