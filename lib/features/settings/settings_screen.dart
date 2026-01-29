import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/backup_service.dart';
import '../../shared/widgets/noise_background.dart';
import '../../shared/widgets/glass_card.dart';
import '../../data/models/subscription_status.dart';
import '../security/security_provider.dart';
import '../home_widgets/widget_settings_screen.dart';
import '../../core/utils/pro_feature_gate.dart';
import 'subscription_provider.dart';
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
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);

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
                      style: TrueStateTypography.h1.copyWith(
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
                    // Subscription Section
                    _SectionHeader(title: 'Subscription'),
                    const SizedBox(height: 12),
                    _SubscriptionCard(
                      status: subscriptionStatus,
                      onUpgrade: () async {
                        HapticService.light();
                        await ref
                            .read(subscriptionStatusProvider.notifier)
                            .presentNativePaywall();
                      },
                      onRestore: () async {
                        HapticService.light();
                        await ref
                            .read(subscriptionStatusProvider.notifier)
                            .restorePurchases();
                        if (context.mounted) {
                          final newStatus = ref.read(
                            subscriptionStatusProvider,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newStatus.isPro
                                    ? 'Pro subscription restored!'
                                    : 'No active subscription found',
                              ),
                            ),
                          );
                        }
                      },
                      onManageSubscription: subscriptionStatus.isPro
                          ? () async {
                              HapticService.light();
                              await ref
                                  .read(subscriptionStatusProvider.notifier)
                                  .presentCustomerCenter();
                            }
                          : null,
                    ),
                    const SizedBox(height: 32),

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
                          final bgTheme = BackgroundTheme.values.firstWhere(
                            (e) => e.value == background,
                            orElse: () => BackgroundTheme.void_,
                          );
                          ref
                              .read(themeProvider.notifier)
                              .setAccentColor(accentColor);
                          ref
                              .read(themeProvider.notifier)
                              .setBackgroundColor(bgTheme);
                        },
                        currentAccentColor: themeState.accent.value,
                        currentBackgroundColor: themeState.background,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _SectionHeader(title: 'Privacy'),
                    const SizedBox(height: 12),
                    ProFeatureGate(
                      featureName: 'Biometric Security',
                      child: SettingsToggle(
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
                              builder: (context) =>
                                  const WidgetSettingsScreen(),
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
                        if (!subscriptionStatus.isPro) {
                          await ref
                              .read(subscriptionStatusProvider.notifier)
                              .presentNativePaywall();
                          return;
                        }
                        try {
                          await backupService.createBackup();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Export failed: \$e')),
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
                      onTap: () async {
                        HapticService.light();
                        if (!subscriptionStatus.isPro) {
                          await ref
                              .read(subscriptionStatusProvider.notifier)
                              .presentNativePaywall();
                          return;
                        }
                        _showRestoreDialog(context, ref);
                      },
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

class _SectionHeader extends ConsumerWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    return Text(
      title.toUpperCase(),
      style: TrueStateTypography.caption.copyWith(
        color: themeState.accentValue,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsItem extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
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
                    color: themeState.accentValue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: themeState.accentValue, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TrueStateTypography.body.copyWith(
                          color: TrueStateColors.textPrimaryDark,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TrueStateTypography.caption.copyWith(
                            color: TrueStateColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: TrueStateColors.textSecondaryDark,
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
        color: TrueStateColors.error.withValues(alpha: 0.1),
        border: Border.all(
          color: TrueStateColors.error.withValues(alpha: 0.3),
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
                    color: TrueStateColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: TrueStateColors.error,
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
                        style: TrueStateTypography.body.copyWith(
                          color: TrueStateColors.error,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TrueStateTypography.caption.copyWith(
                            color: TrueStateColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: TrueStateColors.error,
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

class _SettingsFooter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
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
                  TrueStateColors.borderDark,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Version
          Text(
            'CLEARSTATE v1.0.0',
            style: TrueStateTypography.caption.copyWith(
              color: TrueStateColors.textSecondaryDark,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          // Made with care
          Text(
            'Made with care ✨',
            style: TrueStateTypography.caption.copyWith(
              color: themeState.accentValue.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends ConsumerWidget {
  final SubscriptionStatus status;
  final VoidCallback onUpgrade;
  final VoidCallback onRestore;
  final VoidCallback? onManageSubscription;

  const _SubscriptionCard({
    required this.status,
    required this.onUpgrade,
    required this.onRestore,
    this.onManageSubscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isPro = status.isPro;
    final isTrialing = status.isTrialing;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPro
                      ? themeState.accentValue.withOpacity(0.2)
                      : themeState.textMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPro ? Icons.star : Icons.star_border,
                  color: isPro ? themeState.accentValue : themeState.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPro ? (isTrialing ? 'Pro Trial' : 'Pro') : 'Free',
                      style: TrueStateTypography.bodySemiBold.copyWith(
                        color: isPro
                            ? themeState.accentValue
                            : themeState.textPrimary,
                      ),
                    ),
                    Text(
                      isPro
                          ? (isTrialing
                                ? 'Full features during trial'
                                : 'All features unlocked')
                          : 'Limited to 2 habits',
                      style: TrueStateTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isPro || isTrialing) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeState.accentValue,
                  foregroundColor: themeState.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isTrialing ? 'Upgrade Now' : 'Upgrade to Pro',
                  style: TrueStateTypography.button,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Center(
            child: TextButton(
              onPressed: onRestore,
              child: Text(
                'Restore Purchases',
                style: TrueStateTypography.caption.copyWith(
                  color: TrueStateColors.textTertiaryDark,
                ),
              ),
            ),
          ),
          if (onManageSubscription != null) ...[
            const SizedBox(height: 4),
            Center(
              child: TextButton.icon(
                onPressed: onManageSubscription,
                icon: Icon(
                  Icons.settings_outlined,
                  size: 16,
                  color: TrueStateColors.textTertiaryDark,
                ),
                label: Text(
                  'Manage Subscription',
                  style: TrueStateTypography.caption.copyWith(
                    color: TrueStateColors.textTertiaryDark,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
