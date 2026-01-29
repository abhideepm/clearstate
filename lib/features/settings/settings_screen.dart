import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/backup_service.dart';
import '../../shared/widgets/noise_background.dart';
import '../../shared/widgets/glass_card.dart';
import '../security/security_provider.dart';
import '../home_widgets/widget_settings_screen.dart';
import '../../core/utils/pro_feature_gate.dart';
import 'widgets/settings_toggle.dart';
import 'widgets/wipe_confirmation_dialog.dart';
import 'widgets/restore_confirmation_dialog.dart';
import 'widgets/theme_settings.dart';
import 'notification_provider.dart';

class SettingsScreen extends ConsumerWidget {
  final VoidCallback? onDataWiped;
  final VoidCallback? onRestoreComplete;

  const SettingsScreen({super.key, this.onDataWiped, this.onRestoreComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityProvider);
    final canUseBiometrics = ref.watch(canUseBiometricsProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final backupService = ref.watch(backupServiceProvider);
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: themeState.background,
      body: DawnBackground(
        opacity: 0.025,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'Settings',
                      style: ClearStateTypography.h1.copyWith(
                        color: themeState.textPrimary,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _SectionHeader(title: 'Appearance'),
                    const SizedBox(height: 12),
                    ProFeatureGate(
                      featureName: 'Custom Themes',
                      child: ThemeSettings(
                        onThemeChanged: (accent, background) {
                          HapticService.light();
                          final accentColor = AccentColor.values.firstWhere(
                            (e) => e.value == accent,
                            orElse: () => AccentColor.teal,
                          );
                          ref
                              .read(themeProvider.notifier)
                              .setAccentColor(accentColor);
                        },
                        currentAccentColor: themeState.accent.value,
                        currentBackgroundColor: themeState.background,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _SectionHeader(title: 'Privacy'),
                    const SizedBox(height: 12),
                    SettingsToggle(
                      label: 'App Lock',
                      subtitle: canUseBiometrics.when(
                        data: (available) => available
                            ? 'Require biometric or device passcode to open app'
                            : 'Biometrics not available on this device',
                        loading: () => 'Checking biometric availability...',
                        error: (_, _) => 'Biometrics not available',
                      ),
                      value: securityState.biometricEnabled,
                      enabled: canUseBiometrics.when(
                        data: (available) => available,
                        loading: () => false,
                        error: (_, _) => false,
                      ),
                      onChanged: (value) async {
                        HapticService.light();
                        await ref
                            .read(securityProvider.notifier)
                            .toggleBiometric();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Widgets Section
                    _SectionHeader(title: 'Widgets'),
                    const SizedBox(height: 12),
                    ProFeatureGate(
                      featureName: 'STEALTH WIDGETS',
                      child: _SettingsItem(
                        label: 'Stealth Widgets',
                        subtitle: 'Discreet home screen widgets',
                        icon: Icons.widgets_outlined,
                        onTap: () {
                          HapticService.light();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const WidgetSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Notifications Section
                    _SectionHeader(title: 'Notifications'),
                    const SizedBox(height: 12),
                    SettingsToggle(
                      label: 'Milestone Alerts',
                      subtitle: 'Get notified when you reach milestones',
                      value: notificationSettings.enabled,
                      onChanged: (value) async {
                        HapticService.light();
                        await ref
                            .read(notificationSettingsProvider.notifier)
                            .toggle();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Data Section
                    _SectionHeader(title: 'Data'),
                    const SizedBox(height: 12),
                    _SettingsItem(
                      label: 'Export Backup',
                      subtitle: 'Save your data to a JSON file',
                      icon: Icons.unarchive_outlined,
                      onTap: () async {
                        HapticService.light();
                        try {
                          await backupService.createBackup();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Export failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _SettingsItem(
                      label: 'Restore Backup',
                      subtitle: 'Import data from a backup file',
                      icon: Icons.archive_outlined,
                      onTap: () => _showRestoreDialog(context, ref),
                    ),
                    const SizedBox(height: 12),
                    _DestructiveSettingsItem(
                      label: 'Delete All Data',
                      subtitle: 'Permanently erase everything',
                      onTap: () => _showWipeDialog(context),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),

              // Footer
              _SettingsFooter(),
            ],
          ),
        ),
      ),
    );
  }

  void _showWipeDialog(BuildContext context) {
    HapticService.heavy();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WipeConfirmationDialog(
        onWipeComplete: () {
          if (onDataWiped != null) {
            onDataWiped!();
          }
        },
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, WidgetRef ref) {
    HapticService.medium();
    showDialog(
      context: context,
      builder: (context) => RestoreConfirmationDialog(
        onConfirm: () async {
          try {
            final success = await ref
                .read(backupServiceProvider)
                .restoreBackup();
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data restored successfully')),
              );
              if (onRestoreComplete != null) onRestoreComplete!();
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
            }
          }
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: ClearStateTypography.caption.copyWith(
        color: ClearStateColors.lavender,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ClearStateColors.lavender.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: ClearStateColors.lavender, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: ClearStateTypography.body.copyWith(
                          color: ClearStateColors.textPrimaryDark,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: ClearStateTypography.caption.copyWith(
                            color: ClearStateColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: ClearStateColors.textSecondaryDark,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DestructiveSettingsItem extends StatelessWidget {
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _DestructiveSettingsItem({
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ClearStateColors.error.withValues(alpha: 0.1),
        border: Border.all(
          color: ClearStateColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ClearStateColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: ClearStateColors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: ClearStateTypography.body.copyWith(
                          color: ClearStateColors.error,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: ClearStateTypography.caption.copyWith(
                            color: ClearStateColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: ClearStateColors.error,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Soft divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  ClearStateColors.borderDark,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Version
          Text(
            'CLEARSTATE v1.0.0',
            style: ClearStateTypography.caption.copyWith(
              color: ClearStateColors.textSecondaryDark,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          // Made with care
          Text(
            'Made with care ✨',
            style: ClearStateTypography.caption.copyWith(
              color: ClearStateColors.lavender.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
