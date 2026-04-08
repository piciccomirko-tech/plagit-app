import 'package:flutter/material.dart';
import 'package:plagit/core/theme/app_colors.dart';

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool showSave;
  final bool saved;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const JobCard({
    super.key,
    required this.job,
    this.showSave = true,
    this.saved = false,
    this.onTap,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final title = job['title'] as String? ?? '';
    final company = job['company'] as String? ?? '';
    final location = job['location'] as String? ?? '';
    final salary = job['salary'] as String? ?? '';
    final contract = job['contract'] as String? ?? '';
    final featured = job['featured'] == true;
    final urgent = job['urgent'] == true;
    final hue = (company.hashCode % 360).abs().toDouble();
    final initials = company.isNotEmpty ? company[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration,
        child: Row(children: [
          // Company avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: HSLColor.fromAHSL(1, hue, 0.30, 0.88).toColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: HSLColor.fromAHSL(1, hue, 0.50, 0.45).toColor(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('$company · $location',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  if (salary.isNotEmpty)
                    Text(salary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                  if (salary.isNotEmpty && contract.isNotEmpty)
                    const Text(' · ', style: TextStyle(color: AppColors.tertiary)),
                  if (contract.isNotEmpty)
                    Text(contract, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                  const SizedBox(width: 8),
                  if (featured) _badge('Featured', AppColors.amber),
                  if (urgent) _badge('Urgent', AppColors.red),
                ]),
              ],
            ),
          ),
          if (showSave)
            GestureDetector(
              onTap: onSave,
              child: Icon(
                saved ? Icons.favorite : Icons.favorite_border,
                size: 22,
                color: saved ? AppColors.teal : AppColors.tertiary,
              ),
            ),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
