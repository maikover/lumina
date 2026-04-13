import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/src/core/services/toast_service.dart';
import 'package:lumina/src/core/theme/color_schemes.dart';
import 'package:lumina/src/core/widgets/bauhaus_components.dart';
import 'package:lumina/src/core/url_launcher/url_launcher.dart';
import 'package:lumina/src/features/settings/presentation/widgets/settings_app_header.dart';
import 'package:lumina/src/features/settings/presentation/widgets/settings_appearance_section.dart';
import 'package:lumina/src/features/settings/presentation/widgets/settings_font_section.dart';
import 'package:lumina/src/features/settings/presentation/widgets/settings_info_section.dart';
import 'package:lumina/src/features/settings/presentation/widgets/backup_tile.dart';
import 'package:lumina/src/features/settings/presentation/widgets/check_update_tile.dart';
import 'package:lumina/src/features/settings/presentation/widgets/clean_cache_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../l10n/app_localizations.dart';

const bool _isStoreVersion = bool.fromEnvironment(
  'IS_STORE_VERSION',
  defaultValue: false,
);

/// Settings Screen with Bauhaus design styling
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';
  String _buildNumber = '';

  bool isSelectingFiles = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = (int.tryParse(packageInfo.buildNumber) ?? 0) % 1000;
    String version = packageInfo.version;
    if (buildNumber > 0) {
      if (buildNumber != 999) {
        version += '-pre.$buildNumber';
      }
    }

    setState(() {
      _version = version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: BauhausColors.background,
          appBar: AppBar(
            backgroundColor: BauhausColors.background,
            leading: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: const Icon(
                  Icons.arrow_back,
                  color: BauhausColors.foreground,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'SETTINGS',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: BauhausColors.foreground,
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(4),
              child: Divider(
                height: 4,
                thickness: 4,
                color: BauhausColors.border,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                // Header with geometric shapes
                SettingsAppHeader(version: _version),

                const SizedBox(height: 48),

                // Appearance section - Bauhaus style
                _BauhausSectionHeader(
                  title: 'APPEARANCE',
                  accentColor: BauhausColors.primaryRed,
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: BauhausColors.border,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(4, 4),
                        blurRadius: 0,
                        color: BauhausColors.border,
                      ),
                    ],
                  ),
                  child: const SettingsAppearanceSection(),
                ),

                const SizedBox(height: 24),

                // Library section
                _BauhausSectionHeader(
                  title: l10n.library.toUpperCase(),
                  accentColor: BauhausColors.primaryBlue,
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: BauhausColors.border,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(4, 4),
                        blurRadius: 0,
                        color: BauhausColors.border,
                      ),
                    ],
                  ),
                  child: const BackupTile(),
                ),

                const SizedBox(height: 24),

                // Storage section
                _BauhausSectionHeader(
                  title: l10n.storage.toUpperCase(),
                  accentColor: BauhausColors.primaryYellow,
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: BauhausColors.border,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(4, 4),
                        blurRadius: 0,
                        color: BauhausColors.border,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CleanCacheTile(),
                      const Divider(height: 24, thickness: 2),
                      _BauhausSettingsTile(
                        icon: Icons.folder_open_outlined,
                        title: l10n.openStorageLocation,
                        subtitle: l10n.openStorageLocationSubtitle,
                        onTap: () => Platform.isAndroid
                            ? _openAndroidFolder(l10n)
                            : _openIOSFolder(l10n),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Fonts section
                _BauhausSectionHeader(
                  title: 'FONTS',
                  accentColor: BauhausColors.primaryRed,
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: BauhausColors.border,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(4, 4),
                        blurRadius: 0,
                        color: BauhausColors.border,
                      ),
                    ],
                  ),
                  child: SettingsFontSection(
                    onChangeSelectingState: (state) {
                      setState(() {
                        isSelectingFiles = state;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Project info section
                _BauhausSectionHeader(
                  title: l10n.projectInfo.toUpperCase(),
                  accentColor: BauhausColors.primaryBlue,
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: BauhausColors.border,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(4, 4),
                        blurRadius: 0,
                        color: BauhausColors.border,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _BauhausSettingsTile(
                        icon: Icons.code_outlined,
                        title: l10n.github,
                        subtitle: 'github.com/MilkFeng/lumina.git',
                        onTap: () =>
                            _launchUrl('https://github.com/MilkFeng/lumina.git'),
                      ),
                      const Divider(height: 24, thickness: 2),
                      _BauhausSettingsTile(
                        icon: Icons.person_outline_outlined,
                        title: l10n.author,
                        subtitle: 'Milk Feng',
                      ),
                      const Divider(height: 24, thickness: 2),
                      _BauhausSettingsTile(
                        icon: Icons.attribution_outlined,
                        title: l10n.openSourceLicenses,
                        subtitle: l10n.openSourceLicensesSubtitle,
                        onTap: () => showLicensePage(
                          context: context,
                          applicationVersion: _buildNumber,
                          useRootNavigator: true,
                        ),
                      ),
                      if (!_isStoreVersion) ...[
                        const Divider(height: 24, thickness: 2),
                        const CheckUpdateTile(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tips section
                _BauhausSectionHeader(
                  title: l10n.tips.toUpperCase(),
                  accentColor: BauhausColors.primaryYellow,
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: BauhausColors.border,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(4, 4),
                        blurRadius: 0,
                        color: BauhausColors.border,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _BauhausTipTile(
                        icon: Icons.touch_app_outlined,
                        tip: l10n.tipLongPressTab,
                      ),
                      const Divider(height: 24, thickness: 2),
                      _BauhausTipTile(
                        icon: Icons.keyboard_double_arrow_right_outlined,
                        tip: l10n.tipLongPressNextTrack,
                      ),
                      const Divider(height: 24, thickness: 2),
                      _BauhausTipTile(
                        icon: Icons.image_outlined,
                        tip: l10n.longPressToViewImage,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 128),
              ],
            ),
          ),
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
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await UrlLauncher.canLaunch(uri)) {
      await UrlLauncher.launch(uri);
    }
  }

  Future<void> _openAndroidFolder(AppLocalizations l10n) async {
    if (!Platform.isAndroid) {
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final String applicationId = packageInfo.packageName;
    final String authority = '$applicationId.documents';
    const String rootId = 'lumina_books_root';
    final String rootUri = 'content://$authority/root/$rootId';

    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: rootUri,
      type: 'vnd.android.document/root',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );

    try {
      await intent.launch();
    } catch (e) {
      ToastService.showError(l10n.openStorageLocationFailed(e.toString()));
    }
  }

  Future<void> _openIOSFolder(AppLocalizations l10n) async {
    showDialog(
      context: context,
      builder: (context) => Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.openStorageLocation.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.openStorageLocationIOSMessage,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BauhausButton(
              label: l10n.confirm,
              onPressed: () => Navigator.pop(context),
              variant: BauhausButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bauhaus section header with geometric accent
class _BauhausSectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;

  const _BauhausSectionHeader({
    required this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: accentColor,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: BauhausColors.foreground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 2,
              color: BauhausColors.border,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bauhaus-styled settings tile
class _BauhausSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _BauhausSettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: BauhausColors.border,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: BauhausColors.foreground,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: BauhausColors.foreground,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: BauhausColors.foreground.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right,
              color: BauhausColors.foreground,
              size: 20,
            ),
        ],
      ),
    );
  }
}

/// Bauhaus-styled tip tile
class _BauhausTipTile extends StatelessWidget {
  final IconData icon;
  final String tip;

  const _BauhausTipTile({
    required this.icon,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: BauhausColors.primaryYellow,
            border: Border.all(
              color: BauhausColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: BauhausColors.foreground,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tip,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BauhausColors.foreground,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
