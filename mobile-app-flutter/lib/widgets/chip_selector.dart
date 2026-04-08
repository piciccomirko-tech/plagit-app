import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';

/// Reusable chip selector — mirrors ChipSelectorView.swift.
/// Single-select mode: taps replace selection.
class ChipSelector extends StatelessWidget {
  final List<ChipOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((opt) {
        final isActive = selected == opt.value;
        return GestureDetector(
          onTap: () => onSelected(isActive ? '' : opt.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.teal : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: isActive ? null : Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (opt.icon != null) ...[
                  Icon(opt.icon, size: 14, color: isActive ? Colors.white : AppColors.secondary),
                  const SizedBox(width: 6),
                ],
                Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ChipOption {
  final String value;
  final String label;
  final IconData? icon;

  const ChipOption({required this.value, required this.label, this.icon});
}

/// Job type chip options — mirrors PlagitJobType enum.
const List<ChipOption> jobTypeChips = [
  ChipOption(value: 'Full-time', label: 'Full-time', icon: Icons.schedule),
  ChipOption(value: 'Part-time', label: 'Part-time', icon: Icons.timelapse),
  ChipOption(value: 'Flexible', label: 'Flexible', icon: Icons.swap_horiz),
];
