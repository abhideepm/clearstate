import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/constants/bio_states.dart';
import '../providers/widget_settings_provider.dart';

/// Bottom sheet for configuring the Bio-State widget.
///
/// Shows a list of all available bio metrics with their stealth labels,
/// allowing the user to select which metric to display on the widget.
class BioStateConfigSheet extends ConsumerStatefulWidget {
  const BioStateConfigSheet({super.key});

  @override
  ConsumerState<BioStateConfigSheet> createState() =>
      _BioStateConfigSheetState();
}

class _BioStateConfigSheetState extends ConsumerState<BioStateConfigSheet> {
  late String? _selectedMetricId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentConfig = ref.read(widgetSettingsProvider).bioStateConfig;
    _selectedMetricId = currentConfig?.bioStateMetricId ?? 'gaba';
  }

  @override
  Widget build(BuildContext context) {
    final allMetrics = BioStates.getAllMetrics();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: TrueStateColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TrueStateColors.borderDark,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'BIO-STATE WIDGET',
              style: TrueStateTypography.h2.copyWith(
                color: TrueStateColors.dawnCoral,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select the recovery metric to display',
              style: TrueStateTypography.caption.copyWith(
                color: TrueStateColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Metric list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: allMetrics.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final metric = allMetrics[index];
                  final isSelected = _selectedMetricId == metric.id;

                  return _MetricOption(
                    metric: metric,
                    isSelected: isSelected,
                    onTap: () {
                      HapticService.light();
                      setState(() => _selectedMetricId = metric.id);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: (_isSaving || _selectedMetricId == null)
                  ? null
                  : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: TrueStateColors.dawnCoral,
                disabledBackgroundColor: TrueStateColors.dawnCoral.withAlpha(
                  (0.3 * 255).round(),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TrueStateColors.darkBackground,
                      ),
                    )
                  : Text(
                      'SAVE CONFIGURATION',
                      style: TrueStateTypography.button.copyWith(
                        color: TrueStateColors.darkBackground,
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Cancel
            TextButton(
              onPressed: () {
                HapticService.light();
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: TrueStateTypography.button.copyWith(
                  color: TrueStateColors.textSecondaryDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_selectedMetricId == null) return;

    setState(() => _isSaving = true);
    HapticService.medium();

    await ref
        .read(widgetSettingsProvider.notifier)
        .saveBioStateConfig(metricId: _selectedMetricId!);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

/// Radio option for metric selection.
class _MetricOption extends StatelessWidget {
  final BioStateMetric metric;
  final bool isSelected;
  final VoidCallback onTap;

  const _MetricOption({
    required this.metric,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? TrueStateColors.dawnCoral.withAlpha((0.1 * 255).round())
            : TrueStateColors.darkBackground,
        border: Border.all(
          color: isSelected
              ? TrueStateColors.dawnCoral
              : TrueStateColors.borderDark,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? TrueStateColors.dawnCoral
                          : TrueStateColors.borderDark,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: TrueStateColors.dawnCoral,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Metric info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            metric.stealthLabel.toUpperCase(),
                            style: TrueStateTypography.caption.copyWith(
                              color: isSelected
                                  ? TrueStateColors.dawnCoral
                                  : TrueStateColors.textSecondaryDark,
                              letterSpacing: 2,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            metric.displayName,
                            style: TrueStateTypography.caption.copyWith(
                              color: TrueStateColors.borderDark,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metric.description,
                        style: TrueStateTypography.caption.copyWith(
                          color: TrueStateColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
