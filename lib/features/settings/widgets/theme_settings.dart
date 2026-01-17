import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/motion.dart';
import '../../../core/services/haptic_service.dart';

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
  static const List<Color> _accentColors = [
    Color(0xFFFF6B35),
    Color(0xFF00D26A),
    Color(0xFF6C63FF),
    Color(0xFFFFD93D),
    Color(0xFF00BCD4),
    Color(0xFFFF4081),
    Color(0xFF9C27B0),
    Color(0xFF607D8B),
  ];

  static const List<ThemeBackgroundOption> _backgroundOptions = [
    ThemeBackgroundOption(
      name: 'Void',
      color: ClearStateColors.void_,
      darkValue: 0.0,
    ),
    ThemeBackgroundOption(
      name: 'Deep',
      color: Color(0xFF0A0A0A),
      darkValue: 0.1,
    ),
    ThemeBackgroundOption(
      name: 'Abyss',
      color: Color(0xFF080808),
      darkValue: 0.2,
    ),
    ThemeBackgroundOption(
      name: 'Void+',
      color: Color(0xFF060606),
      darkValue: 0.3,
    ),
    ThemeBackgroundOption(
      name: 'Eclipse',
      color: Color(0xFF0C0C0C),
      darkValue: 0.4,
    ),
  ];

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
                        ? Border.all(color: ClearStateColors.signal, width: 1.5)
                        : Border.all(color: ClearStateColors.ash, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      option.name,
                      style: ClearStateTypography.caption.copyWith(
                        color: isSelected
                            ? ClearStateColors.signal
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
