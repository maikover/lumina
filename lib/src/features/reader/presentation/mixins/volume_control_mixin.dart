part of '../reader_screen.dart';

mixin _VolumeControlMixin on ConsumerState<ReaderScreen> {
  bool get tocDrawerOpen;

  bool get styleDrawerOpen;

  AppLifecycleState? get lastLifecycleState;

  StreamSubscription<String>? get volumeSubscription;
  set volumeSubscription(StreamSubscription<String>? v);

  OverlayEntry? get footnoteOverlayEntry;

  ReaderRendererController get rendererController;

  Future<void> removeFootnoteOverlay({bool animate = true});

  void setupVolumeControl() {
    final resume =
        ref.read(readerSettingsNotifierProvider).volumeKeyTurnsPage &&
        !tocDrawerOpen &&
        !styleDrawerOpen &&
        lastLifecycleState == AppLifecycleState.resumed;

    if (resume) {
      VolumeControlService.enableInterception();
      volumeSubscription ??= VolumeControlService.volumeKeyEvents.listen((
        event,
      ) {
        final isVolumeTurnEnabled = ref
            .read(readerSettingsNotifierProvider)
            .volumeKeyTurnsPage;
        if (isVolumeTurnEnabled) {
          // If footnote overlay is open, volume keys should close it instead of turning page
          if (footnoteOverlayEntry != null) {
            removeFootnoteOverlay();
            return;
          }
          if (event == 'up') {
            rendererController.performPreviousPageTurn();
          } else if (event == 'down') {
            rendererController.performNextPageTurn();
          }
        }
      });
    } else {
      VolumeControlService.disableInterception();
    }
  }

  void disposeVolumeControl() {
    VolumeControlService.disableInterception();
  }
}
