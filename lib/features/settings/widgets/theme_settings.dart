import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/theme_provider.dart';

class ThemeSettings extends ConsumerStatefulWidget {
  final void Function(Color accentColor, Color backgroundColor) onThemeChanged;
  final Color currentAccentColor;
  final Color currentBackgroundColor;

  const ThemeSettings({
    super.key,
    required this.onThemeChanged,
    required this.currentAccentColor,
    required this.currentBackgroundColor,
  });

  @override
  ConsumerState<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends ConsumerState<ThemeSettings> {
  // Use colors directly from AccentColor enum to ensure matching
  List<Color> get _accentColors =>
      AccentColor.values.map((e) => e.value).toList();

  List<ThemeBackgroundOption> get _backgroundOptions =>
      BackgroundTheme.values.map((e) {
        String name = 'Void';
        double darkValue = 0.0;
        switch (e) {
          case BackgroundTheme.void_:
            name = 'Void';
            darkValue = 0.0;
            break;
          case BackgroundTheme.oledBlack:
            name = 'Deep';
            darkValue = 0.1;
            break;
          case BackgroundTheme.charcoalDark:
            name = 'Abyss';
            darkValue = 0.2;
            break;
          case BackgroundTheme.deepNavy:
            name = 'Navy';
            darkValue = 0.3;
            break;
          case BackgroundTheme.texturedDark:
            name = 'Texture';
            darkValue = 0.4;
            break;
        }
        return ThemeBackgroundOption(
          name: name,
          color: e.value,
          darkValue: darkValue,
        );
      }).toList();

  Color _selectedAccent = const Color(0xFFFF6B35);
  Color _selectedBackground = ClearStateColors.void_;

  @override
  void initState() {
    super.initState();
    _selectedAccent = widget.currentAccentColor;
    _selectedBackground = widget.currentBackgroundColor;
  }

  void _selectAccentColor(Color color) {
    HapticService.light();
    setState(() {
      _selectedAccent = color;
    });
    widget.onThemeChanged(color, _selectedBackground);
    _showUndoSnackbar();
  }

  void _selectBackground(Color color) {
    HapticService.light();
    setState(() {
      _selectedBackground = color;
    });
    widget.onThemeChanged(_selectedAccent, color);
    _showUndoSnackbar();
  }

  void _showUndoSnackbar() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snackBar = SnackBar(
      content: Text('Theme updated', style: ClearStateTypography.body),
      backgroundColor: ClearStateColors.charcoal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: ClearStateColors.ash, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accent Color',
          style: ClearStateTypography.caption.copyWith(
            color: ClearStateColors.smoke,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _accentColors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final color = _accentColors[index];
              final isSelected = _selectedAccent == color;

              return GestureDetector(
                onTap: () => _selectAccentColor(color),
                child: AnimatedContainer(
                  duration: ClearStateMotion.duration(
                    const Duration(milliseconds: 150),
                  ),
                  curve: Curves.easeOutCubic,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                    border: isSelected
                        ? Border.all(color: ClearStateColors.bone, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Background',
          style: ClearStateTypography.caption.copyWith(
            color: ClearStateColors.smoke,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _backgroundOptions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = _backgroundOptions[index];
              final isSelected = _selectedBackground == option.color;

              return GestureDetector(
                onTap: () => _selectBackground(option.color),
                child: AnimatedContainer(
                  duration: ClearStateMotion.duration(
                    const Duration(milliseconds: 150),
                  ),
                  curve: Curves.easeOutCubic,
                  width: 100,
                  height: 56,
                  decoration: BoxDecoration(
                    color: option.color,
                    borderRadius: BorderRadius.circular(4),
                    border: isSelected
                        ? Border.all(color: _selectedAccent, width: 1.5)
                        : Border.all(color: ClearStateColors.ash, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      option.name,
                      style: ClearStateTypography.caption.copyWith(
                        color: isSelected
                            ? _selectedAccent
                            : ClearStateColors.smoke,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VibeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _VibeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : ClearStateColors.ash,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              label,
              style: ClearStateTypography.timerLabel.copyWith(
                fontSize: 12,
                color: isSelected ? color : ClearStateColors.smoke,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeBackgroundOption {
  final String name;
  final Color color;
  final double darkValue;

  const ThemeBackgroundOption({
    required this.name,
    required this.color,
    required this.darkValue,
  });
}

class AccentColorPicker extends StatelessWidget {
  final Color selectedColor;
  final List<Color> colors;
  final void Function(Color color) onColorSelected;

  const AccentColorPicker({
    super.key,
    required this.selectedColor,
    this.colors = const [
      Color(0xFFFF6B35),
      Color(0xFF00D26A),
      Color(0xFF6C63FF),
      Color(0xFFFFD93D),
      Color(0xFF00BCD4),
      Color(0xFFFF4081),
    ],
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = selectedColor == color;

          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                border: isSelected
                    ? Border.all(color: ClearStateColors.bone, width: 2)
                    : null,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
