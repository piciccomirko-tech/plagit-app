import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';

// ── Shared admin widgets used across all admin screens ──

/// Standard admin top bar with back button, title, and optional trailing widget
class AdminTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  final String? subtitle;

  const AdminTopBar({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.lg,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              alignment: Alignment.center,
              child: const Icon(Icons.chevron_left, size: 24, color: AppColors.charcoal),
            ),
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.indigo)),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing! else const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }
}

/// Search bar widget
class AdminSearchBar extends StatelessWidget {
  final String hint;
  final String text;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const AdminSearchBar({
    super.key,
    required this.hint,
    required this.text,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.tertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              controller: TextEditingController(text: text)..selection = TextSelection.fromPosition(TextPosition(offset: text.length)),
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 15, color: AppColors.tertiary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.cancel, size: 18, color: AppColors.tertiary),
            ),
        ],
      ),
    );
  }
}

/// Filter chip row
class AdminFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, int>? counts;

  const AdminFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: filters.map((f) {
          final isActive = selected == f;
          final count = counts?[f] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.teal : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: isActive ? Colors.transparent : AppColors.border, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(f, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.secondary)),
                    if (f != 'All' && count > 0) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text('$count', style: TextStyle(fontSize: 10, color: isActive ? Colors.white70 : AppColors.tertiary)),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Summary stat chip (horizontal scrollable)
class AdminSummaryChip extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final VoidCallback? onTap;
  final double width;

  const AdminSummaryChip({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    this.onTap,
    this.width = 64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}

/// Sort row
class AdminSortRow extends StatelessWidget {
  final int count;
  final String entityName;
  final String sortLabel;
  final VoidCallback onSort;

  const AdminSortRow({
    super.key,
    required this.count,
    required this.entityName,
    required this.sortLabel,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Text('$count $entityName', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
          const Spacer(),
          GestureDetector(
            onTap: onSort,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sort: $sortLabel', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.expand_more, size: 14, color: AppColors.teal),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Status pill badge
class StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const StatusPill({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color), maxLines: 1),
    );
  }
}

/// Severity badge (filled background)
class SeverityBadge extends StatelessWidget {
  final String text;
  final Color color;

  const SeverityBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white), maxLines: 1),
    );
  }
}

/// Admin card wrapper
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const AdminCard({super.key, required this.child, this.margin, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

/// Avatar circle with initials and gradient
class AvatarCircle extends StatelessWidget {
  final String initials;
  final double hue;
  final double size;
  final bool verified;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.hue = 0.5,
    this.size = 44,
    this.verified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                HSVColor.fromAHSV(1.0, hue * 360, 0.45, 0.90).toColor(),
                HSVColor.fromAHSV(1.0, hue * 360, 0.55, 0.75).toColor(),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(fontSize: size * 0.32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        if (verified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified, size: size * 0.28, color: AppColors.teal),
            ),
          ),
      ],
    );
  }
}

/// Loading view
class AdminLoadingView extends StatelessWidget {
  final String message;
  const AdminLoadingView({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2),
          const SizedBox(height: AppSpacing.lg),
          Text(message, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
        ],
      ),
    );
  }
}

/// Empty state view
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onShowAll;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.teal.withValues(alpha: 0.10)),
              child: Icon(icon, size: 22, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.secondary), textAlign: TextAlign.center),
            if (onShowAll != null) ...[
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: onShowAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text('Show All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Icon + label helper
class IconLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const IconLabel({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.tertiary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
      ],
    );
  }
}

/// Section title with icon
class AdminSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  const AdminSectionTitle({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
      ],
    );
  }
}

/// Info row for detail views
class AdminInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdminInfoRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
          const Spacer(),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal), textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// Quick action chip
class QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const QuickActionChip({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.teal),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
          ],
        ),
      ),
    );
  }
}
