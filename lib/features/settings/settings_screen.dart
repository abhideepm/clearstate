import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/backup_service.dart';
import '../../shared/widgets/noise_background.dart';
import '../security/security_provider.dart';
import '../widgets/widget_settings_screen.dart';
import 'widgets/settings_toggle.dart';
import 'widgets/wipe_confirmation_dialog.dart';
import 'widgets/restore_confirmation_dialog.dart';
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

    return Scaffold(
      backgroundColor: ClearStateColors.void_,
      body: NoiseBackground(
        opacity: 0.025,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      'SETTINGS',
                      style: ClearStateTypography.timerLabel.copyWith(
                        fontSize: 14,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Privacy Section
                    _SectionHeader(title: 'PRIVACY'),
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
                    _SectionHeader(title: 'WIDGETS'),
                    const SizedBox(height: 12),
                    _SettingsItem(
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

                    const SizedBox(height: 32),

                    // Notifications Section
                    _SectionHeader(title: 'NOTIFICATIONS'),
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
                    _SectionHeader(title: 'DATA'),
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
      title,
      style: ClearStateTypography.timerLabel.copyWith(
        color: ClearStateColors.smoke,
        letterSpacing: 3,
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
    return Container(
      decoration: BoxDecoration(
        color: ClearStateColors.ash.withAlpha((0.05 * 255).round()),
        border: Border.all(
          color: ClearStateColors.ash.withAlpha((0.2 * 255).round()),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ClearStateColors.ash.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Icon(icon, color: ClearStateColors.bone, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: ClearStateTypography.body.copyWith(
                          color: ClearStateColors.bone,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: ClearStateTypography.caption.copyWith(
                            color: ClearStateColors.smoke,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: ClearStateColors.ash,
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
        color: ClearStateColors.relapse.withAlpha((0.08 * 255).round()),
        border: Border.all(
          color: ClearStateColors.relapse.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ClearStateColors.relapse.withAlpha(
                      (0.15 * 255).round(),
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: ClearStateColors.relapse,
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
                          color: ClearStateColors.relapse,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: ClearStateTypography.caption.copyWith(
                            color: ClearStateColors.smoke,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: ClearStateColors.relapse,
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
          // Divider
          Container(height: 1, color: ClearStateColors.ash),
          const SizedBox(height: 24),
          // Version
          Text(
            'CLEARSTATE v1.0.0',
            style: ClearStateTypography.caption.copyWith(
              color: ClearStateColors.smoke,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          // Made with care
          Text(
            'Made with care',
            style: ClearStateTypography.caption.copyWith(
              color: ClearStateColors.ash,
            ),
          ),
        ],
      ),
    );
  }
}
